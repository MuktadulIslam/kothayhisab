// lib/data/models/due_coustomer_model.dart
import 'dart:convert';

class Customer {
  final String id;
  final String name;
  final String mobileNumber;
  final String address;
  final String? photoPath;
  final double? dueAmount;
  final DateTime createdAt;
  final DateTime? lastPaymentDate;

  Customer({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.address,
    this.photoPath,
    this.dueAmount,
    required this.createdAt,
    this.lastPaymentDate,
  });

  // Convert Customer instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'address': address,
      'photoPath': photoPath,
      'dueAmount': dueAmount,
      'createdAt': createdAt.toIso8601String(),
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
    };
  }

  // Create Customer instance from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      mobileNumber: json['mobileNumber'],
      address: json['address'],
      photoPath: json['photoPath'],
      dueAmount:
          json['dueAmount'] != null
              ? double.parse(json['dueAmount'].toString())
              : null,
      createdAt: DateTime.parse(json['createdAt']),
      lastPaymentDate:
          json['lastPaymentDate'] != null
              ? DateTime.parse(json['lastPaymentDate'])
              : null,
    );
  }

  // For list serialization
  static String encodeCustomers(List<Customer> customers) {
    return jsonEncode(
      customers
          .map<Map<String, dynamic>>((customer) => customer.toJson())
          .toList(),
    );
  }

  // For list deserialization
  static List<Customer> decodeCustomers(String customersString) {
    List<dynamic> customersJson = jsonDecode(customersString);
    return customersJson
        .map<Customer>((json) => Customer.fromJson(json))
        .toList();
  }
}
