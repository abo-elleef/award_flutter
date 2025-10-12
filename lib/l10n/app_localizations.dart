import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @main_page_title.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get main_page_title;

  /// No description provided for @main_page_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get main_page_settings;

  /// No description provided for @settings_page_font_size.
  ///
  /// In en, this message translates to:
  /// **'Font size:'**
  String get settings_page_font_size;

  /// No description provided for @settings_page_facebook.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Facebook'**
  String get settings_page_facebook;

  /// No description provided for @settings_page_twitter.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Twitter'**
  String get settings_page_twitter;

  /// No description provided for @settings_page_font_example.
  ///
  /// In en, this message translates to:
  /// **'There is no god but Allah.'**
  String get settings_page_font_example;

  /// No description provided for @settings_page_watch_ad.
  ///
  /// In en, this message translates to:
  /// **'Watch an ads, it help us.'**
  String get settings_page_watch_ad;

  /// No description provided for @settings_page_notifications.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminders'**
  String get settings_page_notifications;

  /// No description provided for @settings_page_notifications_desc.
  ///
  /// In en, this message translates to:
  /// **'Receive daily reminders to read Awrad'**
  String get settings_page_notifications_desc;

  /// No description provided for @settings_page_morning_time.
  ///
  /// In en, this message translates to:
  /// **'Morning Reminder Time'**
  String get settings_page_morning_time;

  /// No description provided for @settings_page_evening_time.
  ///
  /// In en, this message translates to:
  /// **'Evening Reminder Time'**
  String get settings_page_evening_time;

  /// No description provided for @settings_page_morning_notification.
  ///
  /// In en, this message translates to:
  /// **'Time to read morning Awrad'**
  String get settings_page_morning_notification;

  /// No description provided for @settings_page_evening_notification.
  ///
  /// In en, this message translates to:
  /// **'Time to read evening Awrad'**
  String get settings_page_evening_notification;

  /// No description provided for @settings_page_exact_alarm_permission_error.
  ///
  /// In en, this message translates to:
  /// **'Please allow exact alarms in app settings'**
  String get settings_page_exact_alarm_permission_error;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
