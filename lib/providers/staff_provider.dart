import 'package:flutter/foundation.dart';

import '../models/appointment_model.dart';
import '../services/staff_api_service.dart';

class StaffProvider extends ChangeNotifier {
  StaffProvider(this._staffApiService);

  final StaffApiService _staffApiService;

  bool _isLoading = false;
  String? _errorMessage;
  List<AppointmentModel> _appointments = [];
  DateTime? _selectedDate;
  String? _selectedStatus;
  int? _selectedServiceId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AppointmentModel> get appointments => _appointments;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedStatus => _selectedStatus;
  int? get selectedServiceId => _selectedServiceId;

  int get pendingCount =>
      _appointments.where((item) => item.status == 'Pending').length;
  int get completedCount =>
      _appointments.where((item) => item.status == 'Completed').length;

  Future<void> loadAppointments({
    required String token,
    DateTime? date,
    String? status,
    int? serviceId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedDate = date;
    _selectedStatus = status;
    _selectedServiceId = serviceId;
    notifyListeners();

    try {
      _appointments = await _staffApiService.fetchAppointments(
        token: token,
        date: date,
        status: status,
        serviceId: serviceId,
      );
    } catch (_) {
      _appointments = [];
      _errorMessage = 'error_generic';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus({
    required String token,
    required String appointmentNumber,
    required String status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _staffApiService.updateAppointmentStatus(
        token: token,
        appointmentNumber: appointmentNumber,
        status: status,
      );
      _appointments = _appointments.map((appointment) {
        if (appointment.appointmentNumber != appointmentNumber) {
          return appointment;
        }
        return appointment.copyWith(status: status);
      }).toList();
      return true;
    } catch (_) {
      _errorMessage = 'error_generic';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFilters() {
    _selectedDate = null;
    _selectedStatus = null;
    _selectedServiceId = null;
    notifyListeners();
  }
}
