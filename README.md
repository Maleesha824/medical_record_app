# Medical Record App — Version 2

This is a Flutter 3.47 / Dart 3.13 friendly foundation for a personal medical record app.

## Version 2 features
- Medical records with date, disease/condition, doctor, notes and prescription text.
- Prescription/doctor receipt image attachment, persistent local copy and image preview/zoom.
- Clinic visits / appointments stored separately.
- Appointment notifications at the exact appointment time and 24 hours before.
- Medicine reminders scheduled at exact times for: 6h, 8h, 12h, daily, every 2 days or a custom hour interval.
- Medicine stock quantity, +/- stock controls and low-stock warning.
- Weight, blood sugar and blood pressure history.
- Separate graphs for weight, sugar, systolic and diastolic blood pressure.
- Monthly PDF report with real month filtering.
- Dark mode.
- Biometric/device authentication lock.
- Local SQLite storage.

## IMPORTANT first setup
This ZIP is intentionally supplied without generated Android/Gradle build files so it can create the correct Android project for the Flutter SDK installed on your computer.

After extracting the ZIP and opening the project root in VS Code, run:

```powershell
flutter create .
flutter pub get
flutter devices
flutter run
```

Do **not** delete the `lib` folder or `pubspec.yaml` before running `flutter create .`.

## Exact notification notes
Android 13+ requires notification permission. Exact-time reminders also require the Android exact-alarm permission. The app requests both at startup. Notifications are local to the device; no server is required.

If Android asks you to allow exact alarms, allow it for reliable scheduled reminders.

## Suggested test
1. Add a medicine with a first dose a few minutes in the future and a short custom interval.
2. Add an appointment for tomorrow at a chosen time.
3. Check that notifications are enabled in Android settings.
4. Add several health measurements and open the Health screen.
5. Open Monthly Reports and select a month before generating the PDF.
