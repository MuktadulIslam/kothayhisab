import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
      quantity: apiItem['quantity'] ?? 0,
      quantityDescription: apiItem['quantity_description'] ?? '',
    );
  }

  // Get all sales items
  Future<GetSalesResponse> getSalesItems(String shopId) async {
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
          final Map<String, dynamic> responseData = jsonDecode(responseBody);
          // Use the fromJson factory constructor to create a GetSalesResponse object
          final salesResponse = GetSalesResponse.fromJson(responseData);
          print(salesResponse);

          return salesResponse;
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
    String shopId,
    List<SalesItem> items,
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
        "sales_text": rawText,
        "total_amount": totalAmount,
        "currency": currency,
      };
      print('Payload: $payload');

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

  Future<bool> confirmDueSale({
    required int shopId,
    required List<SalesItem> items,
    required String rawText,
    required double totalAmount,
    required String currency,
    required int customerId,
    required double paidAmount,
    required double dueAmount,
    required String description,
  }) async {
    try {
      // Get token from shared preferences
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      // first making sale
      final payloadForSale = {
        'products': items.map((item) => item.toJson()).toList(),
        "sales_text": rawText,
        "total_amount": totalAmount,
        "currency": currency,
      };
      final responseForSale = await http.post(
        Uri.parse('${App.apiUrl}/sales/confirm?shop_id=$shopId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(payloadForSale),
      );

      // now adding due in customar account
      if (responseForSale.statusCode == 200 ||
          responseForSale.statusCode == 201) {
        try {
          // Proper encoding handling for response body
          final String saleResponseBody = utf8.decode(
            responseForSale.bodyBytes,
          );
          final Map<String, dynamic> data = jsonDecode(saleResponseBody);

          // Create a map with the customer data
          DateTime now = DateTime.now();
          final payloadForDue = {
            "sale_id": data['saved_sale']['id'],
            "customer_id": customerId,
            "amount_paid": paidAmount,
            "due_amount": dueAmount,
            "due_date": DateFormat('yyyy-MM-dd').format(now),
            "description": description,
          };
          final responseForDue = await http.post(
            Uri.parse('${App.apiUrl}/due/from-sale?shop_id=$shopId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': token,
              'Accept-Charset': 'utf-8',
            },
            body: jsonEncode(payloadForDue),
          );

          if (responseForDue.statusCode == 200 ||
              responseForDue.statusCode == 201) {
            return true;
          } else {
            return false;
          }
        } catch (e) {
          print('Error parsing JSON response in due: $e');
          return false;
        }
      } else {
        print('Failed in making the sale:');
        return false;
      }
    } catch (e) {
      print('Error confirming sales: $e');
      return false;
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
