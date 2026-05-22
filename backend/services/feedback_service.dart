import '../models/feedback.dart';
import '../repositories/feedback_repository.dart';

class FeedbackService {
  FeedbackService(this._feedbackRepository);

  final FeedbackRepository _feedbackRepository;

  Future<void> submit(Map<String, dynamic> body) {
    final message = _requiredString(body, 'message');
    final rating = _optionalRating(body['rating']);
    final appointmentNumber = body['appointment_number']?.toString().trim();

    final feedback = ResidentFeedback(
      appointmentNumber:
          appointmentNumber == null || appointmentNumber.isEmpty
              ? null
              : appointmentNumber,
      rating: rating,
      message: message,
    );
    return _feedbackRepository.create(feedback);
  }

  String _requiredString(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value == null || value.toString().trim().isEmpty) {
      throw ArgumentError('$key is required.');
    }
    return value.toString().trim();
  }

  int? _optionalRating(Object? value) {
    if (value == null) return null;
    final rating = value is int ? value : int.parse(value.toString());
    if (rating < 1 || rating > 5) {
      throw ArgumentError('rating must be between 1 and 5.');
    }
    return rating;
  }
}
