import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_routes.dart';
import '../../providers/service_provider.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/section_header.dart';
import '../../widgets/service_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();
    final topServices = serviceProvider.services.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('app_short_name')),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12),
            child: Center(child: LanguageSwitcher()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: serviceProvider.loadServices,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HeroCard(isOnline: serviceProvider.isOnline),
            const SizedBox(height: 16),
            if (!serviceProvider.isOnline)
              OfflineBanner(message: context.tr('offline_services_notice')),
            if (!serviceProvider.isOnline) const SizedBox(height: 16),
            _KebeleInfoCard(),
            const SizedBox(height: 24),
            SectionHeader(
              title: context.tr('available_services'),
              actionLabel: context.tr('view_all'),
              onAction: () => Navigator.pushNamed(context, AppRoutes.services),
            ),
            const SizedBox(height: 12),
            if (serviceProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ...topServices.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ServiceCard(
                    service: service,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.serviceDetails,
                      arguments: service,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            _QuickActions(isOnline: serviceProvider.isOnline),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 42,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(height: 18),
          Text(
            context.tr('home_title'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('home_subtitle'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
            onPressed: isOnline
                ? () => Navigator.pushNamed(context, AppRoutes.bookAppointment)
                : null,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(context.tr('book_appointment')),
          ),
        ],
      ),
    );
  }
}

class _KebeleInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('kebele_info_title'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(context.tr('kebele_info_body')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.edit_calendar_outlined,
        label: context.tr('edit_appointment'),
        route: AppRoutes.editAppointment,
        enabled: isOnline,
      ),
      _ActionItem(
        icon: Icons.cancel_outlined,
        label: context.tr('cancel_appointment'),
        route: AppRoutes.cancelAppointment,
        enabled: isOnline,
      ),
      _ActionItem(
        icon: Icons.search_outlined,
        label: context.tr('track_appointment'),
        route: AppRoutes.trackAppointment,
        enabled: true,
      ),
      _ActionItem(
        icon: Icons.feedback_outlined,
        label: context.tr('feedback'),
        route: AppRoutes.feedback,
        enabled: isOnline,
      ),
      _ActionItem(
        icon: Icons.lock_outline,
        label: context.tr('login_staff_admin'),
        route: AppRoutes.login,
        enabled: isOnline,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions.map((action) => _ActionTile(action: action)).toList(),
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool enabled;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action});

  final _ActionItem action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width > 520
          ? 160
          : (MediaQuery.sizeOf(context).width - 52) / 2,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: action.enabled
              ? () => Navigator.pushNamed(context, action.route)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(action.icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  action.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
