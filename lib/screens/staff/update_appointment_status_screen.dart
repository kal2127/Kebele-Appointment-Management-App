import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/appointment_statuses.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/staff_provider.dart';
import '../../utils/appointment_status_localizer.dart';
import '../../widgets/appointment_summary_card.dart';
import '../../widgets/responsive_page.dart';

class UpdateAppointmentStatusScreen extends StatefulWidget {
  const UpdateAppointmentStatusScreen({
    super.key,
    required this.appointment,
  });

  final AppointmentModel appointment;

  @override
  State<UpdateAppointmentStatusScreen> createState() =>
      _UpdateAppointmentStatusScreenState();
}

class _UpdateAppointmentStatusScreenState
    extends State<UpdateAppointmentStatusScreen> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.appointment.status;
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('update_status'))),
      body: ListView(
        children: [
          ResponsivePage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppointmentSummaryCard(
                  appointment: widget.appointment,
                  title: context.tr('appointment_information'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: context.tr('appointment_status'),
                  ),
                  items: AppointmentStatuses.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            localizedAppointmentStatus(context, status),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: staffProvider.isLoading
                      ? null
                      : (status) {
                          if (status == null) return;
                          setState(() => _selectedStatus = status);
                        },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: staffProvider.isLoading ? null : _save,
                  child: staffProvider.isLoading
                      ? Text(context.tr('loading'))
                      : Text(context.tr('save_status')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      _showMessage(context.tr('staff_login_required_message'));
      return;
    }

    final success = await context.read<StaffProvider>().updateStatus(
          token: token,
          appointmentNumber: widget.appointment.appointmentNumber,
          status: _selectedStatus,
        );
    if (!mounted) return;
    _showMessage(
      success
          ? context.tr('status_updated_success')
          : context.tr('error_generic'),
    );
    if (success) Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
