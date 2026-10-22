import 'package:dio/dio.dart';
import 'package:saleskido/core/constants/api_constants.dart';
import 'package:saleskido/core/network/api_exception.dart';
import 'package:saleskido/core/storage/token_storage.dart';

class ApiClient {
  ApiClient({TokenStorage? storage}) : _storage = storage ?? TokenStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  final TokenStorage _storage;

  Dio get dio => _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: query);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final response = e.response;
    final data = response?.data;
    String message = 'Something went wrong';
    bool expired = false;

    if (data is Map) {
      message = (data['message'] ?? message).toString();
      expired = data['expired'] == true;
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timeout. Please try again.';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'No internet connection.';
    }

    return ApiException(
      message,
      statusCode: response?.statusCode,
      expired: expired,
      data: data,
    );
  }
}
