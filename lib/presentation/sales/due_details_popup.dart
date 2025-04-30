import 'package:flutter/material.dart';
import 'package:kothayhisab/core/utils/currency_formatter.dart';

class DueDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> dueItem;
  final bool useBengaliDigits;

  const DueDetailsBottomSheet({
    Key? key,
    required this.dueItem,
    required this.useBengaliDigits,
  }) : super(key: key);

  // Helper method to format date
  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    // Convert to local date
    final localDate = dateTime.toLocal();
    String day =
        useBengaliDigits
            ? BdTakaFormatter.numberToBengaliDigits(localDate.day)
            : localDate.day.toString();

    String month =
        useBengaliDigits
            ? BdTakaFormatter.numberToBengaliDigits(localDate.month)
            : localDate.month.toString();

    String year =
        useBengaliDigits
            ? BdTakaFormatter.numberToBengaliDigits(localDate.year)
            : localDate.year.toString();

    return "$day/$month/$year";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with close button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF01579B),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'বাকির বিস্তারিত',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildInfoCard([
                  _buildInfoRow(
                    'ক্রেতার নামঃ',
                    dueItem['customer_name'] ?? 'অজানা',
                  ),
                  _buildInfoRow(
                    'ক্রেতার মোবাইলঃ',
                    dueItem['customer_phone'] ?? 'অজানা',
                  ),
                  _buildInfoRow(
                    'বিক্রয়ের তারিখঃ',
                    _formatDate(dueItem['created_at']),
                  ),
                ]),

                const SizedBox(height: 10),

                // Products Information (Demo data as an example)
                const Text(
                  'পণ্যের তথ্য',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildProductsTable(),

                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.payment),
                        label: const Text('বাকি পরিশোধ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF01579B),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // Handle payment action
                          Navigator.pop(context);
                          // Add your payment logic here
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build information rows
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build an info card with multiple rows
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // Helper method to build products table (with demo data)
  Widget _buildProductsTable() {
    // Demo product data
    final demoProducts = [
      {'name': 'চাল (মিনিকেট)', 'quantity': 5, 'unit': 'কেজি', 'price': 350.0},
      {'name': 'আটা', 'quantity': 2, 'unit': 'কেজি', 'price': 100.0},
      {'name': 'সয়াবিন তেল', 'quantity': 1, 'unit': 'লিটার', 'price': 150.0},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'পণ্যের নাম',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'পরিমাণ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'মূল্য',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Table rows
          ...demoProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;

            return Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(product['name'].toString())),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${useBengaliDigits ? BdTakaFormatter.numberToBengaliDigits(product['quantity'] as num) : product['quantity']} ${product['unit']}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '৳ ${BdTakaFormatter.format(product['price'] as double, toBengaliDigits: useBengaliDigits)}',
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          // Total row
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                top: BorderSide(width: 1.5, color: Colors.grey.shade400),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'সর্বমোট',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    '৳ ${BdTakaFormatter.format(600.0, toBengaliDigits: useBengaliDigits)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
