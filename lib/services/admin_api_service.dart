import '../models/admin_staff_model.dart';
import '../models/service_model.dart';
import 'api_client.dart';

class AdminApiService {
  AdminApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<void> createService({
    required String token,
    required String name,
    required String description,
    required List<String> requiredDocuments,
    required int dailyLimit,
  }) async {
    await _apiClient.post(
      '/admin/services',
      {
        'name': name,
        'description': description,
        'required_documents': requiredDocuments,
        'daily_limit': dailyLimit,
      },
      token: token,
    );
  }

  Future<void> updateService({
    required String token,
    required ServiceModel service,
  }) async {
    await _apiClient.put(
      '/admin/services/${service.id}',
      service.toJson(),
      token: token,
    );
  }

  Future<void> deleteService({
    required String token,
    required int serviceId,
  }) async {
    await _apiClient.delete('/admin/services/$serviceId', token: token);
  }

  Future<List<AdminStaffModel>> fetchStaff({required String token}) async {
    final response =
        await _apiClient.get('/admin/staff', token: token) as Map<String, dynamic>;
    final data = response['data'] as List<dynamic>;
    return data
        .map((json) => AdminStaffModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> registerStaff({
    required String token,
    required String fullName,
    required String email,
    required String password,
    required int assignedServiceId,
  }) async {
    await _apiClient.post(
      '/admin/staff',
      {
        'full_name': fullName,
        'email': email,
        'password': password,
        'assigned_service_id': assignedServiceId,
      },
      token: token,
    );
  }

  Future<void> assignStaff({
    required String token,
    required int staffId,
    required int assignedServiceId,
  }) async {
    await _apiClient.put(
      '/admin/staff',
      {
        'staff_id': staffId,
        'assigned_service_id': assignedServiceId,
      },
      token: token,
    );
  }

  Future<void> updateLimit({
    required String token,
    required int serviceId,
    required int maxAppointmentsPerDay,
  }) async {
    await _apiClient.put(
      '/admin/limits',
      {
        'service_id': serviceId,
        'max_appointments_per_day': maxAppointmentsPerDay,
      },
      token: token,
    );
  }
}
