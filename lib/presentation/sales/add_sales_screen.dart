import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kothayhisab/data/api/services/sales_service.dart';
import 'package:kothayhisab/data/models/sales_model.dart';

import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/core/utils/currency_formatter.dart';

class AddSalesScreen extends StatefulWidget {
  final String shopId;
  const AddSalesScreen({super.key, required this.shopId});

  @override
  // ignore: library_private_types_in_public_api
  _AddSalesScreenState createState() => _AddSalesScreenState();
}

class _AddSalesScreenState extends State<AddSalesScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final SalesService _salesService = SalesService();

  bool _isLoading = false;
  bool _isSaving = false;
  List<SalesItem> _parsedItems = [];
  bool _hasError = false;
  String _errorMessage = '';
  bool _productsVisible = false;

  // Control whether to use Bengali digits
  bool _useBengaliDigits = true;

  @override
  void initState() {
    super.initState();
    _textFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.removeListener(_onFocusChange);
    _textFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // Trigger rebuild when focus changes
    setState(() {});
  }

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
    // Case 1: If input field is not empty, clear it
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _textController.clear();
        _hasError = false;
        _errorMessage = '';
      });
    }
    // Case 2: If table data exists, clear table
    else if (_parsedItems.isNotEmpty) {
      setState(() {
        _parsedItems = [];
        _productsVisible = false;
        _hasError = false;
        _errorMessage = '';
      });
    }
    // Case 3: If both input and table are empty, go back
    else {
      Navigator.of(context).pop();
    }
  }

  void _removeItemAtIndex(int index) {
    setState(() {
      _parsedItems.removeAt(index);

      // If all items are removed, hide the products section
      if (_parsedItems.isEmpty) {
        _productsVisible = false;
      }
    });
  }

  Future<void> _parseInventoryText() async {
    // Remove focus from text field when button is clicked to dismiss keyboard
    FocusScope.of(context).unfocus();

    final text = _textController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'টেক্সট লিখুন বা ভয়েস রেকর্ড করুন';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final items = await _salesService.parseSalesText(text);

      setState(() {
        // Add new items to existing items list instead of replacing
        _parsedItems.addAll(items);
        _isLoading = false;
        _productsVisible = true;
        // Clear input field after successful parsing
        _textController.clear();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;

        String errorMsg = e.toString();

        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.substring('Exception: '.length);
        }

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

        _errorMessage = errorMsg;
      });
    }
  }

  Future<void> _cashSale() async {
    if (_parsedItems.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'কোন পণ্য যোগ করা হয়নি';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final result = await _salesService.confirmSales(
        _parsedItems,
        _textController.text.trim(),
        widget.shopId,
      );

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('বিক্রয় সফলভাবে সংরক্ষিত হয়েছে')),
        );

        // Reset the state but don't navigate back
        setState(() {
          _textController.clear();
          _parsedItems = [];
          _productsVisible = false;
          _hasError = false;
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;

        String errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.substring('Exception: '.length);
        }
        _errorMessage = errorMsg;
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _dueSale() async {}
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

  @override
  Widget build(BuildContext context) {
    // Get available height for the body content
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardOpen = viewInsets.bottom > 0;

    // Calculate total price
    final totalPrice =
        _productsVisible && _parsedItems.isNotEmpty
            ? _calculateTotalPrice()
            : 0.0;

    // Get currency symbol from first item or default to Taka
    final currency =
        _parsedItems.isNotEmpty ? _parsedItems.first.currency : '৳';

    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow resizing when keyboard appears
      appBar: CustomAppBar('বিক্রয় করুন'),
      body: SafeArea(
        child: GestureDetector(
          // Add GestureDetector to dismiss keyboard when tapping outside input
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              // Input section - this won't expand and will stay at top
              Padding(
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
                      hintText: 'এখানে লিখুন',
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
              ),

              // Scrollable middle section (wrapping in Expanded)
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Voice button - now inside scrollable area
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Color(0xFF005A8D),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.mic, color: Colors.white, size: 28),
                          onPressed: _handleVoiceButtonPressed,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Error message
                      if (_hasError)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Container(
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
                        ),

                      // Total price section (if items are visible)
                      if (_productsVisible && _parsedItems.isNotEmpty)
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'মোট মূল্য:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '$currency ${BdTakaFormatter.format(totalPrice, toBengaliDigits: _useBengaliDigits)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Parsed items table
                      if (_productsVisible && _parsedItems.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
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
                                    SizedBox(
                                      width: 40,
                                    ), // Space for delete button
                                  ],
                                ),
                              ),

                              // Table rows
                              ...List.generate(_parsedItems.length, (index) {
                                final item = _parsedItems[index];
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
                                      // Delete button
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.red.shade400,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                        onPressed:
                                            () => _removeItemAtIndex(index),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Action buttons - these stay at the bottom
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
                            _isLoading || _isSaving
                                ? null
                                : _handleCancelButtonPress,
                        child: Text('বাতিল'),
                      ),
                    ),
                    SizedBox(width: 10),
                    if (_textController.text.trim().isEmpty &&
                        !_textFocusNode.hasFocus &&
                        _productsVisible &&
                        _parsedItems.isNotEmpty)
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
                          child: Text('বাকিতে বিক্রয়'),
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
                            _isLoading || _isSaving
                                ? null
                                : (_textController.text.trim().isEmpty &&
                                        _productsVisible
                                    ? _cashSale
                                    : _parseInventoryText),
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
                                : Text(
                                  _textController.text.trim().isNotEmpty ||
                                          _textFocusNode.hasFocus
                                      ? 'পণ্য দেখুন'
                                      : 'নগদ বিক্রয়',
                                ),
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
