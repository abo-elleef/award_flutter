import './settings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'award.dart';
import './details_screen.dart';
import 'package:in_app_review/in_app_review.dart';
import './list_screen.dart';
import './part_card.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // Initialize MobileAds
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        fontFamily: 'Amiri',
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue
      ),
      builder: (context, child) {
        return SafeArea(
          top: false, // Set to true if you want to avoid notch overlap too
          bottom: true, // Avoids overlap with navigation bar
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

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  String _getRewardedAdUnitId() {
    // Use test ad unit ID for development.
    if (Platform.isAndroid) {
      // return 'ca-app-pub-3940256099942544/5224354917'; // Test
      return 'ca-app-pub-2772630944180636/7242266351'; // Award
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test
    }
    // return 'ca-app-pub-3940256099942544/5224354917'; // Test
    return 'ca-app-pub-2772630944180636/7242266351'; // Award
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _getRewardedAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          setState(() {
            _isRewardedAdReady = true;
          });
          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              ad.dispose();
              setState(() {
                _isRewardedAdReady = false;
              });
              _loadRewardedAd(); // Load the next ad
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              print('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
              setState(() {
                _isRewardedAdReady = false;
              });
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          setState(() {
            _isRewardedAdReady = false;
          });
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          // Handle the reward.
          print('Reward earned: ${reward.type} ${reward.amount}');
          // TODO: Grant the user their reward. For example, by increasing a counter.
        },
      );
    } else {
      print('Rewarded ad is not ready yet.');
      // Optionally, show a message to the user or try to load ad again.
      if (!_isRewardedAdReady) {
        _loadRewardedAd(); // Try to load an ad if not ready
      }
    }
  }

  savePref() async {
    // SharedPreferences _pref = await SharedPreferences.getInstance();
    // _pref.setString('textColor', 'ff0000');
    // _pref.setDouble('fontSize', 48);
  }

  Widget buildRewardedAdWidget() { // Renamed for clarity
    return GestureDetector(
        onTap: _showRewardedAd, // Call _showRewardedAd on tap
        child: _isRewardedAdReady ? Container(
            decoration: const BoxDecoration(
              // color: Color.fromRGBO(255, 255, 255, 0.8),
                color: Color(0xffe1ffe1),
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            padding: const EdgeInsets.only(bottom: 16.0, right: 8.0, left: 8.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Reduced vertical margin
            child: Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text(
                  'إعلان اليوم',
                  style: TextStyle(
                    fontSize: 28.0,
                    color: Color(0xFF000000),
                  )
                  )
                ]
            )
        ) : Container()
    );
  }
  
  Widget buildReviewWidget() {
    return GestureDetector(
      onTap: () async {
        if (await _inAppReview.isAvailable()) {
          _inAppReview.requestReview();
        } else {
          // Optionally, open the store listing if in-app review is not available
          _inAppReview.openStoreListing(appStoreId: 'com.leef.awrad');
          print('In-app review is not available.');
        }
      },
      child: Container(
        decoration: const BoxDecoration(
            color: Color(0xffe1ffe1), // Light blue color, similar to other cards
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        padding: const EdgeInsets.only(bottom: 16.0, right: 8.0, left: 8.0, top: 16.0), // Added top padding
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Consistent margin
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'ساعدنا بتقييمك',
              style: TextStyle(
                fontSize: 28.0,
                color: Color(0xFF000000),
              ),
            )
          ],
        ),
      ),
    );
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
                            Expanded(
                                child: SingleChildScrollView(
                                    child: Column(
                                      children: buildPageDetails()
                                    )
                                )
                            ),
                            buildReviewWidget(),
                            buildRewardedAdWidget()
                          ],
                        ),
                      ),
                )
        )
    );
  }
}
