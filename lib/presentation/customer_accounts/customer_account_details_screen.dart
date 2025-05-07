// lib/screens/due_accounts_screen.dart
import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/customer_account_services.dart';
import 'package:kothayhisab/data/models/customer_model.dart';
// import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';

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
  final CustomerService _customerService = CustomerService();
  final TextEditingController _paymentController = TextEditingController();

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
      _errorMessage = null;
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
      setState(() {
        _errorMessage = e.toString();
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

    try {
      // Filter customers locally based on the query
      final filteredCustomers =
          _customers.where((customer) {
            return customer.name.toLowerCase().contains(query.toLowerCase()) ||
                customer.mobile.toLowerCase().contains(query.toLowerCase());
          }).toList();

      setState(() {
        _customers = filteredCustomers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Refresh customers list
  Future<void> _refreshCustomers() async {
    return _loadCustomers();
  }

  // Handle due payment
  Future<void> _handleDuePayment(Customer customer, double amount) async {
    // TODO: Implement payment API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${customer.name} এর ৳ $amount টাকা বাকি পরিশোধ করা হয়েছে',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Reload customers list to reflect the updated due amount
    _loadCustomers();
  }

  // Show payment popup for the provided customer
  void _showPaymentPopup(Customer customer) {
    // Set initial payment amount to customer's due amount
    _paymentController.text = '${customer.totalDue.toInt()}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 16),

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
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            customer.name,
                            style: const TextStyle(
                              color: Color(0xFF005A8D),
                              fontWeight: FontWeight.bold,
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
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '৳ ${customer.totalDue.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Payment amount input field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: _paymentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'পরিশোধের পরিমাণ',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: InputBorder.none,
                    prefixText: '৳ ',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Confirm payment button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    double amount =
                        double.tryParse(_paymentController.text) ?? 0;
                    Navigator.pop(context);
                    _handleDuePayment(customer, amount);
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: const Color(0xFF00558D),
          title: const Text(
            'গ্রাহকের তালিকা',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'নাম বা মোবাইল নম্বর দিয়ে খুঁজুন',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00558D)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'গ্রাহকের তালিকা',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
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

          // Customer list
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
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              // Customer info section
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Customer icon
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE6F2F5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Color(0xFF005A8D),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Customer details
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
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Due amount
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '৳ ${customer.totalDue.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const Text(
                                          'মোট বাকী',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Action buttons row
                              Row(
                                children: [
                                  // Details button
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/shop-details/see-customer-accounts/details',
                                          arguments: {'customer': customer},
                                        );
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: Color(0xFFEEEEEE),
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Color(0xFFEEEEEE),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.list_alt_outlined,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'ডিটেইলস',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Pay due button
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _showPaymentPopup(customer),
                                      child: Container(
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: Color(0xFFEEEEEE),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.payments_outlined,
                                                size: 16,
                                                color: Color(0xFF005A8D),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'বাকী পরিশোধ',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF005A8D),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      // Floating action button for adding new customer
      floatingActionButton: Container(
        width: 160,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF00558D),
          borderRadius: BorderRadius.circular(24),
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
                  'নতুন গ্রাহক',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                    child: Icon(Icons.add, color: Color(0xFF00558D), size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _paymentController.dispose();
    super.dispose();
  }
}
