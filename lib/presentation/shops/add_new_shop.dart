import 'package:flutter/material.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';

class AddNewShopScreen extends StatefulWidget {
  const AddNewShopScreen({super.key});

  @override
  State<AddNewShopScreen> createState() => _AddNewShopScreenState();
}

class _AddNewShopScreenState extends State<AddNewShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _areaNameController = TextEditingController();
  final _thanaNameController = TextEditingController();
  final _zilaNameController = TextEditingController();
  final _districtNameController = TextEditingController();

  @override
  void dispose() {
    _shopNameController.dispose();
    _areaNameController.dispose();
    _thanaNameController.dispose();
    _zilaNameController.dispose();
    _districtNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('নতুন দোকান যোগ করুন'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFormInputField(
                labelText: 'দোকানের নাম',
                errorMessage: 'দয়া করে দোকানের নাম লিখুন',
                controller: _shopNameController,
              ),

              const SizedBox(height: 16),
              CustomFormInputField(
                labelText: 'এলাকার নাম',
                errorMessage: 'দয়া করে এলাকার নাম লিখুন',
                controller: _areaNameController,
              ),

              const SizedBox(height: 16),
              CustomFormInputField(
                labelText: 'থানার নাম',
                errorMessage: 'দয়া করে থানার নাম লিখুন',
                controller: _thanaNameController,
              ),

              const SizedBox(height: 16),
              CustomFormInputField(
                labelText: 'জেলার নাম',
                errorMessage: 'দয়া করে জেলার নাম লিখুন',
                controller: _zilaNameController,
              ),

              const SizedBox(height: 16),
              CustomFormInputField(
                labelText: 'বিভাগ নাম',
                errorMessage: 'দয়া করে বিভাগ নাম লিখুন',
                controller: _districtNameController,
              ),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // In a real app, you would save to JSON here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('দোকান সফলভাবে যোগ হয়েছে'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 12.0,
                    ),
                    child: Text('যোগ করুন', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomFormInputField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final String errorMessage;

  const CustomFormInputField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMessage;
        }
        return null;
      },
    );
  }
}
