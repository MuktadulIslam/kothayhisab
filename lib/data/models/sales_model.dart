import 'dart:convert';

class SalesItem {
  String name;
  double price;
  num quantity;
  String quantityDescription;
  int? id;
  int? saleId;

  SalesItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.quantityDescription,
    this.id,
    this.saleId,
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
      name: fixEncoding(json['product_name'] ?? ''),
      price: parsePrice(json['price']),
      quantity: json['quantity'] ?? 0,
      quantityDescription: fixEncoding(json['quantity_description'] ?? ''),
      id: json['id'],
      saleId: json['sale_id'],
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

/// Model for sale entry containing details and metadata
class SaleEntry {
  String salesText;
  double totalAmount;
  String currency;
  int id;
  String createdAt;
  int userId;
  String userIdentifier;
  int? itemCount;
  List<SalesItem> saleDetails;

  SaleEntry({
    required this.salesText,
    required this.totalAmount,
    this.currency = "৳",
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.userIdentifier,
    this.itemCount,
    required this.saleDetails,
  });

  factory SaleEntry.fromJson(Map<String, dynamic> json) {
    // Fix encoding for text fields
    String fixEncoding(String? text) {
      if (text == null) return '';

      try {
        if (text.contains('à') || text.contains('§')) {
          List<int> bytes = text.codeUnits;
          return utf8.decode(bytes);
        }
      } catch (e) {
        print('Error fixing encoding: $e');
      }
      return text;
    }

    List<SalesItem> parseSaleDetails(List<dynamic>? details) {
      if (details == null) return [];
      return details.map((item) => SalesItem.fromJson(item)).toList();
    }

    return SaleEntry(
      salesText: fixEncoding(json['sales_text'] ?? ''),
      totalAmount: json['total_amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? "৳",
      id: json['id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      userId: json['user_id'] ?? 0,
      userIdentifier: json['user_identifier'] ?? '',
      itemCount: json['item_count'],
      saleDetails: parseSaleDetails(json['sale_details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sales_text': salesText,
      'total_amount': totalAmount,
      'currency': currency,
      'id': id,
      'created_at': createdAt,
      'user_id': userId,
      'user_identifier': userIdentifier,
      'item_count': itemCount,
      'sale_details': saleDetails.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model for the complete API response with pagination
class GetSalesResponse {
  List<SaleEntry> items;
  int total;
  int skip;
  int limit;
  bool hasMore;

  GetSalesResponse({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
    required this.hasMore,
  });

  factory GetSalesResponse.fromJson(Map<String, dynamic> json) {
    List<SaleEntry> parseItems(List<dynamic>? items) {
      if (items == null) return [];
      return items.map((item) => SaleEntry.fromJson(item)).toList();
    }

    return GetSalesResponse(
      items: parseItems(json['items']),
      total: json['total'] ?? 0,
      skip: json['skip'] ?? 0,
      limit: json['limit'] ?? 0,
      hasMore: json['has_more'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
      'has_more': hasMore,
    };
  }
}
