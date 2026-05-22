import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../models/feedback_model.dart';
import '../../services/api_client.dart';
import '../../services/feedback_api_service.dart';
import '../../utils/validators.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appointmentNumberController = TextEditingController();
  final _messageController = TextEditingController();
  final _feedbackService = FeedbackApiService(ApiClient());

  int? _rating;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _appointmentNumberController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('feedback'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _appointmentNumberController,
              decoration: InputDecoration(
                labelText: context.tr('appointment_number'),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: _rating,
              decoration: InputDecoration(labelText: context.tr('rating_optional')),
              items: [1, 2, 3, 4, 5]
                  .map(
                    (rating) => DropdownMenuItem(
                      value: rating,
                      child: Text('$rating'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _messageController,
              minLines: 4,
              maxLines: 6,
              decoration: InputDecoration(labelText: context.tr('message')),
              validator: (value) =>
                  Validators.requiredField(value, context.tr('field_required')),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? Text(context.tr('loading'))
                  : Text(context.tr('submit_feedback')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await _feedbackService.submitFeedback(
        FeedbackModel(
          appointmentNumber: _appointmentNumberController.text.trim().isEmpty
              ? null
              : _appointmentNumberController.text.trim(),
          rating: _rating,
          message: _messageController.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('error_generic'))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
