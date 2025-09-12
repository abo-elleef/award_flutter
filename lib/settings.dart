import 'package:awrad3/part_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'award.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Widget _buildSocialButton(BuildContext context, String text, String url) {
    final Uri facebookUrl = Uri.parse(url);

    return GestureDetector(
      onTap: () async {
        try {
          if (await canLaunchUrl(facebookUrl)) {
            await launchUrl(facebookUrl, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تعذر فتح الرابط. يرجى التحقق من اتصالك بالإنترنت.')),
              );
            }
            print('Could not launch $facebookUrl');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('حدث خطأ أثناء محاولة فتح الرابط.')),
            );
          }
          print('Error launching URL: $e');
        }
      },
      child: Card(
        color: Color(0xffe1ffe1),
        elevation: 2.0,
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Optional: Add Facebook icon here if desired
              // Icon(Icons.facebook, color: Color(this.textColor), size: this.fontSize + 2),
              // SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: this.fontSize,
                  color: Color(this.textColor),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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
                      PartCard(title: 'لا إله إلا الله', index: 1, listSize: 6, fontSize: this.fontSize, textColor: this.textColor),
                      _buildSocialButton(context, 'تابعنا على فيسبوك', 'https://www.facebook.com/bordaelmadyh/'), // Added Social button (FB)
                      _buildSocialButton(context, 'تابعنا على تويتر', 'https://x.com/bordaelmadyh') // Added Social button (Twitter)
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
