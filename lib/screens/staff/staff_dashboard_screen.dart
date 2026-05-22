import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/responsive_page.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<StaffProvider>().loadAppointments(token: token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final staffProvider = context.watch<StaffProvider>();
    final assignedServiceId = authProvider.user?.assignedServiceId;

    if (!authProvider.isStaff || authProvider.token == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('staff_dashboard'))),
        body: ResponsivePage(
          child: _DashboardCard(
            icon: Icons.lock_outline,
            title: context.tr('login_required'),
            value: context.tr('staff_login_required_message'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.login),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('staff_dashboard'))),
      body: ListView(
        children: [
          ResponsivePage(
            child: Column(
              children: [
                _DashboardCard(
                  icon: Icons.assignment_ind_outlined,
                  title: context.tr('assigned_services'),
                  value: assignedServiceId == null
                      ? context.tr('not_assigned')
                      : '${context.tr('service_list_title')} #$assignedServiceId',
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  icon: Icons.pending_actions,
                  title: context.tr('pending_appointments'),
                  value: '${staffProvider.pendingCount}',
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  icon: Icons.task_alt_outlined,
                  title: context.tr('completed_appointments'),
                  value: '${staffProvider.completedCount}',
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  icon: Icons.calendar_month_outlined,
                  title: context.tr('manage_appointments'),
                  value: context.tr('staff_manage_appointments_hint'),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.staffAppointments,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(value),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
