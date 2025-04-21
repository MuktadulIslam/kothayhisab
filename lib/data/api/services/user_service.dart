import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService {
  // Private constructor to prevent instantiation
  UserProfileService._();

  static const String _userKey = 'user_data';

  // Get user data from shared preferences
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      if (userData != null && userData.isNotEmpty) {
        return jsonDecode(userData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error retrieving user profile: $e');
      return null;
    }
  }

  // Get user name from stored data
  static Future<String?> getUserName() async {
    final userData = await getUserProfile();
    return userData?['name'];
  }

  // Get user mobile number from stored data
  static Future<String?> getUserMobileNumber() async {
    final userData = await getUserProfile();
    return userData?['mobile_number'];
  }

  // Get user email from stored data
  static Future<String?> getUserEmail() async {
    final userData = await getUserProfile();
    return userData?['email'];
  }

  // Get user ID from stored data
  static Future<String?> getUserId() async {
    final userData = await getUserProfile();
    return userData?['id']?.toString();
  }

  // Update user profile data locally
  // Note: This doesn't update on the server, just local storage
  static Future<bool> updateUserProfile(
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      if (userData != null) {
        // Get existing user data
        Map<String, dynamic> existingData = jsonDecode(userData);

        // Update with new data
        existingData.addAll(updatedData);

        // Save back to shared preferences
        await prefs.setString(_userKey, jsonEncode(existingData));
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}
