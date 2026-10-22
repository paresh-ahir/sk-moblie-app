import 'package:saleskido/core/constants/api_constants.dart';
import 'package:saleskido/core/network/api_client.dart';
import 'package:saleskido/core/network/api_exception.dart';

class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final res = await _client.post(
      ApiConstants.login,
      data: {
        'email': email.trim(),
        'password': password.trim(),
        'rememberMe': rememberMe,
        'isMobile': true,
      },
    );
    final body = Map<String, dynamic>.from(res.data as Map);
    if (body['status'] != true) {
      throw ApiException(
        (body['message'] ?? 'Login failed').toString(),
        statusCode: body['statusCode'] as int?,
        expired: body['expired'] == true,
        data: body,
      );
    }
    return body;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await _client.post(
      ApiConstants.forgotPassword,
      data: {'email': email.trim()},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> forgotPasswordAgain(String email) async {
    final res = await _client.post(
      ApiConstants.forgotPasswordAgain,
      data: {'email': email.trim()},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await _client.post(
      ApiConstants.resetPassword,
      data: {
        'token': token,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> verifyEmail(Map<String, dynamic> payload) async {
    final res = await _client.post(ApiConstants.verifyEmail, data: payload);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> verifyEmailAgain(String email) async {
    final res = await _client.post(
      ApiConstants.verifyEmailAgain,
      data: {'email': email.trim()},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getUserFromToken() async {
    final res = await _client.get(ApiConstants.userFromToken);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> logout() async {
    try {
      await _client.get(ApiConstants.logout);
    } catch (_) {}
  }
}
