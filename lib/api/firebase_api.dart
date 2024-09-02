import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_firebase/notification_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;


  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notfication',
    description: 'This channel is used for important notifications',
    importance: Importance.defaultImportance
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> HandleBackgroundMessage(RemoteMessage message) async{
    print('Title: ${message.notification?.title}');
    print('Title: ${message.notification?.body}');
    print('Title: ${message.data}');
  }


  void handleMessage(RemoteMessage? message) {
    if(message == null) return;
    NotificationPage();
  }

  Future initPushNotifications() async{
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );


    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(HandleBackgroundMessage); 
    FirebaseMessaging.onMessage.listen((message){
      final notification = message.notification;
      if (notification == null) {
        return;
      }
      _localNotifications.show(notification.hashCode, notification.title, notification.body, NotificationDetails(android: AndroidNotificationDetails(_androidChannel.id, _androidChannel.name,
      channelDescription: _androidChannel.description,
      icon: '@drawable/ic_launcher',
       )),
       payload: jsonEncode(message.toMap()),
       );
    });
  }


  Future initLocalNotifications() async{
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings,
      
    );
    final platform =_localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<void> initNotifications() async{
    await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();

    print('Token: $fCMToken');
    
    initNotifications();
    initLocalNotifications();
  }
}