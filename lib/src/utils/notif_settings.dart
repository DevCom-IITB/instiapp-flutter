import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:InstiApp/src/api/model/rich_notification.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jaguar/utils/string/string.dart';
import 'package:path_provider/path_provider.dart';

List<NotificationChannel> notifChannels = [
  NotificationChannel(
    channelKey: 'basic_channel',
    channelName: 'Basic notifications',
    channelDescription: 'Notification channel for basic tests',
    defaultColor: Color(0xFF9D50DD),
    ledColor: Colors.white,
    importance: NotificationImportance.High,
  ),
];

void setupNotifications1(BuildContext context, InstiAppBloc bloc,
    GlobalKey<NavigatorState> _navigatorKey) async {
  print("Setting up notifs");

  AwesomeNotifications().isNotificationAllowed().then(
    (isAllowed) {
      if (!isAllowed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Allow Notifications'),
            content: Text('Our app would like to send you notifications'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Don\'t Allow',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () => AwesomeNotifications()
                    .requestPermissionToSendNotifications()
                    .then((_) => Navigator.pop(context)),
                child: Text(
                  'Allow',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    },
  );

  FirebaseMessaging.onMessage.listen(sendMessage);

  String navigateFromNotification(dynamic fromMap) {
    // Navigating to correct page
    return {
          "blogentry":
              fromMap.notificationExtra?.contains("/internship") ?? false
                  ? "/trainblog"
                  : "/placeblog",
          "body": "/body/${fromMap.notificationObjectID ?? ""}",
          "event": "/event/${fromMap.notificationObjectID ?? ""}",
          "userprofile": "/user/${fromMap.notificationObjectID ?? ""}",
          "newsentry": "/news",
          "complaintcomment":
              "/complaint/${fromMap.notificationExtra ?? ""}?reload=true",
          "unresolvedquery": "/query",
        }[fromMap.notificationType] ??
        "/";
  }

  void _handleNotification(ReceivedAction notification) {
    if (notification.channelKey == 'basic_channel' && Platform.isIOS) {
      AwesomeNotifications().getGlobalBadgeCounter().then(
            (value) => AwesomeNotifications().setGlobalBadgeCounter(value - 1),
          );
    }
    log("Entered handle notif");
    if (notification.payload != null) {
      // Getting notification payload
      RichNotification notif = RichNotification.fromJson(notification.payload!);

      // Getting route depending on payload
      String routeName = navigateFromNotification(notif);
      log(routeName);

      // Navigate to Route
      _navigatorKey.currentState?.pushNamed(routeName);

      // marking the notification as read
      bloc.clearNotificationUsingID(notif.notificationID!);
    }
  }

  AwesomeNotifications().actionStream.listen(_handleNotification);

  // Get any messages which caused the application to open from
  // a terminated state.
  RemoteMessage? initialMessage =
      await bloc.firebaseMessaging.getInitialMessage();

  // If the message also contains a data property with a "type" of "chat",
  // navigate to a chat screen
  if (initialMessage != null) {
    log("Handing message");
  }

  // Called when app is open in background and message is opened
  FirebaseMessaging.onMessageOpenedApp.listen((msg) {
    log("Handle msg");
  });
}

Future<void> sendMessage(RemoteMessage message) async {
  log("onMessage: $message");
  // var appDocDir = await getApplicationDocumentsDirectory();

  // String payload = jsonEncode(message.data);

  RichNotification notif = RichNotification.fromJson(message.data);

  createNotification(notif);
}

Future<void> createNotification(RichNotification notif) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: stringToInt(notif.notificationID ?? "") ??
          (DateTime.now().millisecondsSinceEpoch % 10000000),
      channelKey: 'basic_channel',
      title:
          // '${Emojis.money_money_bag + Emojis.plant_cactus} Buy Plant Food!!!',
          notif.notificationTitle,
      body: notif.notificationVerb,
      payload: {
        "extra": notif.notificationExtra ?? "",
        "id": notif.notificationObjectID ?? "",
        "type": notif.notificationType ?? "",
        "notification_id": notif.notificationID ?? "",
      },
      // locked: true,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'AddCal',
        label: 'Add to Calendar',
      )
    ],
    // actionButtons: getActionButtons(notif),
  );
}

List<NotificationActionButton>? getActionButtons(RichNotification notif) {
  switch (notif.notificationType) {
    case "event":
      return [
        NotificationActionButton(
          key: 'AddCal',
          label: 'Add to Calendar',
        )
      ];
    default:
      return [
        NotificationActionButton(
          key: 'AddCal',
          label: 'Add to Calendar',
        )
      ];
  }
}

void disposeNotification() {
  // AwesomeNotifications().actionSink.close();
}
