import 'dart:convert';
import 'dart:math';

import 'package:awrad3/chapter_view.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import './details_screen.dart';
import './werd_details_screen.dart';
import 'package:http/http.dart' as http;
import 'award.dart';
import './part_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ListPage extends StatefulWidget {
  final String departmentName;
  final int index;
  late double fontSize;
  late int textColor;
  ListPage(this.departmentName, this.index);
  @override
  State<StatefulWidget> createState() {
    return ListPageState(departmentName, index);
  }
}

class ListPageState extends State<ListPage> {
  String departmentName;
  int index;
  late double fontSize = 24;
  late int textColor = 0xFF000000;
  ListPageState(this.departmentName, this.index);
  List poems = [];

  void fetchUserPreferences () async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
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
      poems = offlineStore[this.departmentName]!;
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
      return Column(
          children: <Widget>[
            Row(
              textDirection: TextDirection.rtl,
              children: <Widget>[
                Expanded(
                    child: Container(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    if (["الأوراد", "دلائل الخيرات", "صلاوات النبي"].contains(departmentName)) {
                                      return WerdDetails(entry.value['name'].toString(), 1, departmentName);
                                    } else {
                                      if (["بردة المديح للامام البوصيري"].contains(departmentName)) {
                                        return Details(entry.value['name'].toString(), int.parse(entry.value['id']), departmentName, -1);
                                      } else {
                                        if (entry.value['chapters'].length > 1) {
                                          return ChapterView(entry.value, departmentName);
                                        } else {
                                          return Details(entry.value['name'].toString(), entry.value['id'], departmentName, -1);
                                        }
                                      }
                                    }
                                  }) // Correctly closed MaterialPageRoute
                              ); // Correctly closed Navigator.push
                            }, // Correctly closed onTap
                            child: PartCard(title: entry.value['name'].toString(), index: entry.key, listSize: poems.length, fontSize: fontSize, textColor: textColor)
                        )
                    )
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
          ]
      );
    }).toList();
  }

  Widget _desciptionWidget(){
    if(AwradOffline[index]!["desc"] != null){
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

  List<Widget> buildPageDetails() {
    List<Widget> pageDetails = [];
    // pageDetails.add(_desciptionWidget());
    pageDetails.addAll(_buildList());
    return pageDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl, // set this property
        child: Scaffold(
        appBar: AppBar(
          title: Text(departmentName),
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
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: buildPageDetails(),
                ),
              )
            )
          )
        )
      )
    );
  }
}
