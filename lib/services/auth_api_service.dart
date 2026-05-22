import '../models/user_model.dart';
import 'api_client.dart';

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final UserModel user;
}

class AuthApiService {
  AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post('/staff/login', {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;

    return AuthSession(
      token: response['token'] as String,
      user: UserModel.fromJson(response['user'] as Map<String, dynamic>),
    );
  }
}
