import 'package:InstiApp/src/api/model/rich_notification.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jaguar/utils/string/string.dart';
import 'package:url_launcher/url_launcher.dart';

/// Arguments to route from notification screen.
/// Typically used with notification buttons
///
/// [key] is the one among [ActionKeys]
/// [notif] is the notification object
class NotificationRouteArguments {
  /// Action key used to detect the argument
  String key;

  /// Notification object
  RichNotification notif;

  NotificationRouteArguments(this.key, this.notif);
}

/// List of notification channels used in the app
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
    channelGroupKey: NotificationGroups.BLOG,
    channelKey: NotificationChannels.EXTERNAL,
    channelName: 'External blog',
    channelDescription: 'External blog notifications from InstiApp',
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

/// List of channel groups used in the app
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

/// Action keys for notification actions
class ActionKeys {
  static const String ADD_TO_CALENDAR = "ADD_TO_CALENDAR";
  static const String LIKE_REACT = "LIKE_REACT";
  static const String OPEN_BROWSER = "OPEN_BROWSER";
  static const String CHECKOUT = "CHECKOUT";
}

/// Channels used in the app
class NotificationChannels {
  static const String MISCELLANEOUS_CHANNEL = "misc_channel";
  static const String PLACEMENT = "placement_channel";
  static const String INTERNSHIP = "internship_channel";
  static const String EXTERNAL = "external_channel";
  static const String NEWS = "news_channel";
  static const String EVENT = "events_channel";
}

/// Channel groups used in the app
class NotificationGroups {
  static const String MISCELLANEOUS_GROUP = "misc_group";
  static const String BLOG = "blog_group";
  static const String NEWS = "news_group";
  static const String EVENT = "events_group";
}

/// Type of notification to handle
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
  static const String EXTERNAL = "externalblogentry";
}

/// Setup notifications with awesome notifications
///
/// [context] is the [BuildContext] of the app
/// [bloc] is the instance of [InstiAppBloc] used in the app
/// [_navigatorKey] is the [GlobalKey] of the [Navigator] used in the app
void setupNotifications(BuildContext context, InstiAppBloc bloc) async {
  // Check for permission (if not granted, request it)
  if (await bloc.hasNotificationPermission() == null)
    requestNotificationPermission(context, bloc);

  /// Listen for incoming notifs and send a notification to the user
  FirebaseMessaging.onMessage.listen(sendMessage);

  /// Gives the route to navigate to from a notification
  String routeFromNotification(RichNotification fromMap) {
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
          NotificationType.EXTERNAL: "/externalblog",
        }[fromMap.notificationType] ??
        "/";
  }

  /// Handle what action to take depending on key
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

  /// Handle notification on press
  void _handleNotification(ReceivedAction notification) {
    if (notification.payload != null) {
      // Getting notification payload
      RichNotification notif = RichNotification.fromJson(notification.payload!);

      // Getting route depending on payload
      String routeName = routeFromNotification(notif);
      print(routeName);
      // Get action button key if any
      String actionKey = notification.buttonKeyPressed;

      // Navigate to Route
      Navigator.of(context).pushReplacementNamed(routeName,
          arguments: NotificationRouteArguments(actionKey, notif));

      // marking the notification as read
      bloc.clearNotificationUsingID(notif.notificationID!);

      // Handling action key
      _handleActionKey(actionKey, notif);
    }
  }

  // Listen to app opens from notifications
  AwesomeNotifications().actionStream.listen(_handleNotification);
}

void requestNotificationPermission(
    BuildContext context, InstiAppBloc bloc) async {
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
                  bloc.updateNotificationPermission(false);
                },
                child: Text(
                  'Don\'t Allow',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () => AwesomeNotifications()
                    .requestPermissionToSendNotifications()
                    .then(
                  (bool permitted) {
                    Navigator.pop(context);
                    bloc.updateNotificationPermission(permitted);
                  },
                ),
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
}

/// Send a notification to the user
///
/// [message] is the message recieved from firebase
Future<void> sendMessage(RemoteMessage message) async {
  print("Message received: ${message.data}");
  // Get notif from message data
  RichNotification notif = RichNotification.fromJson(message.data);

  // change notification type for blogs.
  if (notif.notificationType == NotificationType.BLOG) {
    if (notif.notificationExtra?.contains("/internship") ?? false) {
      notif.notificationType = NotificationType.INTERNSHIP;
    } else {
      notif.notificationType = NotificationType.PLACEMENT;
    }
  }

  // Create the actual notification
  createNotification(notif);
}

/// Create a notification
Future<void> createNotification(RichNotification notif) async {
  await AwesomeNotifications().createNotification(
    content: getNotificationContent(notif),
    actionButtons: getActionButtons(notif),
  );
}

/// Get the content of the notification
NotificationContent getNotificationContent(RichNotification notif) {
  int id = stringToInt(notif.notificationID ?? "") ??
      (DateTime.now().millisecondsSinceEpoch);

  /// Get the channel name to which the notification should be sent
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
      case NotificationType.EXTERNAL:
        return NotificationChannels.EXTERNAL;
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

/// Get the action buttons of the notification
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

/// Remember to dispose the notification sink when app is closed
void disposeNotification() {
  AwesomeNotifications().actionSink.close();
}
