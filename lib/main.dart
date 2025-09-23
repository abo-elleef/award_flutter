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
// import 'dart:io' show Platform; // Potentially remove if not used elsewhere

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // Initialize MobileAds - Keep this if other ads are used or planned
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أوراد البرهامية',
      theme: ThemeData(
        fontFamily: 'Amiri',
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
          color: Colors.white, // Change the color here
          ),
        ),
      ),
      builder: (context, child) {
        return SafeArea(
          top: false,
          bottom: true,
          child: child!,
        );
      },
      home: const MyHomePage(title: 'الأقسام'),
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
  var names = offlineStore.keys.toList();

  @override
  void initState() {
    super.initState();
    // _loadRewardedAd(); // Removed
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
        names.map((name) {
          return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListPage(name, names.indexOf(name))),
                );
              },
              child: PartCard(title: name, index: names.indexOf(name), listSize: names.length)
          );
        })
    );
    return pageDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
                title: Text(widget.title),
                backgroundColor: Colors.green,
                titleTextStyle: TextStyle(color: Colors.white),
                actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.settings),
                      color: Colors.white,
                      tooltip: 'Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Settings()),
                        );
                      },
                    )
                  ]
            ),
            body: DecoratedBox(
              position: DecorationPosition.background,
              decoration: BoxDecoration(
                image: DecorationImage(
                          image: AssetImage('assets/bg.png'), fit: BoxFit.cover),
                        ),child: Center(
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
