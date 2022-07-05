import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:InstiApp/src/api/model/rich_notification.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jaguar/utils/string/string.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationRouteArguments {
  String key;
  RichNotification notif;

  NotificationRouteArguments(this.key, this.notif);
}

List<NotificationChannel> notifChannels = [
  NotificationChannel(
    channelGroupKey: NotificationGroups.MISCELLANEOUS_GROUP,
    channelKey: NotificationChannels.MISCELLANEOUS_CHANNEL,
    channelName: 'Miscellaneous',
    channelDescription: 'Miscellaneous notifications from InstiApp',
    defaultColor: Color(0xFF9D50DD),
    ledColor: Colors.blue,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: NotificationGroups.BLOG,
    channelKey: NotificationChannels.PLACEMENT,
    channelName: 'Placement blog',
    channelDescription: 'Placement blog notifications from InstiApp',
    defaultColor: Color(0xFF9D50DD),
    ledColor: Colors.blue,
    importance: NotificationImportance.Max,
  ),
  NotificationChannel(
    channelGroupKey: NotificationGroups.BLOG,
    channelKey: NotificationChannels.INTERNSHIP,
    channelName: 'Internship blog',
    channelDescription: 'Internship blog notifications from InstiApp',
    defaultColor: Color(0xFF9D50DD),
    ledColor: Colors.blue,
    importance: NotificationImportance.Max,
  ),
  NotificationChannel(
    channelGroupKey: NotificationGroups.NEWS,
    channelKey: NotificationChannels.NEWS,
    channelName: 'News',
    channelDescription: 'News notifications from InstiApp',
    defaultColor: Color(0xFF9D50DD),
    ledColor: Colors.blue,
    importance: NotificationImportance.Max,
  ),
  NotificationChannel(
    channelGroupKey: NotificationGroups.EVENT,
    channelKey: NotificationChannels.EVENT,
    channelName: 'Events',
    channelDescription: 'Event notifications from InstiApp',
    defaultColor: Color(0xFF9D50DD),
    ledColor: Colors.blue,
    importance: NotificationImportance.Max,
  ),
];

List<NotificationChannelGroup> notifGroups = [
  NotificationChannelGroup(
    channelGroupkey: NotificationGroups.MISCELLANEOUS_GROUP,
    channelGroupName: 'Miscellaneous',
  ),
  NotificationChannelGroup(
    channelGroupkey: NotificationGroups.BLOG,
    channelGroupName: 'Blogs',
  ),
  NotificationChannelGroup(
    channelGroupkey: NotificationGroups.NEWS,
    channelGroupName: 'News',
  ),
  NotificationChannelGroup(
    channelGroupkey: NotificationGroups.EVENT,
    channelGroupName: 'Events',
  ),
];

class NotifSettings {
  static InstiAppBloc? bloc;
}

class ActionKeys {
  static const String ADD_TO_CALENDAR = "ADD_TO_CALENDAR";
  static const String LIKE_REACT = "LIKE_REACT";
  static const String OPEN_BROWSER = "OPEN_BROWSER";
  static const String CHECKOUT = "CHECKOUT";
}

class NotificationChannels {
  static const String MISCELLANEOUS_CHANNEL = "misc_channel";
  static const String PLACEMENT = "placement_channel";
  static const String INTERNSHIP = "internship_channel";
  static const String NEWS = "news_channel";
  static const String EVENT = "events_channel";
}

class NotificationGroups {
  static const String MISCELLANEOUS_GROUP = "misc_group";
  static const String BLOG = "blog_group";
  static const String NEWS = "news_group";
  static const String EVENT = "events_group";
}

class NotificationType {
  static const String BLOG = "blogentry";
  static const String PLACEMENT = "placement";
  static const String INTERNSHIP = "internship";
  static const String BODY = "body";
  static const String EVENT = "event";
  static const String USER = "userprofile";
  static const String NEWS = "newsentry";
  static const String COMPLAINTS = "complaintcomment";
  static const String QUERY = "unresolvedquery";
}

void setupNotifications1(BuildContext context, InstiAppBloc bloc,
    GlobalKey<NavigatorState> _navigatorKey) async {
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

  String navigateFromNotification(RichNotification fromMap) {
    // Navigating to correct page
    return {
          NotificationType.BLOG:
              fromMap.notificationExtra?.contains("/internship") ?? false
                  ? "/trainblog"
                  : "/placeblog",
          NotificationType.PLACEMENT: "/placeblog",
          NotificationType.INTERNSHIP: "/trainblog",
          NotificationType.BODY: "/body/${fromMap.notificationObjectID ?? ""}",
          NotificationType.EVENT:
              "/event/${fromMap.notificationObjectID ?? ""}",
          NotificationType.USER: "/user/${fromMap.notificationObjectID ?? ""}",
          NotificationType.NEWS: "/news",
          NotificationType.COMPLAINTS:
              "/complaint/${fromMap.notificationExtra ?? ""}?reload=true",
          NotificationType.QUERY: "/query",
        }[fromMap.notificationType] ??
        "/";
  }

  void _handleActionKey(String actionKey, RichNotification notif) async {
    // Open browser
    if (actionKey == ActionKeys.OPEN_BROWSER) {
      if (notif.notificationExtra != null) {
        Uri uri = Uri.parse(notif.notificationExtra!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      }
    }
  }

  void _handleNotification(ReceivedAction notification) {
    if (Platform.isIOS) {
      AwesomeNotifications().getGlobalBadgeCounter().then(
            (value) => AwesomeNotifications().setGlobalBadgeCounter(value - 1),
          );
    }

    if (notification.payload != null) {
      // Getting notification payload
      RichNotification notif = RichNotification.fromJson(notification.payload!);

      // Getting route depending on payload
      String routeName = navigateFromNotification(notif);

      // Get action button key if any
      String actionKey = notification.buttonKeyPressed;

      // Navigate to Route
      _navigatorKey.currentState?.pushReplacementNamed(routeName,
          arguments: NotificationRouteArguments(actionKey, notif));

      // marking the notification as read
      bloc.clearNotificationUsingID(notif.notificationID!);

      _handleActionKey(actionKey, notif);
    }
  }

  AwesomeNotifications().actionStream.listen(_handleNotification);
}

Future<void> sendMessage(RemoteMessage message) async {
  RichNotification notif = RichNotification.fromJson(message.data);

  // change notification type for blogs.
  if (notif.notificationType == NotificationType.BLOG) {
    if (notif.notificationExtra?.contains("/internship") ?? false) {
      notif.notificationType = NotificationType.INTERNSHIP;
    } else {
      notif.notificationType = NotificationType.PLACEMENT;
    }
  }

  createNotification(notif);
}

Future<void> createNotification(RichNotification notif) async {
  await AwesomeNotifications().createNotification(
    content: getNotificationContent(notif),
    actionButtons: getActionButtons(notif),
  );
}

NotificationContent getNotificationContent(RichNotification notif) {
  int id = stringToInt(notif.notificationID ?? "") ??
      (DateTime.now().millisecondsSinceEpoch);

  String getChannelKey(RichNotification notif) {
    switch (notif.notificationType) {
      case NotificationType.PLACEMENT:
        return NotificationChannels.PLACEMENT;
      case NotificationType.INTERNSHIP:
        return NotificationChannels.INTERNSHIP;
      case NotificationType.NEWS:
        return NotificationChannels.NEWS;
      case NotificationType.EVENT:
        return NotificationChannels.EVENT;
      default:
        return NotificationChannels.MISCELLANEOUS_CHANNEL;
    }
  }

  return NotificationContent(
    id: id,
    channelKey: getChannelKey(notif),
    title: notif.notificationTitle ?? "New notification from InstiApp!",
    body: notif.notificationVerb,
    bigPicture: notif.notificationImage,
    largeIcon: notif.notificationImage,
    hideLargeIconOnExpand: true,
    color: Colors.blue,
    payload: {
      "extra": notif.notificationExtra ?? "",
      "id": notif.notificationObjectID ?? "",
      "type": notif.notificationType ?? "",
      "notification_id": notif.notificationID ?? "",
    },
    backgroundColor: Colors.blue,
    notificationLayout: notif.notificationImage != null
        ? NotificationLayout.BigPicture
        : NotificationLayout.Default,
  );
}

List<NotificationActionButton>? getActionButtons(RichNotification notif) {
  switch (notif.notificationType) {
    case NotificationType.EVENT:
      return [
        NotificationActionButton(
          key: ActionKeys.CHECKOUT,
          label: 'Check it out',
        ),
        NotificationActionButton(
          key: ActionKeys.ADD_TO_CALENDAR,
          label: 'Add to Calendar',
        ),
      ];
    case NotificationType.NEWS:
      return [
        NotificationActionButton(
          key: ActionKeys.OPEN_BROWSER,
          label: 'Check it out',
        ),
        NotificationActionButton(
          key: ActionKeys.LIKE_REACT,
          label: 'Like/React',
        ),
      ];
    default:
      return null;
  }
}

void disposeNotification() {
  AwesomeNotifications().actionSink.close();
}
