class AdminStaffModel {
  const AdminStaffModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.assignedServiceId,
  });

  final int id;
  final String fullName;
  final String email;
  final int? assignedServiceId;

  factory AdminStaffModel.fromJson(Map<String, dynamic> json) {
    return AdminStaffModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      assignedServiceId: json['assigned_service_id'] as int?,
    );
  }
}
