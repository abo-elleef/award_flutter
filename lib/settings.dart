import 'package:awrad3/part_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'award.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Added import
import 'l10n/app_localizations.dart';
import 'analytics.dart'; // Import the analytics class
import 'package:awrad3/main.dart'; // Import main.dart to access MyAppState

class Settings extends StatefulWidget {
  late double fontSize;
  late int textColor;
  Settings();
  @override
  State<StatefulWidget> createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {
  late double fontSize = 24;
  late int textColor = 0xFF000000;
  final Analytics analytics = Analytics(); // Instantiate the analytics class
  Locale _locale = const Locale('ar');

  SettingsState();

  void fetchUserPreferences () async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String? languageCode = _pref.getString('language_code');
    if (!mounted) return;
    setState(() {
      this.fontSize = _pref.getDouble('fontSize') ?? this.fontSize;
      this.textColor = _pref.getInt('textColor') ?? this.textColor;
      if (languageCode != null) {
        this._locale = Locale(languageCode);
      }
    });
  }

  void setFontSize (value) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setDouble('fontSize', value);
  }

  void setTextColor (value) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setInt('textColor', value);
  }

  Widget _buildSocialButton(BuildContext context, String text, String url) {
    final Uri socialUrl = Uri.parse(url); // Renamed variable for clarity

    return GestureDetector(
      onTap: () async {
        try {
          if (await canLaunchUrl(socialUrl)) {
            await launchUrl(socialUrl, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تعذر فتح الرابط. يرجى التحقق من اتصالك بالإنترنت.')),
              );
            }
            print('Could not launch $socialUrl');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('حدث خطأ أثناء محاولة فتح الرابط.')),
            );
          }
          print('Error launching URL: $e');
        }
      },
      child: Container(
        width: double.infinity,
        child: Card(
          // color: Color(0xffe1ffe1),
          color: Color(0xfffffcf5),
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
                    text,
                    style: TextStyle(
                      fontSize: this.fontSize,
                      color: Color(this.textColor),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
      ),)
    );
  }

  PopupMenuItem<String> buildPopupMenuItem(String value, String flag, String name) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Text(flag),
          SizedBox(width: 10),
          Text(name),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
    analytics.logScreenView("Settings_Page");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: AppLocalizations.of(context)!.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.main_page_settings),
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(color: Colors.white),
          actions: <Widget>[
            PopupMenuButton<String>(
              icon: const Icon(Icons.language_outlined), // -> Specify the Icon
              onSelected: (String newValue) {
                if (newValue != AppLocalizations.of(context)!.localeName) {
                  MyApp.of(context)?.setLocale(Locale(newValue));
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                buildPopupMenuItem('ar', '🇪🇬', 'العربية'),
                buildPopupMenuItem('en', '🇺🇸', 'English'),
                buildPopupMenuItem('fr', '🇫🇷', 'Français'),
              ],
            ),
          ],
        ),
        body:DecoratedBox(
        position: DecorationPosition.background,
        decoration: const BoxDecoration(
            color: Color(0xfffffcf5)
        ),
        child: Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children:[
                          Expanded( // Added Expanded for better layout
                            child: Text(AppLocalizations.of(context)!.settings_page_font_size,
                              style: TextStyle(
                                fontSize: 20, // Consider making this dynamic or a fixed larger size for a label
                                color:  Color(this.textColor),
                              )
                            ),
                          ),
                          Expanded( // Added Expanded for Slider
                            flex: 2, // Give more space to slider
                            child: Slider(
                              value: this.fontSize,
                              max: 36,
                              min: 14,
                              divisions: 11,
                              activeColor: Color(0xff3a863d),
                              label: this.fontSize.round().toString(), // Use round() for cleaner label
                              onChanged: (double value) {
                                setState(() {
                                  this.fontSize = value;
                                  setFontSize(value);
                                });
                              },
                            ),
                          )
                        ]
                      ),
                      PartCard(title: AppLocalizations.of(context)!.settings_page_font_example, index: 0, listSize: 6, fontSize: this.fontSize, textColor: this.textColor),
                      _buildSocialButton(context, AppLocalizations.of(context)!.settings_page_facebook, 'https://www.facebook.com/bordaelmadyh/'),
                      _buildSocialButton(context, AppLocalizations.of(context)!.settings_page_twitter, 'https://x.com/bordaelmadyh'),
                    ]
                  ),
                )
            )
          )
        )
      )
    );
  }
}
