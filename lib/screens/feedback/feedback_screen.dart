import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../models/feedback_model.dart';
import '../../providers/feedback_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/responsive_page.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appointmentNumberController = TextEditingController();
  final _messageController = TextEditingController();

  int? _rating;

  @override
  void dispose() {
    _appointmentNumberController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedbackProvider = context.watch<FeedbackProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('feedback'))),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ResponsivePage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('feedback_help'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _appointmentNumberController,
                    decoration: InputDecoration(
                      labelText: context.tr('appointment_number_optional'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.tr('rating_optional'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _RatingSelector(
                    rating: _rating,
                    onChanged: (rating) => setState(() => _rating = rating),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _messageController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: InputDecoration(labelText: context.tr('message')),
                    validator: (value) => Validators.requiredField(
                      value,
                      context.tr('field_required'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: feedbackProvider.isLoading ? null : _submit,
                    child: feedbackProvider.isLoading
                        ? Text(context.tr('loading'))
                        : Text(context.tr('submit_feedback')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<FeedbackProvider>().submitFeedback(
          FeedbackModel(
            appointmentNumber: _appointmentNumberController.text.trim().isEmpty
                ? null
                : _appointmentNumberController.text.trim(),
            rating: _rating,
            message: _messageController.text.trim(),
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? context.tr('feedback_success') : context.tr('error_generic'),
        ),
      ),
    );
    if (success) {
      _appointmentNumberController.clear();
      _messageController.clear();
      setState(() => _rating = null);
    }
  }
}

class _RatingSelector extends StatelessWidget {
  const _RatingSelector({
    required this.rating,
    required this.onChanged,
  });

  final int? rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: List.generate(5, (index) {
        final value = index + 1;
        final isSelected = rating != null && value <= rating!;
        return IconButton(
          onPressed: () => onChanged(value),
          icon: Icon(
            isSelected ? Icons.star : Icons.star_border,
            color: Theme.of(context).colorScheme.secondary,
          ),
          tooltip: '$value',
        );
      }),
    );
  }
}
