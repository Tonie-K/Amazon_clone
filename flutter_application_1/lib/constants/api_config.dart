import 'dart:io' show Platform;

class ApiConfig {
  static const int port = 5000;
  static String get baseUrl =>
      Platform.isAndroid ? 'http://10.0.2.2:$port' : 'http://localhost:$port';
}
