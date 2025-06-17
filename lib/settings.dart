import 'package:awrad3/part_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'award.dart';
import 'part_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // late int textColor = 0xff3a863d;
  late int textColor = 0xFF000000;
  SettingsState();
  void fetchUserPreferences () async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
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




  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl, // set this property
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
                height: MediaQuery.of(context).size.height - 100,
                width: MediaQuery.of(context).size.width - 16,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children:[
                          Text('حجم الخط',
                            style: TextStyle(
                              fontSize: 20,
                              color:  Color(this.textColor),
                            )
                          ),
                          Slider(
                            value: this.fontSize,
                            max: 36,
                            min: 14,
                            divisions: 11,
                            activeColor: Color(0xff3a863d),
                            label: this.fontSize.toString(),
                            onChanged: (double value) {
                              setState(() {
                                this.fontSize = value;
                                setFontSize(value);
                              });
                            },
                          )
                        ]
                      ),
                      PartCard(title: 'لا إله إلا الله', index: 1, listSize: 6, fontSize: this.fontSize, textColor: this.textColor)
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
