class Appointment {
  const Appointment({
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

  final int id;
  final String appointmentNumber;
  final String residentName;
  final String phoneNumber;
  final int serviceId;
  final String serviceName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String status;

  factory Appointment.fromRow(Map<String, dynamic> row) {
    return Appointment(
      id: row['id'] as int,
      appointmentNumber: row['appointment_number'] as String,
      residentName: row['resident_name'] as String,
      phoneNumber: row['phone_number'] as String,
      serviceId: row['service_id'] as int,
      serviceName: (row['service_name'] ?? '') as String,
      appointmentDate: row['appointment_date'] is DateTime
          ? row['appointment_date'] as DateTime
          : DateTime.parse(row['appointment_date'].toString()),
      appointmentTime: row['appointment_time'].toString(),
      status: row['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
}
