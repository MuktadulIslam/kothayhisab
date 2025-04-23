import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/sales_service.dart';
import 'package:kothayhisab/data/models/sales_model.dart';

import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/core/utils/currency_formatter.dart';

class DueSalesScreen extends StatefulWidget {
  final String shopId;
  final List<SalesItem> products;
  final double totalAmount;

  const DueSalesScreen({
    super.key,
    required this.shopId,
    required this.products,
    required this.totalAmount,
  });

  @override
  _DueSalesScreenState createState() => _DueSalesScreenState();
}

class _DueSalesScreenState extends State<DueSalesScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dueAmountController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final SalesService _salesService = SalesService();

  bool _useBengaliDigits = true;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  double _dueAmount = 0.0;
  double _paidAmount = 0.0;

  // Helper method to convert Bengali digits to English digits
  String bengaliToEnglishDigits(String bengaliNumber) {
    // StringBuffer result = StringBuffer();
    // for (int i = 0; i < bengaliNumber.length; i++) {
    //   String char = bengaliNumber[i];
    //   // Check if the character is a Bengali digit
    //   // int bengaliIndex = BdTakaFormatter._bengaliDigits.indexOf(char);
    //   int bengaliIndex = char;
    //   if (bengaliIndex != -1) {
    //     // Convert to English digit
    //     result.write(bengaliIndex.toString());
    //   } else {
    //     // Keep non-digit characters as is
    //     result.write(char);
    //   }
    // }
    // return result.toString();
    return bengaliNumber;
  }

  @override
  void initState() {
    super.initState();
    // Initialize due amount with total amount
    _dueAmount = widget.totalAmount;
    _dueAmountController.text = BdTakaFormatter.format(
      _dueAmount,
      toBengaliDigits: _useBengaliDigits,
      // showSymbol: false,
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dueAmountController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Update due amount when paid amount changes
  void _updateDueAmount(String value) {
    if (value.isEmpty) {
      setState(() {
        _paidAmount = 0.0;
        _dueAmount = widget.totalAmount;
        _dueAmountController.text = BdTakaFormatter.format(
          _dueAmount,
          toBengaliDigits: _useBengaliDigits,
        );
      });
      return;
    }

    try {
      // If Bengali digits are used, convert to English digits for parsing
      String normalizedValue = value;
      if (_useBengaliDigits) {
        normalizedValue = bengaliToEnglishDigits(normalizedValue);
      }

      // Remove any non-numeric characters (like commas)
      normalizedValue = normalizedValue.replaceAll(RegExp(r'[^0-9.]'), '');

      _paidAmount = double.parse(normalizedValue);
      setState(() {
        _dueAmount = widget.totalAmount - _paidAmount;
        if (_dueAmount < 0) _dueAmount = 0;

        _dueAmountController.text = BdTakaFormatter.format(
          _dueAmount,
          toBengaliDigits: _useBengaliDigits,
        );
      });
    } catch (e) {
      // Handle parsing errors
      setState(() {
        _hasError = true;
        _errorMessage = 'সঠিক অঙ্ক লিখুন';
      });
    }
  }

  Future<void> _saveDueSale() async {}
  // Future<void> _saveDueSale() async {
  //   // Validate customer information
  //   if (_customerNameController.text.trim().isEmpty) {
  //     setState(() {
  //       _hasError = true;
  //       _errorMessage = 'গ্রাহকের নাম দিন';
  //     });
  //     return;
  //   }

  //   if (_phoneController.text.trim().isEmpty) {
  //     setState(() {
  //       _hasError = true;
  //       _errorMessage = 'গ্রাহকের ফোন নম্বর দিন';
  //     });
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //     _hasError = false;
  //     _errorMessage = '';
  //   });

  //   try {
  //     // Prepare due sale data
  //     final dueSaleData = {
  //       'customerName': _customerNameController.text.trim(),
  //       'phoneNumber': _phoneController.text.trim(),
  //       'address': _addressController.text.trim(),
  //       'totalAmount': widget.totalAmount,
  //       'paidAmount': _paidAmount,
  //       'dueAmount': _dueAmount,
  //       'notes': _notesController.text.trim(),
  //       'products': widget.products,
  //       'shopId': widget.shopId,
  //     };

  //     // Call service to save due sale
  //     final result = await _salesService.confirmDueSales(
  //       widget.products,
  //       dueSaleData,
  //       widget.shopId,
  //     );

  //     if (result) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('বাকি বিক্রয় সফলভাবে সংরক্ষিত হয়েছে')),
  //       );

  //       // Go back to previous screen
  //       Navigator.of(context).pop(true);
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _hasError = true;

  //       String errorMsg = e.toString();
  //       if (errorMsg.startsWith('Exception: ')) {
  //         errorMsg = errorMsg.substring('Exception: '.length);
  //       }
  //       _errorMessage = errorMsg;
  //     });
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

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

  @override
  Widget build(BuildContext context) {
    // Get currency symbol from first item or default to Taka
    final currency =
        widget.products.isNotEmpty ? widget.products.first.currency : '৳';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar('বাকিতে বিক্রয়'),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total amount display
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'মোট মূল্য:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '$currency ${BdTakaFormatter.format(widget.totalAmount, toBengaliDigits: _useBengaliDigits)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Customer information section
                        Text(
                          'গ্রাহকের তথ্য',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Name field
                        TextField(
                          controller: _customerNameController,
                          decoration: InputDecoration(
                            labelText: 'গ্রাহকের নাম *',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),

                        // Phone field
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'ফোন নম্বর *',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),

                        // Address field
                        TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'ঠিকানা',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Payment information
                        Text(
                          'পেমেন্ট বিবরণ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Paid amount field
                        TextField(
                          controller: _paidAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'জমা টাকা',
                            prefixText: '$currency ',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: _updateDueAmount,
                        ),
                        SizedBox(height: 12),

                        // Due amount field (read-only)
                        TextField(
                          controller: _dueAmountController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'বাকি টাকা',
                            prefixText: '$currency ',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            fillColor: Colors.grey.shade100,
                            filled: true,
                          ),
                        ),
                        SizedBox(height: 12),

                        // Notes field
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'নোট',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Error message display
                        if (_hasError)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red.shade800),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        SizedBox(height: 16),

                        // Products list header
                        Text(
                          'পণ্যসমূহ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),

                        // Products table
                        if (widget.products.isNotEmpty)
                          Column(
                            children: [
                              // Table header
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          'নাম',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'পরিমাণ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'মূল্য',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Table rows
                              ...List.generate(widget.products.length, (index) {
                                final item = widget.products[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12.0,
                                          ),
                                          child: Text(item.name),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(_formatQuantity(item)),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${item.currency} ${BdTakaFormatter.format(item.price, toBengaliDigits: _useBengaliDigits)}',
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom action buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
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
                        onPressed:
                            _isLoading
                                ? null
                                : () => Navigator.of(context).pop(false),
                        child: Text('বাতিল'),
                      ),
                    ),
                    SizedBox(width: 16),
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
                        onPressed: _isLoading ? null : _saveDueSale,
                        child:
                            _isLoading
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text('সংরক্ষণ করুন'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
