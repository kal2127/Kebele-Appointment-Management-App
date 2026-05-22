import '../database/mysql_connection.dart';
import '../models/appointment.dart';

class AppointmentRepository {
  AppointmentRepository(this._connectionFactory);

  final MySqlConnectionFactory _connectionFactory;

  static const availableBusinessSlots = [
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
  ];

  Future<List<String>> availableSlots({
    required int serviceId,
    required DateTime date,
  }) async {
    if (_isBeforeToday(date)) return [];

    final connection = await _connectionFactory.open();
    try {
      final limitRows = await connection.query(
        '''
        SELECT COALESCE(l.max_appointments_per_day, s.daily_limit) AS daily_limit
        FROM services s
        LEFT JOIN appointment_limits l ON l.service_id = s.id
        WHERE s.id = ?
        ''',
        [serviceId],
      );
      if (limitRows.isEmpty) return [];

      final dailyLimit = _asInt(limitRows.first.fields['daily_limit']);
      final countRows = await connection.query(
        '''
        SELECT COUNT(*) AS total
        FROM appointments
        WHERE service_id = ?
          AND appointment_date = ?
          AND status <> 'Cancelled'
        ''',
        [serviceId, _dateOnly(date)],
      );
      final total = _asInt(countRows.first.fields['total']);
      if (total >= dailyLimit) return [];

      final takenRows = await connection.query(
        '''
        SELECT appointment_time
        FROM appointments
        WHERE service_id = ?
          AND appointment_date = ?
          AND status <> 'Cancelled'
        ''',
        [serviceId, _dateOnly(date)],
      );
      final taken = takenRows
          .map((row) => row.fields['appointment_time'].toString())
          .toSet();
      return availableBusinessSlots
          .where((slot) => !taken.contains(slot))
          .toList();
    } finally {
      await connection.close();
    }
  }

  Future<Appointment> create({
    required String residentName,
    required String phoneNumber,
    required int serviceId,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    // Check the business limit and chosen slot before saving the appointment.
    final slots = await availableSlots(
      serviceId: serviceId,
      date: appointmentDate,
    );
    if (!slots.contains(appointmentTime)) {
      throw StateError('Selected appointment slot is not available.');
    }

    final connection = await _connectionFactory.open();
    try {
      final appointmentNumber = _generateAppointmentNumber(serviceId);
      final result = await connection.query(
        '''
        INSERT INTO appointments(
          appointment_number,
          resident_name,
          phone_number,
          service_id,
          appointment_date,
          appointment_time,
          status
        )
        VALUES (?, ?, ?, ?, ?, ?, 'Pending')
        ''',
        [
          appointmentNumber,
          residentName,
          phoneNumber,
          serviceId,
          _dateOnly(appointmentDate),
          appointmentTime,
        ],
      );
      return (await findByIdOrNumber(result.insertId!.toString()))!;
    } finally {
      await connection.close();
    }
  }

  Future<Appointment?> findByIdOrNumber(String idOrNumber) async {
    final connection = await _connectionFactory.open();
    try {
      final results = await connection.query(
        '''
        SELECT a.*, s.name AS service_name
        FROM appointments a
        INNER JOIN services s ON s.id = a.service_id
        WHERE a.id = ? OR a.appointment_number = ?
        LIMIT 1
        ''',
        [int.tryParse(idOrNumber) ?? 0, idOrNumber],
      );
      if (results.isEmpty) return null;
      return Appointment.fromRow(
        Map<String, dynamic>.from(results.first.fields),
      );
    } finally {
      await connection.close();
    }
  }

  Future<Appointment> update({
    required String idOrNumber,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    final existing = await findByIdOrNumber(idOrNumber);
    if (existing == null) throw StateError('Appointment not found.');
    if (existing.appointmentDate.difference(DateTime.now()).inHours <= 24) {
      throw StateError(
        'Appointment can only be edited more than one day ahead.',
      );
    }
    final slots = await availableSlots(
      serviceId: existing.serviceId,
      date: appointmentDate,
    );
    if (!slots.contains(appointmentTime)) {
      throw StateError('Selected appointment slot is not available.');
    }

    final connection = await _connectionFactory.open();
    try {
      await connection.query(
        '''
        UPDATE appointments
        SET appointment_date = ?, appointment_time = ?, status = 'Rescheduled'
        WHERE appointment_number = ?
        ''',
        [
          _dateOnly(appointmentDate),
          appointmentTime,
          existing.appointmentNumber,
        ],
      );
      return (await findByIdOrNumber(existing.appointmentNumber))!;
    } finally {
      await connection.close();
    }
  }

  Future<void> cancel(String idOrNumber) async {
    final connection = await _connectionFactory.open();
    try {
      await connection.query(
        '''
        UPDATE appointments
        SET status = 'Cancelled'
        WHERE id = ? OR appointment_number = ?
        ''',
        [int.tryParse(idOrNumber) ?? 0, idOrNumber],
      );
    } finally {
      await connection.close();
    }
  }

  Future<List<Appointment>> findForStaff({
    required int staffId,
    String? date,
    String? status,
    int? serviceId,
  }) async {
    final connection = await _connectionFactory.open();
    try {
      final filters = <String>['u.id = ?'];
      final params = <Object>[staffId];
      if (date != null) {
        filters.add('a.appointment_date = ?');
        params.add(date);
      }
      if (status != null) {
        filters.add('a.status = ?');
        params.add(status);
      }
      if (serviceId != null) {
        filters.add('a.service_id = ?');
        params.add(serviceId);
      }

      final results = await connection.query(
        '''
        SELECT a.*, s.name AS service_name
        FROM appointments a
        INNER JOIN services s ON s.id = a.service_id
        INNER JOIN users u ON u.assigned_service_id = s.id
        WHERE ${filters.join(' AND ')}
        ORDER BY a.appointment_date ASC, a.appointment_time ASC
        ''',
        params,
      );
      return results
          .map(
            (row) => Appointment.fromRow(
              Map<String, dynamic>.from(row.fields),
            ),
          )
          .toList();
    } finally {
      await connection.close();
    }
  }

  Future<void> updateStatus({
    required String appointmentNumber,
    required String status,
  }) async {
    final connection = await _connectionFactory.open();
    try {
      await connection.query(
        '''
        UPDATE appointments
        SET status = ?
        WHERE appointment_number = ?
        ''',
        [status, appointmentNumber],
      );
    } finally {
      await connection.close();
    }
  }

  Future<void> updateStatusForStaff({
    required int staffId,
    required String appointmentNumber,
    required String status,
  }) async {
    final connection = await _connectionFactory.open();
    try {
      final matches = await connection.query(
        '''
        SELECT a.id
        FROM appointments a
        INNER JOIN users u ON u.assigned_service_id = a.service_id
        WHERE u.id = ? AND a.appointment_number = ?
        LIMIT 1
        ''',
        [staffId, appointmentNumber],
      );
      if (matches.isEmpty) {
        throw StateError('Appointment not found for assigned service.');
      }

      await connection.query(
        '''
        UPDATE appointments a
        INNER JOIN users u ON u.assigned_service_id = a.service_id
        SET a.status = ?
        WHERE u.id = ? AND a.appointment_number = ?
        ''',
        [status, staffId, appointmentNumber],
      );
    } finally {
      await connection.close();
    }
  }

  String _generateAppointmentNumber(int serviceId) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return 'KBL-$serviceId-$timestamp';
  }

  int _asInt(Object? value) => int.parse(value.toString());

  bool _isBeforeToday(DateTime date) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isBefore(todayOnly);
  }

  String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
}
