import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_push_notifications_app/screens/navigated_screen.dart';

class NotificationServices {
//FirebaseMessaging initialisation
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final player = AudioPlayer();
  static bool audioAlreadyPlayed = false;

//Flutter local notifications initialisation
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

//Requesting users to allow notifications
  void requestNotificationPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      provisional: true,
      sound: true,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted permission!!");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint("User granted provisional permission!!");
    } else {
      debugPrint("User denied permission!!");
    }
  }

//To get device token
  Future<String?> getDevicetoken() async {
    return await messaging.getToken();
  }

//To check whether the device token is expired
  void isTokenRefreshed() async {
    messaging.onTokenRefresh.listen((event) {
      debugPrint("Token refresh: ${event.toString()}");
    });
  }

//Setting up notifications when the app is active
  void firebaseInitialisation(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint("Title: ${message.notification!.title.toString()}");
      debugPrint("Body: ${message.notification!.body.toString()}");
      debugPrint("Payload: ${message.data}");
      initLocalNotification(context, message);
      showNotification(message);
      //Playing the audio file when the app is active
      playAudioFile();
    });
  }

//Initialising the flutter local notifications
  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    //Setting up for android
    var androidInitialization =
        const AndroidInitializationSettings("@mipmap/ic_launcher");

    var initializationSetting = InitializationSettings(
      android: androidInitialization,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: (payload) {
        handleMessage(context, message);
      },
    );
  }

//Showing Notifications
  Future<void> showNotification(RemoteMessage message) async {
    //Setting up Android Notification Channel
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(1000).toString(),
      'High Importance Notifications',
      importance: Importance.max,
    );

    //Setting up Android Notification Details
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    //Setting up Notification Details
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
        Random.secure().nextInt(1000),
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    });
  }

//Handling notification data and writing logic for navigation
  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'message') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NavigatedScreen(),
        ),
      );
    } else {
      debugPrint("Navigate to app!!");
    }
  }

  //Handling navigation while the app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    //When app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        debugPrint("When the app is in the background");
        handleMessage(context, message);
      },
    );

    //When app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("When the app is in terminated!!");
      if (!audioAlreadyPlayed) {
        //Playing the audio file when a notification occurs and when the app is in the terminated state
        playAudioFile();
        audioAlreadyPlayed = true;
      }
      handleMessage(context, initialMessage);
    }
  }

  void playAudioFile() async {
    const audioDuration = Duration(seconds: 10);
    await player.play(
      AssetSource('Minions-Mission-Impossible.mp3'),
    );
    await Future.delayed(audioDuration);
    await player.stop();
  }
}
