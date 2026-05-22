import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthenticatedUser {
  const AuthenticatedUser({
    required this.id,
    required this.role,
    required this.email,
  });

  final int id;
  final String role;
  final String email;
}

AuthenticatedUser requireUser(RequestContext context, {String? role}) {
  final header = context.request.headers[HttpHeaders.authorizationHeader];
  if (header == null || !header.startsWith('Bearer ')) {
    throw Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'message': 'Missing authorization token.'},
    );
  }

  final token = header.substring(7);
  late final AuthenticatedUser user;
  try {
    final jwt = JWT.verify(
      token,
      SecretKey(Platform.environment['JWT_SECRET'] ?? 'dev-secret-change-me'),
    );
    final payload = jwt.payload as Map<String, dynamic>;
    user = AuthenticatedUser(
      id: payload['sub'] as int,
      role: payload['role'] as String,
      email: payload['email'] as String,
    );
  } catch (_) {
    throw Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'message': 'Invalid authorization token.'},
    );
  }

  if (role != null && user.role != role) {
    throw Response.json(
      statusCode: HttpStatus.forbidden,
      body: {'message': 'You do not have permission for this action.'},
    );
  }
  return user;
}
