import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/data/api/middleware/auth_middleware.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileNumberController = TextEditingController();
  final _passwordController = TextEditingController();

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
    _mobileNumberController.addListener(_clearErrorOnChange);
    _passwordController.addListener(_clearErrorOnChange);
  }

  // Function to clear error message when user types in any field
  void _clearErrorOnChange() {
    if (_errorMessage.isNotEmpty) {
      setState(() {
        _errorMessage = '';
      });
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await AuthService.login(
        _mobileNumberController.text,
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['status_code'] == 200) {
        // Navigate to home on successful login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.homePage);
        } else {
          _errorMessage =
              'অ্যাপে একটি অপ্রত্যাশিত ত্রুটি ঘটেছে। দয়া করে আবার লগইন করুন।';
        }
      } else if (response['status_code'] == 401) {
        setState(() {
          _errorMessage = 'ফোন নম্বর অথবা পাসওয়ার্ড সঠিক নয়';
        });
      } else {
        setState(() {
          _errorMessage = 'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে';
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

                  // Login Text
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
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
                        return 'Please enter your password';
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

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005A8D),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text('Login'),
                  ),
                  const SizedBox(height: 20),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.registerPage);
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005A8D),
                          ),
                        ),
                      ),
                    ],
                  ),
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
    _mobileNumberController.removeListener(_clearErrorOnChange);
    _passwordController.removeListener(_clearErrorOnChange);

    // Dispose of controllers
    _mobileNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
