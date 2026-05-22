import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../models/service_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_page.dart';
import '../../widgets/service_card.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final serviceProvider = context.watch<ServiceProvider>();

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('manage_services'))),
        body: EmptyState(message: context.tr('admin_login_required_message')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('manage_services'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: authProvider.isAdmin
            ? () => _showServiceForm(context, null)
            : null,
        icon: const Icon(Icons.add),
        label: Text(context.tr('add_service')),
      ),
      body: RefreshIndicator(
        onRefresh: serviceProvider.loadServices,
        child: ListView(
          children: [
            ResponsivePage(
              child: serviceProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : serviceProvider.services.isEmpty
                      ? EmptyState(message: context.tr('no_services'))
                      : Column(
                          children: serviceProvider.services.map((service) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                children: [
                                  ServiceCard(
                                    service: service,
                                    showDocuments: true,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _showServiceForm(
                                            context,
                                            service,
                                          ),
                                          icon: const Icon(Icons.edit_outlined),
                                          label: Text(context.tr('edit')),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: () => _deleteService(
                                            context,
                                            service,
                                          ),
                                          icon: const Icon(Icons.delete_outline),
                                          label: Text(context.tr('delete')),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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

  Future<void> _showServiceForm(
    BuildContext context,
    ServiceModel? service,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ServiceForm(service: service),
    );
    if (!mounted) return;
    await context.read<ServiceProvider>().loadServices();
  }

  Future<void> _deleteService(
    BuildContext context,
    ServiceModel service,
  ) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('delete_service')),
        content: Text(context.tr('delete_service_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel_appointment')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await context.read<AdminProvider>().deleteService(
          token: token,
          serviceId: service.id,
        );
    if (!mounted) return;
    _showMessage(success ? context.tr('service_deleted') : context.tr('error_generic'));
    await context.read<ServiceProvider>().loadServices();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ServiceForm extends StatefulWidget {
  const _ServiceForm({this.service});

  final ServiceModel? service;

  @override
  State<_ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<_ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _documentsController;
  late final TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    _nameController = TextEditingController(text: service?.name ?? '');
    _descriptionController =
        TextEditingController(text: service?.description ?? '');
    _documentsController = TextEditingController(
      text: service?.requiredDocuments.join(', ') ?? '',
    );
    _limitController = TextEditingController(
      text: service?.dailyLimit.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _documentsController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                widget.service == null
                    ? context.tr('add_service')
                    : context.tr('edit_service'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: context.tr('service_name')),
                validator: (value) =>
                    Validators.requiredField(value, context.tr('field_required')),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    InputDecoration(labelText: context.tr('service_description')),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _documentsController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: context.tr('required_documents_csv'),
                ),
                validator: (value) =>
                    Validators.requiredField(value, context.tr('field_required')),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _limitController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: context.tr('daily_limit')),
                validator: (value) =>
                    Validators.requiredField(value, context.tr('field_required')),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: adminProvider.isLoading ? null : _save,
                child: adminProvider.isLoading
                    ? Text(context.tr('loading'))
                    : Text(context.tr('save_changes')),
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
    if (token == null) return;

    final documents = _documentsController.text
        .split(',')
        .map((document) => document.trim())
        .where((document) => document.isNotEmpty)
        .toList();
    final limit = int.tryParse(_limitController.text.trim()) ?? 0;
    if (limit <= 0 || documents.isEmpty) {
      _showMessage(context.tr('error_generic'));
      return;
    }

    final service = widget.service;
    final success = service == null
        ? await context.read<AdminProvider>().createService(
              token: token,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              requiredDocuments: documents,
              dailyLimit: limit,
            )
        : await context.read<AdminProvider>().updateService(
              token: token,
              service: ServiceModel(
                id: service.id,
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                requiredDocuments: documents,
                dailyLimit: limit,
              ),
            );
    if (!mounted) return;
    _showMessage(
      success
          ? context.tr('service_saved')
          : context.tr('error_generic'),
    );
    if (success) Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
