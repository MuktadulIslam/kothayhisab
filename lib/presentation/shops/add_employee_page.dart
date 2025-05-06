import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/employee_service.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/toast_notification.dart';

class AddEmployeePage extends StatefulWidget {
  final String shopId;

  // Constructor where onEmployeeAdded is optional
  const AddEmployeePage({Key? key, required this.shopId, this.onEmployeeAdded})
    : super(key: key);

  // Optional callback for when an employee is added
  final VoidCallback? onEmployeeAdded;

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileNumberController = TextEditingController();
  String _selectedRole = 'Employee'; // Backend value
  bool _isLoading = false;
  bool _isDisposed = false; // Track if widget is disposed

  // Define roles with their display names and actual values
  final List<Map<String, String>> _roles = [
    {'display': 'নতুন কর্মচারী', 'value': 'Employee'},
    {'display': 'নতুন মালিক', 'value': 'Owner'},
  ];

  @override
  void dispose() {
    _isDisposed = true;
    _mobileNumberController.dispose();
    super.dispose();
  }

  String? _validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'মোবাইল নম্বর অবশ্যই ঠিক ১১ সংখ্যার হতে হবে';
    }
    if (value.length != 11 || !value.startsWith('01')) {
      return 'মোবাইল নম্বর অবশ্যই ০১ দিয়ে শুরু হতে হবে';
    }
    return null;
  }

  Future<void> _addEmployee() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await EmployeeService.addEmployee(
        widget.shopId,
        _mobileNumberController.text,
        _selectedRole, // This contains the backend value 'Employee' or 'Owner'
      );

      // Check if widget is still mounted before updating state
      if (_isDisposed) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ToastNotification.success('নতুন কর্মচারী যোগ করা সফল হয়েছে!');

        // Safely call the callback
        if (!_isDisposed && mounted && widget.onEmployeeAdded != null) {
          // Use Future.microtask to avoid calling setState during build
          Future.microtask(() {
            try {
              widget.onEmployeeAdded!();
            } catch (e) {
              print("Error in callback: $e");
            }
          });
        }

        // Only pop if still mounted
        if (mounted) {
          // Use a slight delay to ensure callback has completed
          Future.delayed(Duration.zero, () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } else {
        if (!_isDisposed) {
          ToastNotification.error(
            'কর্মচারী যোগ করতে সমস্যা হয়েছে! ${result['message']}',
          );
        }
      }
    } catch (e) {
      print("Error adding employee: $e");
      if (!_isDisposed) {
        setState(() {
          _isLoading = false;
        });
        ToastNotification.error('কর্মচারী যোগ করতে সমস্যা হয়েছে!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Handle back button press safely
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar('নতুন কর্মচারীর যোগ'),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'কর্মচারীর মোবাইল নম্বরঃ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mobileNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '01XXXXXXXXX',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF005596),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: _validateMobileNumber,
                ),
                const SizedBox(height: 20),
                const Text(
                  'কর্মচারীর দায়িত্বঃ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    children:
                        _roles.map((role) {
                          return RadioListTile<String>(
                            title: Text(
                              role['display']!,
                              style: const TextStyle(fontSize: 16),
                            ),
                            value: role['value']!,
                            groupValue: _selectedRole,
                            activeColor: const Color(0xFF005596),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                // print('object: $newValue');
                                setState(() {
                                  _selectedRole = newValue;
                                });
                              }
                            },
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005596),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'যোগ করুন',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomAppBar(),
      ),
    );
  }
}
