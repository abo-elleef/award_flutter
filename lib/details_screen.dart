import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'award.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'l10n/app_localizations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'analytics.dart'; // Import the analytics class

class Details extends StatefulWidget {
  final String name;
  final String department;
  final int chapterIndex;
  final int index;
  const Details(
    this.name,
    this.index,
    this.department,
    this.chapterIndex, {
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return DetailsState();
  }
}

class Match {
  final int lineIndex;
  final GlobalKey key;

  Match({required this.lineIndex, required this.key});
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
  bool _hasInternet = false; // Track internet connectivity
  final Analytics analytics = Analytics(); // Instantiate the analytics class
  final ScrollController _scrollController = ScrollController();
  final InAppReview _inAppReview = InAppReview.instance;
  WebViewController? _webViewController;

  // Search state variables
  bool _isSearching = false;
  bool _readingMode = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<GlobalKey> _textKeys = [];
  List<Match> _matches = [];
  int _currentMatchIndex = -1;
  int _matchRenderIndex = 0;
  int _counter = 0;

  // Pinch gesture variables
  double _baseFontSize = 24;
  double _currentScale = 1.0;
  String? desc;

  List range(int start, int size) {
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
      child: WebViewWidget(controller: _webViewController!),
    );
  }

  Widget _buildMediaPlayer() {
    return (links.isNotEmpty && _hasInternet)
        ? soundCloudPlayerWebView()
        : Container();
  }

  List<Widget> _addDescLine(String? desc){
    if(desc != null && desc.isNotEmpty){
      return [Text(desc.toString()), SizedBox(height: 8.0)];
    }else{
      return [Container()];
    }
  }

  Future<void> _checkInternetConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      bool hasConnection =
          connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);

      if (hasConnection) {
        // Try to make a simple HTTP request to verify actual internet access
        final response = await http
            .get(Uri.parse('https://www.google.com'))
            .timeout(const Duration(seconds: 5));
        if (mounted) {
          setState(() {
            _hasInternet = response.statusCode == 200;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasInternet = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasInternet = false;
        });
      }
    }
  }

  void _scrollPage() {
    final currentOffset = _scrollController.offset;
    final pageHeight = _scrollController.position.viewportDimension - 30;
    final maxOffset = _scrollController.position.maxScrollExtent;

    // Calculate the target offset, but don't exceed the max scroll extent.
    final targetOffset = (currentOffset + pageHeight).clamp(0.0, maxOffset);

    _scrollController.animateTo(
      targetOffset - 40,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void fetchUserPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      fontSize = pref.getDouble('fontSize') ?? fontSize;
      textColor = pref.getInt('textColor') ?? textColor;
      _baseFontSize = fontSize;
    });
  }

  void _saveFontSize() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setDouble('fontSize', fontSize);
  }

  void fetchData() async {
    var temp;
    var tempLinks;
    var tempDesc;
    if (["بردة المديح للامام البوصيري"].contains(widget.department)) {
      print("details path 1");
      var content =
          offlineStore
                  .where((item) => item['key'] == widget.department)
                  .toList()[0]['content']!
              as List;
      temp = [
        (content
                    .where(
                      (item) =>
                          item['id'].toString() == widget.index.toString(),
                    )
                    .toList()[0]['lines']
                as List)
            .map((line) {
              return line["body"];
            }),
      ];
      tempLinks = [
        (content
                .where(
                  (item) => item['id'].toString() == widget.index.toString(),
                )
                .toList()[0]['links']
            as List),
      ];
      tempDesc = content.where(
            (item) => item['id'].toString() == widget.index.toString(),
      )
          .toList()[0]['desc'];
    } else {
      if (widget.chapterIndex >= 0) {
        print("details path 2");
        var content =
            offlineStore
                    .where((item) => item['key'] == widget.department)
                    .toList()[0]['content']!
                as List;
        temp = [
          (content
                      .where((item) => item['id'] == widget.index)
                      .toList()[0]!["chapters"]
                  as List)[widget.chapterIndex]['lines']
              .map((line) {
                return line["body"];
              }),
        ];
        tempLinks =
            (content
                        .where(
                          (item) =>
                              item['id'].toString() == widget.index.toString(),
                        )
                        .toList()[0]!['chapters']
                    as List)
                .map((chapter) {
                  return chapter["links"];
                })
                .toList();
        tempDesc = content.where(
              (item) => item['id'].toString() == widget.index.toString(),
        )
            .toList()[0]['desc'];
      } else {
        print("details path 3");
        var content =
            offlineStore
                    .where((item) => item['key'] == widget.department)
                    .toList()[0]['content']!
                as List;
        temp = [
          (content
                      .where(
                        (item) =>
                            item['id'].toString() == widget.index.toString(),
                      )
                      .toList()[0]['lines']
                  as List)
              .map((line) {
                return [line];
              }),
        ];
        tempLinks = [
          ((content
                      .where(
                        (item) =>
                            item['id'].toString() == widget.index.toString(),
                      )
                      .toList()[0]['links'] ??
                  [])
              as List),
        ];
        tempDesc = content.where(
              (item) => item['id'].toString() == widget.index.toString(),
        )
            .toList()[0]['desc'];
      }
    }
    setState(() {
      desc = tempDesc;
      temp.forEach((e) => lines.addAll(e));
      _textKeys = List.generate(lines.length, (_) => GlobalKey());
      if (!tempLinks.isEmpty) {
        tempLinks.forEach((e) => links.addAll(e));
      }

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
      return 'ca-app-pub-2772630944180636/3185523871'; //  Elburda
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ad unit ID for iOS
    }
  // return 'ca-app-pub-3940256099942544/6300978111'; // Test
    return 'ca-app-pub-2772630944180636/3185523871'; // Elburda
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: _getNativeAdUnitId(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print("loading native successfully ");
          if (!mounted) return;
          setState(() {
            _nativeAd = ad as NativeAd;
            _isNativeAdReady = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print("loading native failed ");
          print(error);
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
      return 'ca-app-pub-2772630944180636/2577699828'; // Elburda
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511'; // Test ad unit ID for iOS
    }
    // return 'ca-app-pub-3940256099942544/2247696110'; // Test
    return 'ca-app-pub-2772630944180636/2577699828'; // Elburda
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    fetchUserPreferences();
    _checkInternetConnectivity(); // Check internet connectivity
    fetchData();
    _loadBottomBannerAd();
    _loadNativeAd();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (await _inAppReview.isAvailable()) {
          _inAppReview.requestReview();
        } else {
          _inAppReview.openStoreListing(appStoreId: 'com.ionicframework.borda215096');
        }
      }
    });
    analytics.logScreenView(
      widget.department + "_" + widget.name,
    ); // Log the screen view event
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _searchController.dispose();
    _bottomBannerAd?.dispose();
    _nativeAd?.dispose();
    _scrollController.dispose();
    _webViewController?.loadRequest(Uri.parse('about:blank'));
    _webViewController = null;
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    analytics.logUserAction("start_search");
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchText = '';
      _matches.clear();
      _currentMatchIndex = -1;
    });
  }

  String _removeDiacritics(String text) {
    return text
        .replaceAll(
          RegExp(r'[\u064B-\u0652]'),
          '',
        ) // Remove Arabic diacritics (tashkeel)
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchText = query;
      _matches.clear();
      _currentMatchIndex = -1;

      if (query.isNotEmpty) {
        final cleanQuery = _removeDiacritics(query.toLowerCase());
        for (int i = 0; i < lines.length; i++) {
          String lineText = lines[i].toString();
          final cleanLineText = _removeDiacritics(lineText.toLowerCase());

          int startIndex = 0;
          while (startIndex < cleanLineText.length) {
            final matchIndex = cleanLineText.indexOf(cleanQuery, startIndex);
            if (matchIndex == -1) break;

            _matches.add(Match(lineIndex: i, key: GlobalKey()));
            startIndex = matchIndex + cleanQuery.length;
          }
        }
      }

      if (_matches.isNotEmpty) {
        _currentMatchIndex = 0;
      }
    });

    if (_matches.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToCurrentMatch(),
      );
    }
  }

  void _goToNextMatch() {
    if (_matches.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + 1) % _matches.length;
    });
    _scrollToCurrentMatch();
  }

  void _goToPreviousMatch() {
    if (_matches.isEmpty) return;
    setState(() {
      _currentMatchIndex =
          (_currentMatchIndex - 1 + _matches.length) % _matches.length;
    });
    _scrollToCurrentMatch();
  }

  void _scrollToCurrentMatch() {
    if (_currentMatchIndex < 0 || _currentMatchIndex >= _matches.length) return;
    final match = _matches[_currentMatchIndex];
    final context = match.key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 500),
        alignment: 0.5,
      );
    }
  }

  List<Widget> _bulidPrefixList() {
    var prefixLine = [
      [
        "مَولايَ صَلِّ وَسَلِّم دَائِمَاً أَبَداً",
        "عَلى حَبيبِكَ خَيرِ الخَلقِ كُلِّهِم",
      ],
      [
        "مَولايَ صَلِّ وَسَلِّم دَائِمَاً أَبَداً",
        "عَلى النَّبيِّ وَ آل البَيْتِ كُلِّهِمِ",
      ],
    ];
    return prefixLine.asMap().entries.map((entry) {
      return Container(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 0.0,
          left: 16.0,
          right: 16.0,
        ),
        margin: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: <Widget>[
            Row(
              textDirection: AppLocalizations.of(context)!.localeName == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: _highlightText(entry.value[0], TextAlign.right),
                  ),
                ),
              ],
            ),
            Row(
              textDirection: AppLocalizations.of(context)!.localeName == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 25, bottom: 10),
                    child: _highlightText(entry.value[1], TextAlign.left),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    '------   **   ------',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildList() {
    return lines.asMap().entries.map((entry) {
      return Container(
        key: _textKeys.isNotEmpty ? _textKeys[entry.key] : null,
        decoration: const BoxDecoration(
          // color: Color(0xffe1ffe1),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        padding: const EdgeInsets.only(
          top: 0,
          bottom: 0,
          left: 16.0,
          right: 16.0,
        ),
        margin: const EdgeInsets.only(top: 16.0),
        child: Column(children: _buildRowContent(entry)),
      );
    }).toList();
  }

  RichText _highlightText(String text, TextAlign textAlign) {
    var style = TextStyle(
      fontFamily: 'Amiri',
      fontSize: fontSize,
      color: Color(0xff444444),
    );
    if (_searchText.isEmpty) {
      return RichText(
        text: TextSpan(text: text, style: style),
        textAlign: textAlign,
      );
    }

    String cleanSearchText = _removeDiacritics(_searchText.toLowerCase());
    if (cleanSearchText.isEmpty) {
      return RichText(
        text: TextSpan(text: text, style: style),
      );
    }

    List<InlineSpan> spans = [];

    List<int> originalIndices = [];
    String cleanText = "";
    for (int i = 0; i < text.length; i++) {
      String originalChar = text[i];
      String cleanChar = _removeDiacritics(originalChar);
      if (cleanChar.isNotEmpty) {
        for (int j = 0; j < cleanChar.length; j++) {
          originalIndices.add(i);
        }
        cleanText += cleanChar;
      }
    }

    int startInOriginal = 0;
    int startInClean = 0;

    while (startInClean < cleanText.length) {
      int matchIndexInClean = cleanText.toLowerCase().indexOf(
        cleanSearchText,
        startInClean,
      );

      if (matchIndexInClean == -1) {
        if (startInOriginal < text.length) {
          spans.add(TextSpan(text: text.substring(startInOriginal)));
        }
        break;
      }

      int originalMatchStart = originalIndices[matchIndexInClean];
      int matchEndInClean = matchIndexInClean + cleanSearchText.length;
      int originalMatchEnd;

      if (matchEndInClean < originalIndices.length) {
        originalMatchEnd = originalIndices[matchEndInClean];
      } else {
        originalMatchEnd = text.length;
      }

      if (originalMatchStart > startInOriginal) {
        spans.add(
          TextSpan(text: text.substring(startInOriginal, originalMatchStart)),
        );
      }

      if (_matchRenderIndex < _matches.length) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              key: _matches[_matchRenderIndex].key,
              color: Colors.yellow,
              child: Text(
                text.substring(originalMatchStart, originalMatchEnd),
                style: style.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
        _matchRenderIndex++;
      } else {
        spans.add(
          TextSpan(
            text: text.substring(originalMatchStart, originalMatchEnd),
            style: TextStyle(
              backgroundColor: Colors.yellow,
              color: Colors.black,
              fontSize: style.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      startInOriginal = originalMatchEnd;
      startInClean = matchEndInClean;
    }

    if (spans.isEmpty && startInOriginal == 0) {
      return RichText(
        text: TextSpan(text: text, style: style),
      );
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(style: style, children: spans),
    );
  }

  Widget _buildCommotText(String text, TextAlign align) {
    return Row(
      textDirection: AppLocalizations.of(context)!.localeName == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      children: <Widget>[
        Expanded(child: Container(child: _highlightText(text, align))),
      ],
    );
  }

  Widget _buildRightSideText(text) {
    return _buildCommotText(text, TextAlign.right);
  }

  Widget _buildLeftSideText(text) {
    return _buildCommotText(text, TextAlign.left);
  }

  Widget _buildCenterText(text) {
    return _buildCommotText(text, TextAlign.center);
  }

  List<Widget> _buildRowContent(entry) {
    var rowContent = <Widget>[];
    // TODO: temp solution till we return complete lines for werds
    if (widget.name == "منظومة أسماء الله الحسنى") {
      rowContent.add(_buildRightSideText(entry.value.first[0]));
      rowContent.add(_buildLeftSideText(entry.value.first[1]));
    } else {
      if (entry?.value.length > 1) {
        rowContent.add(_buildRightSideText(entry.value[0]));
        rowContent.add(_buildLeftSideText(entry.value[1]));
      } else {
        rowContent.add(_buildCenterText(entry.value[0]));
      }
    }

    rowContent.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 16.0),
            child: Text(
              '------   ${entry.key + 1} / ${lines.length}   ------',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
    return rowContent;
  }

  Widget _buildBottomBannerAdWidget() {
    if (_isBottomBannerAdReady && _bottomBannerAd != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        width: _bottomBannerAd!.size.width.toDouble(),
        height: _bottomBannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bottomBannerAd!),
      );
    } else {
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
    finalPageDetails.addAll(_addDescLine(desc));
    finalPageDetails.add(_buildMediaPlayer());
    if (["بردة المديح للامام البوصيري"].contains(widget.department)) {
      finalPageDetails.addAll(_bulidPrefixList());
    }
    finalPageDetails.addAll(_buildList()); // Add the content item
    // Add Native Ad at the end, after all content items
    finalPageDetails.add(_buildNativeAdWidget());

    return finalPageDetails;
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(icon: Icon(Icons.clear), onPressed: _stopSearch),
        if (_matches.isNotEmpty) ...[
          Center(
            child: Text(
              '${_currentMatchIndex + 1}/${_matches.length}',
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_upward),
            onPressed: _goToPreviousMatch,
          ),
          IconButton(
            icon: Icon(Icons.arrow_downward),
            onPressed: _goToNextMatch,
          ),
        ],
      ];
    }

    return <Widget>[
      IconButton(icon: Icon(Icons.search), onPressed: _startSearch),
      IconButton(
        icon: Icon(Icons.remove_red_eye),
        onPressed: () => {
          if (_readingMode)
            {analytics.logUserAction("open_reading_mode")}
          else
            {analytics.logUserAction("close_reading_mode")},
          setState(() {
            _readingMode = !_readingMode;
          }),
        },
      ),
    ];
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: TextStyle(color: Colors.white, fontSize: 18.0),
      onChanged: _updateSearchQuery,
    );
  }

  Widget _buildCounterRow() {
    if (!_readingMode) {
      return SizedBox.shrink();
    }
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xffcccccc), // Customize color
            width: 1.0, // Customize thickness
            style: BorderStyle.solid, // Customize style (solid, none)
          ),
        ),
        color: Color(0xfffffcf5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Distributes space evenly between children
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: ElevatedButton(
              onPressed: _scrollPage,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Icon(Icons.arrow_downward, color: Colors.white),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Distributes space evenly between children
            children: [
              ElevatedButton(
                onPressed: _incrementCounter,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Icon(Icons.add, color: Colors.white),
              ),
              SizedBox(width: 16.0),
              Text(
                _counter.toString(),
                style: TextStyle(color: Colors.black, fontSize: fontSize),
              ),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: _resetCounter,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Icon(Icons.replay, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _matchRenderIndex = 0;
    return Directionality(
      textDirection: AppLocalizations.of(context)!.localeName == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching ? _buildSearchField() : Text(widget.name),
          backgroundColor: Colors.green,
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
          actions: _buildActions(),
        ),
        body: DecoratedBox(
          position: DecorationPosition.background,
          decoration: const BoxDecoration(color: Color(0xfffffcf5)),
          child: Center(
            child: Column(
              children: [
                _buildCounterRow(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                      right: 8.0,
                      left: 8.0,
                    ),
                    child: GestureDetector(
                      onScaleStart: (details) {
                        _baseFontSize = fontSize;
                        _currentScale = 1.0;
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          _currentScale = details.scale;
                          // Calculate new font size based on scale
                          // Clamp between 12 and 72 for reasonable font sizes
                          fontSize = (_baseFontSize * _currentScale)
                              .clamp(12.0, 72.0)
                              .roundToDouble();
                        });
                        print(fontSize);
                      },
                      onScaleEnd: (details) {
                        // Save the font size preference when gesture ends
                        _saveFontSize();
                        _baseFontSize = fontSize;
                        _currentScale = 1.0;
                      },
                      child: Column(children: buildPageDetails()),
                    ),
                  ),
                ),
                _buildBottomBannerAdWidget(), // Bottom banner remains at the very bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
