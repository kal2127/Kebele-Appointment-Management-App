import '../models/feedback.dart';
import '../repositories/feedback_repository.dart';

class FeedbackService {
  FeedbackService(this._feedbackRepository);

  final FeedbackRepository _feedbackRepository;

  Future<void> submit(Map<String, dynamic> body) {
    final feedback = ResidentFeedback(
      appointmentNumber: body['appointment_number'] as String?,
      rating: body['rating'] as int?,
      message: body['message'] as String,
    );
    return _feedbackRepository.create(feedback);
  }
}
