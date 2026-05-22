import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_localizations.dart';
import '../models/appointment_model.dart';
import '../utils/appointment_status_localizer.dart';

class AppointmentSummaryCard extends StatelessWidget {
  const AppointmentSummaryCard({
    super.key,
    required this.appointment,
    this.title,
  });

  final AppointmentModel appointment;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
            ],
            _SummaryRow(
              label: context.tr('appointment_number'),
              value: appointment.appointmentNumber,
            ),
            _SummaryRow(
              label: context.tr('service_list_title'),
              value: appointment.serviceName,
            ),
            _SummaryRow(
              label: context.tr('appointment_date'),
              value: dateFormat.format(appointment.appointmentDate),
            ),
            _SummaryRow(
              label: context.tr('appointment_time'),
              value: appointment.appointmentTime,
            ),
            _SummaryRow(
              label: context.tr('appointment_status'),
              value: localizedAppointmentStatus(context, appointment.status),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

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
