class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.appointmentNumber,
    required this.residentName,
    required this.phoneNumber,
    required this.serviceId,
    required this.serviceName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
  });

  final int? id;
  final String appointmentNumber;
  final String residentName;
  final String phoneNumber;
  final int serviceId;
  final String serviceName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String status;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int?,
      appointmentNumber: json['appointment_number'] as String,
      residentName: json['resident_name'] as String,
      phoneNumber: json['phone_number'] as String,
      serviceId: json['service_id'] as int,
      serviceName: (json['service_name'] ?? '') as String,
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      appointmentTime: json['appointment_time'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'appointment_number': appointmentNumber,
      'resident_name': residentName,
      'phone_number': phoneNumber,
      'service_id': serviceId,
      'service_name': serviceName,
      'appointment_date': appointmentDate.toIso8601String().split('T').first,
      'appointment_time': appointmentTime,
      'status': status,
    };
  }

  AppointmentModel copyWith({
    int? id,
    String? appointmentNumber,
    String? residentName,
    String? phoneNumber,
    int? serviceId,
    String? serviceName,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? status,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      appointmentNumber: appointmentNumber ?? this.appointmentNumber,
      residentName: residentName ?? this.residentName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
    );
  }
}
