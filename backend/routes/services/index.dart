import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../database/mysql_connection.dart';
import '../../repositories/service_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'message': 'Method not allowed.'},
    );
  }

  try {
    final repository = ServiceRepository(MySqlConnectionFactory());
    final services = await repository.findAll();
    return Response.json(
      body: {'data': services.map((service) => service.toJson()).toList()},
    );
  } catch (error) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': error.toString()},
    );
  }
}
