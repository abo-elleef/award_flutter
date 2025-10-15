import 'package:awrad3/part_card.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // Added import
import 'l10n/app_localizations.dart';
import 'notification_service.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});
  @override
  State<StatefulWidget> createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {
  late double fontSize = 24;
  late int textColor = 0xFF000000;
  
  // Notification settings
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = false;
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 20, minute: 0);

  SettingsState();

  void fetchUserPreferences () async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      this.fontSize = _pref.getDouble('fontSize') ?? this.fontSize;
      this.textColor = _pref.getInt('textColor') ?? this.textColor;
    });
    
    // Load notification settings
    await _loadNotificationSettings();
  }
  
  Future<void> _loadNotificationSettings() async {
    final enabled = await _notificationService.areNotificationsEnabled();
    final times = await _notificationService.getNotificationTimes();
    
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _morningTime = TimeOfDay(hour: times['morningHour']!, minute: times['morningMinute']!);
      _eveningTime = TimeOfDay(hour: times['eveningHour']!, minute: times['eveningMinute']!);
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
  
  Future<void> _toggleNotifications(bool enabled) async {
    try {
      await _notificationService.setNotificationsEnabled(enabled);
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = enabled;
      });
    } catch (e) {
      print('Error toggling notifications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.settings_page_exact_alarm_permission_error
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      // Reset the toggle state if it failed
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = false;
      });
    }
  }
  
  Future<void> _selectMorningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _morningTime,
    );
    if (picked != null && picked != _morningTime) {
      if (!mounted) return;
      setState(() {
        _morningTime = picked;
      });
      await _notificationService.updateNotificationTimes(
        morningHour: _morningTime.hour,
        morningMinute: _morningTime.minute,
        eveningHour: _eveningTime.hour,
        eveningMinute: _eveningTime.minute,
      );
    }
  }
  
  Future<void> _selectEveningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _eveningTime,
    );
    if (picked != null && picked != _eveningTime) {
      if (!mounted) return;
      setState(() {
        _eveningTime = picked;
      });
      await _notificationService.updateNotificationTimes(
        morningHour: _morningTime.hour,
        morningMinute: _morningTime.minute,
        eveningHour: _eveningTime.hour,
        eveningMinute: _eveningTime.minute,
      );
    }
  }

  Widget _buildNotificationSettings() {
    return Column(
      children: [
        // Notification toggle
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xffe1ffe1),
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.settings_page_notifications,
                      style: TextStyle(
                        fontSize: this.fontSize,
                        color: Color(this.textColor),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.settings_page_notifications_desc,
                      style: TextStyle(
                        fontSize: this.fontSize * 0.8,
                        color: Color(this.textColor).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: Color(0xff3a863d),
              ),
            ],
          ),
        ),
        
        // Time pickers (only show if notifications are enabled)
        if (_notificationsEnabled) ...[
          // Morning time picker
          GestureDetector(
            onTap: _selectMorningTime,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xffe1ffe1),
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
              child: Row(
                children: [
                  Icon(Icons.wb_sunny, color: Color(this.textColor)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.settings_page_morning_time,
                      style: TextStyle(
                        fontSize: this.fontSize,
                        color: Color(this.textColor),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _morningTime.format(context),
                    style: TextStyle(
                      fontSize: this.fontSize,
                      color: Color(this.textColor),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Icon(Icons.access_time, color: Color(this.textColor)),
                ],
              ),
            ),
          ),
          
          // Evening time picker
          GestureDetector(
            onTap: _selectEveningTime,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xffe1ffe1),
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
              child: Row(
                children: [
                  Icon(Icons.nights_stay, color: Color(this.textColor)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.settings_page_evening_time,
                      style: TextStyle(
                        fontSize: this.fontSize,
                        color: Color(this.textColor),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _eveningTime.format(context),
                    style: TextStyle(
                      fontSize: this.fontSize,
                      color: Color(this.textColor),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Icon(Icons.access_time, color: Color(this.textColor)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialButton(BuildContext context, String text, String url) {
    final Uri socialUrl = Uri.parse(url); // Renamed variable for clarity

    return GestureDetector(
      onTap: () async {
        try {
          if (await canLaunchUrl(socialUrl)) {
            await launchUrl(socialUrl, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تعذر فتح الرابط. يرجى التحقق من اتصالك بالإنترنت.')),
              );
            }
            print('Could not launch $socialUrl');
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
      child: Container(
        width: double.infinity,
        child: Card(
          color: Color(0xffe1ffe1),
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
                    text,
                    style: TextStyle(
                      fontSize: this.fontSize,
                      color: Color(this.textColor),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
      ),)
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: AppLocalizations.of(context)!.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.main_page_settings),
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
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children:[
                          Expanded( // Added Expanded for better layout
                            child: Text(AppLocalizations.of(context)!.settings_page_font_size,
                              style: TextStyle(
                                fontSize: 20, // Consider making this dynamic or a fixed larger size for a label
                                color:  Color(this.textColor),
                              )
                            ),
                          ),
                          Expanded( // Added Expanded for Slider
                            flex: 2, // Give more space to slider
                            child: Slider(
                              value: this.fontSize,
                              max: 36,
                              min: 14,
                              divisions: 11,
                              activeColor: Color(0xff3a863d),
                              label: this.fontSize.round().toString(), // Use round() for cleaner label
                              onChanged: (double value) {
                                setState(() {
                                  this.fontSize = value;
                                  setFontSize(value);
                                });
                              },
                            ),
                          )
                        ]
                      ),
                      PartCard(title: AppLocalizations.of(context)!.settings_page_font_example, index: 0, listSize: 6, fontSize: this.fontSize, textColor: this.textColor),
                      _buildNotificationSettings(),
                      _buildSocialButton(context, AppLocalizations.of(context)!.settings_page_facebook, 'https://www.facebook.com/bordaelmadyh/'),
                      _buildSocialButton(context, AppLocalizations.of(context)!.settings_page_twitter, 'https://x.com/bordaelmadyh'),
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
