enum UserRole { admin, staff, resident }

class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.assignedServiceId,
  });

  final int id;
  final String fullName;
  final String email;
  final UserRole role;
  final int? assignedServiceId;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: _roleFromString(json['role'] as String),
      assignedServiceId: json['assigned_service_id'] as int?,
    );
  }

  static UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'staff':
        return UserRole.staff;
      default:
        return UserRole.resident;
    }
  }
}
