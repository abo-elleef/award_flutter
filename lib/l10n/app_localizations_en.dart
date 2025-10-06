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
  String get settings_page_facebook => 'Follow us on Facebook.';

  @override
  String get settings_page_twitter => 'Follow us on Twitter.';

  @override
  String get settings_page_font_example => 'There is no god but Allah.';

  @override
  String get settings_page_watch_ad => 'Watch an ads, it help us.';
}
