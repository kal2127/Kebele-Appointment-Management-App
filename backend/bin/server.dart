import 'dart:io';

Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  server.listen((request) {
    request.response
      ..headers.contentType = ContentType.json
      ..write('{"status":"Use dart_frog dev to serve route files."}')
      ..close();
  });
}
