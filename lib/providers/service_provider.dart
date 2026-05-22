import 'package:flutter/foundation.dart';

import '../database/local_database.dart';
import '../models/service_model.dart';
import '../services/service_api_service.dart';

class ServiceProvider extends ChangeNotifier {
  ServiceProvider(this._serviceApiService, this._localDatabase);

  final ServiceApiService _serviceApiService;
  final LocalDatabase _localDatabase;

  List<ServiceModel> _services = ServiceModel.starterServices();
  bool _isLoading = false;
  bool _isOnline = true;
  String? _errorMessage;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String? get errorMessage => _errorMessage;

  Future<void> loadServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final remoteServices = await _serviceApiService.fetchServices();
      _services = remoteServices;
      _isOnline = true;
      await _localDatabase.cacheServices(remoteServices);
    } catch (_) {
      final cachedServices = await _localDatabase.getCachedServices();
      _services = cachedServices.isEmpty ? ServiceModel.starterServices() : cachedServices;
      _isOnline = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
