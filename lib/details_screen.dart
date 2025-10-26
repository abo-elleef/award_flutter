import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'award.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'l10n/app_localizations.dart';

class Details extends StatefulWidget {
  final String name;
  final String department;
  final int chapterIndex;
  final int index;
  const Details(this.name, this.index, this.department, this.chapterIndex, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return DetailsState();
  }
}

class DetailsState extends State<Details> {
  late double fontSize = 24;
  late int textColor = 0xFF000000;
  List lines = [];
  List links = [];

  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdReady = false;

  NativeAd? _nativeAd;
  bool _isNativeAdReady = false;
  final ScrollController _scrollController = ScrollController();
  final InAppReview _inAppReview = InAppReview.instance;
  WebViewController? _webViewController;

  List range (int start, int size){
    return List<int>.generate(size, (int index) => start + index);
  }

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
    return links.isNotEmpty ? soundCloudPlayerWebView() : Container();
  }

  void fetchUserPreferences () async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      fontSize = pref.getDouble('fontSize') ?? fontSize;
      textColor = pref.getInt('textColor') ?? textColor;
    });
  }

  void fetchData() async {
    var temp;
    var tempLinks;
    if (["بردة المديح للامام البوصيري"].contains(widget.department)) {
      var content = offlineStore.where( (item) => item['key'] == widget.department).toList()[0]['content']! as List;
      temp = [(content.where( (item) => item['id'].toString() == widget.index.toString()).toList()[0]['lines'] as List).map((line){return line["body"];})];
      tempLinks = [(content.where( (item) => item['id'].toString() == widget.index.toString()).toList()[0]['links'] as List)];
    }else{
      if(widget.chapterIndex >= 0){
        var content = offlineStore.where( (item) => item['key'] == widget.department).toList()[0]['content']! as List;
        temp = [(content.where( (item) => item['id'] == widget.index).toList()[0]!["chapters"] as List)[widget.chapterIndex]['lines'].map((line){
          return line["body"];
        })];
        tempLinks = (content.where( (item) => item['id'].toString() == widget.index.toString()).toList()[0]!['chapters'] as List).map((chapter){
          return chapter["links"];
        }).toList();
      }else{
        var content = offlineStore.where( (item) => item['key'] == widget.department).toList()[0]['content']! as List;
        temp = (content.where( (item) => item['id'].toString() == widget.index.toString()).toList()[0]!["chapters"] as List).map((chapter){
          return chapter["lines"].map((line){
            return line["body"];
          });
        });
        tempLinks = (content.where( (item) => item['id'].toString() == widget.index.toString()).toList()[0]!['chapters'] as List).map((chapter){
          return chapter["links"];
        }).toList();
      }
    }
    setState(() {
      temp.forEach((e) => lines.addAll(e));
      tempLinks.forEach((e) => links.addAll(e));
      _initializeMediaControllers();
    });
  }

  void _loadBottomBannerAd() {
    _bottomBannerAd = BannerAd(
      adUnitId: _getBottomBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _isBottomBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bottomBannerAd?.load();
  }

  String _getBottomBannerAdUnitId() {
    if (Platform.isAndroid) {
      // return 'ca-app-pub-3940256099942544/6300978111'; // Test
      return 'ca-app-pub-2772630944180636/8912259990'; // Madeeh
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ad unit ID for iOS
    }
    // return 'ca-app-pub-3940256099942544/6300978111'; // Test
    return 'ca-app-pub-2772630944180636/8912259990'; // Madeeh
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: _getNativeAdUnitId(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) return;
          setState(() {
            _nativeAd = ad as NativeAd;
            _isNativeAdReady = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    )..load();
  }

  String _getNativeAdUnitId() {
    if (Platform.isAndroid) {
      // return 'ca-app-pub-3940256099942544/2247696110'; // Test
      return 'ca-app-pub-2772630944180636/3248869774'; // Madeeh
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511'; // Test ad unit ID for iOS
    }
    // return 'ca-app-pub-3940256099942544/2247696110'; // Test
    return 'ca-app-pub-2772630944180636/3248869774'; // Madeeh
  }

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
    fetchData();
    _loadBottomBannerAd();
    _loadNativeAd();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (await _inAppReview.isAvailable()) {
          _inAppReview.requestReview();
        } else {
          _inAppReview.openStoreListing(appStoreId: 'com.leef.awrad');
        }
      }
    });
  }

  @override
  void dispose() {
    _bottomBannerAd?.dispose();
    _nativeAd?.dispose();
    _scrollController.dispose();
    _webViewController?.loadRequest(Uri.parse('about:blank'));
    _webViewController = null;
    super.dispose();
  }

  List<Widget> _bulidPrefixList(){
    var prefixLine = [
      [
        "مَولايَ صَلِّ وَسَلِّم دَائِمَاً أَبَداً",
        "عَلى حَبيبِكَ خَيرِ الخَلقِ كُلِّهِم",
      ],
      [
        "مَولايَ صَلِّ وَسَلِّم دَائِمَاً أَبَداً",
        "عَلى النَّبيِّ وَ آل البَيْتِ كُلِّهِمِ",
      ]
    ];
    return prefixLine.asMap().entries.map((entry){
      return Container(
          decoration: const BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.all(Radius.circular(15))),
          padding: const EdgeInsets.only(top: 0, bottom: 8.0, left: 16.0, right: 16.0),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
          child: Column(
              children: <Widget>[
                Row(
                  textDirection: AppLocalizations.of(context)!.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
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
                Row(
                  textDirection: AppLocalizations.of(context)!.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
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
              ]
          )
      );
    }).toList();
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
                Row(
                  textDirection: AppLocalizations.of(context)!.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
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
                Row(
                  textDirection: AppLocalizations.of(context)!.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
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
                          '${entry.key + 1} / ${lines.length}',
                      )
                    ]
                )
              ]
            )
            );
    }).toList();
  }

  Widget _buildBottomBannerAdWidget(){
    if (_isBottomBannerAdReady && _bottomBannerAd != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        width: _bottomBannerAd!.size.width.toDouble(),
        height: _bottomBannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bottomBannerAd!),
      );
    }else{
      return const SizedBox.shrink(); // Use SizedBox.shrink() for consistency
    }
  }

  Widget _buildNativeAdWidget() {
    if (_isNativeAdReady && _nativeAd != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        height: 350,
        child: AdWidget(ad: _nativeAd!),
      );
    }
    return const SizedBox.shrink();
  }

  List<Widget> buildPageDetails() {
    List<Widget> finalPageDetails = [];
    finalPageDetails.add(SizedBox(height: 8.0));
    finalPageDetails.add(_buildMediaPlayer());
    if (["بردة المديح للامام البوصيري"].contains(widget.department)) {
      finalPageDetails.addAll(_bulidPrefixList());
    }
    List<Widget> contentItems = _buildList();
    finalPageDetails.addAll(contentItems); // Add the content item

    // Add Native Ad at the end, after all content items
    finalPageDetails.add(_buildNativeAdWidget());

    return finalPageDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: AppLocalizations.of(context)!.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
        appBar: AppBar(
            title: Text(widget.name),
            backgroundColor: Colors.green,
            titleTextStyle: const TextStyle(color: Colors.white)
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
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 8.0, right: 8.0, left: 8.0),
                    child: Column(
                      children: buildPageDetails(),
                      ),
                    )
              ),
              _buildBottomBannerAdWidget() // Bottom banner remains at the very bottom
            ],
          ),
        )
      )
         )
    );
  }
}
