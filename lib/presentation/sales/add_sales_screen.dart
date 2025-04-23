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
  _AddSalesScreenState createState() => _AddSalesScreenState();
}

class _AddSalesScreenState extends State<AddSalesScreen> {
  // Controllers and Services
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final SalesService _salesService = SalesService();

  // State variables
  bool _isLoading = false;
  bool _isSaving = false;
  List<SalesItem> _parsedItems = [];
  bool _hasError = false;
  String _errorMessage = '';
  bool _productsVisible = false;
  bool _useBengaliDigits = true;
  bool _inDueSaleMode = false;
  bool _customerDataVisible = false;
  Map<String, dynamic>? _customerDueData;
  late String currency;

  @override
  void initState() {
    super.initState();
    _textFocusNode.addListener(_onFocusChange);
    currency = _parsedItems.isNotEmpty ? _parsedItems.first.currency : '৳';
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.removeListener(_onFocusChange);
    _textFocusNode.dispose();
    super.dispose();
  }

  // Helper Methods
  void _onFocusChange() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
  }

  void _setError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
  }

  void _clearError() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
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
    // Case 1: If in due sale mode, exit due sale mode
    if (_inDueSaleMode) {
      setState(() {
        _inDueSaleMode = false;
        _customerDataVisible = false;
        _customerDueData = null;
        _textController.clear();
        _hasError = false;
        _errorMessage = '';
      });
    }
    // Case 2: If input field is not empty, clear it
    else if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _textController.clear();
        _hasError = false;
        _errorMessage = '';
      });
    }
    // Case 3: If table data exists, clear table
    else if (_parsedItems.isNotEmpty) {
      setState(() {
        _parsedItems = [];
        _productsVisible = false;
        _hasError = false;
        _errorMessage = '';
      });
    }
    // Case 4: If both input and table are empty, go back
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
      _setError('টেক্সট লিখুন বা ভয়েস রেকর্ড করুন');
      return;
    }

    setState(() {
      _isLoading = true;
      _clearError();
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

        _setError(errorMsg);
      });
    }
  }

  Future<void> _cashSale() async {
    if (_parsedItems.isEmpty) {
      _setError('কোন পণ্য যোগ করা হয়নি');
      return;
    }

    setState(() {
      _isSaving = true;
      _clearError();
    });

    try {
      final result = await _salesService.confirmSales(
        _parsedItems,
        _textController.text.trim(),
        widget.shopId,
      );

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('বিক্রয় সফলভাবে সংরক্ষিত হয়েছে')),
        );

        // Reset the state
        setState(() {
          _textController.clear();
          _parsedItems = [];
          _productsVisible = false;
          _clearError();
        });
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring('Exception: '.length);
      }
      _setError(errorMsg);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _dueSale() async {
    setState(() {
      _inDueSaleMode = true;
      _customerDataVisible = false;
      _customerDueData = null;
      _textController.clear();
      _hasError = false;
      _errorMessage = '';
    });
    _textFocusNode.requestFocus();
  }

  Future<void> _parseDueInfo() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final text = _textController.text.trim();
    if (text.isEmpty) {
      _setError('টেক্সট লিখুন বা ভয়েস রেকর্ড করুন');
      return;
    }

    setState(() {
      _isLoading = true;
      _clearError();
    });

    try {
      final items = await _salesService.parseDuesText(
        '$text total price is ${_calculateTotalPrice()}',
      );
      print('Parsed items: $items');

      setState(() {
        _customerDueData = items;
        _isLoading = false;
        _productsVisible = true;
        _customerDataVisible = true; // Add this line
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

        _setError(errorMsg);
      });
    }
  }

  Future<void> _completeDueSale() async {
    if (_parsedItems.isEmpty) {
      _setError('কোন পণ্য যোগ করা হয়নি');
      return;
    }

    setState(() {
      _isSaving = true;
      _clearError();
    });

    try {
      final result = await _salesService.confirmDueSale(
        _customerDueData ?? {},
        _parsedItems,
        _textController.text.trim(),
        widget.shopId,
      );

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('বাকিতে বিক্রয় সফলভাবে সংরক্ষিত হয়েছে')),
        );

        // Reset the state
        setState(() {
          _textController.clear();
          _parsedItems = [];
          _productsVisible = false;
          _inDueSaleMode = false;
          _customerDataVisible = false;
          _customerDueData = null;
          _clearError();
        });
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring('Exception: '.length);
      }
      _setError(errorMsg);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
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
              if (_inDueSaleMode) {
                _parseDueInfo();
              } else {
                _parseInventoryText();
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Container(
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
    );
  }

  Widget _buildErrorMessage() {
    if (!_hasError) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
    );
  }

  List<Widget> _buildTotalPriceSection() {
    final widgets = <Widget>[];
    const fontSize = 14.0;

    // Customer due data section (if visible)
    if (_productsVisible && _parsedItems.isNotEmpty) {
      if (_customerDataVisible && _customerDueData != null) {
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
                        _customerDueData!['customer_name'].toString(),
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
      } else {
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
                        '$currency ${BdTakaFormatter.format(_calculateTotalPrice(), toBengaliDigits: _useBengaliDigits)}',
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
        _parsedItems.isNotEmpty) {
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
    } else {
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
      // Show "বাকির তথ্য দেখুন" in due sale mode
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
          onPressed: _isLoading || _isSaving ? null : _parseDueInfo,
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
                  : Text('বাকির তথ্য দেখুন'),
        ),
      );
    }
  }

  List<Widget> _buildActionButtons() {
    final cancelButton = Expanded(
      // Remove 'const' here
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

    if (_inDueSaleMode) {
      return [cancelButton, SizedBox(width: 10), _dueActionButton()];
    } else {
      return [cancelButton, SizedBox(width: 10), ..._saleActionButton()];
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardOpen = viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar('বিক্রয় করুন'),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Input section at top
              _buildInputSection(),

              // Scrollable middle section
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // _buildVoiceButton(),
                      SizedBox(height: 16),
                      _buildErrorMessage(),
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
