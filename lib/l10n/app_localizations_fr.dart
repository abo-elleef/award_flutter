// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get main_page_title => 'Sections';

  @override
  String get main_page_settings => 'Paramètres';

  @override
  String get settings_page_font_size => 'Taille de la police:';

  @override
  String get settings_page_facebook => 'Suivez-nous sur Facebook.';

  @override
  String get settings_page_twitter => 'Suivez-nous sur Twitter.';

  @override
  String get settings_page_font_example => 'Il n\'y a de dieu qu\'Allah.';

  @override
  String get settings_page_watch_ad =>
      'Regardez une publicité, cela nous aide.';

  @override
  String get settings_page_notifications => 'Rappels quotidiens';

  @override
  String get settings_page_notifications_desc =>
      'Recevez des rappels quotidiens pour lire les Awrad';

  @override
  String get settings_page_morning_time => 'Heure du rappel matinal';

  @override
  String get settings_page_evening_time => 'Heure du rappel du soir';

  @override
  String get settings_page_morning_notification =>
      'Il est temps de lire les Awrad du matin';

  @override
  String get settings_page_evening_notification =>
      'Il est temps de lire les Awrad du soir';

  @override
  String get settings_page_exact_alarm_permission_error =>
      'Veuillez autoriser les alarmes exactes dans les paramètres de l\'application';
}
