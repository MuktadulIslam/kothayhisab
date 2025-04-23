import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/sales_service.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/core/utils/currency_formatter.dart';

class DuePage extends StatefulWidget {
  final String shopId;
  const DuePage({super.key, required this.shopId});

  @override
  State<DuePage> createState() => _DuePageState();
}

class _DuePageState extends State<DuePage> {
  bool isLoading = true;
  List<Map<String, dynamic>> dueItems = [];
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredItems = [];
  Map<String, List<Map<String, dynamic>>> groupedItems = {};

  // Control whether to use Bengali digits
  bool _useBengaliDigits = true;

  final SalesService _salesService = SalesService();

  @override
  void initState() {
    super.initState();
    fetchDueData();

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
    // Trim whitespace from both ends of the query
    String trimmedQuery = query.trim();

    List<Map<String, dynamic>> items;
    if (trimmedQuery.isEmpty) {
      items = List.from(dueItems);
    } else {
      items =
          dueItems
              .where(
                (item) => item['customer_name'].toLowerCase().contains(
                  trimmedQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    setState(() {
      filteredItems = items;
      groupedItems = _groupItemsByDate(items);
    });
  }

  // Group items by date (formatted as a string)
  Map<String, List<Map<String, dynamic>>> _groupItemsByDate(
    List<Map<String, dynamic>> items,
  ) {
    Map<String, List<Map<String, dynamic>>> result = {};
    for (var item in items) {
      String dateKey = _formatDate(DateTime.parse(item['created_at']));

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
      String day =
          _useBengaliDigits
              ? BdTakaFormatter.numberToBengaliDigits(localDate.day)
              : localDate.day.toString();

      String month =
          _useBengaliDigits
              ? BdTakaFormatter.numberToBengaliDigits(localDate.month)
              : localDate.month.toString();

      String year =
          _useBengaliDigits
              ? BdTakaFormatter.numberToBengaliDigits(localDate.year)
              : localDate.year.toString();

      return "$day/$month/$year";
    }
  }

  // Calculate sum of due amounts for a list of items
  double _calculateTotalDue(List<Map<String, dynamic>> items) {
    return items.fold(
      0.0,
      (total, item) => total + (item['due_amount'] ?? 0.0),
    );
  }

  // Calculate sum of paid amounts for a list of items
  double _calculateTotalPaid(List<Map<String, dynamic>> items) {
    return items.fold(
      0.0,
      (total, item) => total + (item['paid_amount'] ?? 0.0),
    );
  }

  Future<void> fetchDueData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Add method to get due items in DueService
      final result = await _salesService.getDueSales(widget.shopId);

      setState(() {
        dueItems = result;
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
      appBar: CustomAppBar('বাকির হিসাব'),
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
                        hintText: 'ক্রেতার নাম দিয়ে খুঁজুন',
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
          // Container(
          //   color: Colors.grey.shade100,
          //   child: Table(
          //     columnWidths: const {
          //       0: FlexColumnWidth(4),
          //       1: FlexColumnWidth(3),
          //       2: FlexColumnWidth(3),
          //     },
          //     children: [
          //       TableRow(
          //         decoration: BoxDecoration(
          //           color: Colors.grey.shade200,
          //           border: Border(
          //             bottom: BorderSide(color: Colors.grey.shade300),
          //           ),
          //         ),
          //         children: const [
          //           Padding(
          //             padding: EdgeInsets.all(12.0),
          //             child: Text(
          //               'নাম',
          //               style: TextStyle(fontWeight: FontWeight.bold),
          //             ),
          //           ),
          //           Padding(
          //             padding: EdgeInsets.all(12.0),
          //             child: Text(
          //               'বাকি',
          //               style: TextStyle(fontWeight: FontWeight.bold),
          //               textAlign: TextAlign.right,
          //             ),
          //           ),
          //           Padding(
          //             padding: EdgeInsets.all(12.0),
          //             child: Text(
          //               'জমা',
          //               style: TextStyle(fontWeight: FontWeight.bold),
          //               textAlign: TextAlign.right,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : filteredItems.isEmpty
                    ? const Center(child: Text('কোন বাকি পাওয়া যায়নি'))
                    : ListView.builder(
                      itemCount: groupedItems.keys.length,
                      itemBuilder: (context, groupIndex) {
                        final dateKey = groupedItems.keys.elementAt(groupIndex);
                        final dateItems = groupedItems[dateKey]!;
                        final totalDue = _calculateTotalDue(dateItems);
                        final totalPaid = _calculateTotalPaid(dateItems);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header with sum of due and paid amounts
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              color: const Color.fromARGB(239, 222, 239, 245),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateKey,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      // Total items for this date
                                      Text(
                                        'মোট: ${_useBengaliDigits ? BdTakaFormatter.numberToBengaliDigits(dateItems.length) : dateItems.length.toString()}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Sum of due for this date
                                      Text(
                                        'মোট বাকি: ৳ ${BdTakaFormatter.format(totalDue, toBengaliDigits: _useBengaliDigits)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                            255,
                                            193,
                                            51,
                                            41,
                                          ),
                                        ),
                                      ),
                                      // Sum of paid for this date
                                      Text(
                                        'মোট জমা: ৳ ${BdTakaFormatter.format(totalPaid, toBengaliDigits: _useBengaliDigits)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                            255,
                                            12,
                                            101,
                                            15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              color: Colors.grey.shade100,
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(4),
                                  1: FlexColumnWidth(3),
                                  2: FlexColumnWidth(3),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          'নাম',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          'বাকি',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          'জমা',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Items for this date
                            ...dateItems.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> item = entry.value;

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
                                    0: FlexColumnWidth(4),
                                    1: FlexColumnWidth(3),
                                    2: FlexColumnWidth(3),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            item['customer_name'] ?? '',
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            '৳ ${BdTakaFormatter.format(item['due_amount'] ?? 0.0, toBengaliDigits: _useBengaliDigits)}',
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            '৳ ${BdTakaFormatter.format(item['paid_amount'] ?? 0.0, toBengaliDigits: _useBengaliDigits)}',
                                            textAlign: TextAlign.right,
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
        onPressed: fetchDueData,
        backgroundColor: const Color(0xFF01579B),
        child: const Icon(Icons.refresh),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
