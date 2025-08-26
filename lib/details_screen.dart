import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'award.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Details extends StatefulWidget {
  final String name;
  final String department;
  final int chapterIndex;
  final int index;
  late double fontSize;
  late int textColor;
  Details(this.name, this.index, this.department, this.chapterIndex);
  @override
  State<StatefulWidget> createState() {
    return DetailsState(name, index, department, chapterIndex);
  }
}

class DetailsState extends State<Details> {
  String name;
  int index;
  int chapterIndex = -1;
  String department;
  late double fontSize = 24;
  late int textColor = 0xFF000000;
  DetailsState(this.name, this.index, this.department, this.chapterIndex);
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
  Future<void> _showMyDialog(text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text ?? ''),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void fetchData() async {
    var temp ;
    if (["بردة المديح للامام البوصيري"].contains(this.department)) {
      temp = [(offlineStore[this.department]!.where( (item) => item['id'].toString() == index.toString()).toList()[0]['lines'] as List).map((line){return line["body"];})];
    }else{
      if(chapterIndex >= 0){
        temp = [(offlineStore[this.department]!.where( (item) => item['id'] == index).toList()[0]!["chapters"] as List)[chapterIndex]['lines'].map((line){
          return line["body"];
        })];
      }else{
        temp = (offlineStore[this.department]!.where( (item) => item['id'] == index).toList()[0]!["chapters"] as List).map((chapter){
          return chapter["lines"].map((line){
            return line["body"];
          });
        });
      }
    }
    setState(() {
      temp.forEach((e) => lines.addAll(e));
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
    if (Platform.isAndroid) {
      // return 'ca-app-pub-3940256099942544/6300978111'; // test ad unit ID for android
      return 'ca-app-pub-2772630944180636/8443670141'; // real ad unit ID for Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ad unit ID for iOS
    }
    // return 'ca-app-pub-3940256099942544/6300978111'; // test ad unit ID for android
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
              borderRadius: BorderRadius.all(Radius.circular(15))),
          padding: const EdgeInsets.only(top: 0, bottom: 8.0, left: 16.0, right: 16.0),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
          child: Column(
              children: <Widget>[
                Row(textDirection: TextDirection.rtl,
                  children: <Widget>[
                    Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Text(
                            entry.value[0],
                            softWrap: true,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Color(0xff444444)
                            ),
                          ),
                        )
                    )
                  ],
                ),
                Row(textDirection: TextDirection.rtl,
                  children: <Widget>[
                    Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 25, bottom: 10),
                          child: Text(
                            entry.value[1],
                            softWrap: true,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Color(0xff444444)
                            ),
                          ),
                        )
                    )
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _desciptionWidget(){
    if(AwradOffline[index]!["desc"] != null){
      return Container(
        padding: const EdgeInsets.only(
          bottom: 1,
        ),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(
              color: Colors.grey,
              width: 1.0,
            ))
        ),
        child: Text(
          AwradOffline[index]!["desc"].toString(),
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      );
    }else{
      return Container();
    }
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

  List<Widget> buildPageDetails() {
    List<Widget> pageDetails = [];
    pageDetails.addAll(_buildList());
    pageDetails.add(_buildNativeAdWidget()); // Add Native Ad at the end
    return pageDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
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
