import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('admin_dashboard'))),
        body: EmptyState(message: context.tr('admin_login_required_message')),
      );
    }

    final cards = [
      _StatCard(
        context.tr('manage_services'),
        Icons.miscellaneous_services,
        AppRoutes.adminServices,
      ),
      _StatCard(
        context.tr('manage_staff'),
        Icons.group_outlined,
        AppRoutes.adminStaff,
      ),
      _StatCard(
        context.tr('appointment_limits'),
        Icons.tune_outlined,
        AppRoutes.adminLimits,
      ),
      _StatCard(
        context.tr('total_appointments'),
        Icons.calendar_month_outlined,
        null,
      ),
      _StatCard(
        context.tr('completed_appointments'),
        Icons.task_alt_outlined,
        null,
      ),
      _StatCard(
        context.tr('pending_appointments'),
        Icons.pending_actions,
        null,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('admin_dashboard'))),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) => cards[index],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.title, this.icon, this.route);

  final String title;
  final IconData icon;
  final String? route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: route == null ? null : () => Navigator.pushNamed(context, route!),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (route != null) const Spacer(),
              if (route != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
