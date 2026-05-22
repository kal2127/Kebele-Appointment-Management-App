import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/appointment_model.dart';
import '../models/service_model.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._();

  LocalDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      '$databasePath/kebele_appointments.db',
      version: 1,
      onCreate: _createDatabase,
    );
    return _database!;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cached_services(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        required_documents TEXT NOT NULL,
        daily_limit INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cached_appointments(
        appointment_number TEXT PRIMARY KEY,
        resident_name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        service_id INTEGER NOT NULL,
        service_name TEXT NOT NULL,
        appointment_date TEXT NOT NULL,
        appointment_time TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<void> cacheServices(List<ServiceModel> services) async {
    final db = await database;
    final batch = db.batch();
    await db.delete('cached_services');
    for (final service in services) {
      batch.insert(
        'cached_services',
        {
          'id': service.id,
          'name': service.name,
          'description': service.description,
          'required_documents': json.encode(service.requiredDocuments),
          'daily_limit': service.dailyLimit,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<ServiceModel>> getCachedServices() async {
    final db = await database;
    final rows = await db.query('cached_services', orderBy: 'name ASC');
    return rows.map((row) {
      return ServiceModel(
        id: row['id'] as int,
        name: row['name'] as String,
        description: row['description'] as String?,
        requiredDocuments:
            (json.decode(row['required_documents'] as String) as List<dynamic>)
                .map((document) => document.toString())
                .toList(),
        dailyLimit: row['daily_limit'] as int,
      );
    }).toList();
  }

  Future<void> cacheAppointment(AppointmentModel appointment) async {
    final db = await database;
    await db.insert(
      'cached_appointments',
      appointment.toJson()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AppointmentModel>> getCachedAppointments() async {
    final db = await database;
    final rows = await db.query(
      'cached_appointments',
      orderBy: 'appointment_date DESC',
    );
    return rows
        .map((row) => AppointmentModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }
}
