import 'dart:async';
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
  static const Duration _timeout = Duration(seconds: 15);
  static const String _networkError =
      'Network error. Check connection and backend running at ApiConfig.baseUrl.';

  // 1. Send OTP to Email
  static Future<AuthResult> sendEmailOtp(String email) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/v1/send/email/otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email.trim()}),
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
        success: false,
        statusCode: 0,
        message: _networkError,
      );
    }
  }

  // 2. Verify OTP & Login
  static Future<AuthResult> verifyEmailOtp(String email, String otp) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/v1/verify/email/otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'otp': otp.trim(),
            }),
          )
          .timeout(_timeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final user = body['user'] as Map<String, dynamic>?;

      return AuthResult(
        success: res.statusCode == 200,
        statusCode: res.statusCode,
        message: body['message']?.toString() ?? '',
        token: body['token']?.toString(),
        user: user,
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        statusCode: 0,
        message: _networkError,
      );
    }
  }

  // 3. Fetch Current User Profile
  static Future<AuthResult> getCurrentUser(String token) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/current/user'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': token,
        },
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
        success: false,
        statusCode: 0,
        message: _networkError,
      );
    }
  }

  // 4. Update Profile Name
  static Future<AuthResult> updateProfile(String token, String name) async {
    try {
      final res = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/api/v1/update/profile'),
            headers: {
              'Content-Type': 'application/json',
              'authorization': token,
            },
            body: jsonEncode({'name': name.trim()}),
          )
          .timeout(_timeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return AuthResult(
        success: res.statusCode == 200,
        statusCode: res.statusCode,
        message: body['message']?.toString() ?? '',
        user: body['user'] as Map<String, dynamic>?,
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        statusCode: 0,
        message: _networkError,
      );
    }
  }
}
