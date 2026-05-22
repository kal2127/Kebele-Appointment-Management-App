import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../utils/validators.dart';

class EditAppointmentScreen extends StatefulWidget {
  const EditAppointmentScreen({super.key});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _numberController,
            decoration: InputDecoration(
              labelText: context.tr('enter_appointment_number'),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: provider.isLoading ? null : _findAppointment,
            icon: const Icon(Icons.search_outlined),
            label: Text(context.tr('search')),
          ),
          const SizedBox(height: 20),
          if (provider.isLoading) const Center(child: CircularProgressIndicator()),
          if (_appointment != null) ...[
            Text(
              '${context.tr('appointment_date')}: ${_dateFormat.format(_appointment!.appointmentDate)}',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: canEdit ? _pickNewDate : null,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                _newDate == null
                    ? context.tr('select_date')
                    : _dateFormat.format(_newDate!),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.availableSlots.map((slot) {
                return ChoiceChip(
                  label: Text(slot),
                  selected: _newTime == slot,
                  onSelected: canEdit
                      ? (_) => setState(() => _newTime = slot)
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: canEdit && _newDate != null && _newTime != null
                  ? _saveChanges
                  : null,
              child: Text(context.tr('save_changes')),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _findAppointment() async {
    final error = Validators.requiredField(
      _numberController.text,
      context.tr('field_required'),
    );
    if (error != null) {
      _showMessage(error);
      return;
    }
    final appointment = await context
        .read<AppointmentProvider>()
        .trackAppointment(_numberController.text.trim());
    if (!mounted) return;
    setState(() {
      _appointment = appointment;
      _newDate = null;
      _newTime = null;
    });
    if (appointment == null) _showMessage(context.tr('error_generic'));
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
    _showMessage(
      updated == null ? context.tr('error_generic') : context.tr('save_changes'),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
