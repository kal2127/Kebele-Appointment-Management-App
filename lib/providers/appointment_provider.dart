import 'package:flutter/foundation.dart';

import '../database/local_database.dart';
import '../models/appointment_model.dart';
import '../services/appointment_api_service.dart';

class AppointmentProvider extends ChangeNotifier {
  AppointmentProvider(this._appointmentApiService, this._localDatabase);

  final AppointmentApiService _appointmentApiService;
  final LocalDatabase _localDatabase;

  bool _isLoading = false;
  String? _errorMessage;
  List<String> _availableSlots = [];
  List<AppointmentModel> _cachedHistory = [];
  AppointmentModel? _lastBookedAppointment;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get availableSlots => _availableSlots;
  List<AppointmentModel> get cachedHistory => _cachedHistory;
  AppointmentModel? get lastBookedAppointment => _lastBookedAppointment;

  Future<void> loadCachedHistory() async {
    _cachedHistory = await _localDatabase.getCachedAppointments();
    notifyListeners();
  }

  Future<void> loadAvailableSlots({
    required int serviceId,
    required DateTime date,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _availableSlots = await _appointmentApiService.fetchAvailableSlots(
        serviceId: serviceId,
        date: date,
      );
    } catch (_) {
      _availableSlots = [];
      _errorMessage = 'error_generic';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppointmentModel?> bookAppointment({
    required String residentName,
    required String phoneNumber,
    required int serviceId,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final appointment = await _appointmentApiService.bookAppointment(
        residentName: residentName,
        phoneNumber: phoneNumber,
        serviceId: serviceId,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
      );
      _lastBookedAppointment = appointment;
      await _localDatabase.cacheAppointment(appointment);
      await loadCachedHistory();
      return appointment;
    } catch (_) {
      _errorMessage = 'error_generic';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppointmentModel?> trackAppointment(String appointmentNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final appointment =
          await _appointmentApiService.trackAppointment(appointmentNumber);
      await _localDatabase.cacheAppointment(appointment);
      return appointment;
    } catch (_) {
      _errorMessage = 'error_generic';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppointmentModel?> updateAppointment({
    required String appointmentNumber,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final appointment = await _appointmentApiService.updateAppointment(
        appointmentNumber: appointmentNumber,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
      );
      await _localDatabase.cacheAppointment(appointment);
      return appointment;
    } catch (_) {
      _errorMessage = 'error_generic';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(String appointmentNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _appointmentApiService.cancelAppointment(appointmentNumber);
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
