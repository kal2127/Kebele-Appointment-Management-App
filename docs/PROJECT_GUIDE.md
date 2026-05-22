# Kebele Appointment Management System - Beginner Guide

## 1. What this project does

This project is a mobile appointment system for an Ethiopian Kebele office.

Residents can:

- view services
- see required documents
- book appointments
- edit appointments
- cancel appointments
- track appointments
- submit feedback

Staff can:

- login
- view appointments for their assigned service only
- filter appointments
- update appointment status

Admins can:

- login
- manage services
- register and assign staff
- set daily appointment limits

## 2. Project architecture

The project has two main parts.

```text
lib/        Flutter mobile app
backend/    Dart Frog REST API
database/   MySQL schema
docs/       setup and API documentation
```

### Flutter app structure

```text
lib/
  core/        app routes, theme, colors, constants, localization
  database/    local SQLite cache using sqflite
  models/      Dart data models
  providers/   Provider state management classes
  screens/     UI screens grouped by feature
  services/    HTTP API clients
  utils/       validators and small helper functions
  widgets/     reusable UI widgets
```

The Flutter app uses Provider. Screens do not call the backend directly.
Screens call Providers, and Providers call API service classes.

Example flow:

```text
BookAppointmentScreen
  -> AppointmentProvider
  -> AppointmentApiService
  -> Dart Frog backend
  -> MySQL
```

### Backend structure

```text
backend/
  routes/        Dart Frog API routes
  services/      business validation and use cases
  repositories/  MySQL queries
  database/      MySQL connection factory
  middleware/    JWT authentication and role checks
  models/        backend response models
```

The backend route files stay small. Most validation is in service classes, and
SQL queries are in repository classes.

## 3. Database relationships

Main tables:

- `departments`
- `services`
- `users`
- `appointment_limits`
- `appointments`
- `feedback`

Relationships:

- One department can have many services.
- One service can have many appointments.
- One service can have one appointment limit.
- One staff user can be assigned to one service.
- Feedback can optionally reference an appointment number.

Important fields:

- `services.required_documents` stores documents as JSON.
- `appointments.appointment_number` is unique.
- `appointments.status` stores values such as Pending, Completed, Cancelled.
- All tables use `utf8mb4` so Amharic text can be stored safely.

## 4. API flow

### Public/resident APIs

- `GET /services`
- `GET /services/:id`
- `GET /appointments/slots`
- `POST /appointments`
- `GET /appointments/:id`
- `PUT /appointments/:id`
- `DELETE /appointments/:id`
- `POST /feedback`

Resident appointment booking flow:

```text
1. App loads services from GET /services.
2. Resident selects service and date.
3. App loads available slots from GET /appointments/slots.
4. Resident submits booking to POST /appointments.
5. Backend checks daily limit and selected slot.
6. Backend creates a unique appointment number.
7. Appointment is saved in MySQL.
8. App shows success dialog and confirmation screen.
```

### Staff APIs

- `POST /staff/login`
- `GET /staff/appointments`
- `PUT /staff/appointments/status`

Staff appointment flow:

```text
1. Staff logs in and receives JWT token.
2. App sends token in Authorization header.
3. Backend verifies role = staff.
4. Backend only returns appointments for staff assigned service.
5. Staff updates status only for assigned-service appointments.
```

### Admin APIs

- `POST /staff/login`
- `GET /admin/staff`
- `POST /admin/staff`
- `PUT /admin/staff`
- `PUT /admin/staff/reset_password`
- `POST /admin/services`
- `PUT /admin/services/:id`
- `DELETE /admin/services/:id`
- `PUT /admin/limits`

Admin flow:

```text
1. Admin logs in and receives JWT token.
2. App routes admin to Admin Dashboard.
3. Backend verifies role = admin for admin APIs.
4. Admin can manage services, staff, and appointment limits.
```

## 5. Authentication flow

Residents do not login.

Staff and admins login from the same login screen:

```text
LoginScreen
  -> AuthProvider
  -> AuthApiService
  -> POST /staff/login
```

The backend checks:

- email
- password
- role is `staff` or `admin`

If login succeeds:

- backend returns a JWT token
- app stores token with `shared_preferences`
- app redirects based on role

Role navigation:

- `admin` -> Admin Dashboard
- `staff` -> Staff Dashboard

## 6. Localization

Translations are stored in:

```text
assets/translations/en.json
assets/translations/am.json
```

The default language is Amharic.

The app uses Flutter localization delegates and a small custom JSON loader in
`lib/core/app_localizations.dart`.

Amharic support:

- JSON files are UTF-8.
- Flutter theme includes Ethiopic font fallbacks.
- MySQL uses `utf8mb4`.
- Backend connection runs `SET NAMES utf8mb4`.

## 7. Offline support

Offline support is intentionally simple.

The app caches:

- services
- appointment history

The app does not allow offline booking, editing, or cancellation because those
must update MySQL.

Offline behavior:

```text
If service API succeeds:
  - app is online
  - services are saved to SQLite
  - cached appointment history is refreshed

If service API fails:
  - app is offline
  - cached services are shown
  - cached appointment history is shown
  - booking is disabled
```

## 8. Setup instructions

### Flutter app

Install Flutter with Dart 3.10 or newer.

```bash
flutter create .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Use `10.0.2.2` for Android emulator. Use your computer IP address for a real
phone on the same network.

### Backend

The requested `mysql1` package currently requires Dart `<3.0`, so use Dart
2.19.x for the backend package.

```bash
cd backend
dart pub get
dart pub global activate dart_frog_cli 0.3.6
```

Set environment variables:

```bash
export MYSQL_HOST=127.0.0.1
export MYSQL_PORT=3306
export MYSQL_USER=root
export MYSQL_PASSWORD=your_password
export MYSQL_DATABASE=kebele_appointments
export JWT_SECRET=change_this_secret
```

Create database:

```bash
mysql -u root -p < database/schema.sql
```

Run backend:

```bash
cd backend
dart_frog dev
```

Default admin:

- Email: `admin@kebele.gov.et`
- Password: `admin123`

## 9. How to present the project

Suggested presentation order:

1. Explain the problem: Kebele appointment queues and manual scheduling.
2. Show resident home screen and services.
3. Book an appointment and show the appointment number.
4. Track the appointment by appointment number.
5. Demonstrate edit/cancel rules.
6. Login as staff and filter assigned appointments.
7. Update appointment status as staff.
8. Login as admin and manage services/staff/limits.
9. Show feedback submission.
10. Explain offline cache: services/history work offline, booking is disabled.
11. Explain the backend and MySQL schema briefly.

Keep the explanation simple: Flutter handles the user interface, Dart Frog
handles the API, and MySQL stores official appointment data.
