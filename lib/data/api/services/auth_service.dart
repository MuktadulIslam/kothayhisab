// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kothayhisab/config/app_config.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // Private constructor to prevent instantiation
  AuthService._();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Register a new user
  static Future<Map<String, dynamic>> register(
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
        Uri.parse('${App.backendUrl}/auth/register'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );

      if (kDebugMode) {
        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      // Parse the response
      Map<String, dynamic> data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding response: $e');
        }
        return {'success': false, 'message': 'Invalid response format'};
      }

      // Handle successful response
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data['success'] == true && data['access_token'] != null) {
          // Save token with token_type (usually "bearer")
          await _saveToken('${data['token_type']} ${data['access_token']}');

          // Save user data if available
          if (data['user'] != null) {
            await _saveUserData(data['user']);
          }
        }
      }
      data['status_code'] = response.statusCode;
      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Registration error details: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Login with credentials
  static Future<Map<String, dynamic>> login(
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
        Uri.parse('${App.backendUrl}/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );

      // Parse the response
      Map<String, dynamic> data;
      try {
        // Use utf8.decode on bodyBytes to properly handle Unicode characters
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding response: $e');
        }
        return {'success': false, 'message': 'Invalid response format'};
      }

      // Handle successful response
      if (response.statusCode == 200) {
        if (data['success'] == true && data['access_token'] != null) {
          // Save token with token_type (usually "bearer")
          await _saveToken('${data['token_type']} ${data['access_token']}');

          // Save user data if available
          if (data['user'] != null) {
            if (kDebugMode) {
              print("User data received: ${data['user']}");
            }
            await _saveUserData(data['user']);
          }
        }
      }

      // Add the status code to the data map
      data['status_code'] = response.statusCode;
      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Connection error details: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Logout the user
  static Future<Map<String, dynamic>> logout() async {
    try {
      await _clearAuthData();
      return {'success': true, 'message': 'Logout Successful'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Save auth token to shared preferences
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Save user data to shared preferences
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert to JSON with ensure_ascii: false to preserve Unicode characters
    final jsonStr = jsonEncode(userData);
    await prefs.setString(_userKey, jsonStr);

    if (kDebugMode) {
      print("Saved user data: $jsonStr");
    }
  }

  // Clear auth data (token and user info) from shared preferences
  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Get token from shared preferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get user data from shared preferences
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return jsonDecode(userData) as Map<String, dynamic>;
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
