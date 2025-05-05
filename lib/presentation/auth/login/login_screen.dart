import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/data/api/middleware/auth_middleware.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';
import 'package:kothayhisab/presentation/common_widgets/toast_notification.dart';

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
  bool _obscurePassword = true; // For password visibility toggle

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthMiddleware.checkAlreadyLoggedIn(context);
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
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
          ToastNotification.error(
            // ignore: use_build_context_synchronously
            context,
            'অ্যাপে একটি অপ্রত্যাশিত ত্রুটি ঘটেছে। দয়া করে আবার লগইন করুন।',
          );
        }
      } else if (response['status_code'] == 401) {
        ToastNotification.error(
          // ignore: use_build_context_synchronously
          context,
          'ফোন নম্বর অথবা পাসওয়ার্ড সঠিক নয়',
        );
      } else {
        ToastNotification.error(
          // ignore: use_build_context_synchronously
          context,
          'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে',
        );
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
                      'লগইন করুন',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 28, 65, 130),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Mobile Number Field with validation
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
                      // Check if number is 11 digits and starts with 01
                      if (value.length != 11) {
                        return 'মোবাইল নম্বর অবশ্যই ঠিক ১১ সংখ্যার হতে হবে';
                      }
                      if (!value.startsWith('01')) {
                        return 'মোবাইল নম্বর অবশ্যই ০১ দিয়ে শুরু হতে হবে';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Password Field with visibility toggle and updated validation
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
                      hintText: 'পাসওয়ার্ড',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'পাসওয়ার্ড দিন';
                      }
                      // No minimum length check now - just make sure it's not empty
                      return null;
                    },
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
                            : const Text('লগইন করুন'),
                  ),
                  const SizedBox(height: 20),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "আপনার অ্যাকাউন্ট নেই? ",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.registerPage);
                        },
                        child: const Text(
                          'রেজিস্টার করুন',
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
    _mobileNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
