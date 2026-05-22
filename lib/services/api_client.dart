import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    return base.replace(
      path: '${base.path}${path.startsWith('/') ? path : '/$path'}',
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> get(String path,
      {Map<String, String>? queryParameters, String? token}) async {
    final response = await _client.get(
      _uri(path, queryParameters),
      headers: _headers(token),
    );
    return _decode(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body,
      {String? token}) async {
    final response = await _client.post(
      _uri(path),
      headers: _headers(token),
      body: json.encode(body),
    );
    return _decode(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body,
      {String? token}) async {
    final response = await _client.put(
      _uri(path),
      headers: _headers(token),
      body: json.encode(body),
    );
    return _decode(response);
  }

  Future<dynamic> delete(String path, {String? token}) async {
    final response = await _client.delete(
      _uri(path),
      headers: _headers(token),
    );
    return _decode(response);
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response response) {
    final body = response.body.isEmpty ? '{}' : utf8.decode(response.bodyBytes);
    final decoded = json.decode(body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          decoded is Map<String, dynamic> ? decoded['message'] : null;
      throw ApiException(
        message?.toString() ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }
    return decoded;
  }
}
