import '../models/appointment.dart';
import '../repositories/appointment_repository.dart';

class AppointmentService {
  AppointmentService(this._appointmentRepository);

  final AppointmentRepository _appointmentRepository;

  Future<List<String>> availableSlots({
    required int serviceId,
    required DateTime date,
  }) {
    return _appointmentRepository.availableSlots(serviceId: serviceId, date: date);
  }

  Future<Appointment> book(Map<String, dynamic> body) {
    return _appointmentRepository.create(
      residentName: body['resident_name'] as String,
      phoneNumber: body['phone_number'] as String,
      serviceId: body['service_id'] as int,
      appointmentDate: DateTime.parse(body['appointment_date'] as String),
      appointmentTime: body['appointment_time'] as String,
    );
  }

  Future<Appointment?> get(String idOrNumber) {
    return _appointmentRepository.findByIdOrNumber(idOrNumber);
  }

  Future<Appointment> update(String idOrNumber, Map<String, dynamic> body) {
    return _appointmentRepository.update(
      idOrNumber: idOrNumber,
      appointmentDate: DateTime.parse(body['appointment_date'] as String),
      appointmentTime: body['appointment_time'] as String,
    );
  }

  Future<void> cancel(String idOrNumber) {
    return _appointmentRepository.cancel(idOrNumber);
  }
}
