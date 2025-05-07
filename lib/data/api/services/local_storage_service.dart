// // lib/data/api/services/local_storage_service.dart
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:kothayhisab/data/models/due_coustomer_model.dart';

// class LocalStorageService {
//   static const String CUSTOMERS_KEY = 'customers_list';

//   // Get all customers from local storage
//   static Future<List<Customer>> getAllCustomers() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? customersString = prefs.getString(CUSTOMERS_KEY);

//     if (customersString == null || customersString.isEmpty) {
//       return [];
//     }

//     try {
//       return Customer.decodeCustomers(customersString);
//     } catch (e) {
//       // If there is an error in parsing, return empty list
//       return [];
//     }
//   }

//   // Save all customers to local storage
//   static Future<bool> saveAllCustomers(List<Customer> customers) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String encodedData = Customer.encodeCustomers(customers);
//     return await prefs.setString(CUSTOMERS_KEY, encodedData);
//   }

//   // Add a new customer
//   static Future<bool> addCustomer(Customer customer) async {
//     List<Customer> customers = await getAllCustomers();

//     // Check if customer with this mobile number already exists
//     bool exists = customers.any((c) => c.mobileNumber == customer.mobileNumber);
//     if (exists) {
//       return false;
//     }

//     customers.add(customer);
//     return await saveAllCustomers(customers);
//   }

//   // Delete customer by id
//   static Future<bool> deleteCustomer(String id) async {
//     List<Customer> customers = await getAllCustomers();
//     customers.removeWhere((customer) => customer.id == id);
//     return await saveAllCustomers(customers);
//   }

//   // Get customer by id
//   static Future<Customer?> getCustomerById(String id) async {
//     List<Customer> customers = await getAllCustomers();
//     try {
//       return customers.firstWhere((customer) => customer.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   // Search customers by name or mobile number
//   static Future<List<Customer>> searchCustomers(String query) async {
//     if (query.isEmpty) {
//       return await getAllCustomers();
//     }

//     List<Customer> customers = await getAllCustomers();
//     String lowercaseQuery = query.toLowerCase();

//     return customers.where((customer) {
//       return customer.name.toLowerCase().contains(lowercaseQuery) ||
//           customer.mobileNumber.contains(query);
//     }).toList();
//   }
// }
