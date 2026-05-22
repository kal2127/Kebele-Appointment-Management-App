import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../models/admin_staff_model.dart';
import '../../models/service_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_page.dart';

class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final services = context.watch<ServiceProvider>().services;

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('manage_staff'))),
        body: EmptyState(message: context.tr('admin_login_required_message')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('manage_staff'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStaffForm(context),
        icon: const Icon(Icons.person_add_alt),
        label: Text(context.tr('register_staff')),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            ResponsivePage(
              child: adminProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : adminProvider.staff.isEmpty
                      ? EmptyState(message: context.tr('no_staff_found'))
                      : Column(
                          children: adminProvider.staff.map((staff) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _StaffCard(
                                staff: staff,
                                services: services,
                                onAssign: () => _showAssignSheet(
                                  context,
                                  staff,
                                  services,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    await Future.wait([
      context.read<ServiceProvider>().loadServices(),
      context.read<AdminProvider>().loadStaff(token: token),
    ]);
  }

  Future<void> _showStaffForm(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _StaffForm(),
    );
    if (!mounted) return;
    await _load();
  }

  Future<void> _showAssignSheet(
    BuildContext context,
    AdminStaffModel staff,
    List<ServiceModel> services,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => _AssignStaffSheet(staff: staff, services: services),
    );
    if (!mounted) return;
    await _load();
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.staff,
    required this.services,
    required this.onAssign,
  });

  final AdminStaffModel staff;
  final List<ServiceModel> services;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final assignedService = services.where(
      (service) => service.id == staff.assignedServiceId,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              staff.fullName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(staff.email),
            const SizedBox(height: 8),
            Text(
              assignedService.isEmpty
                  ? context.tr('not_assigned')
                  : assignedService.first.localizedName(context),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onAssign,
              icon: const Icon(Icons.assignment_ind_outlined),
              label: Text(context.tr('assign_service')),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffForm extends StatefulWidget {
  const _StaffForm();

  @override
  State<_StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends State<_StaffForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int? _selectedServiceId;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = context.watch<ServiceProvider>().services;
    final adminProvider = context.watch<AdminProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr('register_staff'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: context.tr('full_name')),
                validator: (value) =>
                    Validators.requiredField(value, context.tr('field_required')),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: context.tr('email')),
                validator: (value) =>
                    Validators.requiredField(value, context.tr('field_required')),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: context.tr('password')),
                validator: (value) =>
                    Validators.requiredField(value, context.tr('field_required')),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedServiceId,
                decoration: InputDecoration(labelText: context.tr('assign_service')),
                items: services.map((service) {
                  return DropdownMenuItem(
                    value: service.id,
                    child: Text(service.localizedName(context)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedServiceId = value),
                validator: (value) =>
                    value == null ? context.tr('select_service_error') : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: adminProvider.isLoading ? null : _save,
                child: adminProvider.isLoading
                    ? Text(context.tr('loading'))
                    : Text(context.tr('register_staff')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final token = context.read<AuthProvider>().token;
    if (token == null || _selectedServiceId == null) return;
    final success = await context.read<AdminProvider>().registerStaff(
          token: token,
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          assignedServiceId: _selectedServiceId!,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? context.tr('staff_registered') : context.tr('error_generic')),
      ),
    );
    if (success) Navigator.pop(context);
  }
}

class _AssignStaffSheet extends StatefulWidget {
  const _AssignStaffSheet({
    required this.staff,
    required this.services,
  });

  final AdminStaffModel staff;
  final List<ServiceModel> services;

  @override
  State<_AssignStaffSheet> createState() => _AssignStaffSheetState();
}

class _AssignStaffSheetState extends State<_AssignStaffSheet> {
  int? _serviceId;

  @override
  void initState() {
    super.initState();
    _serviceId = widget.staff.assignedServiceId;
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr('assign_service'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _serviceId,
            decoration: InputDecoration(labelText: context.tr('select_service')),
            items: widget.services.map((service) {
              return DropdownMenuItem(
                value: service.id,
                child: Text(service.localizedName(context)),
              );
            }).toList(),
            onChanged: (value) => setState(() => _serviceId = value),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: adminProvider.isLoading || _serviceId == null
                ? null
                : _save,
            child: adminProvider.isLoading
                ? Text(context.tr('loading'))
                : Text(context.tr('save_changes')),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || _serviceId == null) return;
    final success = await context.read<AdminProvider>().assignStaff(
          token: token,
          staffId: widget.staff.id,
          assignedServiceId: _serviceId!,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? context.tr('staff_assigned') : context.tr('error_generic')),
      ),
    );
    if (success) Navigator.pop(context);
  }
}
