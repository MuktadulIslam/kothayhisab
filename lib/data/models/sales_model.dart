import 'dart:convert';

class SalesItem {
  String name;
  double price; // Changed from num to double
  String currency;
  num quantity;
  String quantityDescription;
  String sourceText;
  DateTime entryDate;

  SalesItem({
    required this.name,
    required this.price,
    required this.currency,
    required this.quantity,
    required this.quantityDescription,
    required this.sourceText,
    required this.entryDate,
  });

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    // Fix encoding for text fields
    String fixEncoding(String text) {
      try {
        // This handles cases where the text is already properly encoded
        // but might have encoding issues
        if (text.contains('à') || text.contains('§')) {
          // If it looks like improperly encoded Bengali text, try to fix it
          List<int> bytes = text.codeUnits;
          return utf8.decode(bytes);
        }
      } catch (e) {
        print('Error fixing encoding: $e');
      }
      return text;
    }

    // Convert price to double
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('Error parsing price from string: $e');
          return 0.0;
        }
      }
      return 0.0;
    }

    return SalesItem(
      name: fixEncoding(json['name'] ?? ''),
      price: parsePrice(json['price']),
      currency: fixEncoding(json['currency'] ?? '৳'),
      quantity: json['quantity'] ?? 0,
      quantityDescription: fixEncoding(json['quantity_description'] ?? ''),
      sourceText: fixEncoding(json['source_text'] ?? ''),
      entryDate:
          json['entry_date'] != null
              ? DateTime.parse(json['entry_date'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'currency': currency,
      'quantity': quantity,
      'quantity_description': quantityDescription,
      'source_text': sourceText,
    };
  }
}
