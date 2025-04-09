// main.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';

class ShopViewScreen extends StatefulWidget {
  const ShopViewScreen({super.key});

  @override
  State<ShopViewScreen> createState() => _ShopViewScreenState();
}

class _ShopViewScreenState extends State<ShopViewScreen> {
  List<ShopItem> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // Simulating loading data from a JSON file
    // In a real app, you would use:
    // final String response = await rootBundle.loadString('assets/shop_data.json');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final String dummyJson = '''
    {
      "items": [
        {
          "id": 1,
          "name": "দোকান-১",
          "amount": "টাকা"
        },
        {
          "id": 2,
          "name": "দোকান-২",
          "amount": "টাকা"
        }
      ]
    }
    ''';

    final data = json.decode(dummyJson);

    setState(() {
      items =
          (data['items'] as List)
              .map(
                (item) => ShopItem(
                  id: item['id'],
                  name: item['name'],
                  amount: item['amount'],
                ),
              )
              .toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('দোকান তথ্য'),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Table(
                        border: TableBorder.all(color: Colors.grey),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                        },
                        children: [
                          // Table Header
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            children: const [
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'নাম',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'লোকেশন',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Table Data Rows
                          ...items.map((item) => _buildTableRow(item)).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/store/add_shops');
        },
        child: const Icon(Icons.add),
        tooltip: 'Add new shop',
      ),
    );
  }

  TableRow _buildTableRow(ShopItem item) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item.name),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item.amount),
          ),
        ),
      ],
    );
  }
}

class ShopItem {
  final int id;
  final String name;
  final String amount;

  ShopItem({required this.id, required this.name, required this.amount});
}
