import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/appointment_summary_card.dart';
import '../../widgets/responsive_page.dart';

class EditAppointmentScreen extends StatefulWidget {
  const EditAppointmentScreen({super.key});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _dateFormat = DateFormat('yyyy-MM-dd');

  AppointmentModel? _appointment;
  DateTime? _newDate;
  String? _newTime;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final canEdit = _appointment == null
        ? false
        : _appointment!.appointmentDate
            .difference(DateTime.now())
            .inHours > 24;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('edit_appointment'))),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ResponsivePage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: provider.isLoading ? null : _findAppointment,
                    icon: const Icon(Icons.search_outlined),
                    label: Text(context.tr('search')),
                  ),
                  const SizedBox(height: 20),
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (_appointment != null) ...[
                    AppointmentSummaryCard(
                      appointment: _appointment!,
                      title: context.tr('current_appointment'),
                    ),
                    const SizedBox(height: 16),
                    if (!canEdit)
                      _InfoCard(
                        icon: Icons.lock_clock_outlined,
                        message: context.tr('cannot_edit_one_day'),
                        isError: true,
                      )
                    else ...[
                      _InfoCard(
                        icon: Icons.edit_calendar_outlined,
                        message: context.tr('edit_allowed_message'),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: _pickNewDate,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(
                          _newDate == null
                              ? context.tr('select_new_date')
                              : _dateFormat.format(_newDate!),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _EditSlotSelector(
                        hasDate: _newDate != null,
                        selectedTime: _newTime,
                        onSelected: (slot) {
                          setState(() => _newTime = slot);
                        },
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _newDate != null &&
                                _newTime != null &&
                                !provider.isLoading
                            ? _saveChanges
                            : null,
                        child: provider.isLoading
                            ? Text(context.tr('loading'))
                            : Text(context.tr('save_changes')),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _findAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    final appointment = await context
        .read<AppointmentProvider>()
        .trackAppointment(_numberController.text.trim());
    if (!mounted) return;
    setState(() {
      _appointment = appointment;
      _newDate = null;
      _newTime = null;
    });
    _showMessage(
      appointment == null
          ? context.tr('appointment_not_found')
          : context.tr('appointment_found'),
    );
  }

  Future<void> _pickNewDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 2)),
      firstDate: now.add(const Duration(days: 2)),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (pickedDate == null || _appointment == null) return;
    setState(() {
      _newDate = pickedDate;
      _newTime = null;
    });
    await context.read<AppointmentProvider>().loadAvailableSlots(
          serviceId: _appointment!.serviceId,
          date: pickedDate,
        );
  }

  Future<void> _saveChanges() async {
    final updated = await context.read<AppointmentProvider>().updateAppointment(
          appointmentNumber: _numberController.text.trim(),
          appointmentDate: _newDate!,
          appointmentTime: _newTime!,
        );
    if (!mounted) return;
    if (updated == null) {
      _showMessage(context.tr('error_generic'));
      return;
    }
    setState(() {
      _appointment = updated;
      _newDate = null;
      _newTime = null;
    });
    _showMessage(context.tr('appointment_updated'));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _EditSlotSelector extends StatelessWidget {
  const _EditSlotSelector({
    required this.hasDate,
    required this.selectedTime,
    required this.onSelected,
  });

  final bool hasDate;
  final String? selectedTime;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    if (!hasDate) {
      return Text(context.tr('choose_date_first'));
    }
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return _InfoCard(
        icon: Icons.error_outline,
        message: context.tr(provider.errorMessage!),
        isError: true,
      );
    }
    if (provider.availableSlots.isEmpty) {
      return _InfoCard(
        icon: Icons.event_busy_outlined,
        message: context.tr('no_available_slots'),
        isError: true,
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: provider.availableSlots.map((slot) {
        return ChoiceChip(
          label: Text(slot),
          selected: selectedTime == slot,
          onSelected: (_) => onSelected(slot),
        );
      }).toList(),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.message,
    this.isError = false,
  });

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
