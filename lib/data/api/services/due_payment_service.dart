// lib/data/api/services/due_payment_service.dart
import 'dart:math';

class DuePaymentService {
  // Process a due payment for a customer
  static Future<Map<String, dynamic>> makePayment(
    String customerId,
    double amount,
  ) async {
    try {
      // Simulate network delay (2-3 seconds)
      final randomDelay = Random().nextInt(1000) + 2000;
      await Future.delayed(Duration(milliseconds: randomDelay));

      // In a real app, you would make an API call here
      // For now we'll just return success with a 95% chance
      final bool isSuccessful = Random().nextDouble() > 0.05;

      if (isSuccessful) {
        return {
          'status': 'success',
          'message': 'বাকি পরিশোধ সফলভাবে সম্পন্ন হয়েছে',
          'data': {
            'customerId': customerId,
            'amount': amount,
            'transactionId': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
            'timestamp': DateTime.now().toIso8601String(),
          },
        };
      } else {
        // Simulate occasional payment failures
        return {
          'status': 'error',
          'message':
              'পেমেন্ট প্রক্রিয়াকরণে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
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

  // Get payment history for a customer (we're not storing anything but this could be used later)
  static Future<Map<String, dynamic>> getPaymentHistory(
    String customerId,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Return empty history since we're not storing anything
      return {'status': 'success', 'data': []};
    } catch (e) {
      return {
        'status': 'error',
        'message': 'পেমেন্ট ইতিহাস লোড করতে সমস্যা হচ্ছে',
      };
    }
  }
}
