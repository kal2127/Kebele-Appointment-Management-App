import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../models/appointment_model.dart';

class AppointmentSuccessDialog extends StatelessWidget {
  const AppointmentSuccessDialog({
    super.key,
    required this.appointment,
  });

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.check_circle,
        color: Theme.of(context).colorScheme.primary,
        size: 48,
      ),
      title: Text(context.tr('booking_success')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('success_dialog_message')),
          const SizedBox(height: 16),
          SelectableText(
            appointment.appointmentNumber,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('view_confirmation')),
        ),
      ],
    );
  }
}
