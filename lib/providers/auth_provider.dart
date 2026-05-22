import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authApiService);

  static const _tokenKey = 'auth_token';

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
      await prefs.setString(_tokenKey, session.token);
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
    await prefs.remove(_tokenKey);
    notifyListeners();
  }
}
