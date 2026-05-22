import 'package:flutter/foundation.dart';

import '../database/local_database.dart';
import '../models/service_model.dart';
import '../services/service_api_service.dart';

class ServiceProvider extends ChangeNotifier {
  ServiceProvider(this._serviceApiService, this._localDatabase);

  final ServiceApiService _serviceApiService;
  final LocalDatabase _localDatabase;

  List<ServiceModel> _services = [];
  bool _isLoading = false;
  bool _isOnline = false;
  bool _hasCheckedConnection = false;
  String? _errorMessage;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  bool get hasCheckedConnection => _hasCheckedConnection;
  String? get errorMessage => _errorMessage;

  ServiceModel? serviceById(int id) {
    for (final service in _services) {
      if (service.id == id) return service;
    }
    return null;
  }

  Future<void> loadServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final remoteServices = await _serviceApiService.fetchServices();
      _services = remoteServices;
      _isOnline = true;
      // The app uses the latest successful API response as the offline cache.
      await _localDatabase.cacheServices(remoteServices);
    } catch (_) {
      final cachedServices = await _localDatabase.getCachedServices();
      _services = cachedServices;
      _isOnline = false;
    } finally {
      _hasCheckedConnection = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ServiceModel?> loadServiceDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final remoteService = await _serviceApiService.fetchService(id);
      _upsertService(remoteService);
      _isOnline = true;
      // Keep the selected service fresh for offline details viewing.
      await _localDatabase.cacheService(remoteService);
      return remoteService;
    } catch (_) {
      final cachedServices = await _localDatabase.getCachedServices();
      final cachedService = cachedServices.where((service) => service.id == id);
      if (cachedService.isNotEmpty) {
        _upsertService(cachedService.first);
      }
      _isOnline = false;
      return serviceById(id);
    } finally {
      _hasCheckedConnection = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  void _upsertService(ServiceModel service) {
    final index = _services.indexWhere((item) => item.id == service.id);
    if (index == -1) {
      _services = [..._services, service];
    } else {
      _services = [
        ..._services.take(index),
        service,
        ..._services.skip(index + 1),
      ];
    }
  }
}
