// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      'http://10.0.2.2:5000/api/auth'; // For Android emulator
  // If using a physical device, use your computer's actual IP address like:
  // static const String baseUrl = 'http://192.168.1.XXX:5000/api/auth'; // Replace with your actual IP
  static const String tokenKey = 'auth_token';

  // Register a new user
  Future<Map<String, dynamic>> register(
    String name,
    String mobileNumber,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'mobile_number': mobileNumber,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Save token
        await _saveToken(data['token']);
      }

      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Login with credentials
  Future<Map<String, dynamic>> login(
    String mobileNumber,
    String password,
  ) async {
    try {
      print('Attempting to connect to: $baseUrl/login');
      print(
        'Request body: ${jsonEncode({'mobile_number': mobileNumber, 'password': password})}',
      );

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile_number': mobileNumber, 'password': password}),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token
        await _saveToken(data['token']);
      }

      return data;
    } catch (e) {
      print('Connection error details: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Logout the user
  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await getToken();

      if (token == null) {
        return {'success': false, 'message': 'Not logged in'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Clear token on successful logout
        await _clearToken();
      }

      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Save auth token to shared preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Clear auth token from shared preferences
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Get token from shared preferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
