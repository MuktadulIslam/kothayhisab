import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/data/models/sales_model.dart';
import 'package:kothayhisab/config/app_config.dart';

class SalesService {
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

  // Helper method to convert API response item to SalesItem
  SalesItem _convertApiItemToSalesItem(Map<String, dynamic> apiItem) {
    return SalesItem(
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

  // Get all sales items
  Future<List<SalesItem>> getSalesItems(String shopId) async {
    try {
      // Get token from auth service
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${App.apiUrl}/sales?shop_id=$shopId'),
        headers: {'Authorization': token, 'Accept-Charset': 'utf-8'},
      );

      // Proper encoding handling for response body
      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = jsonDecode(responseBody);
          // Directly map the list to SalesItem objects
          List<SalesItem> items =
              responseData
                  .map((item) => _convertApiItemToSalesItem(item))
                  .toList();

          // Sort items by entry date (newest first)
          items.sort((a, b) => b.entryDate.compareTo(a.entryDate));

          return items;
        } catch (e) {
          print('Error parsing JSON response in sales: $e');
          throw Exception('Error parsing response in sales: $e');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error. Please log in again.');
      } else {
        try {
          final errorData = jsonDecode(responseBody);
          final errorMessage =
              errorData['detail'] ??
              errorData['message'] ??
              'Failed to fetch sales';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception(
            'Failed to fetch sales. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error fetching sales: $e');
      throw Exception('Error fetching sales: $e');
    }
  }

  // Parse inventory text
  Future<List<SalesItem>> parseSalesText(String text) async {
    try {
      // Get token from shared preferences
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${App.apiUrl}/sales/parse'),
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
          return data.map((item) => SalesItem.fromJson(item)).toList();
        } catch (e) {
          print('Error parsing JSON response in sales: $e');
          throw Exception('Error parsing response in sales: $e');
        }
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(responseBody);
          final errorMessage =
              errorData['detail'] ??
              errorData['message'] ??
              'Invalid input format';
          throw Exception(
            'Server could not parse input in sales: $errorMessage',
          );
        } catch (_) {
          throw Exception('Server could not parse the sales text');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error. Please log in again.');
      } else {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      }
    } catch (e) {
      print('Error parsing sales text: $e');
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
  Future<bool> confirmSales(
    List<SalesItem> items,
    String rawText,
    String shopId,
  ) async {
    try {
      // Get token from shared preferences
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final payload = {
        'sales': items.map((item) => item.toJson()).toList(),
        'raw_text': rawText,
      };

      final response = await http.post(
        Uri.parse('${App.apiUrl}/sales/confirm?shop_id=$shopId'),
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
              'Failed to save sales';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception(
            'Failed to save sales. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error confirming sales: $e');
      throw Exception('Error saving sales: $e');
    }
  }

  // Parse inventory text
  Future<Map<String, dynamic>> parseDuesText(String text) async {
    try {
      // Get token from shared preferences
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${App.apiUrl}/due/parse'),
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
          final Map<String, dynamic> data = jsonDecode(responseBody);
          return data;
        } catch (e) {
          print('Error parsing JSON response in due: $e');
          throw Exception('Error parsing response in due: $e');
        }
      } else if (response.statusCode == 422) {
        try {
          final errorData = jsonDecode(responseBody);
          final errorMessage =
              errorData['detail'] ??
              errorData['message'] ??
              'Invalid input format';
          throw Exception(
            'Server could not parse input in sales: $errorMessage',
          );
        } catch (_) {
          throw Exception('Server could not parse the sales text');
        }
      } else {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      }
    } catch (e) {
      print('Error parsing sales text: $e');
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

  Future<bool> confirmDueSale(
    Map<String, dynamic> duesData,
    List<SalesItem> items,
    String rawText,
    String shopId,
  ) async {
    try {
      // Get token from shared preferences
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final saleResponse = await http.post(
        Uri.parse('${App.apiUrl}/sales/confirm?shop_id=$shopId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'sales': items.map((item) => item.toJson()).toList(),
          'raw_text': rawText,
        }),
      );

      final duesResponse = await http.post(
        Uri.parse('${App.apiUrl}/due/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({'due_data': duesData, 'shop_id': shopId}),
      );

      if ((saleResponse.statusCode == 200 || saleResponse.statusCode == 201) &&
          (duesResponse.statusCode == 200 || duesResponse.statusCode == 201)) {
        return true;
      } else if (saleResponse.statusCode == 401 ||
          saleResponse.statusCode == 403 ||
          duesResponse.statusCode == 401 ||
          duesResponse.statusCode == 403) {
        print('Authentication error. Please log in again.');
        throw Exception('Authentication error. Please log in again.');
      } else {
        print(
          'Failed to save due sale. Sale Status: ${saleResponse.statusCode} and Due Status ${duesResponse.statusCode}',
        );
        throw Exception(
          'Failed to save due sale  Sale Status: ${saleResponse.statusCode} and Due Status ${duesResponse.statusCode}',
        );
      }
    } catch (e) {
      print('Error confirming sales: $e');
      throw Exception('Error saving sales: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDueSales(String shopId) async {
    try {
      // Get token from auth service
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${App.apiUrl}/due/shops/$shopId?skip=0&limit=100'),
        headers: {'Authorization': token, 'Accept-Charset': 'utf-8'},
      );

      // Proper encoding handling for response body
      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = jsonDecode(responseBody);

          // Keep the items as Map<String, dynamic> without converting to SalesItem
          List<Map<String, dynamic>> items =
              responseData.map((item) => item as Map<String, dynamic>).toList();

          // Sort items by created_at (newest first)
          items.sort((a, b) {
            DateTime dateA = DateTime.parse(a['created_at']);
            DateTime dateB = DateTime.parse(b['created_at']);
            return dateB.compareTo(dateA);
          });

          return items;
        } catch (e) {
          print('Error parsing JSON response in dues: $e');
          throw Exception('Error parsing response in dues: $e');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error. Please log in again.');
      } else {
        try {
          final errorData = jsonDecode(responseBody);
          final errorMessage =
              errorData['detail'] ??
              errorData['message'] ??
              'Failed to fetch dues';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception(
            'Failed to fetch dues. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error fetching dues: $e');
      throw Exception('Error fetching dues: $e');
    }
  }
}
