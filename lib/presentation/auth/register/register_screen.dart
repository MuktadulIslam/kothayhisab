// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/data/api/middleware/auth_middleware.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';

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
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthMiddleware.checkAlreadyLoggedIn(context);
    });

    // Add listeners to clear error message when input changes
    _nameController.addListener(_clearErrorOnChange);
    _mobileNumberController.addListener(_clearErrorOnChange);
    _passwordController.addListener(_clearErrorOnChange);
    _confirmPasswordController.addListener(_clearErrorOnChange);
  }

  // Function to clear error message when user types in any field
  void _clearErrorOnChange() {
    if (_errorMessage.isNotEmpty) {
      setState(() {
        _errorMessage = '';
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'পাসওয়ার্ড মিলছে না।';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = '';
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
        setState(() {
          _errorMessage =
              'এই নাম্বারের ব্যবহারকারী ইতোমধ্যেই রয়েছে। অন্য কোন নম্বর ব্যবহার করুন।';
        });
      } else {
        setState(() {
          _errorMessage = 'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে!';
        });
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
                      'assets/images/logo.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Register Text
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full Name Field
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Mobile Number Field
                  TextFormField(
                    controller: _mobileNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                      hintText: '01xxxxxxxxx (11 digits)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      // Add validation for exactly 11 digits
                      if (value.length != 11 ||
                          !RegExp(r'^\d{11}$').hasMatch(value)) {
                        return "মোবাইল নম্বর অবশ্যই ঠিক ১১ সংখ্যার হতে হবে";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 3) {
                        return "পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে।";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'পাসওয়ার্ড মিলছে না।';
                      }
                      return null;
                    },
                  ),

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
                            : const Text('Register'),
                  ),
                  const SizedBox(height: 20),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed(AppRoutes.loginPage);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005A8D),
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
    // Remove listeners before disposing controllers
    _nameController.removeListener(_clearErrorOnChange);
    _mobileNumberController.removeListener(_clearErrorOnChange);
    _passwordController.removeListener(_clearErrorOnChange);
    _confirmPasswordController.removeListener(_clearErrorOnChange);

    // Dispose of controllers
    _nameController.dispose();
    _mobileNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
