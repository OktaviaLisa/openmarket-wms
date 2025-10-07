import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8000/api'; // iOS simulator
    } else {
      return 'http://localhost:8000/api';
    }
  }
  
  static String get realDeviceUrl {
    return 'http://10.10.10.37:8000/api'; // Your computer's IP
  }
}