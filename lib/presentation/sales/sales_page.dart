// lib/screens/sales_page.dart
import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/sales_service.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/core/utils/currency_formatter.dart';
import 'package:kothayhisab/data/models/sales_model.dart';

class SalesPage extends StatefulWidget {
  final String shopId;
  const SalesPage({super.key, required this.shopId});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  bool isLoading = true;
  GetSalesResponse? salesResponse;
  List<SaleEntry> filteredEntries = [];
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Control whether to use Bengali digits
  bool _useBengaliDigits = true;

  final SalesService _salesService = SalesService();

  @override
  void initState() {
    super.initState();
    fetchSalesData();

    _searchController.addListener(() {
      filterEntries(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void filterEntries(String query) {
    // Trim whitespace from both ends of the query
    String trimmedQuery = query.trim().toLowerCase();

    if (salesResponse == null) return;

    setState(() {
      if (trimmedQuery.isEmpty) {
        // If search is empty, show all entries
        filteredEntries = List.from(salesResponse!.items);
      } else {
        // Create a new list for filtered entries
        List<SaleEntry> newFilteredEntries = [];

        for (var entry in salesResponse!.items) {
          // Find only the sales items that match the search query
          List<SalesItem> matchingItems =
              entry.saleDetails
                  .where(
                    (item) => item.name.toLowerCase().contains(trimmedQuery),
                  )
                  .toList();

          if (matchingItems.isNotEmpty) {
            // Create a new entry with only the matching items
            SaleEntry filteredEntry = SaleEntry(
              salesText: entry.salesText,
              totalAmount: matchingItems.fold(
                0.0,
                (sum, item) => sum + item.price,
              ),
              currency: entry.currency,
              id: entry.id,
              createdAt: entry.createdAt,
              userId: entry.userId,
              userIdentifier: entry.userIdentifier,
              itemCount: matchingItems.length,
              saleDetails: matchingItems,
            );
            newFilteredEntries.add(filteredEntry);
          }
        }

        filteredEntries = newFilteredEntries;
      }
    });
  }

  // Format time in Bengali style
  String _formatTimeBengali(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();

    // Convert to Bengali numbers
    String getBengaliNumber(int number) {
      return _useBengaliDigits
          ? BdTakaFormatter.numberToBengaliDigits(number)
          : number.toString();
    }

    // Month name in Bengali
    List<String> bengaliMonths = [
      'জানুয়ারী',
      'ফেব্রুয়ারী',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর',
    ];
    String month = bengaliMonths[dateTime.month - 1];

    // Time period (morning, afternoon, evening, night)
    String timePeriod;
    int hour = dateTime.hour;

    if (hour >= 5 && hour < 12) {
      timePeriod = 'সকাল';
    } else if (hour >= 12 && hour < 17) {
      timePeriod = 'দুপুর';
    } else if (hour >= 17 && hour < 19) {
      timePeriod = 'বিকাল';
    } else if (hour >= 19 && hour < 22) {
      timePeriod = 'সন্ধ্যা';
    } else {
      timePeriod = 'রাত';
    }

    // Convert to 12-hour format
    int hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    // Format: "সকাল ৭টা, ২৬ ফেব্রুয়ারী, ২০২৫"
    return '$timePeriod ${getBengaliNumber(hour12)}টা, ${getBengaliNumber(dateTime.day)} $month, ${getBengaliNumber(dateTime.year)}';
  }

  // Format date for display - just the date part without time
  String _formatDateOnly(String dateString) {
    DateTime date = DateTime.parse(dateString);
    // Convert to local date
    final localDate = date.toLocal();

    // Check if date is today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(localDate.year, localDate.month, localDate.day);

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

    if (itemDate == today) {
      return "আজ ($day/$month/$year)";
    } else if (itemDate == today.subtract(const Duration(days: 1))) {
      return "গতকাল ($day/$month/$year)";
    } else {
      return "$day/$month/$year";
    }
  }

  // Group entries by date
  Map<String, List<SaleEntry>> _groupEntriesByDate(List<SaleEntry> entries) {
    Map<String, List<SaleEntry>> result = {};

    for (var entry in entries) {
      // Use only the date part of the timestamp
      String dateKey = _formatDateOnly(entry.createdAt);

      if (!result.containsKey(dateKey)) {
        result[dateKey] = [];
      }

      result[dateKey]!.add(entry);
    }

    return result;
  }

  // Show details bottom sheet
  void _showDetailsBottomSheet(BuildContext context, SaleEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 1.0,
          maxChildSize: 1.0,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle for dragging
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Original sales text
                    Text(
                      'বিক্রয় বিবরণ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(entry.salesText),
                    ),
                    const SizedBox(height: 16),

                    // User and Time in one row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Added by user
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'যোগ করেছেন',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(entry.userIdentifier),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Creation date/time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'সময়',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(_formatTimeBengali(entry.createdAt)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Total - moved before the table
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'মোট:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${entry.currency} ${BdTakaFormatter.format(entry.totalAmount, toBengaliDigits: _useBengaliDigits)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Items section title
                    Text(
                      'বিক্রি আইটেম',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Table header
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
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
                                child: Text(
                                  'নাম',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'পরিমাণ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'মূল্য',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Table content - No longer in an Expanded widget
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      // No extra padding or margin here
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(entry.saleDetails.length, (
                          index,
                        ) {
                          final item = entry.saleDetails[index];
                          final bool isFirstItem = index == 0;
                          final bool isLastItem =
                              index == entry.saleDetails.length - 1;

                          return Container(
                            // No margin here
                            decoration: BoxDecoration(
                              color:
                                  index % 2 == 0
                                      ? Colors.white
                                      : Colors.grey.shade100,
                              border: Border(
                                bottom:
                                    isLastItem
                                        ? BorderSide.none
                                        : BorderSide(
                                          color: Colors.grey.shade200,
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
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
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
                                                  _useBengaliDigits
                                                      ? BdTakaFormatter.numberToBengaliDigits(
                                                        item.quantity,
                                                      )
                                                      : item.quantity
                                                          .toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
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
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: RichText(
                                        textAlign: TextAlign.right,
                                        text: TextSpan(
                                          style:
                                              DefaultTextStyle.of(
                                                context,
                                              ).style,
                                          children: [
                                            TextSpan(text: entry.currency),
                                            const TextSpan(text: ' '),
                                            TextSpan(
                                              text: BdTakaFormatter.format(
                                                item.price,
                                                toBengaliDigits:
                                                    _useBengaliDigits,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
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
                        }),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> fetchSalesData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await _salesService.getSalesItems(widget.shopId);

      setState(() {
        salesResponse = result;
        filteredEntries = List.from(result.items);
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
    // Group the entries by date
    Map<String, List<SaleEntry>> groupedEntries =
        filteredEntries.isNotEmpty ? _groupEntriesByDate(filteredEntries) : {};

    // Sort the dates (keys) in descending order
    List<String> sortedDates =
        groupedEntries.keys.toList()..sort((a, b) {
          // Handle "আজ" and "গতকাল"
          if (a.startsWith("আজ")) return -1;
          if (b.startsWith("আজ")) return 1;
          if (a.startsWith("গতকাল")) return -1;
          if (b.startsWith("গতকাল")) return 1;

          // For other dates, sort by the date string
          return b.compareTo(a);
        });

    return Scaffold(
      appBar: CustomAppBar('বিক্রয় তালিকা'),
      body: RefreshIndicator(
        onRefresh: fetchSalesData,
        child: Column(
          children: [
            // Search bar
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
                      // Set focus to search field when filter is tapped
                      _searchFocusNode.requestFocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF4CAF50,
                        ), // Changed to green for sales
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

            // Table header - global header for all items
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
                          'পরিমাণ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'মূল্য',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage))
                      : filteredEntries.isEmpty
                      ? const Center(child: Text('কোন বিক্রয় পাওয়া যায়নি'))
                      : ListView.builder(
                        itemCount: sortedDates.length,
                        itemBuilder: (context, dateIndex) {
                          final dateKey = sortedDates[dateIndex];
                          final dateEntries = groupedEntries[dateKey]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date header with total amount
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                color: Colors.grey.shade200,
                                width: double.infinity,
                                child: Row(
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
                                    // Calculate and display total for this date
                                    Text(
                                      'মোট: ${dateEntries.first.currency} ${BdTakaFormatter.format(dateEntries.fold(0.0, (sum, entry) => sum + entry.totalAmount), toBengaliDigits: _useBengaliDigits)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),

                              // Display all sales items for each date (flattened view but with group spacing and borders)
                              ...dateEntries.asMap().entries.expand((
                                entryWithIndex,
                              ) {
                                int entryIndex = entryWithIndex.key;
                                SaleEntry entry = entryWithIndex.value;

                                // Collect all the item widgets for this entry
                                List<Widget> itemWidgets = [];

                                // If this isn't the first entry in the date, add some spacing
                                if (entryIndex > 0) {
                                  itemWidgets.add(
                                    Container(
                                      height: 12,
                                      color: Colors.grey.shade50,
                                    ),
                                  );
                                }

                                // Create a container for this entire entry group with a border
                                itemWidgets.add(
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade500,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Column(
                                      children:
                                          entry.saleDetails.asMap().entries.map((
                                            itemEntry,
                                          ) {
                                            int itemIndex = itemEntry.key;
                                            SalesItem item = itemEntry.value;

                                            // Calculate if this is the first or last item for border radius
                                            bool isFirstItem = itemIndex == 0;
                                            bool isLastItem =
                                                itemIndex ==
                                                entry.saleDetails.length - 1;

                                            return InkWell(
                                              onTap:
                                                  () => _showDetailsBottomSheet(
                                                    context,
                                                    entry,
                                                  ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      itemIndex % 2 == 0
                                                          ? Colors.white
                                                          : Colors.grey.shade50,
                                                  borderRadius: BorderRadius.vertical(
                                                    top:
                                                        isFirstItem
                                                            ? const Radius.circular(
                                                              8,
                                                            )
                                                            : Radius.zero,
                                                    bottom:
                                                        isLastItem
                                                            ? const Radius.circular(
                                                              8,
                                                            )
                                                            : Radius.zero,
                                                  ),
                                                  border:
                                                      !isLastItem
                                                          ? Border(
                                                            bottom: BorderSide(
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade300,
                                                              width: 0.5,
                                                            ),
                                                          )
                                                          : null,
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
                                                          padding:
                                                              const EdgeInsets.all(
                                                                12.0,
                                                              ),
                                                          child: Text(
                                                            item.name,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                12.0,
                                                              ),
                                                          child: RichText(
                                                            text: TextSpan(
                                                              style:
                                                                  DefaultTextStyle.of(
                                                                    context,
                                                                  ).style,
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      _useBengaliDigits
                                                                          ? BdTakaFormatter.numberToBengaliDigits(
                                                                            item.quantity,
                                                                          )
                                                                          : item
                                                                              .quantity
                                                                              .toString(),
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
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                12.0,
                                                              ),
                                                          child: RichText(
                                                            textAlign:
                                                                TextAlign.right,
                                                            text: TextSpan(
                                                              style:
                                                                  DefaultTextStyle.of(
                                                                    context,
                                                                  ).style,
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      entry
                                                                          .currency,
                                                                ),
                                                                const TextSpan(
                                                                  text: ' ',
                                                                ),
                                                                TextSpan(
                                                                  text: BdTakaFormatter.format(
                                                                    item.price,
                                                                    toBengaliDigits:
                                                                        _useBengaliDigits,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                );

                                return itemWidgets;
                              }).toList(),

                              // Add spacing between date sections
                              const SizedBox(height: 8),
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
