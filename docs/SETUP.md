# Kebele Appointment Management System Setup

## Flutter app

1. Install a current Flutter SDK that includes Dart 3.10 or newer. This is
   required by the current `sqflite` and `shared_preferences` releases.
2. From the repository root, generate platform folders if this repository was
   cloned without them:

```bash
flutter create .
```

3. Install packages:

```bash
flutter pub get
```

4. Run the app with the backend URL for your environment:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

The app defaults to Amharic. Users can switch between Amharic and English from the home screen, and the choice is stored with `shared_preferences`.

## Backend

1. Install Dart 2.19.x for the backend package. The requested `mysql1` package
   is currently constrained to Dart `<3.0`, so the backend uses the latest
   Dart Frog/JWT versions compatible with `mysql1`.
2. Install the Dart Frog CLI:

```bash
dart pub global activate dart_frog_cli 0.3.6
```

3. Create the MySQL database:

```bash
mysql -u root -p < database/schema.sql
```

4. Install backend packages:

```bash
cd backend
dart pub get
```

5. Set environment variables. `backend/.env.example` lists the required keys:

```bash
export MYSQL_HOST=127.0.0.1
export MYSQL_PORT=3306
export MYSQL_USER=root
export MYSQL_PASSWORD=your_password
export MYSQL_DATABASE=kebele_appointments
export JWT_SECRET=change_this_secret
```

6. Start the API:

```bash
dart_frog dev
```

## Default admin login

- Email: `admin@kebele.gov.et`
- Password: `admin123`

For production, replace the sample password flow with a real password hashing package and rotate `JWT_SECRET`.
