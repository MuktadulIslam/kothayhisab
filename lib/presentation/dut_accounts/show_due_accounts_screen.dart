// lib/screens/due_accounts_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:kothayhisab/data/api/services/due_account_services.dart';
import 'package:kothayhisab/data/models/due_coustomer_model.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
// import 'package:your_app_name/core/constants/app_routes.dart';

class DueAccountsScreen extends StatefulWidget {
  final String shopId;
  const DueAccountsScreen({super.key, required this.shopId});

  @override
  _DueAccountsScreenState createState() => _DueAccountsScreenState();
}

class _DueAccountsScreenState extends State<DueAccountsScreen> {
  bool _isLoading = false;
  List<Customer> _customers = [];
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

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

  // Load customers data from local storage
  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await CustomerService.getAllCustomers();

    if (response['status'] == 'success') {
      List<dynamic> data = response['data'];
      setState(() {
        _customers = data.map((item) => Customer.fromJson(item)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response['message'];
        _isLoading = false;
      });
    }
  }

  // Search customers by name or mobile number
  Future<void> _searchCustomers(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await CustomerService.searchCustomers(query);

    if (response['status'] == 'success') {
      List<dynamic> data = response['data'];
      setState(() {
        _customers = data.map((item) => Customer.fromJson(item)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response['message'];
        _isLoading = false;
      });
    }
  }

  // Refresh customers list
  Future<void> _refreshCustomers() async {
    return _loadCustomers();
  }

  // Navigate to make due payment screen
  void _navigateToMakePayment(Customer customer) {
    Navigator.pushNamed(
      context,
      '/shop-details/make-due-payment',
      arguments: {'shopId': widget.shopId, 'customer': customer},
    ).then((value) {
      // Refresh list when returning from payment screen
      if (value == true) {
        _loadCustomers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('গ্রাহকের তালিকা'),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
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

          // Customer list using ListView.builder
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshCustomers,
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _customers.isEmpty
                      ? const Center(
                        child: Text(
                          'কোন গ্রাহক নেই',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 139, 133, 133),
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _customers.length,
                        padding: const EdgeInsets.only(top: 8),
                        itemBuilder: (context, index) {
                          final customer = _customers[index];
                          return InkWell(
                            onTap: () {
                              // Navigate to customer details
                              Navigator.pushNamed(
                                context,
                                '/shop-details/see-due-accounts/details',
                                arguments: {'customer': customer},
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
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
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFE8F5FE),
                                      child:
                                          customer.photoPath != null &&
                                                  File(
                                                    customer.photoPath!,
                                                  ).existsSync()
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
                                                size: 24,
                                                color: Color(0xFF00558D),
                                              ),
                                    ),
                                    title: Text(
                                      customer.name,
                                      style: const TextStyle(
                                        color: Color(0xFF00558D),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'মোবাইল নাম্বারঃ ',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: customer.mobileNumber,
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'মোট বাকিঃ ',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    '${customer.dueAmount ?? 0} টাকা',
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Due Payment Button
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      bottom: 12,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 36,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            () => _navigateToMakePayment(
                                              customer,
                                            ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF00558D,
                                          ),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        icon: const Icon(
                                          Icons.payment,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'বাকি পরিশোধ করুন',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),

          // Add New Customer button at the bottom
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Center(
              child: Container(
                height: 48,
                width: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF00558D),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.blue.shade300, width: 1),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/shop-details/add-due-accounts',
                      arguments: {'shopId': widget.shopId},
                    ).then((value) {
                      if (value == true) {
                        _loadCustomers();
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'গ্রাহক যোগ করুন',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              color: Color(0xFF00558D),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
