import 'package:flutter/widgets.dart';

import '../core/app_localizations.dart';

String localizedAppointmentStatus(BuildContext context, String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return context.tr('status_pending');
    case 'confirmed':
      return context.tr('status_confirmed');
    case 'completed':
      return context.tr('status_completed');
    case 'rescheduled':
      return context.tr('status_rescheduled');
    case 'cancelled':
      return context.tr('status_cancelled');
    case 'not served':
      return context.tr('status_not_served');
    default:
      return status;
  }
}
