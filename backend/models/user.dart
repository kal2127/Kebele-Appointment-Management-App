class User {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.passwordHash,
    this.assignedServiceId,
  });

  final int id;
  final String fullName;
  final String email;
  final String role;
  final String passwordHash;
  final int? assignedServiceId;

  factory User.fromRow(Map<String, dynamic> row) {
    return User(
      id: row['id'] as int,
      fullName: row['full_name'] as String,
      email: row['email'] as String,
      role: row['role'] as String,
      passwordHash: row['password_hash'] as String,
      assignedServiceId: row['assigned_service_id'] as int?,
    );
  }

  Map<String, dynamic> toSafeJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'assigned_service_id': assignedServiceId,
    };
  }
}
