import 'dart:convert';

class InventoryItem {
  String name;
  double price; // Changed from num to double
  num quantity;
  String quantityDescription;
  int? id;
  int? inventoryId;

  InventoryItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.quantityDescription,
    this.id,
    this.inventoryId,
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
      id: json['id'] ?? 0,
      inventoryId: json['inventory_id'] ?? 0,
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

/// Model for inventory entry containing details and metadata
class InventoryEntry {
  String inventoryText;
  double totalAmount;
  String currency;
  int id;
  String createdAt;
  int userId;
  String userIdentifier;
  int? itemCount;
  List<InventoryItem> inventoryDetails;

  InventoryEntry({
    required this.inventoryText,
    required this.totalAmount,
    this.currency = "৳",
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.userIdentifier,
    this.itemCount,
    required this.inventoryDetails,
  });

  factory InventoryEntry.fromJson(Map<String, dynamic> json) {
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

    List<InventoryItem> parseInventoryDetails(List<dynamic>? details) {
      if (details == null) return [];
      return details.map((item) => InventoryItem.fromJson(item)).toList();
    }

    return InventoryEntry(
      inventoryText: fixEncoding(json['inventory_text'] ?? ''),
      totalAmount: json['total_amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? "৳",
      id: json['id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      userId: json['user_id'] ?? 0,
      userIdentifier: json['user_identifier'] ?? '',
      itemCount: json['item_count'],
      inventoryDetails: parseInventoryDetails(json['inventory_details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventory_text': inventoryText,
      'total_amount': totalAmount,
      'currency': currency,
      'id': id,
      'created_at': createdAt,
      'user_id': userId,
      'user_identifier': userIdentifier,
      'item_count': itemCount,
      'inventory_details':
          inventoryDetails.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model for the complete API response with pagination
class GetInventoryResponse {
  List<InventoryEntry> items;
  int total;
  int skip;
  int limit;
  bool hasMore;

  GetInventoryResponse({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
    required this.hasMore,
  });

  factory GetInventoryResponse.fromJson(Map<String, dynamic> json) {
    List<InventoryEntry> parseItems(List<dynamic>? items) {
      if (items == null) return [];
      return items.map((item) => InventoryEntry.fromJson(item)).toList();
    }

    return GetInventoryResponse(
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

// Example usage:
/*
void fetchInventory() async {
  final response = await http.get(Uri.parse('your_api_endpoint'));
  
  if (response.statusCode == 200) {
    final inventoryResponse = InventoryResponse.fromJson(json.decode(response.body));
    
    // Access the data
    for (var entry in inventoryResponse.items) {
      print('Inventory: ${entry.inventoryText}');
      print('Total Amount: ${entry.currency}${entry.totalAmount}');
      
      for (var item in entry.inventoryDetails) {
        print('  - ${item.productName}: ${item.quantity} ${item.quantityDescription} at ${item.price}');
      }
    }
    
    // Pagination info
    print('Showing ${inventoryResponse.items.length} of ${inventoryResponse.total} items');
    print('Has more: ${inventoryResponse.hasMore}');
  }
}
*/
