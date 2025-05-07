// lib/services/shops_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/config/app_config.dart';
import 'package:kothayhisab/data/models/shop_model.dart';

class ShopsService {
  // Create a new shop
  Future<bool> updateShop(Shop shop) async {
    try {
      // Get token from auth service
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Initial request
      final response = await http.put(
        Uri.parse('${App.apiUrl}/shops/${shop.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(shop.toJson()),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error creating shop: $e');
      throw Exception('Error creating shop: $e');
    }
  }

  // Create a new shop
  Future<bool> createShop(Shop shop) async {
    try {
      // Get token from auth service
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('shop.toJson(): ${shop.toJson()}');

      // Initial request
      final response = await http.post(
        Uri.parse('${App.apiUrl}/shops'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(shop.toJson()),
      );

      // Handle redirect (status code 307)
      if (response.statusCode == 307) {
        // Get the redirect URL from the 'location' header
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          // Make a new request to the redirect URL
          final redirectResponse = await http.post(
            Uri.parse(redirectUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': token,
              'Accept-Charset': 'utf-8',
            },
            body: jsonEncode(shop.toJson()),
          );

          // Process the redirect response
          final String redirectResponseBody = utf8.decode(
            redirectResponse.bodyBytes,
          );

          if (redirectResponse.statusCode == 200 ||
              redirectResponse.statusCode == 201) {
            return true;
          } else {
            throw _handleErrorResponse(
              redirectResponse.statusCode,
              redirectResponseBody,
            );
          }
        } else {
          throw Exception('Redirect URL not found in response headers');
        }
      }

      // Proper encoding handling for response body
      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error. Please log in again.');
      } else {
        throw _handleErrorResponse(response.statusCode, responseBody);
      }
    } catch (e) {
      print('Error creating shop: $e');
      throw Exception('Error creating shop: $e');
    }
  }

  // Helper method to handle error responses
  Exception _handleErrorResponse(int statusCode, String responseBody) {
    try {
      final errorData = jsonDecode(responseBody);
      final errorMessage =
          errorData['detail'] ??
          errorData['message'] ??
          'Failed to create shop';
      return Exception(errorMessage);
    } catch (_) {
      return Exception('Failed to create shop. Status: $statusCode');
    }
  }

  // Get all shops
  Future<List<Shop>> getShops() async {
    try {
      // Get token from auth service
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${App.apiUrl}/shops'),
        headers: {'Authorization': token, 'Accept-Charset': 'utf-8'},
      );

      // Proper encoding handling for response body
      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

          // Check if response has "shops" array
          if (jsonResponse.containsKey('shops') &&
              jsonResponse['shops'] is List) {
            final List<dynamic> shopsData = jsonResponse['shops'];
            // Map the list to Shop objects
            List<Shop> shops =
                shopsData.map((item) => Shop.fromJson(item)).toList();
            return shops;
          } else {
            // Fallback if response structure is different
            if (jsonResponse is List) {
              // Direct list of shops
              return (jsonResponse as List)
                  .map((item) => Shop.fromJson(item))
                  .toList();
            } else {
              throw Exception('Unexpected response format');
            }
          }
        } catch (e) {
          print('Error parsing JSON response: $e');
          throw Exception('Error parsing response: $e');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error. Please log in again.');
      } else {
        try {
          final errorData = jsonDecode(responseBody);
          final errorMessage =
              errorData['detail'] ??
              errorData['message'] ??
              'Failed to fetch shops';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception(
            'Failed to fetch shops. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error fetching shops: $e');
      throw Exception('Error fetching shops: $e');
    }
  }

  // Get shop by ID
  Future<Shop> getShopById(String shopId) async {
    try {
      // Get token from auth service
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${App.apiUrl}/shops/$shopId'),
        headers: {'Authorization': token, 'Accept-Charset': 'utf-8'},
      );

      // Proper encoding handling for response body
      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(responseBody);
          return Shop.fromJson(responseData);
        } catch (e) {
          print('Error parsing JSON response: $e');
          throw Exception('Error parsing response: $e');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error. Please log in again.');
      } else {
        try {
          final errorData = jsonDecode(responseBody);
          final errorMessage =
              errorData['detail'] ??
              errorData['message'] ??
              'Failed to fetch shop';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception(
            'Failed to fetch shop. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error fetching shop: $e');
      throw Exception('Error fetching shop: $e');
    }
  }
}
