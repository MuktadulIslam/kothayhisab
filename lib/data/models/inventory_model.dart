import 'dart:convert';

class InventoryItem {
  String name;
  double price; // Changed from num to double
  num quantity;
  String quantityDescription;

  InventoryItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.quantityDescription,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
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

    return InventoryItem(
      name: fixEncoding(json['product_name'] ?? ''),
      price: parsePrice(json['price']),
      quantity: json['quantity'] ?? 0,
      quantityDescription: fixEncoding(json['quantity_description'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': name,
      'price': price,
      'quantity': quantity,
      'quantity_description': quantityDescription,
    };
  }
}
