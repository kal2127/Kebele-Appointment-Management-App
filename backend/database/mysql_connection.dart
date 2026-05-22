import 'dart:io';

import 'package:mysql1/mysql1.dart';

class MySqlConnectionFactory {
  Future<MySqlConnection> open() async {
    final settings = ConnectionSettings(
      host: Platform.environment['MYSQL_HOST'] ?? '127.0.0.1',
      port: int.tryParse(Platform.environment['MYSQL_PORT'] ?? '') ?? 3306,
      user: Platform.environment['MYSQL_USER'] ?? 'root',
      password: Platform.environment['MYSQL_PASSWORD'] ?? '',
      db: Platform.environment['MYSQL_DATABASE'] ?? 'kebele_appointments',
      timeout: const Duration(seconds: 10),
    );

    final connection = await MySqlConnection.connect(settings);
    // Keep Amharic text safe across API, MySQL connection, and storage.
    await connection.query("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci");
    return connection;
  }
}
