import 'package:flutter/services.dart';

class LocalReminders {
  LocalReminders._();

  static const _channel = MethodChannel('cmstudy/reminders');

  static void listenForLaunchActions(void Function(String action) onAction) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'launchAction') {
        final action = call.arguments?.toString();
        if (action != null && action.isNotEmpty) {
          onAction(action);
        }
      }
    });
  }

  static Future<String?> consumeLaunchAction() async {
    try {
      final action = await _channel.invokeMethod<String>('consumeLaunchAction');
      return action?.isEmpty == true ? null : action;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  static Future<bool> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      final scheduled = await _channel.invokeMethod<bool>('scheduleDaily', {
        'id': id,
        'title': title,
        'body': body,
        'hour': hour,
        'minute': minute,
      });
      return scheduled ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
