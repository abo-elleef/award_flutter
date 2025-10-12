// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get main_page_title => 'Sections';

  @override
  String get main_page_settings => 'Settings';

  @override
  String get settings_page_font_size => 'Font size:';

  @override
  String get settings_page_facebook => 'Follow us on Facebook';

  @override
  String get settings_page_twitter => 'Follow us on Twitter';

  @override
  String get settings_page_font_example => 'There is no god but Allah.';

  @override
  String get settings_page_watch_ad => 'Watch an ads, it help us.';

  @override
  String get settings_page_notifications => 'Daily Reminders';

  @override
  String get settings_page_notifications_desc =>
      'Receive daily reminders to read Awrad';

  @override
  String get settings_page_morning_time => 'Morning Reminder Time';

  @override
  String get settings_page_evening_time => 'Evening Reminder Time';

  @override
  String get settings_page_morning_notification => 'Time to read morning Awrad';

  @override
  String get settings_page_evening_notification => 'Time to read evening Awrad';

  @override
  String get settings_page_exact_alarm_permission_error =>
      'Please allow exact alarms in app settings';
}
