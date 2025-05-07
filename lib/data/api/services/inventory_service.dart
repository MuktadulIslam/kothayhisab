// lib/services/inventory_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/data/models/inventory_model.dart';
import 'package:kothayhisab/config/app_config.dart';

class InventoryService {
  // Helper method to convert price to double
  double _convertToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('Error parsing price from string: $e');
        return 0.0;
      }
    }
    return 0.0;
  }

  // Helper method to convert API response item to InventoryItem
  InventoryItem _convertApiItemToInventoryItem(Map<String, dynamic> apiItem) {
    return InventoryItem(
      name: apiItem['product_name'] ?? '',
      price: _convertToDouble(apiItem['price']),
      quantity: apiItem['quantity'] ?? 0,
      quantityDescription: apiItem['quantity_description'] ?? '',
    );
  }

  // Get all inventory items
  Future<List<InventoryItem>> getInventoryItems(String shopId) async {
    try {
      // Get token from auth service
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${App.apiUrl}/inventory?shop_id=$shopId'),
        headers: {'Authorization': token, 'Accept-Charset': 'utf-8'},
      );

      // Proper encoding handling for response body
      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = jsonDecode(responseBody);
          // Directly map the list to InventoryItem objects
          List<InventoryItem> items =
              responseData
                  .map((item) => _convertApiItemToInventoryItem(item))
                  .toList();

          // // Sort items by entry date (newest first)
          // items.sort((a, b) => b.entryDate.compareTo(a.entryDate));

          return items;
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
              'Failed to fetch inventory';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception(
            'Failed to fetch inventory. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error fetching inventory: $e');
      throw Exception('Error fetching inventory: $e');
    }
  }

  // Parse inventory text
  Future<List<InventoryItem>> parseInventoryText(String text) async {
    try {
      // Get token from shared preferences
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${App.apiUrl}/inventory/parse'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({'text': text}),
      );

      // Proper encoding handling for response body
      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = jsonDecode(responseBody);
          return data.map((item) => InventoryItem.fromJson(item)).toList();
        } catch (e) {
          print('Error parsing JSON response: $e');
          throw Exception('Error parsing response: $e');
        }
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(responseBody);
          final errorMessage =
              errorData['detail'] ??
              errorData['message'] ??
              'Invalid input format';
          throw Exception(
            'Server could not parse input in inventory: $errorMessage',
          );
        } catch (_) {
          throw Exception('Server could not parse the inventory text');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error. Please log in again.');
      } else {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      }
    } catch (e) {
      print('Error parsing inventory text: $e');
      String errorMessage = e.toString();
      if (errorMessage.contains(
        'type \'double\' is not a subtype of type \'int\'',
      )) {
        errorMessage =
            'Error processing numbers in the response. Please contact support.';
      }
      throw Exception(errorMessage);
    }
  }

  // Confirm and save inventory items
  Future<bool> confirmInventory(
    String shopId,
    List<InventoryItem> items,
    String rawText,
    double totalAmount,
    String currency,
  ) async {
    try {
      // Get token from shared preferences
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final payload = {
        'products': items.map((item) => item.toJson()).toList(),
        "inventory_text": rawText,
        "total_amount": totalAmount,
        "currency": currency,
      };

      final response = await http.post(
        Uri.parse('${App.apiUrl}/inventory/confirm?shop_id=$shopId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(payload),
      );

      // Proper encoding handling for response body
      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error. Please log in again.');
      } else {
        try {
          final errorData = jsonDecode(responseBody);
          final errorMessage =
              errorData['detail'] ??
              errorData['message'] ??
              'Failed to save inventory';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception(
            'Failed to save inventory. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error confirming inventory: $e');
      throw Exception('Error saving inventory: $e');
    }
  }
}
