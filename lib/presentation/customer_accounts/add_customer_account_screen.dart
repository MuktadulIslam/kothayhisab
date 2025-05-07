// lib/screens/add_customer_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:kothayhisab/data/api/services/customer_account_services.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/toast_notification.dart';

class AddCustomerAccountsScreen extends StatefulWidget {
  final String shopId;
  const AddCustomerAccountsScreen({super.key, required this.shopId});

  @override
  _AddCustomerAccountsScreenState createState() =>
      _AddCustomerAccountsScreenState();
}

class _AddCustomerAccountsScreenState extends State<AddCustomerAccountsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final CustomerService _customerService = CustomerService();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

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
      });

      // Add customer with local storage service (1 second delay)
      final response = await _customerService.createCustomer(
        customerName: _nameController.text,
        mobileNumber: _mobileNumberController.text,
        address: _addressController.text,
        photoUrl: _selectedImage?.path ?? '',
        shopId: widget.shopId,
      );

      setState(() {
        _isLoading = false;
      });

      if (response) {
        ToastNotification.success('গ্রাহক সফলভাবে যোগ করা হয়েছে!');
        // Go back to previous screen
        Navigator.of(context).pop();
      } else {
        ToastNotification.success('একটি অপ্রত্যাশিত ত্রুটি ঘটেছে!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('নতুন গ্রাহক সংযোগ'),
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
                  const SizedBox(height: 10),

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
                  const SizedBox(height: 10),

                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    keyboardType: TextInputType.multiline,
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
                  const SizedBox(height: 15),
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
                            : const Text(
                              'গ্রাহক যোগ করুন',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }

  @override
  void dispose() {
    // Dispose of controllers
    _nameController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
