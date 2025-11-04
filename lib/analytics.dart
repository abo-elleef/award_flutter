import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Log a screen view event
  Future<void> logScreenView(String screenName) async {
    await _analytics.logEvent(
      name: 'page_open',
      parameters: <String, Object>{
        'screen_name': screenName,
      },
    );
  }

  // Log a custom user action
  Future<void> logUserAction(String action) async {
    await _analytics.logEvent(
      name: 'user_action',
      parameters: <String, Object>{
        'action_type': action,
      },
    );
  }
}
