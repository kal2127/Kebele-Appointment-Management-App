import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authApiService);

  final AuthApiService _authApiService;

  bool _isLoading = false;
  String? _token;
  UserModel? _user;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get token => _token;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isStaff => _user?.role == UserRole.staff;
  bool get isAdmin => _user?.role == UserRole.admin;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session =
          await _authApiService.login(email: email, password: password);
      _token = session.token;
      _user = session.user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.authTokenPreferenceKey, session.token);
      return true;
    } catch (_) {
      _errorMessage = 'error_generic';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenPreferenceKey);
    notifyListeners();
  }
}
