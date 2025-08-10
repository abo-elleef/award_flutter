import 'dart:async';

import './settings.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'award.dart';
import './details_screen.dart';
import './list_screen.dart';
import './part_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أوراد البرهامية',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        fontFamily: 'Amiri',
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue
      ),
      home: const MyHomePage(title: 'الأقسام'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BannerAd? _bannerAd;
  var names = ApiEndPoints.keys.toList();

  savePref() async {
    // SharedPreferences _pref = await SharedPreferences.getInstance();
    // _pref.setString('textColor', 'ff0000');
    // _pref.setDouble('fontSize', 48);
  }

  // Wideget _tile(String title) =>
  // ListTile(
  //   title: Center(
  //       child: Text(title,
  //           style: TextStyle(
  //             fontWeight: FontWeight.w500,
  //             fontSize: 20,
  //           ))),
  //   onTap: () {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => Details(title)),
  //     );
  //   },
  // );
  @override
  void initState() {

    // TODO: Load a banner ad
    BannerAd(
    adUnitId: "ca-app-pub-2772630944180636/8443670141",
    request: AdRequest(),
    size: AdSize.banner,
    listener: BannerAdListener(
    onAdLoaded: (ad) {
    setState(() {
    _bannerAd = ad as BannerAd;
    });
    },
    onAdFailedToLoad: (ad, err) {
    print('Failed to load a banner ad: ${err.message}');
    ad.dispose();
    },
    ),
    ).load();
    }
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl, // set this property
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
                  // TODO: Display a banner when ready
                  if (_bannerAd != null)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),

                  Container(
                      height: MediaQuery.of(context).size.height - 100,
                      child: SingleChildScrollView(
                          child: Column(
                            children: names.map((name) {
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ListPage(name, names.indexOf(name))),
                                    );
                                  },
                                  child: PartCard(title: name, index: names.indexOf(name), listSize: names.length)
                              );
                            }).toList()
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
