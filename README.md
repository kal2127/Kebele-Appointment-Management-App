# Kebele Appointment Management System

A beginner-friendly Flutter and Dart Frog project for appointment-focused Ethiopian Kebele office workflows.

## Included modules

- Flutter mobile app with Material Design 3
- Provider state management
- English and Amharic JSON localization, defaulting to Amharic
- Resident home, service list, booking, edit, cancel, track, and feedback screens
- Staff/Admin login flow with role-based navigation
- SQLite cache for services and appointment history
- Dart Frog REST API backend
- MySQL schema using `utf8mb4` for Amharic text

## Project structure

```text
lib/
  core/
  models/
  services/
  providers/
  screens/
  widgets/
  utils/
  database/
backend/
  routes/
  services/
  repositories/
  database/
  middleware/
  models/
database/
  schema.sql
docs/
  SETUP.md
  API_EXAMPLES.md
```

See `docs/SETUP.md` for setup steps and `docs/API_EXAMPLES.md` for sample requests.