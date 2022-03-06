import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../util.dart';

Stream<String>? _tokenStream;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
  //await Firebase.initializeApp();
}

void setToken(String? token) {
  if (token == null)
    return;
  dprint('FCM Token: $token');
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null)
    FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
      "FCB": token,
    }, SetOptions(merge:true)).then((value2) {});
}

firebaseInitApp(BuildContext context) async {
  dprint("firebaseInitApp");
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null && message.notification != null) {
      dprint("FCB message _notifyCallback=;_notifyCallback ${message.from}");
      if (message.data['chat'] != null){
        if (message.data['chat'] == "true") {
          if (_chatCallback != null)
            _chatCallback!();
          return;
        }
      }
      if (_notifyCallback != null)
        _notifyCallback!(message);
      }
    }
  );
}

firebaseGetToken(BuildContext context) async {
  print ("Firebase messaging: _getToken");

  // iOS
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Create an Android Notification Channel.
  //
  // We use this channel in the `AndroidManifest.xml` file to override the
  // default FCM channel to enable heads up notifications.
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //     AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  // Update the iOS foreground notification presentation options to allow
  // heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  setToken(await FirebaseMessaging.instance.getToken());
  _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
  _tokenStream!.listen(setToken);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification == null)
      return;
    if (_lastMessageId != null)
      if (_lastMessageId == message.messageId)
        return;
    _lastMessageId = message.messageId;
    print("FirebaseMessaging.onMessageOpenedApp $message ${message.from}");
    if (message.data['chat'] != null){
      if (message.data['chat'] == "true") {
        if (_chatCallback != null)
          _chatCallback!();
        return;
      }
    }
    if (_notifyCallback != null)
      _notifyCallback!(message);

  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("FirebaseMessaging.onMessage ${message.messageId}" );
    print("${message.data['chat']}" );
    if (_lastMessageId != null)
      if (_lastMessageId == message.messageId)
        return;
    _lastMessageId = message.messageId;
    if (message.data['chat'] != null){
      if (message.data['chat'] == "true") {
        if (_chatCallback != null)
          _chatCallback!();
        return;
      }
    }
    if (_notifyCallback != null)
      _notifyCallback!(message);
  });
}

String? _lastMessageId;

Function(RemoteMessage message)? _notifyCallback;

setNotifyCallback(Function(RemoteMessage message) notifyCallback){
  _notifyCallback = notifyCallback;
}

Function()? _chatCallback;

setChatCallback(Function() chatCallback){
  _chatCallback = chatCallback;
}
