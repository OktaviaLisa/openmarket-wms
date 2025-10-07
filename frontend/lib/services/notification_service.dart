import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final workingUrl = await ApiConfig.getAutoDetectedBaseUrl();

      final response = await http.get(
        Uri.parse('$workingUrl/notifications'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        // Return mock data if API fails
        return _getMockNotifications();
      }
    } catch (e) {
      // Return mock data if connection fails
      return _getMockNotifications();
    }
  }

  static List<Map<String, dynamic>> _getMockNotifications() {
    return [
      {
        'id': 1,
        'title': 'Pesanan telah selesai.',
        'message': 'Terima kasih atas kerja keras Anda!',
        'time': '6 Juli 2026, 18.40',
        'isToday': true,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 2,
        'title': 'Stock opname completed.',
        'message': 'Inventory count has been updated successfully.',
        'time': '6 Juli 2026, 16.30',
        'isToday': true,
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 3,
        'title': 'Quality check required.',
        'message': 'New incoming goods need quality inspection.',
        'time': '5 Juli 2026, 14.20',
        'isToday': false,
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];
  }
}