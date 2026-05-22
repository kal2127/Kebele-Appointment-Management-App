import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'name': 'Kebele Appointment Management System API',
      'status': 'running',
      'encoding': 'utf-8',
      'routes': [
        'GET /services',
        'GET /services/:id',
        'GET /appointments/slots',
        'POST /appointments',
        'GET /appointments/:id',
        'PUT /appointments/:id',
        'DELETE /appointments/:id',
        'POST /staff/login',
        'GET /staff/appointments',
        'PUT /staff/appointments/status',
        'POST /admin/staff',
        'POST /admin/services',
        'PUT /admin/limits',
        'POST /feedback',
      ],
    },
  );
}
