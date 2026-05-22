import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../database/mysql_connection.dart';
import '../../repositories/appointment_repository.dart';
import '../../services/appointment_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final service = AppointmentService(
    AppointmentRepository(MySqlConnectionFactory()),
  );

  try {
    switch (context.request.method) {
      case HttpMethod.get:
        final appointment = await service.get(id);
        if (appointment == null) {
          return Response.json(
            statusCode: HttpStatus.notFound,
            body: {'message': 'Appointment not found.'},
          );
        }
        return Response.json(body: {'data': appointment.toJson()});
      case HttpMethod.put:
        final body = await context.request.json() as Map<String, dynamic>;
        final appointment = await service.update(id, body);
        return Response.json(body: {'data': appointment.toJson()});
      case HttpMethod.delete:
        await service.cancel(id);
        return Response.json(body: {'message': 'Appointment cancelled.'});
      default:
        return Response.json(
          statusCode: HttpStatus.methodNotAllowed,
          body: {'message': 'Method not allowed.'},
        );
    }
  } catch (error) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'message': error.toString()},
    );
  }
}
