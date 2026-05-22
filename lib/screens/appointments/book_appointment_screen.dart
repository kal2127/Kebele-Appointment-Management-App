import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_routes.dart';
import '../../models/service_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/service_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/appointment_success_dialog.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/responsive_page.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key, this.initialService});

  final ServiceModel? initialService;

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateFormat = DateFormat('yyyy-MM-dd');

  int? _selectedServiceId;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _selectedServiceId = widget.initialService?.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();
    final appointmentProvider = context.watch<AppointmentProvider>();
    final services = serviceProvider.services;
    final selectedService = _selectedService(services);
    final isBookingEnabled = serviceProvider.isOnline;
    final showOffline = serviceProvider.hasCheckedConnection &&
        !serviceProvider.isOnline;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('book_appointment'))),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ResponsivePage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showOffline)
                    OfflineBanner(message: context.tr('offline_booking_notice')),
                  if (showOffline) const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration:
                        InputDecoration(labelText: context.tr('full_name')),
                    validator: (value) => Validators.requiredField(
                      value,
                      context.tr('field_required'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration:
                        InputDecoration(labelText: context.tr('phone_number')),
                    validator: (value) => Validators.ethiopianPhone(
                      value,
                      context.tr('field_required'),
                      context.tr('invalid_phone'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    value: selectedService?.id,
                    decoration: InputDecoration(
                      labelText: context.tr('select_service'),
                    ),
                    items: services
                        .map(
                          (service) => DropdownMenuItem(
                            value: service.id,
                            child: Text(service.localizedName(context)),
                          ),
                        )
                        .toList(),
                    onChanged: isBookingEnabled
                        ? (value) {
                            setState(() {
                              _selectedServiceId = value;
                              _selectedTimeSlot = null;
                            });
                            _loadSlotsIfReady();
                          }
                        : null,
                    validator: (value) => value == null
                        ? context.tr('select_service_error')
                        : null,
                  ),
                  const SizedBox(height: 14),
                  if (selectedService != null)
                    _RequiredDocuments(service: selectedService),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: isBookingEnabled ? _pickDate : null,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      _selectedDate == null
                          ? context.tr('select_date')
                          : _dateFormat.format(_selectedDate!),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.tr('available_slots'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _SlotSelector(
                    hasSelectionContext:
                        _selectedServiceId != null && _selectedDate != null,
                    isBookingEnabled: isBookingEnabled,
                    selectedTimeSlot: _selectedTimeSlot,
                    onSelected: (slot) {
                      setState(() => _selectedTimeSlot = slot);
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed:
                        isBookingEnabled && !appointmentProvider.isLoading
                            ? _submit
                            : null,
                    child: appointmentProvider.isLoading
                        ? Text(context.tr('loading'))
                        : Text(context.tr('submit_booking')),
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
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );

    if (pickedDate == null) return;
    setState(() {
      _selectedDate = pickedDate;
      _selectedTimeSlot = null;
    });
    await _loadSlotsIfReady();
  }

  ServiceModel? _selectedService(List<ServiceModel> services) {
    for (final service in services) {
      if (service.id == _selectedServiceId) return service;
    }
    return null;
  }

  Future<void> _loadSlotsIfReady() async {
    if (_selectedServiceId == null || _selectedDate == null) return;
    await context.read<AppointmentProvider>().loadAvailableSlots(
          serviceId: _selectedServiceId!,
          date: _selectedDate!,
        );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showMessage(context.tr('select_date_error'));
      return;
    }
    if (_selectedTimeSlot == null) {
      _showMessage(context.tr('select_slot_error'));
      return;
    }

    final appointment = await context.read<AppointmentProvider>().bookAppointment(
          residentName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          serviceId: _selectedServiceId!,
          appointmentDate: _selectedDate!,
          appointmentTime: _selectedTimeSlot!,
        );

    if (!mounted) return;
    if (appointment == null) {
      _showMessage(context.tr('error_generic'));
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppointmentSuccessDialog(appointment: appointment),
    );
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.appointmentConfirmation,
      arguments: appointment,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SlotSelector extends StatelessWidget {
  const _SlotSelector({
    required this.hasSelectionContext,
    required this.isBookingEnabled,
    required this.selectedTimeSlot,
    required this.onSelected,
  });

  final bool hasSelectionContext;
  final bool isBookingEnabled;
  final String? selectedTimeSlot;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = context.watch<AppointmentProvider>();

    if (!hasSelectionContext) {
      return Text(context.tr('choose_date_first'));
    }
    if (appointmentProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (appointmentProvider.errorMessage != null) {
      return _SlotMessageCard(
        icon: Icons.error_outline,
        message: context.tr(appointmentProvider.errorMessage!),
        color: Theme.of(context).colorScheme.error,
      );
    }
    if (appointmentProvider.availableSlots.isEmpty) {
      return _SlotMessageCard(
        icon: Icons.event_busy_outlined,
        message: context.tr('no_available_slots'),
        color: Theme.of(context).colorScheme.error,
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: appointmentProvider.availableSlots.map((slot) {
        return ChoiceChip(
          label: Text(slot),
          selected: selectedTimeSlot == slot,
          onSelected: isBookingEnabled ? (_) => onSelected(slot) : null,
        );
      }).toList(),
    );
  }
}

class _SlotMessageCard extends StatelessWidget {
  const _SlotMessageCard({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
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

class _RequiredDocuments extends StatelessWidget {
  const _RequiredDocuments({required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    final documents = service.localizedDocuments(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('required_documents'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            ...documents.map(
              (document) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(document)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
