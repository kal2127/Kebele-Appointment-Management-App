import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../database/mysql_connection.dart';
import '../../repositories/service_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'message': 'Method not allowed.'},
    );
  }

  try {
    final serviceId = int.parse(id);
    final repository = ServiceRepository(MySqlConnectionFactory());
    final service = await repository.findById(serviceId);
    if (service == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'message': 'Service not found.'},
      );
    }
    return Response.json(body: {'data': service.toJson()});
  } catch (error) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'message': error.toString()},
    );
  }
}
