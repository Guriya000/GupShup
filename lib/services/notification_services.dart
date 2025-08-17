// // services/notification_service.dart
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final FirebaseMessaging _firebaseMessaging =
//       FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin
//   _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     // Request permission
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // Initialize local notifications
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final DarwinInitializationSettings initializationSettingsDarwin =
//         DarwinInitializationSettings(
//           requestSoundPermission: true,
//           requestBadgePermission: true,
//           requestAlertPermission: true,
//         );

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//           android: initializationSettingsAndroid,
//           iOS: initializationSettingsDarwin,
//         );

//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _showNotification(message);
//     });

//     // Handle background messages
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // Get token
//     String? token = await _firebaseMessaging.getToken();
//     print("FCM Token: $token");

//     // Save this token to your database associated with the user
//     // await saveTokenToDatabase(token);
//   }

//   static Future<void> _showNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//           'high_importance_channel',
//           'High Importance Notifications',
//           importance: Importance.max,
//           priority: Priority.high,
//           showWhen: false,
//         );

//     const DarwinNotificationDetails darwinPlatformChannelSpecifics =
//         DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         );

//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: darwinPlatformChannelSpecifics,
//     );

//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       message.notification?.title ?? 'New Message',
//       message.notification?.body ?? 'You have a new message',
//       platformChannelSpecifics,
//       payload:
//           message.data['chatRoomId'], // Pass chat room ID to open when tapped
//     );
//   }

//   @pragma('vm:entry-point')
//   static Future<void> _firebaseMessagingBackgroundHandler(
//     RemoteMessage message,
//   ) async {
//     await _showNotification(message);
//   }

//   static Future<String?> getDeviceToken() async {
//     return await _firebaseMessaging.getToken();
//   }

//   static Future<void> subscribeToTopic(String topic) async {
//     await _firebaseMessaging.subscribeToTopic(topic);
//   }

//   static Future<void> unsubscribeFromTopic(String topic) async {
//     await _firebaseMessaging.unsubscribeFromTopic(topic);
//   }
// }
