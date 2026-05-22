import '../models/appointment.dart';
import '../repositories/appointment_repository.dart';

class AppointmentService {
  AppointmentService(this._appointmentRepository);

  final AppointmentRepository _appointmentRepository;

  Future<List<String>> availableSlots({
    required int serviceId,
    required DateTime date,
  }) {
    return _appointmentRepository.availableSlots(
      serviceId: serviceId,
      date: date,
    );
  }

  Future<Appointment> book(Map<String, dynamic> body) {
    final residentName = _requiredString(body, 'resident_name');
    final phoneNumber = _requiredString(body, 'phone_number');
    final serviceId = _requiredInt(body, 'service_id');
    final appointmentDate = DateTime.parse(
      _requiredString(body, 'appointment_date'),
    );
    final appointmentTime = _requiredString(body, 'appointment_time');

    return _appointmentRepository.create(
      residentName: residentName,
      phoneNumber: phoneNumber,
      serviceId: serviceId,
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
    );
  }

  Future<Appointment?> get(String idOrNumber) {
    return _appointmentRepository.findByIdOrNumber(idOrNumber);
  }

  Future<Appointment> update(String idOrNumber, Map<String, dynamic> body) {
    return _appointmentRepository.update(
      idOrNumber: idOrNumber,
      appointmentDate: DateTime.parse(_requiredString(body, 'appointment_date')),
      appointmentTime: _requiredString(body, 'appointment_time'),
    );
  }

  Future<void> cancel(String idOrNumber) async {
    if (idOrNumber.trim().isEmpty) {
      throw ArgumentError('appointment number is required.');
    }
    final appointment =
        await _appointmentRepository.findByIdOrNumber(idOrNumber);
    if (appointment == null) {
      throw StateError('Appointment not found.');
    }
    return _appointmentRepository.cancel(idOrNumber);
  }

  String _requiredString(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value == null || value.toString().trim().isEmpty) {
      throw ArgumentError('$key is required.');
    }
    return value.toString().trim();
  }

  int _requiredInt(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value is int) return value;
    return int.parse(_requiredString(body, key));
  }
}
