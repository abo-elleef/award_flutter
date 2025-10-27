import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart'; // Added import
import 'award.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WerdDetails extends StatefulWidget {
  final String title;
  final String storeKey;
  final int index;
  late double fontSize;
  late int textColor;
  WerdDetails(this.title, this.index, this.storeKey);
  @override
  State<StatefulWidget> createState() {
    return WerdDetailsState(title, index, storeKey);
  }
}

class WerdDetailsState extends State<WerdDetails> {
  String title;
  int index;
  String storeKey;
  late double fontSize = 24;
  // late int textColor = 0xff3a863d;
  late int textColor = 0xff444444;
  late String desc = "";
  WerdDetailsState(this.title, this.index, this.storeKey);
  List lines = [];
  List links = [];
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  NativeAd? _nativeAd;
  bool _isNativeAdReady = false;
  bool _hasInternet = false; // Track internet connectivity
  final ScrollController _scrollController = ScrollController(); // Added ScrollController
  final InAppReview _inAppReview = InAppReview.instance; // Added InAppReview instance
  WebViewController? _webViewController;


  // media methods
  void _initializeWebViewController(String url) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
  }

  void _initializeMediaControllers() {
    if (links.isEmpty) return;
    final firstLink = links.first;
    final link = firstLink['link'] as String?;
    _initializeWebViewController(link!);
  }

  Widget soundCloudPlayerWebView() {
    if (_webViewController == null) return Container();
    return SizedBox(
      height: 300,
      child: WebViewWidget(
        controller: _webViewController!,
      ),
    );
  }

  Widget _buildMediaPlayer() {
    return (links.isNotEmpty && _hasInternet) ? soundCloudPlayerWebView() : Container();
  }
  // end of media methods


  void fetchUserPreferences () async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      fontSize = pref.getDouble('fontSize') ?? fontSize;
      textColor = pref.getInt('textColor') ?? textColor;
    });
  }

  Future<void> _checkInternetConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      bool hasConnection = connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);

      if (hasConnection) {
        // Try to make a simple HTTP request to verify actual internet access
        final response = await http.get(
          Uri.parse('https://www.google.com'),
        ).timeout(const Duration(seconds: 5));
        setState(() {
          _hasInternet = response.statusCode == 200;
        });
      } else {
        setState(() {
          _hasInternet = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasInternet = false;
      });
    }
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
      return 'ca-app-pub-3940256099942544/6300978111'; // Test
      // return 'ca-app-pub-2772630944180636/8443670141'; // Award
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ad unit ID for iOS
    }
    return 'ca-app-pub-3940256099942544/6300978111'; // Test
    // return 'ca-app-pub-2772630944180636/8443670141'; // Award
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: _getNativeAdUnitId(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isNativeAdReady = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
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
      return 'ca-app-pub-3940256099942544/2247696110'; // Test
      // return 'ca-app-pub-2772630944180636/2469070370'; // Award

    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511'; // Test ad unit ID for iOS
    }
    return 'ca-app-pub-3940256099942544/2247696110'; // Test
    // return 'ca-app-pub-2772630944180636/2469070370'; // Award
  }

  void fetchData() async {
    var json = (offlineStore.where( (item) => item['key'] == storeKey).toList()[0]['content'] as List).where(
        (item) => item['id'].toString() == index.toString()
    ).first;
    setState(() {
      lines = (json?["textPages"] as List?) ?? const [];
      links = (json?["links"] as List?) ?? const [];
      desc = json['desc']!.toString();
      _initializeMediaControllers();
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchUserPreferences();
      _checkInternetConnectivity(); // Check internet connectivity
      fetchData();
      _loadBannerAd();
      _loadNativeAd();
    });


    _scrollController.addListener(() async { // Added listener for in-app review
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (await _inAppReview.isAvailable()) {
          _inAppReview.requestReview();
        } else {
          // Optionally, open the store listing if in-app review is not available
          _inAppReview.openStoreListing(appStoreId: 'com.leef.awrad'); // Replace with your actual appStoreId if different

        }
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    _scrollController.dispose(); // Dispose ScrollController
    _webViewController?.loadRequest(Uri.parse('about:blank'));
    _webViewController = null;
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
                Row(
                  textDirection: AppLocalizations.of(context)!.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
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
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
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
          bottom: 8.0, // Space between underline and text
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
    pageDetails.add(_buildMediaPlayer());
    pageDetails.addAll(_buildList());
    pageDetails.add(_buildNativeAdWidget()); // Add Native Ad at the end
    return pageDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: AppLocalizations.of(context)!.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
        appBar: AppBar(
          title: Text(title),
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
                    controller: _scrollController, // Assign controller
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