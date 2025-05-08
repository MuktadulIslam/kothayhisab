// lib/screens/due_accounts_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:kothayhisab/core/utils/currency_formatter.dart';
import 'package:kothayhisab/data/api/services/customer_account_services.dart';
import 'package:kothayhisab/data/models/customer_model.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/toast_notification.dart';

class CustomerAccountsScreen extends StatefulWidget {
  final String shopId;
  const CustomerAccountsScreen({super.key, required this.shopId});

  @override
  _CustomerAccountsScreenState createState() => _CustomerAccountsScreenState();
}

class _CustomerAccountsScreenState extends State<CustomerAccountsScreen> {
  bool _isLoading = false;
  List<Customer> _customers = [];
  final TextEditingController _searchController = TextEditingController();
  final CustomerService _customerService = CustomerService();
  final _useBengaliDigits = true;

  @override
  void initState() {
    super.initState();
    // Load customers when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomers();
    });

    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        _searchCustomers(_searchController.text);
      } else {
        _loadCustomers();
      }
    });
  }

  // Load customers data from API
  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the updated API endpoint with dues information
      final customers = await _customerService.getCustomers(
        widget.shopId,
        hasDueOnly: false, // Get all customers, not just those with dues
        activeOnly: true, // Only get active customers
        skip: 0, // Start from the first record
        limit: 100, // Get up to 100 customers
      );

      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      ToastNotification.error(
        'সার্ভারে কাস্টমের লিস্টে একটি অপ্রত্যাশিত ত্রুটি ঘটেছে!',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchCustomers(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all customers first using the updated API
      final customers = await _customerService.getCustomers(
        widget.shopId,
        hasDueOnly: false,
        activeOnly: true,
        skip: 0,
        limit: 100,
      );

      // Filter customers locally based on the query
      final filteredCustomers =
          customers.where((customer) {
            return customer.name.toLowerCase().contains(query.toLowerCase()) ||
                customer.mobile.toLowerCase().contains(query.toLowerCase());
          }).toList();

      setState(() {
        _customers = filteredCustomers;
        _isLoading = false;
      });
    } catch (e) {
      ToastNotification.error(
        'অ্যাপে একটি অপ্রত্যাশিত ত্রুটি ঘটেছে। দয়া করে আবার চেষ্টা করুন।',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Refresh customers list
  Future<void> _refreshCustomers() async {
    return _loadCustomers();
  }

  Future<void> _handleDuePayment(Customer customer, int amount) async {
    try {
      // Call the makeDuePayment service
      bool result = await _customerService.makeDuePayment(
        customerId: customer.id ?? 0,
        paymentAmount: amount,
        description: 'Due payment by ${customer.name}',
        shopId: widget.shopId,
      );

      if (result) {
        ToastNotification.success(
          '"${customer.name}" এর ${amount} টাকা বাকী পরিশোধ সফল হয়েছে',
        );
      } else {
        ToastNotification.error('বাকী পরিশোধ ব্যর্থ হয়েছে');
      }
      // Reload customers list to reflect the updated due amount
      await _loadCustomers();
    } catch (e) {
      // Check if the widget is still mounted before using context
      if (!mounted) return;

      ToastNotification.error(
        'অ্যাপে একটি অপ্রত্যাশিত ত্রুটি ঘটেছে। দয়া করে আবার বাকী পরিশোধ করুন।',
      );
    }
  }

  // Show payment popup for the provided customer
  void _showPaymentPopup(Customer customer) {
    final TextEditingController paymentController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    // Make sure to use showModalBottomSheet correctly
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This is important
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        // Make sure to accept context parameter
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Important to make it wrap content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'বাকী পরিশোধ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              // Rest of your bottom sheet content...
              // Customer name and due amount row
              Row(
                children: [
                  // Selected customer
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'নির্বাচিত গ্রাহক:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 118, 118, 118),
                            ),
                          ),
                          Text(
                            customer.name,
                            style: const TextStyle(
                              color: Color(0xFF005A8D),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Current due amount
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'অবশিষ্ট বাকী:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 118, 118, 118),
                            ),
                          ),
                          Text(
                            '৳ ${BdTakaFormatter.format(customer.totalDue, toBengaliDigits: _useBengaliDigits)}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Form(
                // Add Form widget here
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: paymentController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          labelText: 'পরিশোধের পরিমাণ',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: InputBorder.none,
                          prefixText: '৳ ',
                          hintText: '0',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'পরিশোধের পরিমাণ দিন';
                          }
                          // Check if it's a valid number
                          if (double.tryParse(value) == null) {
                            return 'সঠিক সংখ্যা দিন';
                          }
                          return null;
                        },
                        // Add this onFieldSubmitted handler
                        onFieldSubmitted: (value) {
                          // Validate the form and submit if valid
                          if (_formKey.currentState!.validate()) {
                            int amount =
                                int.tryParse(paymentController.text) ?? 0;
                            Navigator.pop(context);
                            _handleDuePayment(customer, amount);
                          }
                        },
                        // Add TextInputAction.done to show proper keyboard action
                        textInputAction: TextInputAction.done,
                      ),

                      // To see bangla number in the input
                      // TextFormField(
                      //   controller: paymentController,
                      //   keyboardType: TextInputType.number,
                      //   decoration: InputDecoration(
                      //     filled: true,
                      //     fillColor: Colors.grey[100],
                      //     labelText: 'পরিশোধের পরিমাণ',
                      //     contentPadding: const EdgeInsets.symmetric(
                      //       horizontal: 16,
                      //       vertical: 16,
                      //     ),
                      //     border: InputBorder.none,
                      //     prefixText: '৳ ',
                      //     hintText: _useBengaliDigits ? '০' : '0',
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'পরিশোধের পরিমাণ দিন';
                      //     }
                      //     // Convert Bengali digits to English digits for validation
                      //     String englishValue = BdTakaFormatter.toBengaliDigits(
                      //       value,
                      //     );
                      //     // Check if it's a valid number
                      //     if (double.tryParse(englishValue) == null) {
                      //       return 'সঠিক সংখ্যা দিন';
                      //     }
                      //     return null;
                      //   },
                      //   onChanged: (value) {
                      //     if (_useBengaliDigits && value.isNotEmpty) {
                      //       // Save cursor position
                      //       int cursorPos = paymentController.selection.start;

                      //       // Convert to Bengali digits
                      //       String bengaliText =
                      //           BdTakaFormatter.toBengaliDigits(value);

                      //       // Only update if the text actually changed
                      //       if (bengaliText != value) {
                      //         paymentController.text = bengaliText;

                      //         // Restore cursor position, adjusted for any length change
                      //         int newCursorPos =
                      //             cursorPos +
                      //             (bengaliText.length - value.length);
                      //         if (newCursorPos >= 0 &&
                      //             newCursorPos <= bengaliText.length) {
                      //           paymentController
                      //               .selection = TextSelection.fromPosition(
                      //             TextPosition(offset: newCursorPos),
                      //           );
                      //         }
                      //       }
                      //     }
                      //   },
                      //   onFieldSubmitted: (value) {
                      //     // Validate the form and submit if valid
                      //     if (_formKey.currentState!.validate()) {
                      //       // Convert Bengali digits to English digits for processing
                      //       String englishValue =
                      //           BdTakaFormatter.toBengaliDigits(value);
                      //       int amount = int.tryParse(englishValue) ?? 0;
                      //       Navigator.pop(context);
                      //       _handleDuePayment(customer, amount);
                      //     }
                      //   },
                      //   textInputAction: TextInputAction.done,
                      // ),
                    ),

                    const SizedBox(height: 20),

                    // Confirm payment button - Modified to validate the form
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate the form first
                          if (_formKey.currentState!.validate()) {
                            int amount =
                                int.tryParse(paymentController.text) ?? 0;
                            Navigator.pop(context);
                            _handleDuePayment(customer, amount);
                          }
                          // If validation fails, error messages will show automatically
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005A8D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'বাকী পরিশোধ করুন',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('গ্রাহকের তালিকা'),
      body: RefreshIndicator(
        onRefresh: _refreshCustomers,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'নাম বা মোবাইল নম্বর দিয়ে খুঁজুন',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Customer list header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Text(
                'গ্রাহকের তালিকা',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),

            // Customer List
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _customers.isEmpty
                      ? const Center(
                        child: Text(
                          'কোন গ্রাহক নেই',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _customers.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final customer = _customers[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Customer Info
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      // Customer Avatar
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            205,
                                            237,
                                            255,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: Color(0xFF005A8D),
                                          size: 35,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Customer Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customer.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              customer.mobile,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color.fromARGB(
                                                  255,
                                                  111,
                                                  111,
                                                  111,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Due Amount
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '৳ ${BdTakaFormatter.format(customer.totalDue, toBengaliDigits: _useBengaliDigits)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          const Text(
                                            'মোট বাকী',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color.fromARGB(
                                                255,
                                                111,
                                                111,
                                                111,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Action Buttons
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      // Details Button
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            // Navigator.pushNamed(
                                            //   context,
                                            //   '/shop-details/see-due-accounts/details',
                                            //   arguments: {'customer': customer},
                                            // );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: const Color.fromARGB(
                                                  255,
                                                  173,
                                                  173,
                                                  173,
                                                ),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.list_alt,
                                                  size: 20,
                                                  color: Colors.grey.shade800,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'ডিটেইলস',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Gap between buttons
                                      const SizedBox(width: 10),

                                      // Pay Due Button
                                      Expanded(
                                        child: InkWell(
                                          onTap:
                                              () => _showPaymentPopup(customer),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0078D4),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.payments_outlined,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'বাকী পরিশোধ',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 40,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/shop-details/add-customer-accounts',
              arguments: {'shopId': widget.shopId},
            ).then((value) {
              if (value == true) {
                _loadCustomers();
              }
            });
          },
          backgroundColor: const Color(0xFF005A8D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Color(0xFF005A8D), size: 18),
          ),
          label: const Text(
            'নতুন গ্রাহক',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
