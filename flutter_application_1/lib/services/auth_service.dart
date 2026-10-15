import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/constants/api_config.dart';

class AuthResult {
  final bool success;
  final int statusCode;
  final String message;
  final String? token;
  final Map<String, dynamic>? user;

  const AuthResult({
    required this.success,
    required this.statusCode,
    required this.message,
    this.token,
    this.user,
  });
}

class AuthService {
  static const _timeout = Duration(seconds: 15);
  static const _networkError =
      'Could not reach the server. Check your connection and try again.';

  static Future<AuthResult> sendOtp(String email) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/v1/send/email/otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return AuthResult(
        success: res.statusCode == 200,
        statusCode: res.statusCode,
        message: body['message']?.toString() ?? '',
      );
    } catch (_) {
      return const AuthResult(
          success: false, statusCode: 0, message: _networkError);
    }
  }

  static Future<AuthResult> verifyOtp(String email, String otp) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/v1/verify/email/otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'otp': otp}),
          )
          .timeout(_timeout);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return AuthResult(
        success: res.statusCode == 200,
        statusCode: res.statusCode,
        message: body['message']?.toString() ?? '',
        token: body['token']?.toString(),
        user: body['user'] as Map<String, dynamic>?,
      );
    } catch (_) {
      return const AuthResult(
          success: false, statusCode: 0, message: _networkError);
    }
  }

  /// Used on app start to check that a saved token is still valid.
  static Future<AuthResult> getCurrentUser(String token) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/current/user'),
        // requireLogin reads the raw token from the "authorization" header
        headers: {'authorization': token},
      ).timeout(_timeout);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return AuthResult(
        success: res.statusCode == 200,
        statusCode: res.statusCode,
        message: body['message']?.toString() ?? '',
        user: body['user'] as Map<String, dynamic>?,
      );
    } catch (_) {
      return const AuthResult(
          success: false, statusCode: 0, message: _networkError);
    }
  }
}
