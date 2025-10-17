import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Log a screen view event
  Future<void> logScreenView(String screenName) async {
    await _analytics.logEvent(
      name: 'screen_view',
      parameters: <String, Object>{
        'firebase_screen': screenName,
      },
    );
  }
}
