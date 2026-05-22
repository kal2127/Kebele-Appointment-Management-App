import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/service_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/responsive_page.dart';

class CancelAppointmentScreen extends StatefulWidget {
  const CancelAppointmentScreen({super.key});

  @override
  State<CancelAppointmentScreen> createState() =>
      _CancelAppointmentScreenState();
}

class _CancelAppointmentScreenState extends State<CancelAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices();
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final showOffline = serviceProvider.hasCheckedConnection &&
        !serviceProvider.isOnline;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('cancel_appointment'))),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ResponsivePage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showOffline)
                    OfflineBanner(
                      message: context.tr('offline_management_notice'),
                    ),
                  if (showOffline) const SizedBox(height: 16),
                  Text(
                    context.tr('cancel_appointment_help'),
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
                    onPressed:
                        provider.isLoading || !serviceProvider.isOnline
                            ? null
                            : _cancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: provider.isLoading
                        ? Text(context.tr('loading'))
                        : Text(context.tr('cancel_appointment')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancel() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('cancel_confirmation_title')),
        content: Text(context.tr('cancel_confirmation_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('keep_appointment')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('cancel_appointment')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await context
        .read<AppointmentProvider>()
        .cancelAppointment(_numberController.text.trim());
    if (!mounted) return;
    _showMessage(
      success
          ? context.tr('appointment_cancelled_message')
          : context.tr('error_generic'),
    );
    if (success) _numberController.clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
