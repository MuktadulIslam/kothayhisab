// lib/screens/add_customer_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:kothayhisab/data/api/services/due_account_services.dart';

class AddDueCustomerScreen extends StatefulWidget {
  final String shopId;
  const AddDueCustomerScreen({super.key, required this.shopId});

  @override
  _AddDueCustomerScreenState createState() => _AddDueCustomerScreenState();
}

class _AddDueCustomerScreenState extends State<AddDueCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _addressController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Add listeners to clear error message when input changes
    _nameController.addListener(_clearErrorOnChange);
    _mobileNumberController.addListener(_clearErrorOnChange);
    _addressController.addListener(_clearErrorOnChange);
  }

  // Function to clear error message when user types in any field
  void _clearErrorOnChange() {
    if (_errorMessage.isNotEmpty) {
      setState(() {
        _errorMessage = '';
      });
    }
  }

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _addCustomer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Add customer with local storage service (1 second delay)
      final response = await CustomerService.addCustomer(
        _nameController.text,
        _mobileNumberController.text,
        _addressController.text,
        _selectedImage?.path,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == 'success') {
        if (mounted) {
          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('গ্রাহক সফলভাবে যোগ করা হয়েছে!'),
              backgroundColor: Colors.green,
            ),
          );

          // Go back to previous screen
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে!';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন গ্রাহক যোগ করুন'),
        backgroundColor: const Color(0xFF005A8D),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Profile Image Upload Section
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF005A8D),
                              width: 2,
                            ),
                          ),
                          child:
                              _selectedImage != null
                                  ? ClipOval(
                                    child: Image.file(
                                      _selectedImage!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF005A8D),
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            onTap: _pickImage,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Full Name Field
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'পুরো নাম',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'গ্রাহকের নাম দিন';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Mobile Number Field with 01 prefix validation
                  TextFormField(
                    controller: _mobileNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'মোবাইল নম্বর',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                      hintText: '01XXXXXXXXX',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'মোবাইল নম্বর দিন';
                      }
                      // Check if number is 11 digits
                      if (value.length != 11) {
                        return 'মোবাইল নম্বর অবশ্যই ঠিক ১১ সংখ্যার হতে হবে';
                      }
                      // Check if number starts with 01
                      if (!value.startsWith('01')) {
                        return 'মোবাইল নম্বর অবশ্যই ০১ দিয়ে শুরু হতে হবে';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'ঠিকানা',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'গ্রাহকের ঠিকানা দিন';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Add Customer Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005A8D),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text('গ্রাহক যোগ করুন'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Remove listeners before disposing controllers
    _nameController.removeListener(_clearErrorOnChange);
    _mobileNumberController.removeListener(_clearErrorOnChange);
    _addressController.removeListener(_clearErrorOnChange);

    // Dispose of controllers
    _nameController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
