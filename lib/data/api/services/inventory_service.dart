// lib/services/inventory_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class InventoryItem {
  String name;
  double price; // Changed from num to double
  String currency;
  num quantity;
  String quantityDescription;
  String sourceText;
  DateTime entryDate;

  InventoryItem({
    required this.name,
    required this.price,
    required this.currency,
    required this.quantity,
    required this.quantityDescription,
    required this.sourceText,
    required this.entryDate,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    // Fix encoding for text fields
    String fixEncoding(String text) {
      try {
        // This handles cases where the text is already properly encoded
        // but might have encoding issues
        if (text.contains('à') || text.contains('§')) {
          // If it looks like improperly encoded Bengali text, try to fix it
          List<int> bytes = text.codeUnits;
          return utf8.decode(bytes);
        }
      } catch (e) {
        print('Error fixing encoding: $e');
      }
      return text;
    }

    // Convert price to double
    double parsePrice(dynamic value) {
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

    return InventoryItem(
      name: fixEncoding(json['name'] ?? ''),
      price: parsePrice(json['price']),
      currency: fixEncoding(json['currency'] ?? '৳'),
      quantity: json['quantity'] ?? 0,
      quantityDescription: fixEncoding(json['quantity_description'] ?? ''),
      sourceText: fixEncoding(json['source_text'] ?? ''),
      entryDate:
          json['entry_date'] != null
              ? DateTime.parse(json['entry_date'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'currency': currency,
      'quantity': quantity,
      'quantity_description': quantityDescription,
      'source_text': sourceText,
    };
  }
}

class InventoryService {
  static const String baseUrl = 'https://smartpricescrive.onrender.com/api/v1';
  static const String tokenKey = 'auth_token';
  static AuthService _authService = AuthService();

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
      currency: apiItem['currency'] ?? '৳',
      quantity: apiItem['quantity'] ?? 0,
      quantityDescription: apiItem['quantity_description'] ?? '',
      sourceText: apiItem['raw_input_text'] ?? '',
      entryDate:
          apiItem['entry_date'] != null
              ? DateTime.parse(apiItem['entry_date'])
              : DateTime.now(),
    );
  }

  // Get all inventory items
  Future<List<InventoryItem>> getInventoryItems() async {
    try {
      // Get token from auth service
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/inventory'),
        headers: {'Authorization': token, 'Accept-Charset': 'utf-8'},
      );

      // Proper encoding handling for response body
      final String responseBody = utf8.decode(response.bodyBytes);
      print('Inventory fetch status code: ${response.statusCode}');
      print('Inventory fetch response body (decoded): $responseBody');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = jsonDecode(responseBody);
          // Directly map the list to InventoryItem objects
          List<InventoryItem> items =
              responseData
                  .map((item) => _convertApiItemToInventoryItem(item))
                  .toList();

          // Sort items by entry date (newest first)
          items.sort((a, b) => b.entryDate.compareTo(a.entryDate));

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
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/inventory/parse'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({'text': text}),
      );

      print('Status code: ${response.statusCode}');

      // Proper encoding handling for response body
      final String responseBody = utf8.decode(response.bodyBytes);
      print('Response body (decoded): $responseBody');

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
          throw Exception('Server could not parse input: $errorMessage');
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
    List<InventoryItem> items,
    String rawText,
  ) async {
    try {
      // Get token from shared preferences
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final payload = {
        'products': items.map((item) => item.toJson()).toList(),
        'raw_text': rawText,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/inventory/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(payload),
      );

      // Proper encoding handling for response body
      final String responseBody = utf8.decode(response.bodyBytes);
      print('Confirm status code: ${response.statusCode}');
      print('Confirm response body (decoded): $responseBody');

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
