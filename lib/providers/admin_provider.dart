import 'package:flutter/foundation.dart';

import '../models/admin_staff_model.dart';
import '../models/service_model.dart';
import '../services/admin_api_service.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider(this._adminApiService);

  final AdminApiService _adminApiService;

  bool _isLoading = false;
  String? _errorMessage;
  List<AdminStaffModel> _staff = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AdminStaffModel> get staff => _staff;

  Future<bool> createService({
    required String token,
    required String name,
    required String description,
    required List<String> requiredDocuments,
    required int dailyLimit,
  }) async {
    return _run(() {
      return _adminApiService.createService(
        token: token,
        name: name,
        description: description,
        requiredDocuments: requiredDocuments,
        dailyLimit: dailyLimit,
      );
    });
  }

  Future<bool> updateService({
    required String token,
    required ServiceModel service,
  }) async {
    return _run(() {
      return _adminApiService.updateService(token: token, service: service);
    });
  }

  Future<bool> deleteService({
    required String token,
    required int serviceId,
  }) async {
    return _run(() {
      return _adminApiService.deleteService(token: token, serviceId: serviceId);
    });
  }

  Future<void> loadStaff({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _staff = await _adminApiService.fetchStaff(token: token);
    } catch (_) {
      _staff = [];
      _errorMessage = 'error_generic';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerStaff({
    required String token,
    required String fullName,
    required String email,
    required String password,
    required int assignedServiceId,
  }) async {
    return _run(() async {
      await _adminApiService.registerStaff(
        token: token,
        fullName: fullName,
        email: email,
        password: password,
        assignedServiceId: assignedServiceId,
      );
      _staff = await _adminApiService.fetchStaff(token: token);
    });
  }

  Future<bool> assignStaff({
    required String token,
    required int staffId,
    required int assignedServiceId,
  }) async {
    return _run(() async {
      await _adminApiService.assignStaff(
        token: token,
        staffId: staffId,
        assignedServiceId: assignedServiceId,
      );
      _staff = await _adminApiService.fetchStaff(token: token);
    });
  }

  Future<bool> updateLimit({
    required String token,
    required int serviceId,
    required int maxAppointmentsPerDay,
  }) async {
    return _run(() {
      return _adminApiService.updateLimit(
        token: token,
        serviceId: serviceId,
        maxAppointmentsPerDay: maxAppointmentsPerDay,
      );
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (_) {
      _errorMessage = 'error_generic';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
