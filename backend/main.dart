import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'name': 'Kebele Appointment Management System API',
      'status': 'running',
    },
  );
}
