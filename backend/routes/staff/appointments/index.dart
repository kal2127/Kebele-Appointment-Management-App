import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../../database/mysql_connection.dart';
import '../../../middleware/auth_middleware.dart';
import '../../../repositories/appointment_repository.dart';

const allowedStatuses = {
  'Pending',
  'Confirmed',
  'Completed',
  'Rescheduled',
  'Cancelled',
  'Not Served',
};

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'message': 'Method not allowed.'},
    );
  }

  try {
    final user = requireUser(context, role: 'staff');
    final query = context.request.uri.queryParameters;
    final serviceId = int.tryParse(query['service_id'] ?? '');
    final status = query['status'];
    if (status != null && !allowedStatuses.contains(status)) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Invalid appointment status.'},
      );
    }
    final repository = AppointmentRepository(MySqlConnectionFactory());
    final appointments = await repository.findForStaff(
      staffId: user.id,
      date: query['date'],
      status: status,
      serviceId: serviceId,
    );
    return Response.json(
      body: {
        'data': appointments.map((appointment) => appointment.toJson()).toList(),
      },
    );
  } catch (error) {
    if (error is Response) return error;
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'message': error.toString()},
    );
  }
}
