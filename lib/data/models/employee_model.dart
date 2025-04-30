// lib/models/employee_model.dart
class EmployeeListResponse {
  final List<Employee> employees;

  EmployeeListResponse({required this.employees});

  factory EmployeeListResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeListResponse(
      employees:
          (json['employees'] as List)
              .map((employeeJson) => Employee.fromJson(employeeJson))
              .toList(),
    );
  }
}

class Employee {
  final int userId;
  final String name;
  final String mobileNumber;
  final String shopMemberRole;
  final DateTime createdAt;

  Employee({
    required this.userId,
    required this.name,
    required this.mobileNumber,
    required this.shopMemberRole,
    required this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      shopMemberRole: json['shop_member_role'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'mobile_number': mobileNumber,
      'shop_member_role': shopMemberRole,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
