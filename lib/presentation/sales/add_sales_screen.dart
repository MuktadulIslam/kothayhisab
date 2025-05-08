import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:kothayhisab/data/api/services/sales_service.dart';
import 'package:kothayhisab/data/api/services/customer_account_services.dart';
import 'package:kothayhisab/data/models/sales_model.dart';
import 'package:kothayhisab/data/models/customer_model.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/core/utils/currency_formatter.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_date_picker.dart';
import 'package:kothayhisab/presentation/common_widgets/toast_notification.dart';

class AddSalesScreen extends StatefulWidget {
  final String shopId;
  const AddSalesScreen({super.key, required this.shopId});

  @override
  _AddSalesScreenState createState() => _AddSalesScreenState();
}

class _AddSalesScreenState extends State<AddSalesScreen> {
  // Controllers and Services
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final SalesService _salesService = SalesService();
  final CustomerService _customerService = CustomerService();
  final String _currency = '৳';
  final bool _useBengaliDigits = true;

  // State variables
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isLoadingCustomers = false;
  List<SalesItem> _parsedItems = [];
  // bool _hasError = false;
  // String _errorMessage = '';
  String _rowText = '';
  bool _productsVisible = false;
  bool _inDueSaleMode = false;
  bool _customerSelectionMode = false;
  bool _customerDataVisible = false;
  Map<String, dynamic>? _customerDueData;
  Customer? _selectedCustomer;
  List<Customer> _customers = [];

  // Grid view configuration
  final int _crossAxisCount = 2;
  final double _aspectRatio = 3.5;
  final double _customerGridHeight = 250.0;

  @override
  void initState() {
    super.initState();
    _textFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    _paymentAmountController.dispose();
    _textFocusNode.removeListener(_onFocusChange);
    _textFocusNode.dispose();
    super.dispose();
  }

  // Helper Methods
  void _onFocusChange() {
    setState(() {});
  }

  // Calculate total price of all items
  double _calculateTotalPrice() {
    return _parsedItems.fold(0.0, (total, item) => total + item.price);
  }

  // Format quantity with or without description
  String _formatQuantity(SalesItem item) {
    String quantity =
        _useBengaliDigits
            ? BdTakaFormatter.numberToBengaliDigits(item.quantity)
            : item.quantity.toString();

    if (item.quantityDescription.isNotEmpty) {
      return '$quantity ${item.quantityDescription}';
    }
    return quantity;
  }

  // Customer related methods
  Future<void> _loadCustomers() async {
    setState(() {
      _isLoadingCustomers = true;
    });

    try {
      final customerData = await _customerService.getCustomers(
        widget.shopId,
        hasDueOnly: false, // Get all customers, not just those with dues
        activeOnly: true, // Only get active customers
        skip: 0, // Start from the first record
        limit: 100, // Get up to 100 customers);
      );

      if (customerData != []) {
        setState(() {
          _customers = customerData;
        });
      } else {
        ToastNotification.error('তালিকা লোড করতে সমস্যা হচ্ছে');
      }
    } catch (e) {
      ToastNotification.error('কোনো  গ্রাহকের তালিকা পাওয়া যায়নি!');
    } finally {
      setState(() {
        _isLoadingCustomers = false;
      });
    }
  }

  Future<void> _searchCustomers(String query) async {
    // setState(() {
    //   _isLoadingCustomers = true;
    // });

    // try {
    //   final response = await CustomerService.searchCustomers(query);

    //   if (response['status'] == 'success') {
    //     List<dynamic> data = response['data'];
    //     setState(() {
    //       _customers = data.map((item) => Customer.fromJson(item)).toList();
    //     });
    //   } else {
    // ToastNotification.error('গ্রাহকের তালিকা খুঁজতে সমস্যা হচ্ছে');
    //   }
    // } catch (e) {
    //   ToastNotification.error('গ্রাহকের তালিকা খুঁজতে সমস্যা হচ্ছে');
    // } finally {
    //   setState(() {
    //     _isLoadingCustomers = false;
    //   });
    // }
  }

  // Action Methods
  void _handleVoiceButtonPressed() {
    _textFocusNode.requestFocus();

    Future.delayed(Duration(milliseconds: 100), () {
      SystemChannels.textInput.invokeMethod('TextInput.updateConfig', {
        'inputType': {
          'name': 'TextInputType.multiline',
          'signed': null,
          'decimal': null,
        },
        'inputAction': 'TextInputAction.none',
        'enableSuggestions': true,
        'enableDictation': true,
      });
    });
  }

  void _handleCancelButtonPress() {
    // Case 1: If in customer selection mode, exit this mode first
    if (_customerSelectionMode) {
      setState(() {
        _customerSelectionMode = false;
        _selectedCustomer = null;
      });
    }
    // Case 2: If in due sale mode, exit due sale mode
    else if (_inDueSaleMode) {
      setState(() {
        _inDueSaleMode = false;
        _customerDataVisible = false;
        _customerDueData = null;
        _textController.clear();
      });
    }
    // Case 3: If input field is not empty, clear it
    else if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _textController.clear();
      });
    }
    // Case 4: If table data exists, clear table
    else if (_parsedItems.isNotEmpty) {
      setState(() {
        _rowText = '';
        _parsedItems = [];
        _productsVisible = false;
      });
    }
    // Case 5: If both input and table are empty, go back
    else {
      Navigator.of(context).pop();
    }
  }

  void _removeItemAtIndex(int index) {
    setState(() {
      _parsedItems.removeAt(index);
      // Hide products section if all items are removed
      if (_parsedItems.isEmpty) {
        _productsVisible = false;
      }
    });
  }

  Future<void> _parseInventoryText() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final text = _textController.text.trim();
    if (text.isEmpty) {
      ToastNotification.error('টেক্সট লিখুন বা ভয়েস রেকর্ড করুন');
      return;
    }
    if (_rowText == '') {
      _rowText = text;
    } else {
      _rowText += '\n$text';
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _salesService.parseSalesText(text);

      setState(() {
        _parsedItems.addAll(items);
        _isLoading = false;
        _productsVisible = true;
        _textController.clear();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;

        String errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.substring('Exception: '.length);
        }

        // Format specific error messages
        if (errorMsg.contains(
          'type \'double\' is not a subtype of type \'int\'',
        )) {
          errorMsg = 'ফরম্যাট সমস্যা: সংখ্যা প্রসেসিং এ ত্রুটি।';
        } else if (errorMsg.contains('No authentication token found')) {
          errorMsg = 'অনুগ্রহ করে আবার লগইন করুন।';
        } else if (errorMsg.contains('Server could not parse')) {
          errorMsg =
              'মজুদ টেক্সট পার্স করা সম্ভব হয়নি। অন্য ফরম্যাটে চেষ্টা করুন।';
        }
        ToastNotification.error(errorMsg);
      });
    }
  }

  Future<void> _cashSale() async {
    if (_parsedItems.isEmpty) {
      ToastNotification.error('কোন পণ্য যোগ করা হয়নি');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await _salesService.confirmSales(
        widget.shopId,
        _parsedItems,
        _rowText,
        _calculateTotalPrice(),
        _currency,
      );

      if (result) {
        ToastNotification.success('বিক্রয় সফলভাবে সংরক্ষিত হয়েছে');

        // Reset the state
        setState(() {
          _textController.clear();
          _parsedItems = [];
          _productsVisible = false;
        });
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring('Exception: '.length);
      }
      ToastNotification.error(errorMsg);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _dueSale() async {
    setState(() {
      _customerSelectionMode = true;
      _inDueSaleMode = true;
    });

    // Load customers
    _loadCustomers();

    // Set up search listener
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        _searchCustomers(_searchController.text);
      } else {
        _loadCustomers();
      }
    });
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _customerSelectionMode = false;
      _customerDataVisible = true;

      // Create customer due data
      _customerDueData = {
        'customer_id': customer.id,
        'customer_name': customer.name,
        'total_amount': _calculateTotalPrice(),
        'paid_amount': double.tryParse(_paymentAmountController.text) ?? 0,
        'due_amount':
            _calculateTotalPrice() -
            (double.tryParse(_paymentAmountController.text) ?? 0),
      };
    });
  }

  Future<void> _completeDueSale() async {
    if (_parsedItems.isEmpty) {
      ToastNotification.error('কোন পণ্য যোগ করা হয়নি');
      return;
    }

    if (_selectedCustomer == null) {
      ToastNotification.error('গ্রাহক নির্বাচন করুন');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      double paidAmount = double.tryParse(_paymentAmountController.text) ?? 0;
      double totalAmount = _calculateTotalPrice();
      double dueAmount = totalAmount - paidAmount;

      final result = await _salesService.confirmDueSale(
        shopId: int.parse(widget.shopId),
        items: _parsedItems,
        rawText: _rowText,
        totalAmount: totalAmount,
        currency: _currency,
        customerId: _selectedCustomer!.id ?? 0,
        paidAmount: paidAmount,
        dueAmount: dueAmount,
        description:
            "${_selectedCustomer!.name} ${_paymentAmountController.text} টাকা জমা দিয়েছে",
      );

      if (result) {
        ToastNotification.success('বাকিতে বিক্রয় সফলভাবে সংরক্ষিত হয়েছে');
        // Reset the state
        setState(() {
          _textController.clear();
          _paymentAmountController.text = '';
          _parsedItems = [];
          _productsVisible = false;
          _inDueSaleMode = false;
          _customerSelectionMode = false;
          _customerDataVisible = false;
          _customerDueData = null;
          _selectedCustomer = null;
        });
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring('Exception: '.length);
      }
      ToastNotification.error(errorMsg);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _updatePaidAmount(String value) {
    if (_customerDueData != null) {
      double paidAmount = double.tryParse(value) ?? 0;
      setState(() {
        _customerDueData!['paid_amount'] = paidAmount;
        _customerDueData!['due_amount'] = _calculateTotalPrice() - paidAmount;
      });
    }
  }

  void _showAddNewCustomerDialog() {
    ToastNotification.info('নতুন গ্রাহক যোগ করার ফিচার বাস্তবায়ন প্রয়োজন');
  }

  // UI Building Methods
  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _textController,
          focusNode: _textFocusNode,
          decoration: InputDecoration(
            hintText:
                _inDueSaleMode
                    ? 'এখানে লিখুন (উদাহরণঃ করিম ১০০০ টাকা জমা দিয়েছে)'
                    : 'এখানে লিখুন (উদাহরণঃ ৫ কেজি আলু ২২৫ টাকা)',
            contentPadding: EdgeInsets.all(16),
            border: InputBorder.none,
          ),
          maxLines: 4,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _parseInventoryText();
            }
          },
        ),
      ),
    );
  }

  Widget _buildCustomerSelectionSection(viewInsets, isKeyboardOpen) {
    if (!_customerSelectionMode) return SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'মোট মূল্যঃ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '$_currency ${BdTakaFormatter.format(_calculateTotalPrice(), toBengaliDigits: _useBengaliDigits)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Amount entry at top
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _paymentAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'জমার পরিমাণ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.attach_money, color: Color(0xFF00558D)),
              hintText: '০',
            ),
          ),
        ),

        // Row with search bar and add button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              // Search bar
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'গ্রাহক খুঁজুন',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF00558D),
                      ),
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
              ),

              // Add new button
              SizedBox(width: 10),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF00558D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.person_add, color: Colors.white),
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
                ),
              ),
            ],
          ),
        ),

        // Customer Grid with expanded height
        Expanded(
          child:
              _isLoadingCustomers
                  ? Center(child: CircularProgressIndicator())
                  : _customers.isEmpty
                  ? Center(
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
                      return _buildCustomerCard(_customers[index]);
                    },
                  ),
        ),

        // Action buttons at bottom
        Padding(
          padding: EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            top: 8.0,
            bottom: isKeyboardOpen ? viewInsets.bottom : 16.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _handleCancelButtonPress,
                  child: Text('বাতিল'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF005A8D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed:
                      _selectedCustomer != null ? _completeDueSale : null,
                  child: Opacity(
                    opacity: _selectedCustomer != null ? 1.0 : 0.5,
                    child:
                        _isSaving
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text('বাকিতে বিক্রয় করুন'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return GestureDetector(
      onTap: () => _selectCustomer(customer),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              // Customer photo (Left side)
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFE8F5FE),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Color(0xFF00558D),
                    ),
                  ),
                ],
              ),

              // Customer info (Right side)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Customer name
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00558D),
                          height: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 15,
                            color: Colors.black54,
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: customer.address,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTotalPriceSection() {
    final widgets = <Widget>[];
    const fontSize = 14.0;

    // Customer due data section (if visible)
    if (_productsVisible && _parsedItems.isNotEmpty) {
      if (_customerDataVisible &&
          _customerDueData != null &&
          _selectedCustomer != null) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'গ্রাহকের নামঃ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        _selectedCustomer!.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'মোট মূল্যঃ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '৳ ${BdTakaFormatter.format(_customerDueData!['total_amount'] ?? 0, toBengaliDigits: _useBengaliDigits)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'জমাঃ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '৳ ${BdTakaFormatter.format(_customerDueData!['paid_amount'] ?? 0, toBengaliDigits: _useBengaliDigits)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: const Color.fromARGB(255, 0, 121, 93),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'বাকিঃ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '৳ ${BdTakaFormatter.format(_customerDueData!['due_amount'] ?? 0, toBengaliDigits: _useBengaliDigits)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: const Color.fromARGB(255, 0, 121, 93),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      } else if (!_customerSelectionMode) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'মোট মূল্যঃ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                      Text(
                        '$_currency ${BdTakaFormatter.format(_calculateTotalPrice(), toBengaliDigits: _useBengaliDigits)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildItemsTable() {
    if (!_productsVisible || _parsedItems.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Table header
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'নাম',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'পরিমাণ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'মূল্য',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(width: 40), // Space for delete button
              ],
            ),
          ),

          // Table rows
          ...List.generate(_parsedItems.length, (index) {
            final item = _parsedItems[index];
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(item.name),
                    ),
                  ),
                  Expanded(child: Text(_formatQuantity(item))),
                  Expanded(
                    child: Text(
                      '$_currency ${BdTakaFormatter.format(item.price, toBengaliDigits: _useBengaliDigits)}',
                      textAlign: TextAlign.right,
                    ),
                  ),
                  // Delete button
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => _removeItemAtIndex(index),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _saleActionButton() {
    final widgets = <Widget>[];

    if (_textController.text.trim().isEmpty &&
        !_textFocusNode.hasFocus &&
        _productsVisible &&
        _parsedItems.isNotEmpty &&
        !_customerDataVisible) {
      widgets.add(
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 237, 68, 68),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _isLoading || _isSaving ? null : _dueSale,
            child: Text('বাকিতে বিক্রয়'),
          ),
        ),
      );

      widgets.add(SizedBox(width: 10));
    }

    if (_textController.text.trim().isNotEmpty || _textFocusNode.hasFocus) {
      widgets.add(
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF005A8D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _parseInventoryText,
            child:
                _isLoading || _isSaving
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text('পণ্য দেখুন'),
          ),
        ),
      );
    } else if (!_customerDataVisible) {
      widgets.add(
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF005A8D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _isLoading || _isSaving ? null : _cashSale,
            child:
                _isLoading || _isSaving
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text('নগদ বিক্রয়'),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _dueActionButton() {
    if (_customerDataVisible &&
        _parsedItems.isNotEmpty &&
        _selectedCustomer != null &&
        !_textFocusNode.hasFocus) {
      // Show "বাকিতে বিক্রয় করুন" after customer data is fetched and products are added
      return Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF005A8D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: _isLoading || _isSaving ? null : _completeDueSale,
          child:
              _isLoading || _isSaving
                  ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Text('বাকিতে বিক্রয় করুন'),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  List<Widget> _buildActionButtons() {
    final cancelButton = Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: _isLoading || _isSaving ? null : _handleCancelButtonPress,
        child: Text('বাতিল'),
      ),
    );

    if (_customerSelectionMode) {
      // In customer selection mode, show cancel and "বাকিতে বিক্রয় করুন" buttons
      return [
        cancelButton,
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF005A8D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _selectedCustomer != null ? _completeDueSale : null,
            child: Text('বাকিতে বিক্রয় করুন'),
          ),
        ),
      ];
    } else if (_customerDataVisible && _selectedCustomer != null) {
      return [cancelButton, SizedBox(width: 10), _dueActionButton()];
    } else {
      return [cancelButton, SizedBox(width: 10), ..._saleActionButton()];
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardOpen = viewInsets.bottom > 0;

    // If we're in customer selection mode, show a different layout
    if (_customerSelectionMode) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar('বাকিতে বিক্রয়'),
        body: SafeArea(
          child: _buildCustomerSelectionSection(viewInsets, isKeyboardOpen),
        ),
        bottomNavigationBar: CustomBottomAppBar(),
      );
    }

    // Normal sales mode layout
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar('বিক্রয় করুন'),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 10, right: 10),
                child: CustomDatePicker(
                  onDateSelected: (DateTime selectedDate) {
                    // Handle the selected date
                    print('Date selected: $selectedDate');
                  },
                ),
              ),

              // Hide input section if a customer is selected for due sale
              if (!(_inDueSaleMode && _customerDataVisible))
                _buildInputSection(),

              // Scrollable middle section
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      ..._buildTotalPriceSection(),
                      _buildItemsTable(),
                    ],
                  ),
                ),
              ),

              // Action buttons at bottom
              Padding(
                padding: EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  top: 8.0,
                  bottom:
                      isKeyboardOpen
                          ? viewInsets.bottom
                          : 16.0, // Adjust for keyboard
                ),
                child: Row(children: [..._buildActionButtons()]),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
