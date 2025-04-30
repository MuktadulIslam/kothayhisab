// lib/screens/due_payment_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:kothayhisab/data/api/services/due_account_services.dart';
import 'package:kothayhisab/data/api/services/due_payment_service.dart';
import 'package:kothayhisab/data/models/due_coustomer_model.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:intl/intl.dart';

class DuePaymentScreen extends StatefulWidget {
  final Customer customer;
  final String shopId;

  const DuePaymentScreen({
    super.key,
    required this.customer,
    required this.shopId,
  });

  @override
  _DuePaymentScreenState createState() => _DuePaymentScreenState();
}

class _DuePaymentScreenState extends State<DuePaymentScreen> {
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Grid view configuration
  final int _crossAxisCount = 2;
  final double _aspectRatio = 3.5;

  @override
  void initState() {
    super.initState();
    _loadCustomers();

    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        _searchCustomers(_searchController.text);
      } else {
        _loadCustomers();
      }
    });
  }

  // Load all customers
  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await CustomerService.getAllCustomers();

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 'success') {
      List<dynamic> data = response['data'];
      setState(() {
        _customers = data.map((item) => Customer.fromJson(item)).toList();
      });
    } else {
      setState(() {
        _errorMessage = response['message'] ?? 'তালিকা লোড করতে সমস্যা হচ্ছে';
      });
    }
  }

  // Search customers
  Future<void> _searchCustomers(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await CustomerService.searchCustomers(query);

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 'success') {
      List<dynamic> data = response['data'];
      setState(() {
        _customers = data.map((item) => Customer.fromJson(item)).toList();
      });
    } else {
      setState(() {
        _errorMessage = response['message'] ?? 'খুঁজতে সমস্যা হচ্ছে';
      });
    }
  }

  // Make payment
  Future<void> _makePayment() async {
    // Validate selection and amount
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('দয়া করে একজন গ্রাহক নির্বাচন করুন'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('দয়া করে পরিমাণ লিখুন'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সঠিক পরিমাণ লিখুন'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Process payment
    final response = await DuePaymentService.makePayment(
      _selectedCustomer!.id,
      amount,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (response['status'] == 'success') {
      // Clear the form after successful payment
      _amountController.clear();
      setState(() {
        _selectedCustomer = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('বাকি পরিশোধ সফলভাবে সম্পন্ন হয়েছে'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'বাকি পরিশোধে সমস্যা হয়েছে'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('বাকি পরিশোধ'),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'নাম বা মোবাইল নম্বর দিয়ে খুঁজুন',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00558D)),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF00558D),
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Error message if any
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red[100],
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // Customer Grid
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _customers.isEmpty
                    ? const Center(
                      child: Text(
                        'কোন গ্রাহক পাওয়া যায়নি',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 139, 133, 133),
                        ),
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _crossAxisCount,
                        childAspectRatio: _aspectRatio,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _customers.length,
                      itemBuilder: (context, index) {
                        final customer = _customers[index];
                        return _buildCustomerCard(customer);
                      },
                    ),
          ),

          // Payment form
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _selectedCustomer != null ? 230 : 0,
            child:
                _selectedCustomer != null
                    ? Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Selected customer name
                          Row(
                            children: [
                              const Text(
                                'নির্বাচিত গ্রাহক: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _selectedCustomer!.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF00558D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedCustomer = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Amount input
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'পরিশোধের পরিমাণ',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                              hintText: '০.০০',
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Payment button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _makePayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00558D),
                              ),
                              child:
                                  _isSubmitting
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        'বাকি পরিশোধ করুন',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : null,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    bool isSelected = _selectedCustomer?.id == customer.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCustomer = customer;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF00558D) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            children: [
              // Customer photo (Left side)
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFE8F5FE),
                    child:
                        customer.photoPath != null &&
                                File(customer.photoPath!).existsSync()
                            ? ClipOval(
                              child: Image.file(
                                File(customer.photoPath!),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Icon(
                              Icons.person,
                              size: 30,
                              color: Color(0xFF00558D),
                            ),
                  ),
                  if (isSelected)
                    Positioned(
                      bottom: 5,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00558D),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 2),

              // Customer info (Right side)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Customer name
                    Text(
                      customer.name,
                      // 'টাকা জমা দিয়েছে এবং টাকা ফেরত চায়',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00558D),
                        height: 1, // Added this line to reduce the line height
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Customer mobile
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color.fromARGB(255, 36, 31, 31),
                        ),
                        children: [
                          const TextSpan(
                            text: 'ঠিকানাঃ ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: '${customer.address}'),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
