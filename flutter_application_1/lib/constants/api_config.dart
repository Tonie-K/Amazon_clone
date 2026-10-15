import 'dart:io' show Platform;

class ApiConfig {
  // Set this to the PORT in your backend .env
  static const int port = 5000;

  // Android emulator reaches your computer at 10.0.2.2.
  // iOS simulator / desktop can use localhost.
  // For a real phone, replace with your computer's LAN IP, e.g. 'http://192.168.1.10:5000'.
  static String get baseUrl =>
      Platform.isAndroid ? 'http://10.0.2.2:$port' : 'http://localhost:$port';
}
