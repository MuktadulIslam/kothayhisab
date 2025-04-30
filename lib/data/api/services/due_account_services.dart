// lib/data/api/services/customer_service.dart
import 'dart:math';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';
import 'package:kothayhisab/data/models/due_coustomer_model.dart';
import 'package:kothayhisab/data/api/services/local_storage_service.dart';

class CustomerService {
  static final _uuid = Uuid();

  // Add a new customer with 1 second delay
  static Future<Map<String, dynamic>> addCustomer(
    String name,
    String mobileNumber,
    String address,
    String? photoPath,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Create a new customer object
      final customer = Customer(
        id: _uuid.v4(),
        name: name,
        mobileNumber: mobileNumber,
        address: address,
        photoPath: photoPath,
        createdAt: DateTime.now(),
      );

      // Save to local storage
      final success = await LocalStorageService.addCustomer(customer);

      if (success) {
        return {'status': 'success', 'data': customer.toJson()};
      } else {
        return {
          'status': 'error',
          'message': 'এই মোবাইল নাম্বারের গ্রাহক ইতিমধ্যে রেজিস্টার করা হয়েছে',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message':
            'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে! কিছুক্ষণ পর আবার চেষ্টা করুন।',
      };
    }
  }

  // Get all customers
  static Future<Map<String, dynamic>> getAllCustomers() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final customers = await LocalStorageService.getAllCustomers();

      return {
        'status': 'success',
        'data': customers.map((customer) => customer.toJson()).toList(),
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'গ্রাহকের তালিকা আনতে সমস্যা হচ্ছে',
      };
    }
  }

  // Delete a customer
  static Future<Map<String, dynamic>> deleteCustomer(String id) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final success = await LocalStorageService.deleteCustomer(id);

      if (success) {
        return {
          'status': 'success',
          'message': 'গ্রাহক সফলভাবে মুছে ফেলা হয়েছে',
        };
      } else {
        return {'status': 'error', 'message': 'গ্রাহক মুছতে সমস্যা হচ্ছে'};
      }
    } catch (e) {
      return {
        'status': 'error',
        'message':
            'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে! কিছুক্ষণ পর আবার চেষ্টা করুন।',
      };
    }
  }

  // Get customer details
  static Future<Map<String, dynamic>> getCustomerDetails(String id) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final customer = await LocalStorageService.getCustomerById(id);

      if (customer != null) {
        return {'status': 'success', 'data': customer.toJson()};
      } else {
        return {'status': 'error', 'message': 'গ্রাহক খুঁজে পাওয়া যায়নি'};
      }
    } catch (e) {
      return {
        'status': 'error',
        'message':
            'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে! কিছুক্ষণ পর আবার চেষ্টা করুন।',
      };
    }
  }

  // Search customers
  static Future<Map<String, dynamic>> searchCustomers(String query) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final customers = await LocalStorageService.searchCustomers(query);

      return {
        'status': 'success',
        'data': customers.map((customer) => customer.toJson()).toList(),
      };
    } catch (e) {
      return {'status': 'error', 'message': 'গ্রাহক খুঁজতে সমস্যা হচ্ছে'};
    }
  }
}
