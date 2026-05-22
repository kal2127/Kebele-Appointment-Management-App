import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_localizations.dart';
import '../../core/app_routes.dart';
import '../../models/appointment_model.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  const AppointmentConfirmationScreen({super.key, required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('booking_success'))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  context.tr('booking_success'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 18),
                _DetailRow(
                  label: context.tr('appointment_number'),
                  value: appointment.appointmentNumber,
                ),
                _DetailRow(
                  label: context.tr('service_list_title'),
                  value: appointment.serviceName,
                ),
                _DetailRow(
                  label: context.tr('appointment_date'),
                  value: dateFormat.format(appointment.appointmentDate),
                ),
                _DetailRow(
                  label: context.tr('appointment_time'),
                  value: appointment.appointmentTime,
                ),
                const SizedBox(height: 12),
                Text(context.tr('confirmation_message')),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (_) => false,
                  ),
                  child: Text(context.tr('back_to_home')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
