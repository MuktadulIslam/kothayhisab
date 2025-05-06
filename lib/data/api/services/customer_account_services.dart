// lib/services/customer_service.dart
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/config/app_config.dart';
import 'package:kothayhisab/data/models/customer_model.dart';

class CustomerService {
  // Delete a customer by ID
  Future<bool> deleteCustomer(String customerId) async {
    try {
      // Get token from auth service
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('${App.apiUrl}/customer/$customerId'),
        headers: {
          'Authorization': token,
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error. Please log in again.');
      } else {
        // Proper encoding handling for response body
        final String responseBody = utf8.decode(response.bodyBytes);
        throw _handleErrorResponse(response.statusCode, responseBody);
      }
    } catch (e) {
      print('Error deleting customer: $e');
      throw Exception('Error deleting customer: $e');
    }
  }

  // Get all customers for a shop
  Future<List<Customer>> getCustomers(
    String shopId, {
    bool hasDueOnly = false,
    bool activeOnly = true,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      // Get token from auth service
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Build URL with query parameters
      final uri = Uri.parse(
        '${App.apiUrl}/customer/customers-with-dues',
      ).replace(
        queryParameters: {
          'shop_id': shopId,
          'has_due_only': hasDueOnly.toString(),
          'active_only': activeOnly.toString(),
          'skip': skip.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': token,
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
      );

      // Proper encoding handling for response body
      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        try {
          final List<dynamic> customersData = jsonDecode(responseBody);
          List<Customer> customers =
              customersData.map((item) => Customer.fromJson(item)).toList();
          return customers;
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
              'Failed to fetch customers';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception(
            'Failed to fetch customers. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error fetching customers: $e');
      throw Exception('Error fetching customers: $e');
    }
  }

  // Create a new customer
  Future<bool> createCustomer({
    required String customerName,
    required String mobileNumber,
    required String address,
    String photoUrl = '',
    required String shopId,
  }) async {
    try {
      // Get token from auth service
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Create a map with the customer data
      final customerData = {
        'name': customerName,
        'mobile': mobileNumber,
        'address': address,
        'photo_url': photoUrl,
      };

      print('customer data: $customerData');

      // Initial request
      final response = await http.post(
        Uri.parse('${App.apiUrl}/customer?shop_id=$shopId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(customerData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Redirect URL not found in response headers');
      }
    } catch (e) {
      print('Error creating customer: $e');
      throw Exception('Error creating customer: $e');
    }
  }

  // Create a new customer
  Future<bool> makeDuePayment({
    required int customerId,
    required int paymentAmount,
    required String description,
    required String shopId,
  }) async {
    try {
      print('Make payment is called');
      // Get token from auth service
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Create a map with the customer data
      DateTime now = DateTime.now();
      final paymentData = {
        'customer_id': customerId,
        'payment_amount': paymentAmount,
        'description': description,
        'payment_date': DateFormat('yyyy-MM-dd').format(now),
      };

      print('customer data: $paymentData');

      // Initial request
      final response = await http.post(
        Uri.parse('${App.apiUrl}/due/payment?shop_id=$shopId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error creating customer: $e');
      return false;
    }
  }

  // Helper method to handle error responses
  Exception _handleErrorResponse(int statusCode, String responseBody) {
    try {
      final errorData = jsonDecode(responseBody);
      final errorMessage =
          errorData['detail'] ??
          errorData['message'] ??
          'Failed to process customer request';
      return Exception(errorMessage);
    } catch (_) {
      return Exception('Failed to process request. Status: $statusCode');
    }
  }
}
