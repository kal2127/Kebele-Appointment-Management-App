import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../database/mysql_connection.dart';
import '../../repositories/feedback_repository.dart';
import '../../services/feedback_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'message': 'Method not allowed.'},
    );
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final service = FeedbackService(
      FeedbackRepository(MySqlConnectionFactory()),
    );
    await service.submit(body);
    return Response.json(
      statusCode: HttpStatus.created,
      body: {'message': 'Feedback submitted successfully.'},
    );
  } catch (error) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'message': error.toString()},
    );
  }
}
