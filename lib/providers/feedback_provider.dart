import 'package:flutter/foundation.dart';

import '../models/feedback_model.dart';
import '../services/feedback_api_service.dart';

class FeedbackProvider extends ChangeNotifier {
  FeedbackProvider(this._feedbackApiService);

  final FeedbackApiService _feedbackApiService;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> submitFeedback(FeedbackModel feedback) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _feedbackApiService.submitFeedback(feedback);
      return true;
    } catch (_) {
      _errorMessage = 'error_generic';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
