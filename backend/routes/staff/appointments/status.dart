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
  if (context.request.method != HttpMethod.put) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'message': 'Method not allowed.'},
    );
  }

  try {
    final user = requireUser(context, role: 'staff');
    final body = await context.request.json() as Map<String, dynamic>;
    final appointmentNumber = body['appointment_number']?.toString().trim();
    final status = body['status']?.toString().trim();
    if (appointmentNumber == null || appointmentNumber.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'appointment_number is required.'},
      );
    }
    if (status == null || status.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'status is required.'},
      );
    }
    if (!allowedStatuses.contains(status)) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Invalid appointment status.'},
      );
    }

    final repository = AppointmentRepository(MySqlConnectionFactory());
    await repository.updateStatusForStaff(
      staffId: user.id,
      appointmentNumber: appointmentNumber,
      status: status,
    );
    return Response.json(body: {'message': 'Status updated.'});
  } catch (error) {
    if (error is Response) return error;
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'message': error.toString()},
    );
  }
}
