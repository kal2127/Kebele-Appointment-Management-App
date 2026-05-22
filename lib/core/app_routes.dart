import 'package:flutter/material.dart';

import '../models/appointment_model.dart';
import '../models/service_model.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/appointments/appointment_confirmation_screen.dart';
import '../screens/appointments/book_appointment_screen.dart';
import '../screens/appointments/cancel_appointment_screen.dart';
import '../screens/appointments/edit_appointment_screen.dart';
import '../screens/appointments/track_appointment_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/feedback/feedback_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/services/service_list_screen.dart';
import '../screens/staff/staff_dashboard_screen.dart';

class AppRoutes {
  static const home = '/';
  static const services = '/services';
  static const bookAppointment = '/appointments/book';
  static const appointmentConfirmation = '/appointments/confirmation';
  static const editAppointment = '/appointments/edit';
  static const cancelAppointment = '/appointments/cancel';
  static const trackAppointment = '/appointments/track';
  static const feedback = '/feedback';
  static const login = '/login';
  static const staffDashboard = '/staff/dashboard';
  static const adminDashboard = '/admin/dashboard';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case services:
        return MaterialPageRoute(builder: (_) => const ServiceListScreen());
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
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
