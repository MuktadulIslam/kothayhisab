import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kothayhisab/data/api/services/inventory_service.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';

class AddInventoryScreen extends StatefulWidget {
  @override
  _AddInventoryScreenState createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final InventoryService _inventoryService = InventoryService();

  bool _isLoading = false;
  bool _isSaving = false;
  List<InventoryItem> _parsedItems = [];
  bool _hasError = false;
  String _errorMessage = '';
  bool _productsVisible = false;

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
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

  void _resetState() {
    setState(() {
      _textController.clear();
      _parsedItems = [];
      _productsVisible = false;
      _hasError = false;
      _errorMessage = '';
    });
  }

  Future<void> _parseInventoryText() async {
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
      final items = await _inventoryService.parseInventoryText(text);

      setState(() {
        _parsedItems = items;
        _isLoading = false;
        _productsVisible = true;
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

  Future<void> _confirmInventory() async {
    setState(() {
      _isSaving = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final result = await _inventoryService.confirmInventory(
        _parsedItems,
        _textController.text.trim(),
      );

      if (result) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('মজুদ সফলভাবে সংরক্ষিত হয়েছে')));

        _resetState();
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

  @override
  Widget build(BuildContext context) {
    // Get available height for the body content
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardOpen = viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow resizing when keyboard appears
      appBar: CustomAppBar('মজুদ যোগ করুন'),
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
                    enabled: !_productsVisible,
                    decoration: InputDecoration(
                      hintText: 'এখানে লিখুন',
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      if (!_productsVisible) {
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
                          onPressed:
                              _productsVisible
                                  ? null
                                  : _handleVoiceButtonPressed,
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
                                        'মূল্য',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
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
                                        child: Text(
                                          '${item.currency} ${item.price}',
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${item.quantity} ${item.quantityDescription}',
                                        ),
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
                  left: 16.0,
                  right: 16.0,
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
                        onPressed: _isLoading || _isSaving ? null : _resetState,
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
                        onPressed:
                            _isLoading || _isSaving
                                ? null
                                : (_productsVisible
                                    ? _confirmInventory
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
                                  _productsVisible ? 'মজুদ করুন' : 'পণ্য দেখুন',
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
