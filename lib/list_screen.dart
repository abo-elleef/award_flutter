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
  late double fontSize = 24;
  late int textColor = 0xFF000000;

  ListPageState(this.storeKey, this.title, this.index);

  List poems = [];

  void fetchUserPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      // print("this is fine");
      // print(this.index);
      fontSize = pref.getDouble('fontSize') ?? fontSize;
      textColor = pref.getInt('textColor') ?? textColor;
    });
  }

  void fetchData() async {
    // try {
    //   final response = await http
    //       .get(Uri.parse(ApiEndPoints[this.name]!["list"]!));
    //   if (response.statusCode == 200) {
    //     setState(() {
    //       poems = (jsonDecode(response.body));
    //     });
    //     // TODO: save response to user preferences
    //   } else {
    //     // TODO: read from user preferences
    //     // print(response.body);
    //     // throw Exception('Failed to load album');
    //   }
    // } on Exception catch(_){
    setState(() {
      poems =
          offlineStore
                  .where((item) => item['key'] == storeKey)
                  .toList()[0]['content']!
              as List;
    });
    // }
  }

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
    fetchData();
  }

  // ... inside ListPageState class ...

  List<Widget> _buildList() {
    return poems.asMap().entries.map((entry) {
      String key = "name_" + AppLocalizations.of(context)!.localeName;
      String title = "";
      if (entry.value[key] == null || entry.value[key].isEmpty) {
        title = entry.value['name'].toString();
      } else {
        title = entry.value[key];
      }
      ;
      return Column(
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
                            if ([
                              "الأوراد",
                              "دلائل الخيرات",
                              "صلاوات النبي",
                            ].contains(storeKey)) {
                              // باقي الاثسام
                              print("path 1");
                              return Details(
                                title,
                                int.parse(entry.value['id'].toString()),
                                storeKey,
                                -1,
                              );
                              // return WerdDetails(title, int.parse(entry.value['id'].toString()), storeKey as String);
                            } else {
                              if ([
                                "بردة المديح للامام البوصيري",
                              ].contains(storeKey)) {
                                // البردة
                                print("path 2");
                                return Details(
                                  title,
                                  int.parse(entry.value['id'].toString()),
                                  storeKey,
                                  -1,
                                );
                              } else {
                                if (entry.value['chapters'].length > 1) {
                                  // قصيدة مدح من اكتر فصل واحد
                                  print("path 3");
                                  return ChapterView(entry.value, storeKey);
                                } else {
                                  // قصيدة مدح من فصل واحد
                                  print("path 4");
                                  return Details(
                                    title,
                                    int.parse(entry.value['id'].toString()),
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
                    child: PartCard(
                      title: title,
                      index: entry.key,
                      listSize: poems.length,
                      fontSize: fontSize,
                      textColor: textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // issue when deployed to store
          // Positioned(
          //     bottom: 20,
          //     left: 10,
          //     child: Text(
          //       (pagesList.indexOf(page) + 1).toString(),
          //       style: const TextStyle(
          //         fontSize: 12,
          //       ),
          //     )
          // )
        ],
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
          title: Text(title),
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        body: DecoratedBox(
          position: DecorationPosition.background,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
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
