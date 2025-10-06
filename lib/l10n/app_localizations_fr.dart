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
}
