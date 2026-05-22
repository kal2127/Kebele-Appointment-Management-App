import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_routes.dart';
import '../../providers/service_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/responsive_page.dart';
import '../../widgets/service_card.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
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

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('service_list_title'))),
      body: RefreshIndicator(
        onRefresh: serviceProvider.loadServices,
        child: ListView(
          children: [
            ResponsivePage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('service_list_subtitle'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  if (!serviceProvider.isOnline)
                    OfflineBanner(
                      message: context.tr('offline_services_notice'),
                    ),
                  if (!serviceProvider.isOnline) const SizedBox(height: 16),
                  if (serviceProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (serviceProvider.services.isEmpty)
                    EmptyState(message: context.tr('no_services'))
                  else
                    ...serviceProvider.services.map(
                      (service) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ServiceCard(
                          service: service,
                          showDocuments: true,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.serviceDetails,
                            arguments: service,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
