import 'package:flutter/material.dart';

import '../models/appointment_model.dart';
import '../models/service_model.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/appointment_limit_management_screen.dart';
import '../screens/admin/manage_services_screen.dart';
import '../screens/admin/manage_staff_screen.dart';
import '../screens/appointments/appointment_confirmation_screen.dart';
import '../screens/appointments/book_appointment_screen.dart';
import '../screens/appointments/cancel_appointment_screen.dart';
import '../screens/appointments/edit_appointment_screen.dart';
import '../screens/appointments/track_appointment_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/feedback/feedback_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/services/service_details_screen.dart';
import '../screens/services/service_list_screen.dart';
import '../screens/staff/staff_appointment_management_screen.dart';
import '../screens/staff/staff_dashboard_screen.dart';
import '../screens/staff/update_appointment_status_screen.dart';

class AppRoutes {
  static const home = '/';
  static const services = '/services';
  static const serviceDetails = '/services/details';
  static const bookAppointment = '/appointments/book';
  static const appointmentConfirmation = '/appointments/confirmation';
  static const editAppointment = '/appointments/edit';
  static const cancelAppointment = '/appointments/cancel';
  static const trackAppointment = '/appointments/track';
  static const feedback = '/feedback';
  static const login = '/login';
  static const staffDashboard = '/staff/dashboard';
  static const staffAppointments = '/staff/appointments';
  static const staffUpdateStatus = '/staff/appointments/status';
  static const adminDashboard = '/admin/dashboard';
  static const adminServices = '/admin/services';
  static const adminStaff = '/admin/staff';
  static const adminLimits = '/admin/limits';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case services:
        return MaterialPageRoute(builder: (_) => const ServiceListScreen());
      case serviceDetails:
        return MaterialPageRoute(
          builder: (_) => ServiceDetailsScreen(
            service: settings.arguments as ServiceModel,
          ),
        );
      case bookAppointment:
        return MaterialPageRoute(
          builder: (_) => BookAppointmentScreen(
            initialService: settings.arguments as ServiceModel?,
          ),
        );
      case appointmentConfirmation:
        return MaterialPageRoute(
          builder: (_) => AppointmentConfirmationScreen(
            appointment: settings.arguments as AppointmentModel,
          ),
        );
      case editAppointment:
        return MaterialPageRoute(builder: (_) => const EditAppointmentScreen());
      case cancelAppointment:
        return MaterialPageRoute(
          builder: (_) => const CancelAppointmentScreen(),
        );
      case trackAppointment:
        return MaterialPageRoute(builder: (_) => const TrackAppointmentScreen());
      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case staffDashboard:
        return MaterialPageRoute(builder: (_) => const StaffDashboardScreen());
      case staffAppointments:
        return MaterialPageRoute(
          builder: (_) => const StaffAppointmentManagementScreen(),
        );
      case staffUpdateStatus:
        return MaterialPageRoute(
          builder: (_) => UpdateAppointmentStatusScreen(
            appointment: settings.arguments as AppointmentModel,
          ),
        );
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case adminServices:
        return MaterialPageRoute(builder: (_) => const ManageServicesScreen());
      case adminStaff:
        return MaterialPageRoute(builder: (_) => const ManageStaffScreen());
      case adminLimits:
        return MaterialPageRoute(
          builder: (_) => const AppointmentLimitManagementScreen(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
