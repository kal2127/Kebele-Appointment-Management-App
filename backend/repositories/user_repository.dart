import '../database/mysql_connection.dart';
import '../models/user.dart';

class UserRepository {
  UserRepository(this._connectionFactory);

  final MySqlConnectionFactory _connectionFactory;

  Future<User?> findByEmail(String email) async {
    final connection = await _connectionFactory.open();
    try {
      final results = await connection.query(
        '''
        SELECT id, full_name, email, role, password_hash, assigned_service_id
        FROM users
        WHERE email = ? AND is_active = 1
        LIMIT 1
        ''',
        [email],
      );
      if (results.isEmpty) return null;
      return User.fromRow(Map<String, dynamic>.from(results.first.fields));
    } finally {
      await connection.close();
    }
  }

  Future<int> createStaff({
    required String fullName,
    required String email,
    required String password,
    required int assignedServiceId,
  }) async {
    final connection = await _connectionFactory.open();
    try {
      final result = await connection.query(
        '''
        INSERT INTO users(full_name, email, password_hash, role, assigned_service_id)
        VALUES (?, ?, ?, 'staff', ?)
        ''',
        [fullName, email, password, assignedServiceId],
      );
      return result.insertId!;
    } finally {
      await connection.close();
    }
  }

  Future<List<User>> findStaff() async {
    final connection = await _connectionFactory.open();
    try {
      final results = await connection.query(
        '''
        SELECT id, full_name, email, role, password_hash, assigned_service_id
        FROM users
        WHERE role = 'staff' AND is_active = 1
        ORDER BY full_name ASC
        ''',
      );
      return results
          .map((row) => User.fromRow(Map<String, dynamic>.from(row.fields)))
          .toList();
    } finally {
      await connection.close();
    }
  }

  Future<void> assignStaffToService({
    required int staffId,
    required int assignedServiceId,
  }) async {
    final connection = await _connectionFactory.open();
    try {
      await connection.query(
        '''
        UPDATE users
        SET assigned_service_id = ?
        WHERE id = ? AND role = 'staff'
        ''',
        [assignedServiceId, staffId],
      );
    } finally {
      await connection.close();
    }
  }

  Future<void> resetPassword({
    required int userId,
    required String newPassword,
  }) async {
    final connection = await _connectionFactory.open();
    try {
      await connection.query(
        'UPDATE users SET password_hash = ? WHERE id = ?',
        [newPassword, userId],
      );
    } finally {
      await connection.close();
    }
  }
}
