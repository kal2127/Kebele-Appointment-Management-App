import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_routes.dart';
import '../../models/service_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/service_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/offline_banner.dart';

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

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('book_appointment'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!isBookingEnabled)
              OfflineBanner(message: context.tr('offline_booking_notice')),
            if (!isBookingEnabled) const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: context.tr('full_name')),
              validator: (value) =>
                  Validators.requiredField(value, context.tr('field_required')),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: context.tr('phone_number')),
              validator: (value) => Validators.ethiopianPhone(
                value,
                context.tr('field_required'),
                context.tr('invalid_phone'),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: selectedService?.id,
              decoration:
                  InputDecoration(labelText: context.tr('select_service')),
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
              validator: (value) =>
                  value == null ? context.tr('select_service_error') : null,
            ),
            const SizedBox(height: 14),
            if (selectedService != null) _RequiredDocuments(service: selectedService),
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
            if (_selectedServiceId == null || _selectedDate == null)
              Text(context.tr('choose_date_first'))
            else if (appointmentProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: appointmentProvider.availableSlots.map((slot) {
                  return ChoiceChip(
                    label: Text(slot),
                    selected: _selectedTimeSlot == slot,
                    onSelected: isBookingEnabled
                        ? (_) => setState(() => _selectedTimeSlot = slot)
                        : null,
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isBookingEnabled && !appointmentProvider.isLoading
                  ? _submit
                  : null,
              child: appointmentProvider.isLoading
                  ? Text(context.tr('loading'))
                  : Text(context.tr('submit_booking')),
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
