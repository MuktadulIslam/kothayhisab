class User {
  // Private attributes
  int _id;
  String? _name;
  String? _username;
  String? _email;
  String _mobileNumber;
  String _role;
  bool _isActive;
  DateTime _createdAt;
  DateTime _updatedAt;

  // Constructor
  User({
    required int id,
    required String? name,
    required String? username,
    required String? email,
    required String mobileNumber,
    required String role,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : _id = id,
       _name = name,
       _username = username,
       _email = email,
       _mobileNumber = mobileNumber,
       _role = role,
       _isActive = isActive,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  // Getters only - no setters
  int get id => _id;
  String? get name => _name;
  String? get username => _username;
  String? get email => _email;
  String get mobileNumber => _mobileNumber;
  String get role => _role;
  bool get isActive => _isActive;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      mobileNumber: json['mobile_number'],
      role: json['role'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'username': _username,
      'email': _email,
      'mobile_number': _mobileNumber,
      'role': _role,
      'is_active': _isActive,
      'created_at': _createdAt.toIso8601String(),
      'updated_at': _updatedAt.toIso8601String(),
    };
  }
}
