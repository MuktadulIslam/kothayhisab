import 'package:flutter/material.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Store icon
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.store,
                  color: Color(0xFF0C5D8F),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Store text
              const Text(
                'মুরাদ ষ্টোর', // "Root Store" in Bengali
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              // Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0C5D8F),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 6.0,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.edit, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'পরিবর্তন', // "Change" in Bengali
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Location info
          Row(
            children: const [
              Icon(Icons.location_on, color: Colors.grey, size: 18),
              SizedBox(width: 8),
              Text(
                'সাভার, ঢাকা', // "Dhaka, Root City" in Bengali
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
