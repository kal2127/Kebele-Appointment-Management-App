import 'dart:convert';

import '../database/mysql_connection.dart';
import '../models/service.dart';

class ServiceRepository {
  ServiceRepository(this._connectionFactory);

  final MySqlConnectionFactory _connectionFactory;

  Future<List<Service>> findAll() async {
    final connection = await _connectionFactory.open();
    try {
      final results = await connection.query('''
        SELECT s.id, s.name, s.description, s.required_documents,
               COALESCE(l.max_appointments_per_day, s.daily_limit) AS daily_limit
        FROM services s
        LEFT JOIN appointment_limits l ON l.service_id = s.id
        WHERE s.is_active = 1
        ORDER BY s.name ASC
      ''');
      return results
          .map((row) => Service.fromRow(_rowToMap(row.fields)))
          .toList();
    } finally {
      await connection.close();
    }
  }

  Future<Service?> findById(int id) async {
    final connection = await _connectionFactory.open();
    try {
      final results = await connection.query(
        '''
        SELECT s.id, s.name, s.description, s.required_documents,
               COALESCE(l.max_appointments_per_day, s.daily_limit) AS daily_limit
        FROM services s
        LEFT JOIN appointment_limits l ON l.service_id = s.id
        WHERE s.id = ? AND s.is_active = 1
        LIMIT 1
        ''',
        [id],
      );
      if (results.isEmpty) return null;
      return Service.fromRow(_rowToMap(results.first.fields));
    } finally {
      await connection.close();
    }
  }

  Future<int> create({
    required String name,
    required List<String> requiredDocuments,
    required int dailyLimit,
    String? description,
  }) async {
    final connection = await _connectionFactory.open();
    try {
      final result = await connection.query(
        '''
        INSERT INTO services(name, description, required_documents, daily_limit)
        VALUES (?, ?, ?, ?)
        ''',
        [name, description, json.encode(requiredDocuments), dailyLimit],
      );
      return result.insertId!;
    } finally {
      await connection.close();
    }
  }

  Future<void> update({
    required int id,
    required String name,
    required List<String> requiredDocuments,
    required int dailyLimit,
    String? description,
  }) async {
    final connection = await _connectionFactory.open();
    try {
      await connection.query(
        '''
        UPDATE services
        SET name = ?, description = ?, required_documents = ?, daily_limit = ?
        WHERE id = ?
        ''',
        [name, description, json.encode(requiredDocuments), dailyLimit, id],
      );
    } finally {
      await connection.close();
    }
  }

  Future<void> delete(int id) async {
    final connection = await _connectionFactory.open();
    try {
      // Soft delete keeps existing appointments valid for history and reports.
      await connection.query(
        'UPDATE services SET is_active = 0 WHERE id = ?',
        [id],
      );
    } finally {
      await connection.close();
    }
  }

  Future<void> setLimit({
    required int serviceId,
    required int maxAppointmentsPerDay,
  }) async {
    final connection = await _connectionFactory.open();
    try {
      await connection.query(
        '''
        INSERT INTO appointment_limits(service_id, max_appointments_per_day)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE
          max_appointments_per_day = VALUES(max_appointments_per_day)
        ''',
        [serviceId, maxAppointmentsPerDay],
      );
    } finally {
      await connection.close();
    }
  }

  Map<String, dynamic> _rowToMap(Map<String, dynamic> row) {
    final documents = row['required_documents'];
    return {
      ...row,
      'required_documents': documents == null
          ? <String>[]
          : (json.decode(documents.toString()) as List<dynamic>)
              .map((item) => item.toString())
              .toList(),
    };
  }
}
