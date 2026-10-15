import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';
  static const _emailKey = 'user_email';
  static const _nameKey = 'user_name';

  String? _token;
  String? _email;
  String? _name;

  String? get token => _token;
  String? get email => _email;
  String? get name => _name;
  bool get isLoggedIn => _token != null;

  /// Name if the user has one, otherwise their email.
  String get displayName =>
      (_name != null && _name!.isNotEmpty) ? _name! : (_email ?? '');

  /// Reads the saved session from the device. Call before runApp.
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _email = prefs.getString(_emailKey);
    _name = prefs.getString(_nameKey);
    notifyListeners();
  }

  /// Checks the saved token with the server. Logs out only if the server
  /// says the token is invalid (401/404), not when the network is down.
  Future<void> validateSession() async {
    if (_token == null) return;
    final result = await AuthService.getCurrentUser(_token!);
    if (result.statusCode == 401 || result.statusCode == 404) {
      await logout();
    } else if (result.success && result.user != null) {
      await _save(
        token: _token!,
        email: result.user!['email']?.toString(),
        name: result.user!['name']?.toString(),
      );
    }
  }

  Future<void> login(String token, Map<String, dynamic>? user) async {
    await _save(
      token: token,
      email: user?['email']?.toString(),
      name: user?['name']?.toString(),
    );
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
    _name = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    notifyListeners();
  }

  Future<void> _save({
    required String token,
    String? email,
    String? name,
  }) async {
    _token = token;
    _email = email;
    _name = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (email != null) await prefs.setString(_emailKey, email);
    if (name != null) await prefs.setString(_nameKey, name);
    notifyListeners();
  }
}
