import 'dart:convert';
import 'dart:math';

import 'package:awrad3/chapter_view.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import './details_screen.dart';
import 'package:http/http.dart' as http;
import 'award.dart';
import './part_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'analytics.dart'; // Import the analytics class

class ListPage extends StatefulWidget {
  final String storeKey;
  final String title;
  final int index;
  late double fontSize;
  late int textColor;

  ListPage(this.storeKey, this.title, this.index);

  @override
  State<StatefulWidget> createState() {
    return ListPageState(storeKey, title, index);
  }
}

class ListPageState extends State<ListPage> {
  String storeKey;
  String title;
  int index;
  final Analytics analytics = Analytics(); // Instantiate the analytics class
  late double fontSize = 24;
  late int textColor = 0xFF000000;

  // Search state variables
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<GlobalKey> _itemKeys = [];
  List<int> _matchIndexes = [];
  int _currentMatchIndex = -1;
  final ScrollController _scrollController = ScrollController();


  ListPageState(this.storeKey, this.title, this.index);

  List poems = [];

  void fetchUserPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      fontSize = pref.getDouble('fontSize') ?? fontSize;
      textColor = pref.getInt('textColor') ?? textColor;
    });
  }

  void fetchData() async {
    setState(() {
      poems =
          offlineStore
                  .where((item) => item['key'] == storeKey)
                  .toList()[0]['content']!
              as List;
      _itemKeys = List.generate(poems.length, (_) => GlobalKey());
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
    fetchData();
    _searchController.addListener(() {
      _updateSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchText = '';
      _matchIndexes.clear();
      _currentMatchIndex = -1;
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchText = query;
      _matchIndexes.clear();
      _currentMatchIndex = -1;

      if (query.isNotEmpty) {
        for (int i = 0; i < poems.length; i++) {
          final poem = poems[i];
          final title = poem['name']?.toString().toLowerCase() ?? '';
          final titleAr = poem['name_ar']?.toString().toLowerCase() ?? '';
          final titleEn = poem['name_en']?.toString().toLowerCase() ?? '';
          final titleFr = poem['name_fr']?.toString().toLowerCase() ?? '';

          if (title.contains(query.toLowerCase()) ||
              titleAr.contains(query.toLowerCase()) ||
              titleEn.contains(query.toLowerCase()) ||
              titleFr.contains(query.toLowerCase())) {
            _matchIndexes.add(i);
          }
        }

        if (_matchIndexes.isNotEmpty) {
          _currentMatchIndex = 0;
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToMatch(_matchIndexes[0]));
        }
      }
    });
  }

  void _goToNextMatch() {
    if (_matchIndexes.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + 1) % _matchIndexes.length;
    });
    _scrollToMatch(_matchIndexes[_currentMatchIndex]);
  }

  void _goToPreviousMatch() {
    if (_matchIndexes.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex - 1 + _matchIndexes.length) % _matchIndexes.length;
    });
    _scrollToMatch(_matchIndexes[_currentMatchIndex]);
  }

  void _scrollToMatch(int index) {
    final key = _itemKeys[index];
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context,
          duration: Duration(milliseconds: 300), alignment: 0.5);
    }
  }


  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: _stopSearch,
        ),
        if (_matchIndexes.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text('${_currentMatchIndex + 1}/${_matchIndexes.length}', style: TextStyle(color: Colors.white)),
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
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  RichText _highlightText(String text) {
    if (_searchText.isEmpty) {
      return RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: fontSize,
            color: Color(textColor),
          ),
        ),
      );
    }

    final List<TextSpan> children = [];
    final textLower = text.toLowerCase();
    final searchTextLower = _searchText.toLowerCase();

    int start = 0;
    int indexOfHighlight;

    while ((indexOfHighlight = textLower.indexOf(searchTextLower, start)) != -1) {
      if (indexOfHighlight > start) {
        children.add(TextSpan(
          text: text.substring(start, indexOfHighlight),
           style: TextStyle(
            fontSize: fontSize,
            color: Color(textColor),
          ),
        ));
      }
      children.add(
        TextSpan(
          text: text.substring(indexOfHighlight, indexOfHighlight + _searchText.length),
          style: TextStyle(
            fontSize: fontSize,
            color: Color(textColor),
            backgroundColor: Colors.yellow,
          ),
        ),
      );
      start = indexOfHighlight + _searchText.length;
    }

    if (start < text.length) {
      children.add(TextSpan(
        text: text.substring(start),
         style: TextStyle(
            fontSize: fontSize,
            color: Color(textColor),
          ),
      ));
    }

    return RichText(text: TextSpan(children: children));
  }


  // ... inside ListPageState class ...

  List<Widget> _buildList() {
    return poems.asMap().entries.map((entry) {
      final int index = entry.key;
      final poem = entry.value;

      String key = "name_" + AppLocalizations.of(context)!.localeName;
      String title = "";
      if (poem[key] == null || poem[key].isEmpty) {
        title = poem['name'].toString();
      } else {
        title = poem[key];
      }

      final bool isCurrentMatch = _isSearching && _matchIndexes.isNotEmpty && _matchIndexes[_currentMatchIndex] == index;

      return Container(
        key: _itemKeys[index],
        color: isCurrentMatch ? Colors.amber.withOpacity(0.3) : null,
        child: Column(
          children: <Widget>[
            Row(
              textDirection: AppLocalizations.of(context)!.localeName == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: make sure all ids are numbers not string
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              analytics.logScreenView(storeKey + ":" + poem['name']); // Log the screen view event
                              if ([
                                "الأوراد",
                                "دلائل الخيرات",
                                "صلاوات النبي",
                              ].contains(storeKey)) {
                                // باقي الاثسام
                                print("path 1");
                                return Details(
                                  title,
                                  int.parse(poem['id'].toString()),
                                  storeKey,
                                  -1,
                                );
                                // return WerdDetails(title, int.parse(poem['id'].toString()), storeKey as String);
                              } else {
                                if ([
                                  "بردة المديح للامام البوصيري",
                                ].contains(storeKey)) {
                                  // البردة
                                  print("path 2");
                                  return Details(
                                    title,
                                    int.parse(poem['id'].toString()),
                                    storeKey,
                                    -1,
                                  );
                                } else {
                                  if (poem['chapters'].length > 1) {
                                    // قصيدة مدح من اكتر فصل واحد
                                    print("path 3");
                                    return ChapterView(poem, storeKey);
                                  } else {
                                    // قصيدة مدح من فصل واحد
                                    print("path 4");
                                    return Details(
                                      title,
                                      int.parse(poem['id'].toString()),
                                      storeKey,
                                      0,
                                    );
                                  }
                                }
                              }
                            },
                          ), // Correctly closed MaterialPageRoute
                        ); // Correctly closed Navigator.push
                      }, // Correctly closed onTap
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xffcccccc), // Customize color
                                width: 1.0, // Customize thickness
                                style: BorderStyle
                                    .solid, // Customize style (solid, none)
                              ),
                            ),
                            color: Color(0xfffffcf5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                textDirection:
                                AppLocalizations.of(context)!.localeName == 'ar'
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  // Container(
                                  //   margin: EdgeInsets.only(top: 20, bottom: 0, left: 8.0, right: 8.0),
                                  //   child: Image.asset("assets/book.png", width: 20),
                                  // ),
                                  Text(
                                    "(" + (entry.key + 1).toString() + ")",
                                    style: TextStyle(
                                      fontSize: fontSize / 1.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff666666),
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Expanded(child: _highlightText(title)),
                                ],
                              ),
                            ],
                          ),
                        )
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> buildPageDetails() {
    List<Widget> pageDetails = [];
    pageDetails.addAll(_buildList());
    return pageDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocalizations.of(context)!.localeName == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching ? _buildSearchField() : Text(title),
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(color: Colors.white),
          actions: _buildActions(),
        ),
        body: DecoratedBox(
          position: DecorationPosition.background,
          decoration: const BoxDecoration(
              color: Color(0xfffffcf5)
          ),
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildPageDetails(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
