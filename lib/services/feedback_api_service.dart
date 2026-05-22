import '../models/feedback_model.dart';
import 'api_client.dart';

class FeedbackApiService {
  FeedbackApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<void> submitFeedback(FeedbackModel feedback) async {
    await _apiClient.post('/feedback', feedback.toJson());
  }
}
