import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../database/mysql_connection.dart';
import '../../middleware/auth_middleware.dart';
import '../../repositories/service_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/admin_service.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    requireUser(context, role: 'admin');
    final adminService = AdminService(
      ServiceRepository(MySqlConnectionFactory()),
      UserRepository(MySqlConnectionFactory()),
    );

    switch (context.request.method) {
      case HttpMethod.get:
        final staff = await adminService.listStaff();
        return Response.json(body: {'data': staff});
      case HttpMethod.post:
        final body = await context.request.json() as Map<String, dynamic>;
        final id = await adminService.createStaff(body);
        return Response.json(
          statusCode: HttpStatus.created,
          body: {'id': id},
        );
      case HttpMethod.put:
        final body = await context.request.json() as Map<String, dynamic>;
        await adminService.assignStaff(body);
        return Response.json(body: {'message': 'Staff assignment updated.'});
      default:
        return Response.json(
          statusCode: HttpStatus.methodNotAllowed,
          body: {'message': 'Method not allowed.'},
        );
    }
  } catch (error) {
    if (error is Response) return error;
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'message': error.toString()},
    );
  }
}
