import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../database/mysql_connection.dart';
import '../../repositories/appointment_repository.dart';
import '../../services/appointment_service.dart';

Future<Response> onRequest(RequestContext context) async {
  final service = AppointmentService(
    AppointmentRepository(MySqlConnectionFactory()),
  );

  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'message': 'Method not allowed.'},
    );
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final appointment = await service.book(body);
    return Response.json(
      statusCode: HttpStatus.created,
      body: {'data': appointment.toJson()},
    );
  } catch (error) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'message': error.toString()},
    );
  }
}
