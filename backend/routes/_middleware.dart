import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(_jsonHeaders());
}

Middleware _jsonHeaders() {
  return (handler) {
    return (context) async {
      final response = await handler(context);
      return response.copyWith(
        headers: {
          ...response.headers,
          'Content-Type': 'application/json; charset=utf-8',
        },
      );
    };
  };
}
