import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_routes.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/responsive_page.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key, required this.service});

  final ServiceModel service;

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServiceDetail(widget.service.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();
    final service = serviceProvider.serviceById(widget.service.id) ?? widget.service;
    final documents = service.localizedDocuments(context);
    final showOffline = serviceProvider.hasCheckedConnection &&
        !serviceProvider.isOnline;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('service_details_title'))),
      body: RefreshIndicator(
        onRefresh: serviceProvider.loadServices,
        child: ListView(
          children: [
            ResponsivePage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (serviceProvider.isLoading)
                    const LinearProgressIndicator(),
                  if (serviceProvider.isLoading) const SizedBox(height: 16),
                  if (showOffline)
                    OfflineBanner(
                      message: context.tr('offline_services_notice'),
                    ),
                  if (showOffline) const SizedBox(height: 16),
                  _ServiceHero(service: service),
                  const SizedBox(height: 16),
                  _DocumentsCard(documents: documents),
                  const SizedBox(height: 16),
                  _LimitCard(service: service),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: serviceProvider.isOnline
                        ? () => Navigator.pushNamed(
                              context,
                              AppRoutes.bookAppointment,
                              arguments: service,
                            )
                        : null,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(context.tr('book_this_service')),
                  ),
                  if (showOffline) ...[
                    const SizedBox(height: 10),
                    Text(
                      context.tr('offline_booking_notice'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceHero extends StatelessWidget {
  const _ServiceHero({required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.description_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              service.localizedName(context),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              service.description?.isNotEmpty == true
                  ? service.description!
                  : context.tr('service_details_body'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard({required this.documents});

  final List<String> documents;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('required_documents'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            ...documents.map(
              (document) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
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

class _LimitCard extends StatelessWidget {
  const _LimitCard({required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              Icons.event_available_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${context.tr('daily_limit')}: ${service.dailyLimit} '
                '${context.tr('appointments_per_day')}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
