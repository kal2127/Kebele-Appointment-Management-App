import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import 'api_client.dart';

class StaffApiService {
  StaffApiService(this._apiClient);

  final ApiClient _apiClient;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Future<List<AppointmentModel>> fetchAppointments({
    required String token,
    DateTime? date,
    String? status,
    int? serviceId,
  }) async {
    final response = await _apiClient.get(
      '/staff/appointments',
      token: token,
      queryParameters: {
        if (date != null) 'date': _dateFormat.format(date),
        if (status != null && status.isNotEmpty) 'status': status,
        if (serviceId != null) 'service_id': serviceId.toString(),
      },
    ) as Map<String, dynamic>;

    final data = response['data'] as List<dynamic>;
    return data
        .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateAppointmentStatus({
    required String token,
    required String appointmentNumber,
    required String status,
  }) async {
    await _apiClient.put(
      '/staff/appointments/status',
      {
        'appointment_number': appointmentNumber,
        'status': status,
      },
      token: token,
    );
  }
}
