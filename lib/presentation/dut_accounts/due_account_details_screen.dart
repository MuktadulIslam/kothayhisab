// lib/screens/customer_details_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:kothayhisab/data/models/due_coustomer_model.dart';
import 'package:kothayhisab/data/api/services/due_account_services.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:intl/intl.dart';

class DueAccountsDetailsScreen extends StatefulWidget {
  final Customer customer;

  const DueAccountsDetailsScreen({super.key, required this.customer});

  @override
  _DueAccountsDetailsScreenState createState() =>
      _DueAccountsDetailsScreenState();
}

class _DueAccountsDetailsScreenState extends State<DueAccountsDetailsScreen> {
  bool _isLoading = false;

  Future<void> _deleteCustomer() async {
    setState(() {
      _isLoading = true;
    });

    final response = await CustomerService.deleteCustomer(widget.customer.id);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('গ্রাহক সফলভাবে মুছে ফেলা হয়েছে'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back with result to refresh the list
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'মুছতে সমস্যা হয়েছে'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'dd/MM/yyyy',
    ).format(widget.customer.createdAt);

    return Scaffold(
      appBar: CustomAppBar('গ্রাহকের বিবরণ'),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Customer photo
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5FE),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00558D),
                            width: 2,
                          ),
                        ),
                        child:
                            widget.customer.photoPath != null &&
                                    File(
                                      widget.customer.photoPath!,
                                    ).existsSync()
                                ? ClipOval(
                                  child: Image.file(
                                    File(widget.customer.photoPath!),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Color(0xFF00558D),
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Customer name
                    Text(
                      widget.customer.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00558D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Customer details
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Mobile Number
                          DetailRow(
                            icon: Icons.phone,
                            title: 'মোবাইল নম্বর',
                            value: widget.customer.mobileNumber,
                          ),
                          const SizedBox(height: 16),

                          // Address
                          DetailRow(
                            icon: Icons.home,
                            title: 'ঠিকানা',
                            value: widget.customer.address,
                          ),
                          const SizedBox(height: 16),

                          // Creation Date
                          DetailRow(
                            icon: Icons.calendar_today,
                            title: 'যোগ করার তারিখ',
                            value: formattedDate,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Delete button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Show delete confirmation dialog
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('গ্রাহক মুছে ফেলুন'),
                                  content: Text(
                                    'আপনি কি নিশ্চিত যে আপনি ${widget.customer.name} কে মুছে ফেলতে চান?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('না'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteCustomer();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('হ্যাঁ, মুছে ফেলুন'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          'গ্রাহক মুছে ফেলুন',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

// Detail row widget for consistent formatting
class DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const DetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5FE),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF00558D), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
