import '../repositories/service_repository.dart';
import '../repositories/user_repository.dart';

class AdminService {
  AdminService(this._serviceRepository, this._userRepository);

  final ServiceRepository _serviceRepository;
  final UserRepository _userRepository;

  Future<int> createService(Map<String, dynamic> body) {
    return _serviceRepository.create(
      name: body['name'] as String,
      description: body['description'] as String?,
      requiredDocuments: (body['required_documents'] as List<dynamic>)
          .map((document) => document.toString())
          .toList(),
      dailyLimit: body['daily_limit'] as int,
    );
  }

  Future<int> createStaff(Map<String, dynamic> body) {
    return _userRepository.createStaff(
      fullName: body['full_name'] as String,
      email: body['email'] as String,
      password: body['password'] as String,
      assignedServiceId: body['assigned_service_id'] as int,
    );
  }

  Future<void> updateLimit(Map<String, dynamic> body) {
    return _serviceRepository.setLimit(
      serviceId: body['service_id'] as int,
      maxAppointmentsPerDay: body['max_appointments_per_day'] as int,
    );
  }
}
