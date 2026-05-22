import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../utils/validators.dart';

class TrackAppointmentScreen extends StatefulWidget {
  const TrackAppointmentScreen({super.key});

  @override
  State<TrackAppointmentScreen> createState() => _TrackAppointmentScreenState();
}

class _TrackAppointmentScreenState extends State<TrackAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  AppointmentModel? _appointment;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = context.watch<AppointmentProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('track_appointment'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _numberController,
              decoration: InputDecoration(
                labelText: context.tr('enter_appointment_number'),
              ),
              validator: (value) =>
                  Validators.requiredField(value, context.tr('field_required')),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: appointmentProvider.isLoading ? null : _search,
              icon: const Icon(Icons.search_outlined),
              label: Text(context.tr('search')),
            ),
            const SizedBox(height: 20),
            if (appointmentProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_appointment != null)
              _AppointmentResult(appointment: _appointment!),
          ],
        ),
      ),
    );
  }

  Future<void> _search() async {
    if (!_formKey.currentState!.validate()) return;
    final appointment = await context
        .read<AppointmentProvider>()
        .trackAppointment(_numberController.text.trim());
    if (!mounted) return;
    setState(() => _appointment = appointment);
    if (appointment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('error_generic'))),
      );
    }
  }
}

class _AppointmentResult extends StatelessWidget {
  const _AppointmentResult({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Row(
              label: context.tr('appointment_number'),
              value: appointment.appointmentNumber,
            ),
            _Row(
              label: context.tr('service_list_title'),
              value: appointment.serviceName,
            ),
            _Row(
              label: context.tr('appointment_date'),
              value: dateFormat.format(appointment.appointmentDate),
            ),
            _Row(
              label: context.tr('appointment_time'),
              value: appointment.appointmentTime,
            ),
            _Row(
              label: context.tr('appointment_status'),
              value: appointment.status,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
