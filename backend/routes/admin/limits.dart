import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../database/mysql_connection.dart';
import '../../middleware/auth_middleware.dart';
import '../../repositories/service_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/admin_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.put) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'message': 'Method not allowed.'},
    );
  }

  try {
    requireUser(context, role: 'admin');
    final body = await context.request.json() as Map<String, dynamic>;
    final adminService = AdminService(
      ServiceRepository(MySqlConnectionFactory()),
      UserRepository(MySqlConnectionFactory()),
    );
    await adminService.updateLimit(body);
    return Response.json(body: {'message': 'Appointment limit updated.'});
  } catch (error) {
    if (error is Response) return error;
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'message': error.toString()},
    );
  }
}
