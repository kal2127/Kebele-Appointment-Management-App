import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(context.tr('total_appointments'), Icons.calendar_month_outlined),
      _StatCard(context.tr('completed_appointments'), Icons.task_alt_outlined),
      _StatCard(context.tr('pending_appointments'), Icons.pending_actions),
      _StatCard(context.tr('manage_services'), Icons.miscellaneous_services),
      _StatCard(context.tr('manage_staff'), Icons.group_outlined),
      _StatCard(context.tr('appointment_limits'), Icons.tune_outlined),
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
  const _StatCard(this.title, this.icon);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
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
          ],
        ),
      ),
    );
  }
}
