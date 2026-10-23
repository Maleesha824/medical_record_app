import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final plugin = FlutterLocalNotificationsPlugin();
  static const _channel = AndroidNotificationChannel('medical_reminders', 'Medical Reminders', description: 'Medicine and appointment reminders', importance: Importance.max);

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Colombo'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(const InitializationSettings(android: android));
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  static NotificationDetails get _details => const NotificationDetails(android: AndroidNotificationDetails('medical_reminders', 'Medical Reminders', channelDescription: 'Medicine and appointment reminders', importance: Importance.max, priority: Priority.high, playSound: true));

  static Future<void> showTest(String title, String body) async => plugin.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, _details);

  static Future<void> scheduleMedicine({required int medicationId, required String name, required String dosage, required DateTime firstDose, required int durationDays, required Duration interval}) async {
    await cancelMedicine(medicationId);
    final end = firstDose.add(Duration(days: durationDays));
    var current = firstDose;
    var index = 0;
    while (current.isBefore(end)) {
      if (current.isAfter(DateTime.now())) {
        final id = _medicineId(medicationId, index);
        await plugin.zonedSchedule(id, 'Medicine reminder', '$name${dosage.isEmpty ? '' : ' • $dosage'}', tz.TZDateTime.from(current, tz.local), _details, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, payload: 'medicine:$medicationId');
      }
      index++;
      current = current.add(interval);
      if (index > 5000) break;
    }
  }

  static Future<void> scheduleAppointment({required int visitId, required String clinic, required DateTime appointment}) async {
    await cancelAppointment(visitId);
    final dayId = _appointmentId(visitId, 1);
    final beforeId = _appointmentId(visitId, 2);
    if (appointment.isAfter(DateTime.now())) {
      await plugin.zonedSchedule(dayId, 'Clinic appointment today', 'Appointment at $clinic is scheduled for ${appointment.hour.toString().padLeft(2, '0')}:${appointment.minute.toString().padLeft(2, '0')}.', tz.TZDateTime.from(appointment, tz.local), _details, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, payload: 'appointment:$visitId');
    }
    final reminder = appointment.subtract(const Duration(hours: 24));
    if (reminder.isAfter(DateTime.now())) {
      await plugin.zonedSchedule(beforeId, 'Clinic appointment tomorrow', 'You have an appointment at $clinic in 24 hours.', tz.TZDateTime.from(reminder, tz.local), _details, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, payload: 'appointment:$visitId');
    }
  }

  static Future<void> cancelMedicine(int medicationId) async {
    for (var i = 0; i < 5000; i++) await plugin.cancel(_medicineId(medicationId, i));
  }
  static Future<void> cancelAppointment(int visitId) async { await plugin.cancel(_appointmentId(visitId, 1)); await plugin.cancel(_appointmentId(visitId, 2)); }
  static int _medicineId(int medicationId, int index) => 100000 + medicationId * 5000 + index;
  static int _appointmentId(int visitId, int kind) => 900000 + visitId * 10 + kind;
}
