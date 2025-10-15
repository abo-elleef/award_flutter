import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Notification IDs
  static const int morningNotificationId = 1;
  static const int eveningNotificationId = 2;

  // Default notification times (24-hour format)
  static const int defaultMorningHour = 8;
  static const int defaultMorningMinute = 0;
  static const int defaultEveningHour = 20;
  static const int defaultEveningMinute = 0;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - you can navigate to specific screens here
    print('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Request permissions for Android 13+
    bool? result = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request exact alarm permission for Android 12+
    bool? exactAlarmResult = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    return (result ?? false) && (exactAlarmResult ?? false);
  }

  Future<void> scheduleDailyNotifications({
    required int morningHour,
    required int morningMinute,
    required int eveningHour,
    required int eveningMinute,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Cancel existing notifications
      await cancelAllNotifications();

      // Schedule morning notification
      await _scheduleNotification(
        id: morningNotificationId,
        title: 'أوراد البرهامية',
        body: 'حان وقت قراءة الأوراد الصباحية',
        hour: morningHour,
        minute: morningMinute,
      );

      // Schedule evening notification
      await _scheduleNotification(
        id: eveningNotificationId,
        title: 'أوراد البرهامية',
        body: 'حان وقت قراءة الأوراد المسائية',
        hour: eveningHour,
        minute: eveningMinute,
      );

      // Save notification times to preferences
      await _saveNotificationTimes(
        morningHour: morningHour,
        morningMinute: morningMinute,
        eveningHour: eveningHour,
        eveningMinute: eveningMinute,
      );
    } catch (e) {
      print('Error scheduling notifications: $e');
      // If exact alarms are not permitted, try to request permission again
      if (e.toString().contains('exact_alarms_not_permitted')) {
        await requestPermissions();
        // Optionally, you could retry scheduling here or show a message to the user
      }
      rethrow;
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_awrad',
      'Daily Awrad Notifications',
      channelDescription: 'Daily notifications for Awrad reading times',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Calculate next occurrence of the scheduled time
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    if (enabled) {
      // Get saved times or use defaults
      final times = await getNotificationTimes();
      await scheduleDailyNotifications(
        morningHour: times['morningHour']!,
        morningMinute: times['morningMinute']!,
        eveningHour: times['eveningHour']!,
        eveningMinute: times['eveningMinute']!,
      );
    } else {
      await cancelAllNotifications();
    }
  }

  Future<Map<String, int>> getNotificationTimes() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'morningHour': prefs.getInt('morning_hour') ?? defaultMorningHour,
      'morningMinute': prefs.getInt('morning_minute') ?? defaultMorningMinute,
      'eveningHour': prefs.getInt('evening_hour') ?? defaultEveningHour,
      'eveningMinute': prefs.getInt('evening_minute') ?? defaultEveningMinute,
    };
  }

  Future<void> _saveNotificationTimes({
    required int morningHour,
    required int morningMinute,
    required int eveningHour,
    required int eveningMinute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('morning_hour', morningHour);
    await prefs.setInt('morning_minute', morningMinute);
    await prefs.setInt('evening_hour', eveningHour);
    await prefs.setInt('evening_minute', eveningMinute);
  }

  Future<void> updateNotificationTimes({
    required int morningHour,
    required int morningMinute,
    required int eveningHour,
    required int eveningMinute,
  }) async {
    final enabled = await areNotificationsEnabled();
    if (enabled) {
      await scheduleDailyNotifications(
        morningHour: morningHour,
        morningMinute: morningMinute,
        eveningHour: eveningHour,
        eveningMinute: eveningMinute,
      );
    } else {
      await _saveNotificationTimes(
        morningHour: morningHour,
        morningMinute: morningMinute,
        eveningHour: eveningHour,
        eveningMinute: eveningMinute,
      );
    }
  }
}
