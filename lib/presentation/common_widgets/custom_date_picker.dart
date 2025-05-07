import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatefulWidget {
  /// The initially selected date (defaults to current date if null)
  final DateTime? initialDate;

  /// The earliest date the user is permitted to pick
  final DateTime? firstDate;

  /// The latest date the user is permitted to pick
  final DateTime? lastDate;

  /// Date format to display the selected date
  final String dateFormat;

  /// Hint text when no date is selected
  final String hintText;

  /// Icon for the date picker button
  final IconData icon;

  /// Theme color for the date picker
  final Color? themeColor;

  /// Callback function when date is selected
  final Function(DateTime) onDateSelected;

  /// Border radius for the text field
  final double borderRadius;

  /// Use Bengali digits for displaying date
  final bool useBengaliDigits;

  const CustomDatePicker({
    Key? key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.dateFormat = 'yyyy-MM-dd',
    this.hintText = 'তারিখ নির্বাচন করুন',
    this.icon = Icons.calendar_today,
    this.themeColor,
    required this.onDateSelected,
    this.borderRadius = 8.0,
    this.useBengaliDigits = true,
  }) : super(key: key);

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _selectedDate;
  late DateTime _firstDate;
  late DateTime _lastDate;
  bool _mounted = true;
  bool _isCalendarVisible = false;

  // Current displayed month in the calendar
  late DateTime _currentDisplayMonth;

  // For handling overflow
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    // Always default to current date if not provided
    _selectedDate = widget.initialDate ?? DateTime.now();
    _firstDate = widget.firstDate ?? DateTime(1900);
    _lastDate = widget.lastDate ?? DateTime(2100);
    _currentDisplayMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);

    // Call the callback with the initial date to ensure it's passed to services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        widget.onDateSelected(_selectedDate);
      }
    });
  }

  @override
  void dispose() {
    _hideCalendar();
    _mounted = false;
    super.dispose();
  }

  // Safe setState that checks if the widget is still mounted
  void _safeSetState(VoidCallback fn) {
    if (_mounted && mounted) {
      setState(fn);
    }
  }

  // Format date based on settings
  String _formatDate(DateTime date) {
    if (widget.useBengaliDigits) {
      return DatePickerUtils.formatBengaliDate(date);
    } else {
      return DateFormat(widget.dateFormat).format(date);
    }
  }

  // Check if a date is selectable based on first and last date constraints
  bool _isDateSelectable(DateTime date) {
    return !date.isBefore(_firstDate) && !date.isAfter(_lastDate);
  }

  // Show the calendar in an overlay to avoid overflow issues
  void _showCalendar() {
    _hideCalendar();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isCalendarVisible = true;
  }

  // Hide the calendar overlay
  void _hideCalendar() {
    _isCalendarVisible = false;
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  // Create the overlay entry for the calendar
  OverlayEntry _createOverlayEntry() {
    // Get the RenderBox of the date picker field
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 5.0),
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 350, // Restrict height to avoid overflow
                    ),
                    child: StatefulBuilder(
                      builder: (context, setOverlayState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Month and year navigation
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.chevron_left),
                                    onPressed: () {
                                      setOverlayState(() {
                                        _currentDisplayMonth = DateTime(
                                          _currentDisplayMonth.year,
                                          _currentDisplayMonth.month - 1,
                                          1,
                                        );
                                      });
                                    },
                                    color:
                                        widget.themeColor ??
                                        Theme.of(context).primaryColor,
                                  ),
                                  Text(
                                    widget.useBengaliDigits
                                        ? DatePickerUtils.getBengaliMonthYear(
                                          _currentDisplayMonth,
                                        )
                                        : DateFormat(
                                          'MMMM yyyy',
                                        ).format(_currentDisplayMonth),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.chevron_right),
                                    onPressed: () {
                                      setOverlayState(() {
                                        _currentDisplayMonth = DateTime(
                                          _currentDisplayMonth.year,
                                          _currentDisplayMonth.month + 1,
                                          1,
                                        );
                                      });
                                    },
                                    color:
                                        widget.themeColor ??
                                        Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),

                            // Weekday headers
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: _buildWeekdayHeaders(),
                              ),
                            ),

                            // Calendar grid
                            Flexible(
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: _buildCalendarDays(
                                      _currentDisplayMonth,
                                      setOverlayState,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Done button
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _hideCalendar();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      widget.themeColor ??
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  widget.useBengaliDigits ? 'সেভ করুন' : 'Done',
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: () {
          if (_isCalendarVisible) {
            _hideCalendar();
          } else {
            _showCalendar();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade500),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(_selectedDate),
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ),
              Icon(
                widget.icon,
                color: widget.themeColor ?? Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build weekday headers (Sun, Mon, etc.)
  List<Widget> _buildWeekdayHeaders() {
    final List<String> weekdays =
        widget.useBengaliDigits
            ? ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি']
            : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return List.generate(7, (index) {
      return Expanded(
        child: Center(
          child: Text(
            weekdays[index],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  index == 0 || index == 6
                      ? Colors.red.shade300
                      : Colors.black87,
            ),
          ),
        ),
      );
    });
  }

  // Build calendar days
  List<Widget> _buildCalendarDays(
    DateTime displayMonth,
    StateSetter setOverlayState,
  ) {
    List<Widget> calendarRows = [];

    // Get the first day of the month
    final DateTime firstDayOfMonth = displayMonth;

    // Get the number of days in the month
    final int daysInMonth =
        DateTime(firstDayOfMonth.year, firstDayOfMonth.month + 1, 0).day;

    // Get the day of week for the first day (0 = Sunday, 1 = Monday, etc.)
    final int firstWeekday = firstDayOfMonth.weekday % 7;

    // Calculate total number of cells needed (previous month days + current month days)
    final int totalCells = firstWeekday + daysInMonth;

    // Calculate number of rows needed (ceiling of totalCells / 7)
    final int numRows = (totalCells / 7).ceil();

    int dayCounter = 1 - firstWeekday;

    // Build rows
    for (int row = 0; row < numRows; row++) {
      List<Widget> rowChildren = [];

      // Build cells for each row
      for (int col = 0; col < 7; col++) {
        if (dayCounter > 0 && dayCounter <= daysInMonth) {
          // Current month days
          final date = DateTime(
            displayMonth.year,
            displayMonth.month,
            dayCounter,
          );

          final bool isSelected =
              date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          final bool isSelectable = _isDateSelectable(date);

          rowChildren.add(
            Expanded(
              child: GestureDetector(
                onTap:
                    isSelectable
                        ? () {
                          setState(() {
                            _selectedDate = date;
                          });
                          widget.onDateSelected(_selectedDate);
                          _hideCalendar();
                        }
                        : null,
                child: Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? widget.themeColor ??
                                Theme.of(context).primaryColor
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius / 2,
                    ),
                  ),
                  height: 36,
                  child: Center(
                    child: Text(
                      widget.useBengaliDigits
                          ? DatePickerUtils._convertToBengaliNumeral(
                            dayCounter.toString(),
                          )
                          : dayCounter.toString(),
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : isSelectable
                                ? (col == 0 || col == 6)
                                    ? Colors.red.shade300
                                    : Colors.black87
                                : Colors.grey.shade400,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          // Empty cell or previous/next month days
          rowChildren.add(
            Expanded(
              child: Container(
                height: 36,
                margin: EdgeInsets.all(2),
                child: Center(
                  child: Text(
                    '',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),
          );
        }
        dayCounter++;
      }

      calendarRows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: rowChildren,
        ),
      );
    }

    return calendarRows;
  }
}

// Utility class for implementing the date picker in different pages
class DatePickerUtils {
  // Helper method to format dates
  static String formatDate(DateTime date, String format) {
    return DateFormat(format).format(date);
  }

  // Get Bengali month and year
  static String getBengaliMonthYear(DateTime date) {
    final Map<String, String> bengaliMonths = {
      'January': 'জানুয়ারি',
      'February': 'ফেব্রুয়ারি',
      'March': 'মার্চ',
      'April': 'এপ্রিল',
      'May': 'মে',
      'June': 'জুন',
      'July': 'জুলাই',
      'August': 'আগস্ট',
      'September': 'সেপ্টেম্বর',
      'October': 'অক্টোবর',
      'November': 'নভেম্বর',
      'December': 'ডিসেম্বর',
    };

    String englishMonth = DateFormat('MMMM').format(date);
    String bengaliMonth = bengaliMonths[englishMonth] ?? englishMonth;
    String year = _convertToBengaliNumeral(date.year.toString());

    return '$bengaliMonth $year';
  }

  // Convert date to Bengali format
  static String formatBengaliDate(DateTime date) {
    final Map<String, String> bengaliMonths = {
      'January': 'জানুয়ারি',
      'February': 'ফেব্রুয়ারি',
      'March': 'মার্চ',
      'April': 'এপ্রিল',
      'May': 'মে',
      'June': 'জুন',
      'July': 'জুলাই',
      'August': 'আগস্ট',
      'September': 'সেপ্টেম্বর',
      'October': 'অক্টোবর',
      'November': 'নভেম্বর',
      'December': 'ডিসেম্বর',
    };

    String englishMonth = DateFormat('MMMM').format(date);
    String bengaliMonth = bengaliMonths[englishMonth] ?? englishMonth;

    // Convert day and year to Bengali numerals
    String day = _convertToBengaliNumeral(date.day.toString());
    String year = _convertToBengaliNumeral(date.year.toString());

    return '$day $bengaliMonth, $year';
  }

  // Convert English numerals to Bengali numerals
  static String _convertToBengaliNumeral(String number) {
    const Map<String, String> bengaliNumerals = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };

    String result = '';
    for (int i = 0; i < number.length; i++) {
      result += bengaliNumerals[number[i]] ?? number[i];
    }
    return result;
  }
}
