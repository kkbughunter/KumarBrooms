import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'auth_user.dart';

class AuthService extends ChangeNotifier {
  AuthService(this._client);

  static const _sessionKey = 'authenticated_user';
  final ApiClient _client;
  AuthUser? _user;

  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<Map<String, dynamic>> loadProfile() async {
    try {
      final response = await _client.dio.get<dynamic>('/api/user/profile');
      return _extractData(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<Map<String, dynamic>>> loadOrganizationUsers() async {
    try {
      final response = await _client.dio.get<dynamic>('/api/admin/users');
      final body = response.data;
      if (body is! Map || body['data'] is! List) {
        throw const ApiException('The server returned an invalid response.');
      }
      return (body['data'] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_sessionKey);
    if (encoded == null) return;
    try {
      _user = AuthUser.fromJson(
        Map<String, dynamic>.from(jsonDecode(encoded) as Map),
      );
      // Refresh the cached identity when online. A temporary connection failure
      // intentionally does not discard an otherwise valid persisted session.
      final response = await _client.dio.get<dynamic>('/api/user/profile');
      final profile = _extractData(response.data);
      _user = AuthUser.fromJson(profile);
      await _persistUser();
    } on Object {
      // The API interceptor has already attempted token renewal. Keeping the
      // local identity lets the app remain usable while the server is offline.
    }
  }

  Future<AuthUser> login({
    required String orgCode,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post<dynamic>(
        '/api/auth/login',
        data: {
          'orgCode': orgCode.trim().toLowerCase(),
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );
      _user = AuthUser.fromJson(_extractData(response.data));
      await _persistUser();
      notifyListeners();
      return _user!;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AuthUser> register({
    required String orgName,
    required String orgCode,
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _client.dio.post<dynamic>(
        '/api/auth/register',
        data: {
          'orgName': orgName.trim(),
          'orgCode': orgCode.trim().toLowerCase(),
          'fullName': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'phone': phone?.trim().isEmpty ?? true ? null : phone!.trim(),
        },
      );
      _user = AuthUser.fromJson(_extractData(response.data));
      await _persistUser();
      notifyListeners();
      return _user!;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> _persistUser() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(_user!.toJson()));
  }

  static Map<String, dynamic> _extractData(dynamic responseBody) {
    if (responseBody is! Map || responseBody['data'] is! Map) {
      throw const ApiException('The server returned an invalid response.');
    }
    return Map<String, dynamic>.from(responseBody['data'] as Map);
  }
}
