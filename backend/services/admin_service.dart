import '../repositories/service_repository.dart';
import '../repositories/user_repository.dart';

class AdminService {
  AdminService(this._serviceRepository, this._userRepository);

  final ServiceRepository _serviceRepository;
  final UserRepository _userRepository;

  Future<int> createService(Map<String, dynamic> body) {
    return _serviceRepository.create(
      name: _requiredString(body, 'name'),
      description: body['description']?.toString(),
      requiredDocuments: _requiredStringList(body, 'required_documents'),
      dailyLimit: _requiredInt(body, 'daily_limit'),
    );
  }

  Future<void> updateService(int id, Map<String, dynamic> body) {
    return _serviceRepository.update(
      id: id,
      name: _requiredString(body, 'name'),
      description: body['description']?.toString(),
      requiredDocuments: _requiredStringList(body, 'required_documents'),
      dailyLimit: _requiredInt(body, 'daily_limit'),
    );
  }

  Future<void> deleteService(int id) {
    return _serviceRepository.delete(id);
  }

  Future<int> createStaff(Map<String, dynamic> body) {
    return _userRepository.createStaff(
      fullName: _requiredString(body, 'full_name'),
      email: _requiredString(body, 'email'),
      password: _requiredString(body, 'password'),
      assignedServiceId: _requiredInt(body, 'assigned_service_id'),
    );
  }

  Future<List<Map<String, dynamic>>> listStaff() async {
    final staff = await _userRepository.findStaff();
    return staff.map((user) => user.toSafeJson()).toList();
  }

  Future<void> assignStaff(Map<String, dynamic> body) {
    return _userRepository.assignStaffToService(
      staffId: _requiredInt(body, 'staff_id'),
      assignedServiceId: _requiredInt(body, 'assigned_service_id'),
    );
  }

  Future<void> resetStaffPassword(Map<String, dynamic> body) {
    return _userRepository.resetPassword(
      userId: _requiredInt(body, 'staff_id'),
      newPassword: _requiredString(body, 'new_password'),
    );
  }

  Future<void> updateLimit(Map<String, dynamic> body) {
    return _serviceRepository.setLimit(
      serviceId: _requiredInt(body, 'service_id'),
      maxAppointmentsPerDay: _requiredInt(body, 'max_appointments_per_day'),
    );
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

  List<String> _requiredStringList(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value is! List) {
      throw ArgumentError('$key is required.');
    }
    return value.map((document) => document.toString().trim()).where(
      (document) {
        return document.isNotEmpty;
      },
    ).toList();
  }
}
