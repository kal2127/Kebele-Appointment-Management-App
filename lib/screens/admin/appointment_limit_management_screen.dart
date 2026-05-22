import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../models/service_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_page.dart';

class AppointmentLimitManagementScreen extends StatefulWidget {
  const AppointmentLimitManagementScreen({super.key});

  @override
  State<AppointmentLimitManagementScreen> createState() =>
      _AppointmentLimitManagementScreenState();
}

class _AppointmentLimitManagementScreenState
    extends State<AppointmentLimitManagementScreen> {
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
        appBar: AppBar(title: Text(context.tr('appointment_limits'))),
        body: EmptyState(message: context.tr('admin_login_required_message')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('appointment_limits'))),
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
                              child: _LimitCard(service: service),
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LimitCard extends StatefulWidget {
  const _LimitCard({required this.service});

  final ServiceModel service;

  @override
  State<_LimitCard> createState() => _LimitCardState();
}

class _LimitCardState extends State<_LimitCard> {
  late final TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController(
      text: widget.service.dailyLimit.toString(),
    );
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.service.localizedName(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: context.tr('daily_limit')),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: adminProvider.isLoading ? null : _save,
              child: adminProvider.isLoading
                  ? Text(context.tr('loading'))
                  : Text(context.tr('save_limit')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().token;
    final limit = int.tryParse(_limitController.text.trim()) ?? 0;
    if (token == null || limit <= 0) {
      _showMessage(context.tr('error_generic'));
      return;
    }
    final success = await context.read<AdminProvider>().updateLimit(
          token: token,
          serviceId: widget.service.id,
          maxAppointmentsPerDay: limit,
        );
    if (!mounted) return;
    _showMessage(success ? context.tr('limit_saved') : context.tr('error_generic'));
    if (success) {
      await context.read<ServiceProvider>().loadServices();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
