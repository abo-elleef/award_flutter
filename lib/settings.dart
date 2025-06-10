import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'award.dart';
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
  late int textColor = 0xff3a863d;
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
                    children: [Row(
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
                          activeColor: Color(this.textColor),
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
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Color.fromRGBO(255, 255, 255, 0.8),
                                    borderRadius: BorderRadius.all(Radius.circular(15))),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16.0),
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0.0),
                                child:Text(
                                  'لا إله إلا الله',
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: this.fontSize,
                                    color:  Color(this.textColor),
                                  ),
                                ),
                              )
                          )
                      ],)
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
