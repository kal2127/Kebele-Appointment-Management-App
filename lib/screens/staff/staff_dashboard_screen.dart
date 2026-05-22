import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('staff_dashboard'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _DashboardCard(
            icon: Icons.assignment_ind_outlined,
            title: context.tr('assigned_services'),
            value: context.tr('available_services'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            icon: Icons.insights_outlined,
            title: context.tr('appointment_statistics'),
            value: context.tr('manage_appointments'),
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
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
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
          ],
        ),
      ),
    );
  }
}
