import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../models/service_model.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.showDocuments = false,
  });

  final ServiceModel service;
  final VoidCallback? onTap;
  final bool showDocuments;

  @override
  Widget build(BuildContext context) {
    final documents = service.localizedDocuments(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.description_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      service.localizedName(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${context.tr('daily_limit')}: ${service.dailyLimit} ${context.tr('appointments_per_day')}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (showDocuments) ...[
                const SizedBox(height: 14),
                Text(
                  context.tr('required_documents'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                ...documents.map(
                  (document) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(document)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
