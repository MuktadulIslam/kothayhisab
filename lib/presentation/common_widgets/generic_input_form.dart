import 'package:flutter/material.dart';

class GenericInputForm extends StatefulWidget {
  final String title;
  final List<FormField> fields;
  final Function(Map<String, String>) onSubmit;
  final String submitButtonText;

  const GenericInputForm({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.submitButtonText = 'Submit',
  });

  @override
  State<GenericInputForm> createState() => _GenericInputFormState();
}

class _GenericInputFormState extends State<GenericInputForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each field
    for (var field in widget.fields) {
      _controllers[field.name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Generate form fields dynamically
              ...widget.fields.map((field) {
                return Column(
                  children: [
                    TextFormField(
                      controller: _controllers[field.name],
                      decoration: InputDecoration(
                        labelText: field.label,
                        hintText: field.hint,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (field.isRequired &&
                            (value == null || value.isEmpty)) {
                          return field.errorMessage ?? 'This field is required';
                        }
                        return field.validator?.call(value);
                      },
                      keyboardType: field.keyboardType,
                      obscureText: field.isPassword,
                      maxLines: field.maxLines,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),

              const SizedBox(height: 8),

              // Submit button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Collect all form data
                      final formData = <String, String>{};
                      for (var entry in _controllers.entries) {
                        formData[entry.key] = entry.value.text;
                      }

                      // Call the onSubmit callback with the collected data
                      widget.onSubmit(formData);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 12.0,
                    ),
                    child: Text(
                      widget.submitButtonText,
                      style: const TextStyle(fontSize: 16),
                    ),
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

// Form field class to define each input field
class FormField {
  final String name;
  final String label;
  final String? hint;
  final bool isRequired;
  final String? errorMessage;
  final bool isPassword;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  FormField({
    required this.name,
    required this.label,
    this.hint,
    this.isRequired = true,
    this.errorMessage,
    this.isPassword = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });
}
