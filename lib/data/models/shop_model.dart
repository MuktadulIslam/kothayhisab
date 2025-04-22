class Shop {
  final String name;
  final String address;
  final String gpsLocation;
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Shop({
    required this.name,
    required this.address,
    required this.gpsLocation,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {'shop_name': name, 'address': address, 'gps_location': gpsLocation};
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      name: json['shop_name'] ?? '',
      address: json['address'] ?? '',
      gpsLocation: json['gps_location'] ?? '',
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
