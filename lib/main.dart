import './settings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'award.dart';
import './details_screen.dart';
import './list_screen.dart';
import './part_card.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'analytics.dart'; // Import the analytics class
// import 'dart:io' show Platform; // Potentially remove if not used elsewhere

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // Initialize MobileAds - Keep this if other ads are used or planned
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Helper method to find the state object of MyApp
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar');
  double fontSize = 24;

  @override
  void initState() {
    super.initState();
    _fetchUserPref();
  }

  void _fetchUserPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    double? fontSize = prefs.getDouble('fontSize');
    if (languageCode != null) {
      if (!mounted) return;
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  void setLocale(Locale value) async {
    if (!mounted) return;
    setState(() {
      _locale = value;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', value.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أوراد البرهامية',
      locale: _locale,
      theme: ThemeData(
        fontFamily: 'Amiri',
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
          color: Colors.white, // Change the color here
          ),
        ),
      ),
      builder: (context, child) {
        return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          child: SafeArea(
            top: false,
            bottom: Theme.of(context).platform == TargetPlatform.android,
            child: child!,
          )
        );
      },
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('ar'), // Arabic
        Locale('fr'), // French
      ],
      home: Builder(
        builder: (BuildContext context) {
          // This context is a descendant of MaterialApp
          return MyHomePage(title: AppLocalizations.of(context)!.main_page_title);
        }
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double fontSize = 24;
  final Analytics analytics = Analytics(); // Instantiate the analytics class

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  savePref() async {
    // SharedPreferences _pref = await SharedPreferences.getInstance();
    // _pref.setString('textColor', 'ff0000');
    // _pref.setDouble('fontSize', 48);
  }

  List<Widget> buildPageDetails() {
    List<Widget> pageDetails = [];
    pageDetails.addAll(
        offlineStore.asMap().entries.map((entry) {
          final store = entry.value;
          final lang = AppLocalizations.of(context)!.localeName.split('_').first;
          final key = 'name_$lang';
          final localized = (store[key] as String?)?.trim();
          final displayTitle = (localized != null && localized.isNotEmpty) ? localized : (store['name'] as String?)?.trim() ?? '';
          return GestureDetector(
              onTap: () {
                analytics.logScreenView(displayTitle); // Log the screen view event
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListPage(store["key"].toString(), displayTitle, entry.key)),
                );
              },
              //  as String
              child: PartCard(title: displayTitle, index: entry.key, listSize: offlineStore.length, fontSize: fontSize)
          );
        })
    );
    return pageDetails;
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
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: AppLocalizations.of(context)!.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
            appBar: AppBar(
                title: Text(widget.title),
                backgroundColor: Colors.green,
                titleTextStyle: TextStyle(color: Colors.white),
                actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.settings),
                      color: Colors.white,
                      tooltip: AppLocalizations.of(context)!.main_page_settings,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Settings()),
                        );
                      },
                    ),
                  PopupMenuButton<String>(
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
                  ]
            ),
            body: DecoratedBox(
              position: DecorationPosition.background,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/bg.png'), fit: BoxFit.cover),
                        ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                              children: buildPageDetails()
                            )
                        )
                    ),
                  ],
                ),
              ),
            )
        )
    );
  }
}
