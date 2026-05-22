import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../../database/mysql_connection.dart';
import '../../../middleware/auth_middleware.dart';
import '../../../repositories/service_repository.dart';
import '../../../repositories/user_repository.dart';
import '../../../services/admin_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  try {
    requireUser(context, role: 'admin');
    final serviceId = int.parse(id);
    final adminService = AdminService(
      ServiceRepository(MySqlConnectionFactory()),
      UserRepository(MySqlConnectionFactory()),
    );

    switch (context.request.method) {
      case HttpMethod.put:
        final body = await context.request.json() as Map<String, dynamic>;
        await adminService.updateService(serviceId, body);
        return Response.json(body: {'message': 'Service updated.'});
      case HttpMethod.delete:
        await adminService.deleteService(serviceId);
        return Response.json(body: {'message': 'Service deleted.'});
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
