// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/data/api/middleware/auth_middleware.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';
import 'package:kothayhisab/presentation/common_widgets/toast_notification.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthMiddleware.checkAlreadyLoggedIn(context);
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final response = await AuthService.register(
        _mobileNumberController.text,
        _passwordController.text,
        _nameController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['status_code'] == 201) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.homePage);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.loginPage);
        }
      } else if (response['status_code'] == 409) {
        ToastNotification.error(
          'এই নাম্বারের ব্যবহারকারী ইতোমধ্যেই রয়েছে। অন্য কোন নম্বর ব্যবহার করুন।',
        );
      } else {
        ToastNotification.error('একটি অপ্রত্যাশিত ত্রুটি ঘটেছে!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const SizedBox(height: 40),
                  // Logo and app name
                  Center(
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'রেজিস্টার করুন',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 28, 65, 130),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

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
                        return 'আপনার নাম দিন';
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

                  // Password Field with visibility toggle - removed 8 char minimum
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'পাসওয়ার্ড',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      hintText: 'পাসওয়ার্ড দিন',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'পাসওয়ার্ড দিন';
                      }
                      // Removed the length check
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Confirm Password Field with visibility toggle
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'পাসওয়ার্ড নিশ্চিত করুন',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'পাসওয়ার্ড নিশ্চিত করুন';
                      }
                      if (value != _passwordController.text) {
                        return 'পাসওয়ার্ড মিলছে না।';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Register Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005A8D),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text('রেজিস্টার'),
                  ),
                  const SizedBox(height: 20),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "ইতিমধ্যে একাউন্ট আছে? ",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed(AppRoutes.loginPage);
                        },
                        child: const Text(
                          'লগইন করুন',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005A8D),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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
    // Dispose of controllers
    _nameController.dispose();
    _mobileNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
