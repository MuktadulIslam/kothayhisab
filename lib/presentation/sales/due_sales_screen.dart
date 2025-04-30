import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/sales_service.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/core/utils/currency_formatter.dart';
import 'package:kothayhisab/presentation/sales/due_details_popup.dart';

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
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> filteredItems = [];
  Map<String, List<Map<String, dynamic>>> groupedItems = {};

  // Control whether to use Bengali digits
  final bool _useBengaliDigits = true;

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
    _searchFocusNode.dispose();
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
      groupedItems = _groupItemsByCustomer(items);
    });
  }

  // Group items by customer name
  Map<String, List<Map<String, dynamic>>> _groupItemsByCustomer(
    List<Map<String, dynamic>> items,
  ) {
    // Sort items by customer name first
    items.sort(
      (a, b) => (a['customer_name'] ?? '').toString().toLowerCase().compareTo(
        (b['customer_name'] ?? '').toString().toLowerCase(),
      ),
    );

    Map<String, List<Map<String, dynamic>>> result = {};
    for (var item in items) {
      String customerKey = item['customer_name'] ?? 'Unknown Customer';

      if (!result.containsKey(customerKey)) {
        result[customerKey] = [];
      }

      result[customerKey]!.add(item);
    }

    return result;
  }

  // Format date for display
  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    // Convert to local date
    final localDate = dateTime.toLocal();
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
        groupedItems = _groupItemsByCustomer(result);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  // Function to show the bottom sheet when a row is tapped
  void _showDueDetailsBottomSheet(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This allows the sheet to take up more space
      backgroundColor: Colors.transparent, // Make the background transparent
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {}, // This prevents taps inside the sheet from closing it
          child: DismissibleBottomSheet(
            child: DueDetailsBottomSheet(
              dueItem: item,
              useBengaliDigits: _useBengaliDigits,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('বাকির হিসাব'),
      body: RefreshIndicator(
        onRefresh: fetchDueData,
        child: Column(
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
                        focusNode: _searchFocusNode,
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
                      _searchFocusNode.requestFocus();
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
                          Text(
                            'ফিল্টার',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
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
                      ? const Center(child: Text('কোন বাকি পাওয়া যায়নি'))
                      : ListView.builder(
                        itemCount: groupedItems.keys.length,
                        itemBuilder: (context, groupIndex) {
                          final customerName = groupedItems.keys.elementAt(
                            groupIndex,
                          );
                          final customerItems = groupedItems[customerName]!;
                          final totalDue = _calculateTotalDue(customerItems);
                          final totalPaid = _calculateTotalPaid(customerItems);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Customer header with sum of due and paid amounts
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
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
                                        Expanded(
                                          child: Text(
                                            customerName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Total items for this customer
                                        Text(
                                          'মোট বিক্রয়: ${_useBengaliDigits ? BdTakaFormatter.numberToBengaliDigits(customerItems.length) : customerItems.length.toString()}',
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
                                        // Sum of due for this customer
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
                                        // Sum of paid for this customer
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
                                    0: FlexColumnWidth(5),
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
                                            'তারিখ',
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

                              // Items for this customer
                              ...customerItems.asMap().entries.map((entry) {
                                int index = entry.key;
                                Map<String, dynamic> item = entry.value;

                                return InkWell(
                                  onTap: () {
                                    // Open bottom sheet when a row is tapped
                                    _showDueDetailsBottomSheet(context, item);
                                  },
                                  child: Container(
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
                                        0: FlexColumnWidth(5),
                                        1: FlexColumnWidth(3),
                                        2: FlexColumnWidth(3),
                                      },
                                      children: [
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Text(
                                                item['created_at'] != null
                                                    ? _formatDate(
                                                      item['created_at'],
                                                    )
                                                    : 'N/A',
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Text(
                                                '৳ ${BdTakaFormatter.format(item['due_amount'] ?? 0.0, toBengaliDigits: _useBengaliDigits)}',
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Text(
                                                '৳ ${BdTakaFormatter.format(item['paid_amount'] ?? 0.0, toBengaliDigits: _useBengaliDigits)}',
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}

// Custom Bottom Sheet that can be dismissed by tapping outside
class DismissibleBottomSheet extends StatelessWidget {
  final Widget child;

  const DismissibleBottomSheet({Key? key, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height *
          0.8, // Takes up 4/5 of the screen height
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Stack(
        children: [
          // This invisible container covers the entire screen and closes the bottom sheet when tapped
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
          ),
          // The actual bottom sheet content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height:
                  MediaQuery.of(context).size.height *
                  0.8, // Takes up 4/5 of the screen height
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
