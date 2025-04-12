// lib/screens/inventory_page.dart
import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/inventory_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  bool isLoading = true;
  List<InventoryItem> inventoryItems = [];
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  List<InventoryItem> filteredItems = [];
  Map<String, List<InventoryItem>> groupedItems = {};

  final InventoryService _inventoryService = InventoryService();

  @override
  void initState() {
    super.initState();
    fetchInventoryData();

    _searchController.addListener(() {
      filterItems(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterItems(String query) {
    List<InventoryItem> items;
    if (query.isEmpty) {
      items = List.from(inventoryItems);
    } else {
      items =
          inventoryItems
              .where(
                (item) => item.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    }

    setState(() {
      filteredItems = items;
      groupedItems = _groupItemsByDate(items);
    });
  }

  // Group items by date (formatted as a string)
  Map<String, List<InventoryItem>> _groupItemsByDate(
    List<InventoryItem> items,
  ) {
    Map<String, List<InventoryItem>> result = {};

    for (var item in items) {
      String dateKey = _formatDate(item.entryDate);

      if (!result.containsKey(dateKey)) {
        result[dateKey] = [];
      }

      result[dateKey]!.add(item);
    }

    return result;
  }

  // Format date for display
  String _formatDate(DateTime date) {
    // Convert to local date
    final localDate = date.toLocal();

    // Check if date is today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(localDate.year, localDate.month, localDate.day);

    if (itemDate == today) {
      return "আজ";
    } else if (itemDate == today.subtract(const Duration(days: 1))) {
      return "গতকাল";
    } else {
      // Format date in Bengali
      return "${localDate.day}/${localDate.month}/${localDate.year}";
    }
  }

  Future<void> fetchInventoryData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Add method to get inventory items in InventoryService
      final result = await _inventoryService.getInventoryItems();

      setState(() {
        inventoryItems = result;
        filteredItems = List.from(result);
        groupedItems = _groupItemsByDate(result);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'মজুদ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF01579B),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    // Implement filter functionality
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF01579B),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.filter_list, color: Colors.white),
                        SizedBox(width: 5),
                        Text('ফিল্টার', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey.shade100,
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'নাম',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'মূল্য',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'পরিমাণ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : filteredItems.isEmpty
                    ? const Center(child: Text('কোন আইটেম পাওয়া যায়নি'))
                    : ListView.builder(
                      itemCount: groupedItems.keys.length,
                      itemBuilder: (context, groupIndex) {
                        final dateKey = groupedItems.keys.elementAt(groupIndex);
                        final dateItems = groupedItems[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              color: Colors.grey.shade200,
                              width: double.infinity,
                              child: Text(
                                dateKey,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            // Items for this date
                            ...dateItems.asMap().entries.map((entry) {
                              int index = entry.key;
                              InventoryItem item = entry.value;

                              return Container(
                                decoration: BoxDecoration(
                                  color:
                                      index % 2 == 0
                                          ? Colors.white
                                          : Colors.grey.shade100,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(2),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(item.name),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style:
                                                  DefaultTextStyle.of(
                                                    context,
                                                  ).style,
                                              children: [
                                                TextSpan(text: item.currency),
                                                const TextSpan(text: ' '),
                                                TextSpan(
                                                  text: item.price.toString(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style:
                                                  DefaultTextStyle.of(
                                                    context,
                                                  ).style,
                                              children: [
                                                TextSpan(
                                                  text:
                                                      item.quantity.toString(),
                                                ),
                                                if (item
                                                    .quantityDescription
                                                    .isNotEmpty)
                                                  TextSpan(
                                                    text:
                                                        ' ${item.quantityDescription}',
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchInventoryData,
        backgroundColor: const Color(0xFF01579B),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
