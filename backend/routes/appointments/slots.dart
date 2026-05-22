import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../database/mysql_connection.dart';
import '../../repositories/appointment_repository.dart';
import '../../services/appointment_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'message': 'Method not allowed.'},
    );
  }

  try {
    final query = context.request.uri.queryParameters;
    final serviceId = int.parse(query['service_id'] ?? '');
    final date = DateTime.parse(query['date'] ?? '');
    final service = AppointmentService(
      AppointmentRepository(MySqlConnectionFactory()),
    );
    final slots = await service.availableSlots(serviceId: serviceId, date: date);
    return Response.json(body: {'data': slots});
  } catch (error) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'message': error.toString()},
    );
  }
}
