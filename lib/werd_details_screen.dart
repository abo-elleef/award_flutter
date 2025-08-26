import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'award.dart';
import 'package:shared_preferences/shared_preferences.dart';
class WerdDetails extends StatefulWidget {
  final String name;
  final String department;
  final int index;
  late double fontSize;
  late int textColor;
  WerdDetails(this.name, this.index, this.department);
  @override
  State<StatefulWidget> createState() {
    return WerdDetailsState(name, index, department);
  }
}

class WerdDetailsState extends State<WerdDetails> {
  String name;
  int index;
  String department;
  late double fontSize = 24;
  // late int textColor = 0xff3a863d;
  late int textColor = 0xff444444;
  late String desc = "";
  WerdDetailsState(this.name, this.index, this.department);
  List lines = [];
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  NativeAd? _nativeAd;
  bool _isNativeAdReady = false;

  List range (int start, int size){
    return List<int>.generate(size, (int index) => start + index);
  }

  void fetchUserPreferences () async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      fontSize = pref.getDouble('fontSize') ?? fontSize;
      textColor = pref.getInt('textColor') ?? textColor;
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _getBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  String _getBannerAdUnitId() {
    // Replace these with your actual ad unit IDs
    if (Platform.isAndroid) {
      // return 'ca-app-pub-3940256099942544/6300978111'; // Test ad unit ID for Android
      return 'ca-app-pub-2772630944180636/8443670141'; //  real ad unit ID for Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ad unit ID for iOS
    }
    // return 'ca-app-pub-3940256099942544/6300978111'; // Default to Android test ID
    return 'ca-app-pub-2772630944180636/8443670141'; // real ad unit ID for Android
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: _getNativeAdUnitId(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('$NativeAd loaded.');
          setState(() {
            _isNativeAdReady = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$NativeAd failedToLoad: $error');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      // Styling
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        // Optional styling options
      ),
    )..load();
  }

  String _getNativeAdUnitId() {
    if (Platform.isAndroid) {
      // return 'ca-app-pub-3940256099942544/2247696110'; // Test ad unit ID for Android
      return 'ca-app-pub-2772630944180636/2469070370'; // Real ad unit ID for Android

    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511'; // Test ad unit ID for iOS
    }
    // return 'ca-app-pub-3940256099942544/2247696110'; // Default to Android test ID
    return 'ca-app-pub-2772630944180636/2469070370'; // Default to Android Real ID

  }

  void fetchData() async {
    var json = (offlineStore[this.department]!.where( (item) => item['name'] == name.toString()).toList()[0]);
    setState(() {
      lines = json?["textPages"] as List;
      desc = json['desc']!.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
    fetchData();
    _loadBannerAd();
    _loadNativeAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  List<Widget> _buildList() {
        return lines.asMap().entries.map((entry){
          return Container(
              decoration: const BoxDecoration(
                  color: Color(0xffe1ffe1),
                  borderRadius: BorderRadius.all(Radius.circular(15.0))
              ),
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
              child: Column(
              children: <Widget>[
                Row(textDirection: TextDirection.rtl,
                  children: <Widget>[
                    Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text(
                            entry.value,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: fontSize,
                              height: 2,
                              color:  Color(textColor),
                            ),
                          ),
                        )
                    )
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally
                    children: <Widget>[
                      Text(
                        (entry.key + 1).toString() +" / "+ lines.length.toString(),
                      )
                    ]
                )
              ]
            )
            );
        }).toList();
  }
  Widget _add_banner_ads(){
    if (_isBannerAdReady) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }else{
      return Container();
    }
  }

  Widget _buildNativeAdWidget() {
    if (_isNativeAdReady && _nativeAd != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        height: 350, // Adjust height as needed for TemplateType.medium
        child: AdWidget(ad: _nativeAd!),
      );
    }
    return SizedBox.shrink();
  }

  Widget _desciptionWidget(){
    if(desc.length != 0){
      return Container(
        padding: const EdgeInsets.only(
          bottom: 1, // Space between underline and text
        ),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(
              color: Colors.grey,
              width: 1.0, // Underline thickness
            ))
        ),
        child: Text(
          desc,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      );
    }else{
      return Container();
    }

  }

  List<Widget> buildPageDetails() {
    List<Widget> pageDetails = [];
    pageDetails.add(_desciptionWidget());
    pageDetails.addAll(_buildList());
    pageDetails.add(_buildNativeAdWidget()); // Add Native Ad at the end
    return pageDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl, // set this property
        child: Scaffold(
        appBar: AppBar(
          title: Text(name),
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
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 8.0, right: 8.0, left: 8.0),
                    child: Column(
                      children: buildPageDetails(),
                      ),
                    )
              ),
              _add_banner_ads()
            ],
          ),
        )
      )
        )
    );
  }
}
