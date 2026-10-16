import 'dart:io' show Platform;

class ApiConfig {
  static const int port = 8000;
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$port';
    } else {
      // iOS Simulator & macOS Desktop
      return 'http://127.0.0.1:$port';
    }
  }
}
