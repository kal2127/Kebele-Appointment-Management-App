import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import 'api_client.dart';

class AppointmentApiService {
  AppointmentApiService(this._apiClient);

  final ApiClient _apiClient;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Future<List<String>> fetchAvailableSlots({
    required int serviceId,
    required DateTime date,
  }) async {
    final response = await _apiClient.get('/appointments/slots',
        queryParameters: {
          'service_id': serviceId.toString(),
          'date': _dateFormat.format(date),
        }) as Map<String, dynamic>;
    return (response['data'] as List<dynamic>).map((slot) => '$slot').toList();
  }

  Future<AppointmentModel> bookAppointment({
    required String residentName,
    required String phoneNumber,
    required int serviceId,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    final response = await _apiClient.post('/appointments', {
      'resident_name': residentName,
      'phone_number': phoneNumber,
      'service_id': serviceId,
      'appointment_date': _dateFormat.format(appointmentDate),
      'appointment_time': appointmentTime,
    }) as Map<String, dynamic>;
    return AppointmentModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<AppointmentModel> trackAppointment(String appointmentNumber) async {
    final response = await _apiClient.get('/appointments/$appointmentNumber')
        as Map<String, dynamic>;
    return AppointmentModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<AppointmentModel> updateAppointment({
    required String appointmentNumber,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    final response = await _apiClient.put('/appointments/$appointmentNumber', {
      'appointment_date': _dateFormat.format(appointmentDate),
      'appointment_time': appointmentTime,
    }) as Map<String, dynamic>;
    return AppointmentModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> cancelAppointment(String appointmentNumber) async {
    await _apiClient.delete('/appointments/$appointmentNumber');
  }
}
