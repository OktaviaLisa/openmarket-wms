import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class UserService {
  static Future<Map<String, dynamic>?> getUserProfile(String username) async {
    try {
      final workingUrl = await ApiConfig.getAutoDetectedBaseUrl();

      final response = await http.get(
        Uri.parse('$workingUrl/users/profile/$username'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return _getMockUserProfile(username);
      }
    } catch (e) {
      return _getMockUserProfile(username);
    }
  }

  static Map<String, dynamic> _getMockUserProfile(String username) {
    return {
      'name': 'Putri Cahyani',
      'email': 'putricahyani.gsk@gmail.com',
      'username': username,
      'warehouse': 'Warehouse A',
      'role': 'Warehouse Staff',
      'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
      'phone': '+62 812-3456-7890',
      'joined_date': '2024-01-15',
    };
  }

  static Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final workingUrl = await ApiConfig.getAutoDetectedBaseUrl();

      final response = await http.put(
        Uri.parse('$workingUrl/users/profile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profileData),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}