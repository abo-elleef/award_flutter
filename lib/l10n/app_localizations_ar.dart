// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get main_page_title => 'الأقسام';

  @override
  String get main_page_settings => 'الإعدادات';

  @override
  String get settings_page_font_size => 'حجم الخط';

  @override
  String get settings_page_facebook => 'شاركنا الرحلة علي facebook';

  @override
  String get settings_page_twitter => 'شاركنا الرحلة علي twitter';

  @override
  String get settings_page_font_example => 'لا اله الا الله';

  @override
  String get settings_page_watch_ad => 'شاهد اعلان. بيساعدنا نكبر';

  @override
  String get settings_page_notifications => 'التذكيرات اليومية';

  @override
  String get settings_page_notifications_desc =>
      'استقبل تذكيرات يومية لقراءة الأوراد';

  @override
  String get settings_page_morning_time => 'وقت التذكير الصباحي';

  @override
  String get settings_page_evening_time => 'وقت التذكير المسائي';

  @override
  String get settings_page_morning_notification =>
      'حان وقت قراءة الأوراد الصباحية';

  @override
  String get settings_page_evening_notification =>
      'حان وقت قراءة الأوراد المسائية';

  @override
  String get settings_page_exact_alarm_permission_error =>
      'يرجى السماح بالتنبيهات الدقيقة في إعدادات التطبيق';
}
