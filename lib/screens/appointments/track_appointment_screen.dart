import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/appointment_summary_card.dart';
import '../../widgets/responsive_page.dart';

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
          children: [
            ResponsivePage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('track_appointment_help'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _numberController,
                    decoration: InputDecoration(
                      labelText: context.tr('enter_appointment_number'),
                    ),
                    validator: (value) => Validators.requiredField(
                      value,
                      context.tr('field_required'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: appointmentProvider.isLoading ? null : _search,
                    icon: const Icon(Icons.search_outlined),
                    label: appointmentProvider.isLoading
                        ? Text(context.tr('loading'))
                        : Text(context.tr('search')),
                  ),
                  const SizedBox(height: 20),
                  if (appointmentProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_appointment != null)
                    AppointmentSummaryCard(
                      appointment: _appointment!,
                      title: context.tr('track_result_title'),
                    ),
                ],
              ),
            ),
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
        SnackBar(content: Text(context.tr('appointment_not_found'))),
      );
    }
  }
}
