import 'dart:async';

import 'package:dio/dio.dart';

import '../constants.dart';
import 'platform_client.dart';

class ApiClient {
  ApiClient._(this.dio);

  final Dio dio;
  Future<bool>? _refreshing;

  static Future<ApiClient> create() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );
    await configurePlatformClient(dio);
    final client = ApiClient._(dio);
    dio.interceptors.add(
      InterceptorsWrapper(onError: client._handleAuthenticationError),
    );
    return client;
  }

  Future<void> _handleAuthenticationError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;
    final isUnauthorized = error.response?.statusCode == 401;
    final isAuthRequest = request.path.startsWith('/api/auth/');
    final alreadyRetried = request.extra['authRetried'] == true;

    if (!isUnauthorized || isAuthRequest || alreadyRetried) {
      handler.next(error);
      return;
    }

    _refreshing ??= _refreshSession().whenComplete(() => _refreshing = null);
    if (!await _refreshing!) {
      handler.next(error);
      return;
    }

    try {
      request.extra['authRetried'] = true;
      final response = await dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refreshSession() async {
    try {
      await dio.post<void>(
        '/api/auth/refresh',
        options: Options(extra: {'skipRefresh': true}),
      );
      return true;
    } on DioException {
      return false;
    }
  }
}
