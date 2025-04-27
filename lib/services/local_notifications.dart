import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Global navigator key for notifications routing
final GlobalKey<NavigatorState> notificationsNavigatorKey = GlobalKey<NavigatorState>();

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin 
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  

//initalize local notifications
  static Future localNotiInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          'demoCategory',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
              'id_2',
              'Action 2',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
            DarwinNotificationAction.plain(
              'id_3',
              'Action 3',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        )
      ],
    );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  // on tap local notification in foreground or background or terminated // User will redirect to this route //

  static void onNotificationTap(NotificationResponse notificationResponse) {
    notificationsNavigatorKey.currentState!
        .pushNamed("/message", arguments: notificationResponse);
  }

  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_2', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            icon: '@mipmap/ic_launcher');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

  static Future<void> showScheduleNotification({
    required String title,
    required String body,
    required String payload,
    required DateTime scheduledTime,
  }) async {
    tz.initializeTimeZones();

    final tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_3',
      'Your Channel Name',
      channelDescription: 'Your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
    );
    
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      title,
      body,
      tzScheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }
}

// / How to use ///

// DateTime scheduledTime = DateTime(2025, 3, 3, 14, 30); // March 3, 2025, 2:30 PM
// await showScheduleNotification(
//   title: "Meeting Reminder",
//   body: "Your meeting is starting soon!",
//   payload: "meeting_123",
//   scheduledTime: scheduledTime,
// );
