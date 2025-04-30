// lib/services/employee_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kothayhisab/config/app_config.dart';
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/data/models/employee_model.dart';

class EmployeeService {
  // Fetch all employees for a shop
  static Future<Map<String, dynamic>> getEmployees(String shopId) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
          'data': <Employee>[],
        };
      }

      final response = await http.get(
        Uri.parse('${App.backendUrl}/shops/$shopId/employees'),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (kDebugMode) {
        print('Get Employees Status code: ${response.statusCode}');
        print('Get Employees Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        final EmployeeListResponse employeeResponse =
            EmployeeListResponse.fromJson(jsonData);

        return {
          'success': true,
          'message': 'Employees fetched successfully',
          'data': employeeResponse.employees,
        };
      } else {
        Map<String, dynamic> errorData;
        try {
          errorData = jsonDecode(utf8.decode(response.bodyBytes));
        } catch (e) {
          errorData = {'message': 'Failed to fetch employees'};
        }

        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch employees',
          'status_code': response.statusCode,
          'data': <Employee>[],
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get employees error: $e');
      }
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': <Employee>[],
      };
    }
  }

  // Add a new employee to a shop
  static Future<Map<String, dynamic>> addEmployee(
    String shopId,
    String mobileNumber,
    String memberRole,
  ) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'Authentication token not found'};
      }

      final requestBody = {
        'mobile_number': mobileNumber,
        'member_role': memberRole,
      };

      final response = await http.post(
        Uri.parse('${App.backendUrl}/shops/$shopId/employees'),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (kDebugMode) {
        print('Add Employee Status code: ${response.statusCode}');
        print('Add Employee Response body: ${response.body}');
      }

      // Try to parse response body
      Map<String, dynamic> responseData = {};
      try {
        if (response.body.isNotEmpty) {
          responseData = jsonDecode(utf8.decode(response.bodyBytes));
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing response: $e');
        }
      }

      // Handle different status codes
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Employee added successfully',
          'data': responseData['data'],
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'User with this mobile number does not exist',
          'status_code': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to add employee',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Add employee error: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Update the deleteEmployee method in EmployeeService
  static Future<Map<String, dynamic>> deleteEmployee(
    String shopId,
    String employeeId,
  ) async {
    try {
      print('Hello World1');
      final token = await AuthService.getToken();
      print('Hello World2');

      if (token == null) {
        return {'success': false, 'message': 'Authentication token not found'};
      }

      // Ensure we're using the correct URL format
      final url = '${App.backendUrl}/shops/$shopId/employees/$employeeId';
      print('Making DELETE request to: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (kDebugMode) {
        print('Delete Employee Status code: ${response.statusCode}');
        print('Delete Employee Response body: ${response.body}');
      }

      // Handle 204 No Content response (successful deletion)
      if (response.statusCode == 204 || response.statusCode == 200) {
        return {
          'success': true,
          'message':
              'কর্মচারী সফলভাবে অপসারণ করা হয়েছে', // Employee removed successfully in Bengali
        };
      } else {
        Map<String, dynamic> errorData = {
          'message': 'Failed to remove employee',
        };

        // Try to parse error response if available
        try {
          if (response.body.isNotEmpty) {
            errorData = jsonDecode(utf8.decode(response.bodyBytes));
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing response: $e');
          }
        }

        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to remove employee',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Delete employee error: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
