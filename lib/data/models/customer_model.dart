// lib/data/models/customer_model.dart
class Customer {
  final int? id;
  final String name;
  final String address;
  final String mobile;
  final String? photoUrl;
  final int? shopId;
  final int? userId;
  final bool activeStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double totalDue;

  Customer({
    this.id,
    required this.name,
    required this.address,
    required this.mobile,
    this.photoUrl,
    this.shopId,
    this.userId,
    this.activeStatus = true,
    this.createdAt,
    this.updatedAt,
    this.totalDue = 0,
  });

  // Factory method to create a Customer from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    // Safely parse numeric values with null checks
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) {
        try {
          return double.parse(value);
        } catch (_) {
          return 0;
        }
      }
      return 0;
    }

    return Customer(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      mobile: json['mobile'] ?? '',
      photoUrl: json['photo_url'],
      shopId: json['shop_id'],
      userId: json['user_id'],
      activeStatus: json['active_status'] ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      totalDue: parseDouble(json['total_due']),
    );
  }

  // Convert Customer object to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'address': address,
      'mobile': mobile,
      'active_status': activeStatus,
    };

    // Only add non-null fields
    if (id != null) data['id'] = id;
    if (photoUrl != null) data['photo_url'] = photoUrl;
    if (shopId != null) data['shop_id'] = shopId;
    if (userId != null) data['user_id'] = userId;

    data['total_due'] = totalDue;

    return data;
  }

  // Create a copy of Customer with optional parameter updates
  Customer copyWith({
    int? id,
    String? name,
    String? address,
    String? mobile,
    String? photoUrl,
    int? shopId,
    int? userId,
    bool? activeStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalDue,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      mobile: mobile ?? this.mobile,
      photoUrl: photoUrl ?? this.photoUrl,
      shopId: shopId ?? this.shopId,
      userId: userId ?? this.userId,
      activeStatus: activeStatus ?? this.activeStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalDue: totalDue ?? this.totalDue,
    );
  }
}
