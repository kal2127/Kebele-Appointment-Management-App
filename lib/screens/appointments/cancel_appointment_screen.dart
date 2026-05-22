import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../providers/appointment_provider.dart';
import '../../utils/validators.dart';

class CancelAppointmentScreen extends StatefulWidget {
  const CancelAppointmentScreen({super.key});

  @override
  State<CancelAppointmentScreen> createState() =>
      _CancelAppointmentScreenState();
}

class _CancelAppointmentScreenState extends State<CancelAppointmentScreen> {
  final _numberController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('cancel_appointment'))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _numberController,
              decoration: InputDecoration(
                labelText: context.tr('enter_appointment_number'),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: provider.isLoading ? null : _cancel,
              icon: const Icon(Icons.cancel_outlined),
              label: provider.isLoading
                  ? Text(context.tr('loading'))
                  : Text(context.tr('cancel_appointment')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancel() async {
    final error = Validators.requiredField(
      _numberController.text,
      context.tr('field_required'),
    );
    if (error != null) {
      _showMessage(error);
      return;
    }
    final success = await context
        .read<AppointmentProvider>()
        .cancelAppointment(_numberController.text.trim());
    if (!mounted) return;
    _showMessage(
      success ? context.tr('status_cancelled') : context.tr('error_generic'),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
