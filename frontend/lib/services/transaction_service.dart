import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_models.dart';
import '../config/api_config.dart';

class TransactionService {
  static Future<String> get baseUrl async => await ApiConfig.getAutoDetectedBaseUrl();

  // Master Data Services
  static Future<List<Supplier>> getSuppliers() async {
    try {
      final apiUrl = await baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/suppliers'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((item) => Supplier.fromJson(item))
            .toList();
      }
      throw Exception('Failed to load suppliers');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<Customer>> getCustomers() async {
    try {
      final apiUrl = await baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/customers'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((item) => Customer.fromJson(item))
            .toList();
      }
      throw Exception('Failed to load customers');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<Unit>> getUnits() async {
    try {
      final apiUrl = await baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/units'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((item) => Unit.fromJson(item))
            .toList();
      }
      throw Exception('Failed to load units');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<Location>> getLocations() async {
    try {
      final apiUrl = await baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/locations'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((item) => Location.fromJson(item))
            .toList();
      }
      throw Exception('Failed to load locations');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Receiving Services
  static Future<Map<String, dynamic>> createReceiving(ReceivingRequest request) async {
    try {
      final apiUrl = await baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/receiving'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Failed to create receiving');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<Receiving>> getReceivings() async {
    try {
      final apiUrl = await baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/receiving'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) return [];
        return (data['data'] as List)
            .map((item) => Receiving.fromJson(item))
            .toList();
      }
      throw Exception('Failed to load receivings');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Issuing Services
  static Future<Map<String, dynamic>> createIssuing(IssuingRequest request) async {
    try {
      final apiUrl = await baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/issuing'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Failed to create issuing');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<Issuing>> getIssuings() async {
    try {
      final apiUrl = await baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/issuing'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) return [];
        return (data['data'] as List)
            .map((item) => Issuing.fromJson(item))
            .toList();
      }
      throw Exception('Failed to load issuings');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}