import 'package:awrad3/part_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'award.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Added import

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

  RewardedAd? _rewardedAd; // Added state variable
  bool _isRewardedAdReady = false; // Added state variable

  SettingsState();

  void fetchUserPreferences () async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      this.fontSize = _pref.getDouble('fontSize') ?? this.fontSize;
      this.textColor = _pref.getInt('textColor') ?? this.textColor;
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

  // Copied from main.dart
  String _getRewardedAdUnitId() {
    if (Platform.isAndroid) {
      // return 'ca-app-pub-3940256099942544/5224354917'; // Test
      return 'ca-app-pub-2772630944180636/7242266351'; // Award
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test
    }
    // Fallback, should match one of the above based on your main.dart logic
    // return 'ca-app-pub-3940256099942544/5224354917'; // Test
    return 'ca-app-pub-2772630944180636/7242266351'; // Award
  }

  // Copied from main.dart
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _getRewardedAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          if (!mounted) return;
          setState(() {
            _isRewardedAdReady = true;
          });
          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              ad.dispose();
              if (!mounted) return;
              setState(() {
                _isRewardedAdReady = false;
              });
              _loadRewardedAd(); // Load the next ad
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              print('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
              if (!mounted) return;
              setState(() {
                _isRewardedAdReady = false;
              });
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          if (!mounted) return;
          setState(() {
            _isRewardedAdReady = false;
          });
        },
      ),
    );
  }

  // Copied from main.dart
  void _showRewardedAd() {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('Reward earned: ${reward.type} ${reward.amount}');
          // TODO: Grant the user their reward.
        },
      );
    } else {
      print('Rewarded ad is not ready yet.');
      if (!_isRewardedAdReady) {
        _loadRewardedAd();
      }
    }
  }

  // Copied from main.dart
  Widget buildRewardedAdWidget() {
    return GestureDetector(
        onTap: _showRewardedAd,
        child: _isRewardedAdReady ? Container(
            decoration: const BoxDecoration(
                color: Color(0xffe1ffe1), // Using similar styling as PartCard
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            padding: const EdgeInsets.all(16.0), // Consistent padding
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Consistent margin
            child: Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text(
                  'شاهد إعلان (مكافأة)', // Updated text
                  style: TextStyle(
                    fontSize: this.fontSize, // Using dynamic font size
                    color: Color(this.textColor), // Using dynamic text color
                    fontWeight: FontWeight.bold,
                  )
                  )
                ]
            )
        ) : Container() // Or SizedBox.shrink()
    );
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
      child: Card(
        color: Color(0xffe1ffe1),
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                text,
                style: TextStyle(
                  fontSize: this.fontSize,
                  color: Color(this.textColor),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
    _loadRewardedAd(); // Load rewarded ad
  }

  @override
  void dispose() {
    _rewardedAd?.dispose(); // Dispose rewarded ad
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
        appBar: AppBar(
          title: Text('الاعدادات'),
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(color: Colors.white)
        ),
        body:DecoratedBox(
        position: DecorationPosition.background,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.png'), fit: BoxFit.cover),
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
                            child: Text('حجم الخط',
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
                      PartCard(title: 'لا إله إلا الله', index: 0, listSize: 6, fontSize: this.fontSize, textColor: this.textColor),
                      _buildSocialButton(context, 'تابعنا على فيسبوك', 'https://www.facebook.com/bordaelmadyh/'),
                      _buildSocialButton(context, 'تابعنا على تويتر', 'https://x.com/bordaelmadyh'),
                      buildRewardedAdWidget(),
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
