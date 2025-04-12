// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      'https://smartpricescrive.onrender.com/api/v1'; // For Android emulator
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  // Register a new user
  // Updated register method for AuthService class
  Future<Map<String, dynamic>> register(
    String mobileNumber,
    String password,
    String name, {
    String? email,
    String? username,
  }) async {
    try {
      // Create the request body exactly as in Postman
      final Map<String, dynamic> requestBody = {
        "mobile_number": mobileNumber,
        "password": password,
        "name": name,
      };

      // Add optional fields if provided
      if (email != null) requestBody["email"] = email;
      if (username != null) requestBody["username"] = username;

      final body = jsonEncode(requestBody);

      // Make the request matching the Postman format
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        // Only add Content-Type if needed - Postman example doesn't have it
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Parse the response
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('Error decoding response: $e');
        return {'success': false, 'message': 'Invalid response format'};
      }

      // Handle successful response
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data['success'] == true && data['access_token'] != null) {
          // Save token with token_type (usually "bearer")
          await _saveToken('${data['token_type']} ${data['access_token']}');

          // Save user data if available
          if (data['user'] != null) {
            await _saveUserData(jsonEncode(data['user']));
          }
        }
      }

      return data;
    } catch (e) {
      print('Registration error details: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Login with credentials
  // Updated login method for AuthService class
  Future<Map<String, dynamic>> login(
    String mobileNumber,
    String password,
  ) async {
    try {
      // Create the request body exactly as in Postman
      final body = jsonEncode({
        "mobile_number": mobileNumber,
        "password": password,
      });

      // Make the request matching the Postman format
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        // Only add Content-Type if needed - Postman example doesn't have it
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Parse the response
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('Error decoding response: $e');
        return {'success': false, 'message': 'Invalid response format'};
      }

      // Handle successful response
      if (response.statusCode == 200) {
        if (data['success'] == true && data['access_token'] != null) {
          // Save token with token_type (usually "bearer")
          await _saveToken('${data['token_type']} ${data['access_token']}');

          // Save user data if available
          if (data['user'] != null) {
            await _saveUserData(jsonEncode(data['user']));
          }
        }
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
      // final token = await getToken();

      // if (token == null) {
      //   return {'success': false, 'message': 'Not logged in'};
      // }

      // final response = await http.post(
      //   Uri.parse('$baseUrl/logout'),
      //   headers: {'Content-Type': 'application/json', 'Authorization': token},
      // );

      // final data = jsonDecode(response.body);

      // if (response.statusCode == 200) {
      //   // Clear token and user data on successful logout
      //   await _clearAuthData();
      // }
      await _clearAuthData();
      return {'success': true, 'message': 'Logout Successful'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Save auth token to shared preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Save user data to shared preferences
  Future<void> _saveUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, userData);
  }

  // Clear auth data (token and user info) from shared preferences
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  // Get token from shared preferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Get user data from shared preferences
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    if (userData != null) {
      return jsonDecode(userData) as Map<String, dynamic>;
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
