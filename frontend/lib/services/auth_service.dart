import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './logger_service.dart';
import '../config/api_config.dart';

class AuthService {
  static String? cachedBaseUrl;
  
  static Future<String> get baseUrl async {
    final apiBaseUrl = await ApiConfig.getAutoDetectedBaseUrl();
    print('🔑 AuthService: Using auth URL: $apiBaseUrl/auth');
    return '$apiBaseUrl/auth';
  }
  
  static Future<String> get apiBaseUrl async {
    return await ApiConfig.getAutoDetectedBaseUrl();
  }
  
  static Future<void> resetCache() async {
    await ApiConfig.resetCache();
  }

  Future<bool> login(String username, String password) async {
    try {
      AppLogger.info('Attempting login for: $username');
      AppLogger.info('Searching for backend server...');
      
      final authUrl = await baseUrl;
      AppLogger.info('Using URL: $authUrl/login');
      
      final response = await http.post(
        Uri.parse('$authUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      AppLogger.info('Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);
        AppLogger.info('Login successful');
        return true;
      } else {
        AppLogger.info('Login failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      AppLogger.info('Login error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
        AppLogger.info('Network connection failed - trying to find new backend host');
        resetCache();
        
        try {
          final newAuthUrl = await baseUrl;
          AppLogger.info('Retrying with: $newAuthUrl/login');
          
          final response = await http.post(
            Uri.parse('$newAuthUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': username,
              'password': password,
            }),
          ).timeout(const Duration(seconds: 5));
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', data['access']);
            await prefs.setString('refresh_token', data['refresh']);
            AppLogger.info('Login successful after retry');
            return true;
          }
        } catch (retryError) {
          AppLogger.info('Retry login failed: $retryError');
        }
      }
      return false;
    }
  }

  Future<bool> register(String username, String email, String password,
      String firstName, String lastName) async {
    try {
      final authUrl = await baseUrl;
      final response = await http.post(
        Uri.parse('$authUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      // Extract user ID from simple token format: token_userId_timestamp
      final parts = token.split('_');
      if (parts.length >= 2) {
        final userId = int.tryParse(parts[1]);
        if (userId != null) {
          // Get user details from API
          final apiUrl = await apiBaseUrl;
          final response = await http.get(
            Uri.parse('$apiUrl/users'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (response.statusCode == 200) {
            final List<dynamic> users = json.decode(response.body);
            final userData = users.firstWhere(
              (user) => user['id'] == userId,
              orElse: () => null,
            );
            
            if (userData != null) {
              return {
                'user_id': userData['id'],
                'username': userData['username'],
                'is_staff': userData['is_staff'] ?? false,
                'email': userData['email'] ?? '',
                'first_name': userData['first_name'] ?? '',
                'last_name': userData['last_name'] ?? '',
                'role': userData['role'] ?? 'user',
                'roles': userData['roles'] ?? ['user'],
              };
            }
          }
        }
      }

      // Fallback
      return {
        'user_id': 1,
        'username': 'User',
        'is_staff': false,
        'role': 'user',
        'roles': ['user'],
      };
    } catch (e) {
      AppLogger.info('Error getting user info: $e');
      return null;
    }
  }

  Future<bool> isAdmin() async {
    final userInfo = await getUserInfo();
    return userInfo?['is_staff'] ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) return false;

    // Simple token validation - check if it starts with 'token_'
    return token.startsWith('token_');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) return false;

      final authUrl = await baseUrl;
      final response = await http.post(
        Uri.parse('$authUrl/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString('access_token', data['access']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
