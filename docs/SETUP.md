# Kebele Appointment Management System Setup

## Flutter app

1. Install Flutter 3.x.
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

1. Install Dart and Dart Frog CLI:

```bash
dart pub global activate dart_frog_cli
```

2. Create the MySQL database:

```bash
mysql -u root -p < database/schema.sql
```

3. Install backend packages:

```bash
cd backend
dart pub get
```

4. Set environment variables:

```bash
export MYSQL_HOST=127.0.0.1
export MYSQL_PORT=3306
export MYSQL_USER=root
export MYSQL_PASSWORD=your_password
export MYSQL_DATABASE=kebele_appointments
export JWT_SECRET=change_this_secret
```

5. Start the API:

```bash
dart_frog dev
```

## Default admin login

- Email: `admin@kebele.gov.et`
- Password: `admin123`

For production, replace the sample password flow with a real password hashing package and rotate `JWT_SECRET`.
