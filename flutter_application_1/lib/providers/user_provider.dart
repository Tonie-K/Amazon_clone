import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  static const String _keyToken = 'auth_token';
  static const String _keyEmail = 'auth_email';
  static const String _keyName = 'auth_name';

  String? _token;
  String? _email;
  String? _name;

  String? get token => _token;
  String? get email => _email;
  String? get name => _name;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  String get displayName {
    if (_name != null && _name!.trim().isNotEmpty) {
      return _name!.trim();
    }
    if (_email != null && _email!.contains('@')) {
      return _email!.split('@').first;
    }
    return 'Customer';
  }

  // Load user session from device storage on launch
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_keyToken);
    _email = prefs.getString(_keyEmail);
    _name = prefs.getString(_keyName);
    notifyListeners();
  }

  // Validate session against server in background
  Future<void> validateSession() async {
    if (!isLoggedIn) return;

    final result = await AuthService.getCurrentUser(_token!);
    if (!result.success) {
      await logout();
    } else if (result.user != null) {
      _email = result.user!['email']?.toString() ?? _email;
      _name = result.user!['name']?.toString() ?? _name;
      final prefs = await SharedPreferences.getInstance();
      if (_email != null) await prefs.setString(_keyEmail, _email!);
      if (_name != null) await prefs.setString(_keyName, _name!);
      notifyListeners();
    }
  }

  // Login Handler
  Future<void> setSession({
    required String token,
    required String email,
    String? name,
  }) async {
    await _save(token: token, email: email, name: name);
  }

  // Update Display Name
  Future<bool> updateName(String newName) async {
    if (_token == null) return false;

    final result = await AuthService.updateProfile(_token!, newName);
    if (result.success && result.user != null) {
      await _save(
        token: _token!,
        email: result.user!['email']?.toString() ?? _email,
        name: result.user!['name']?.toString(),
      );
      return true;
    }
    return false;
  }

  // Clear Session / Logout
  Future<void> logout() async {
    _token = null;
    _email = null;
    _name = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);

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
    await prefs.setString(_keyToken, token);
    if (email != null) {
      await prefs.setString(_keyEmail, email);
    } else {
      await prefs.remove(_keyEmail);
    }

    if (name != null && name.isNotEmpty) {
      await prefs.setString(_keyName, name);
    } else {
      await prefs.remove(_keyName);
    }

    notifyListeners();
  }
}
