import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../database/mysql_connection.dart';
import '../../repositories/user_repository.dart';
import '../../services/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'message': 'Method not allowed.'},
    );
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final authService = AuthService(UserRepository(MySqlConnectionFactory()));
    final session = await authService.login(
      email: body['email'] as String,
      password: body['password'] as String,
    );
    return Response.json(body: session);
  } catch (error) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'message': error.toString()},
    );
  }
}
