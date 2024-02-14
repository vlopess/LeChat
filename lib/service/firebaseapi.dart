import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lechat/main.dart';
import 'package:lechat/models/connection_chat_model.dart';
import 'package:lechat/screens/chat_screen.dart';
import 'package:http/http.dart' as http;

Future<void> handBackgroundMessage(RemoteMessage message) async{
  log("----------------");
  log(message.notification!.title.toString());
  log(message.notification!.body.toString());
  log(message.data.toString());
  log("----------------");
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final androidChannel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  

  void handleMessage(RemoteMessage? message) async {
    if(message == null) return;
    var chatID = message.data['connection_id'];
    navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => ChatScreen(chatID: chatID),));
  }

  Future initPushNotification() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true
    );
    FirebaseMessaging.onBackgroundMessage(handBackgroundMessage);
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if(notification == null) return;
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            androidChannel.id,
            androidChannel.name,
            channelDescription: androidChannel.description,
            icon: "@mipmap/ic_launcher"
          ),          
        ),
        payload: jsonEncode(message.toMap())
      );      
    });
  }

  Future initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("@mipmap/ic_launcher");
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(onDidReceiveLocalNotification: (id, title, body, payload) {},);
    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid,iOS: initializationSettingsDarwin, linux: initializationSettingsLinux);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,      
      onDidReceiveNotificationResponse: (payload) {
        final message = RemoteMessage.fromMap(jsonDecode(payload.toString()));
        handleMessage(message);
      },
    );
    final plataform = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await plataform?.createNotificationChannel(androidChannel);
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    initPushNotification();
    FirebaseMessaging.onBackgroundMessage(handBackgroundMessage);   
    initLocalNotifications();       
  }

  Future<String?> getToken() async => await _firebaseMessaging.getToken();

  Future<void> sendPushNotification({required Connection connection, required String message}) async {
    String accessToken = 'AAAAm7NfBos:APA91bGtrM6UEu0N5FxOzNCW5QY7KFN-335nNtfp-rc0_851koRD0D3egqMFYG7PMuccF0dTisil3kvs35cUcnG8RTYMiUQ8ZsNBHKC2Bmttoqd4V3hRuRjl_Mc2KgCr4_Z794Mdl9Tr';
    for (var user in connection.users!) {
        //user.token
      var data = {      
        "to": user.token,
        "notification": {
          "title": connection.roomName,
          "body": message
        },
        "data": {
          "connection_id": connection.chatId
        }
      };
      await http.post(      
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          "Content-Type" : "application/json",
          'Authorization' : 'key=$accessToken'
        }
      );
    }    
  }
}