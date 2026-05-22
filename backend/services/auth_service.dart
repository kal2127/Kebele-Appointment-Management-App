import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthService {
  AuthService(this._userRepository);

  final UserRepository _userRepository;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final user = await _userRepository.findByEmail(email);
    if (user == null || user.passwordHash != password) {
      throw StateError('Invalid email or password.');
    }
    if (user.role != 'admin' && user.role != 'staff') {
      throw StateError('Only staff and admins can login.');
    }

    final token = _createToken(user);
    return {'token': token, 'user': user.toSafeJson()};
  }

  String _createToken(User user) {
    final jwt = JWT({
      'sub': user.id,
      'role': user.role,
      'email': user.email,
    });
    return jwt.sign(
      SecretKey(Platform.environment['JWT_SECRET'] ?? 'dev-secret-change-me'),
      expiresIn: const Duration(hours: 8),
    );
  }
}
