import '../database/mysql_connection.dart';
import '../models/feedback.dart';

class FeedbackRepository {
  FeedbackRepository(this._connectionFactory);

  final MySqlConnectionFactory _connectionFactory;

  Future<void> create(ResidentFeedback feedback) async {
    final connection = await _connectionFactory.open();
    try {
      await connection.query(
        '''
        INSERT INTO feedback(appointment_number, rating, message)
        VALUES (?, ?, ?)
        ''',
        [feedback.appointmentNumber, feedback.rating, feedback.message],
      );
    } finally {
      await connection.close();
    }
  }
}
