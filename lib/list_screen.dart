import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import './details_screen.dart';
import './werd_details_screen.dart';
import 'package:http/http.dart' as http;
import 'award.dart';
import './part_card.dart';
// import 'package:shared_preferences/shared_preferences.dart';
class ListPage extends StatefulWidget {
  final String name;
  final int index;
  late double fontSize;
  late int textColor;
  ListPage(this.name, this.index);
  @override
  State<StatefulWidget> createState() {
    return ListPageState(name, index);
  }
}

class ListPageState extends State<ListPage> {
  String name;
  int index;
  late double fontSize = 24;
  late int textColor = 0xff3a863d;
  ListPageState(this.name, this.index);
  List poems = [];

  void fetchUserPreferences () async {
    // SharedPreferences pref = await SharedPreferences.getInstance();
    // setState(() {
    //   fontSize = pref.getDouble('fontSize') ?? fontSize;
    //   textColor = pref.getInt('textColor') ?? textColor;
    // });
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
      poems = offlineStore[this.name]!;
    });
    // }
  }
  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
    fetchData();
  }
  List<Widget> _buildList() {
        return poems.asMap().entries.map((entry){
          return Row(
                textDirection: TextDirection.rtl,
                children: <Widget>[
                  Expanded(
                      child: Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                if (name == "الأوراد" || name == 'دلائل الخيرات'){
                                  return WerdDetails(entry.value['name'].toString(), 1, name);
                                }else{
                                  return Details(entry.value['name'].toString(), entry.value['id'], name);
                                }
                              })
                            );
                          },
                          child: PartCard(title: entry.value['name'].toString())
                        )
                    )
                  ),
                 // Text((entry.key+ 1).toString(),
                 //   style: const TextStyle(
                 //     fontSize: 12,
                 //   ),
                 // )
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
  Widget _desciptionWidget(){
    if(AwardSource[index]!["desc"] != null){
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
          AwardSource[index]!["desc"].toString(),
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
