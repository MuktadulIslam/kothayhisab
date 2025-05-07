class Shop {
  final String name;
  final String userRole; // Changed to a regular String
  final String address;
  final String gpsLocation;
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Shop({
    required this.name,
    required this.address,
    required this.gpsLocation,
    this.userRole = "Owner", // Default value, can be overridden
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'shop_name': name,
      'address': address,
      'gps_location': gpsLocation,
      'user_role': userRole,
    };
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      name: json['shop_name'] ?? '',
      address: json['address'] ?? '',
      gpsLocation: json['gps_location'] ?? '',
      userRole: json['user_role'] ?? 'Owner',
      id: json['id'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }
}
