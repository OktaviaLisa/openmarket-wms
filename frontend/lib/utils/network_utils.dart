import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  static String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      // For real device, use your computer's IP
      // For emulator, use 10.0.2.2
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:8000/api';
    } else {
      return 'http://localhost:8000/api';
    }
  }
  
  static String getAuthUrl() {
    return '${getBaseUrl().replaceAll('/api', '')}/api/auth';
  }
  
  // For real device testing, change this to your computer's actual IP
  static String getRealDeviceUrl() {
    return 'http://192.168.1.100:8000/api'; // Change this IP
  }
}