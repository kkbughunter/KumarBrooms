import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final body = error.response?.data;
    final message = body is Map && body['message'] is String
        ? body['message'] as String
        : error.type == DioExceptionType.connectionError ||
                error.type == DioExceptionType.connectionTimeout
            ? 'Could not connect to the server. Please try again.'
            : 'Something went wrong. Please try again.';
    return ApiException(message, statusCode: error.response?.statusCode);
  }

  @override
  String toString() => message;
}
