import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_routes.dart';
import '../../core/appointment_statuses.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/staff_provider.dart';
import '../../utils/appointment_status_localizer.dart';
import '../../widgets/appointment_summary_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_page.dart';

class StaffAppointmentManagementScreen extends StatefulWidget {
  const StaffAppointmentManagementScreen({super.key});

  @override
  State<StaffAppointmentManagementScreen> createState() =>
      _StaffAppointmentManagementScreenState();
}

class _StaffAppointmentManagementScreenState
    extends State<StaffAppointmentManagementScreen> {
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _serviceController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAppointments());
  }

  @override
  void dispose() {
    _serviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final staffProvider = context.watch<StaffProvider>();

    if (!authProvider.isStaff || authProvider.token == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('manage_appointments'))),
        body: ResponsivePage(
          child: EmptyState(message: context.tr('staff_login_required_message')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('manage_appointments'))),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: ListView(
          children: [
            ResponsivePage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilterCard(
                    dateLabel: _selectedDate == null
                        ? context.tr('filter_by_date')
                        : _dateFormat.format(_selectedDate!),
                    serviceController: _serviceController,
                    selectedStatus: _selectedStatus,
                    onPickDate: _pickDate,
                    onStatusChanged: (status) {
                      setState(() => _selectedStatus = status);
                    },
                    onApply: _loadAppointments,
                    onClear: _clearFilters,
                  ),
                  const SizedBox(height: 16),
                  if (staffProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (staffProvider.appointments.isEmpty)
                    EmptyState(message: context.tr('no_appointments_found'))
                  else
                    ...staffProvider.appointments.map(
                      (appointment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _StaffAppointmentCard(
                          appointment: appointment,
                          onUpdate: () => Navigator.pushNamed(
                            context,
                            AppRoutes.staffUpdateStatus,
                            arguments: appointment,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }

  Future<void> _loadAppointments() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    await context.read<StaffProvider>().loadAppointments(
          token: token,
          date: _selectedDate,
          status: _selectedStatus,
          serviceId: int.tryParse(_serviceController.text.trim()),
        );
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedDate = null;
      _selectedStatus = null;
      _serviceController.clear();
    });
    context.read<StaffProvider>().clearFilters();
    await _loadAppointments();
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.dateLabel,
    required this.serviceController,
    required this.selectedStatus,
    required this.onPickDate,
    required this.onStatusChanged,
    required this.onApply,
    required this.onClear,
  });

  final String dateLabel;
  final TextEditingController serviceController;
  final String? selectedStatus;
  final VoidCallback onPickDate;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('filter_appointments'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onPickDate,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(dateLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: serviceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.tr('filter_by_service_id'),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(
                labelText: context.tr('filter_by_status'),
              ),
              items: AppointmentStatuses.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(localizedAppointmentStatus(context, status)),
                    ),
                  )
                  .toList(),
              onChanged: onStatusChanged,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClear,
                    child: Text(context.tr('clear_filters')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onApply,
                    child: Text(context.tr('apply_filters')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffAppointmentCard extends StatelessWidget {
  const _StaffAppointmentCard({
    required this.appointment,
    required this.onUpdate,
  });

  final AppointmentModel appointment;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppointmentSummaryCard(appointment: appointment),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onUpdate,
          icon: const Icon(Icons.edit_outlined),
          label: Text(context.tr('update_status')),
        ),
      ],
    );
  }
}
