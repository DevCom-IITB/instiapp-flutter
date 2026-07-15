import 'package:InstiApp/main.dart';
import 'package:InstiApp/src/api/model/rich_notification.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
  NotificationChannel(
    channelGroupKey: NotificationGroups.COMMUNITY,
    channelKey: NotificationChannels.COMMUNITY,
    channelName: 'Community',
    channelDescription: 'Community notifications from InstiApp',
    defaultColor: Color(0xFF9D50DD),
    ledColor: Colors.blue,
    importance: NotificationImportance.Max,
  ),
  NotificationChannel(
    channelGroupKey: NotificationGroups.COMMUNITY,
    channelKey: NotificationChannels.COMMUNITYPOST,
    channelName: 'Community Post',
    channelDescription: 'Communitypost notifications from InstiApp',
    defaultColor: Color(0xFF9D50DD),
    ledColor: Colors.blue,
    importance: NotificationImportance.Max,
  ),
  NotificationChannel(
    channelGroupKey: NotificationGroups.COMMUNITY,
    channelKey: NotificationChannels.COMMUNITYPOSTUSERREACTION,
    channelName: 'Community Post Reaction',
    channelDescription: 'Communitypostuserreaction notifications from InstiApp',
    defaultColor: Color(0xFF9D50DD),
    ledColor: Colors.blue,
    importance: NotificationImportance.Max,
  ),
];

/// List of channel groups used in the app
List<NotificationChannelGroup> notifGroups = [
  NotificationChannelGroup(
    channelGroupKey: NotificationGroups.MISCELLANEOUS_GROUP,
    channelGroupName: 'Miscellaneous',
  ),
  NotificationChannelGroup(
    channelGroupKey: NotificationGroups.BLOG,
    channelGroupName: 'Blogs',
  ),
  NotificationChannelGroup(
    channelGroupKey: NotificationGroups.NEWS,
    channelGroupName: 'News',
  ),
  NotificationChannelGroup(
    channelGroupKey: NotificationGroups.COMMUNITY,
    channelGroupName: 'Community',
  ),
  NotificationChannelGroup(
    channelGroupKey: NotificationGroups.EVENT,
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
  static const String COMMUNITY = "community_channel";
  static const String COMMUNITYPOST = "communitypost_channel";
  static const String COMMUNITYPOSTUSERREACTION =
      "communitypostuserreaction_channel";
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
  static const String COMMUNITY = "community_group";
}

/// Type of notification to handle
class NotificationType {
  static const String BLOG = "blogentry";
  static const String PLACEMENT = "placement";
  static const String INTERNSHIP = "internship";
  static const String COMMUNITY = "community";
  static const String COMMUNITYPOST = "communitypost";
  static const String COMMUNITYPOSTUSERREACTION = "communitypostuserreaction";
  static const String BODY = "body";
  static const String EVENT = "event";
  static const String USER = "userprofile";
  static const String NEWS = "newsentry";
  static const String COMPLAINTS = "complaintcomment";
  static const String QUERY = "unresolvedquery";
  static const String EXTERNAL = "externalblogentry";
}

/// Whether the app has navigated past the login/splash flow, so that
/// notification taps can be routed immediately. Before that, routes are
/// parked in [_pendingNotificationRoute] and consumed by the homepage once
/// the app is ready (see [consumePendingNotificationRoute]).
bool notificationNavigationReady = false;
String? _pendingNotificationRoute;

/// Route a notification tap to the right page.
///
/// Safe to call at any point of the app lifecycle: if the navigator is not
/// ready yet (cold start from a notification tap), the route is stored and
/// executed once the homepage is up.
void handleNotificationNavigation(RichNotification notif) {
  final String route = routeFromNotification(notif);
  final NavigatorState? nav = navigatorKey.currentState;
  debugPrint("NOTIF: resolve type=${notif.notificationType} id=${notif.notificationObjectID} -> $route "
      "(ready=$notificationNavigationReady, nav=${nav != null})");
  if (notificationNavigationReady && nav != null) {
    nav.pushNamed(route);
  } else {
    _pendingNotificationRoute = route;
  }
}

/// Called by the homepage once the app is fully up. Navigates to the route
/// of the notification that launched the app, if any.
void consumePendingNotificationRoute() {
  final String? route = _pendingNotificationRoute;
  _pendingNotificationRoute = null;
  if (route != null) {
    debugPrint("NOTIF: consuming pending route $route");
    navigatorKey.currentState?.pushNamed(route);
  }
}

/// True on Android (the only platform where notifications are displayed
/// locally through AwesomeNotifications; see [attachNotificationListeners])
bool get _useAwesomeNotifications =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint(
        "NOTIF: onActionReceived button=${receivedAction.buttonKeyPressed} payload=${receivedAction.payload}");
    if (receivedAction.payload == null) return;

    RichNotification notif =
        RichNotification.fromJson(receivedAction.payload!);
    String actionKey = receivedAction.buttonKeyPressed;

    // Handle "Open Browser" action
    if (actionKey == ActionKeys.OPEN_BROWSER &&
        notif.notificationExtra != null) {
      Uri uri = Uri.parse(notif.notificationExtra!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    handleNotificationNavigation(notif);
  }
}

/// Gives the route to navigate to from a notification
///
/// Every route returned from here MUST exist in the route table of
/// [main.dart]'s onGenerateRoute — unknown routes fall back to the login
/// page there, which looks like a broken/blank screen to the user.
/// Types whose dedicated pages are not wired up route to /notifications.
String routeFromNotification(RichNotification fromMap) {
  final String objectID = fromMap.notificationObjectID ?? "";

  // Navigating to correct page
  return {
        NotificationType.BLOG:
            fromMap.notificationExtra?.contains("/internship") ?? false
                ? "/trainblog"
                : "/placeblog",
        NotificationType.PLACEMENT: "/placeblog",
        NotificationType.COMMUNITY:
            objectID.isNotEmpty ? "/group/$objectID" : "/groups",
        NotificationType.COMMUNITYPOST:
            objectID.isNotEmpty ? "/communitypost/$objectID" : "/groups",
        NotificationType.COMMUNITYPOSTUSERREACTION: "/groups",
        NotificationType.INTERNSHIP: "/trainblog",
        NotificationType.BODY:
            objectID.isNotEmpty ? "/body/$objectID" : "/feed",
        NotificationType.EVENT:
            objectID.isNotEmpty ? "/event/$objectID" : "/feed",
        NotificationType.USER:
            objectID.isNotEmpty ? "/user/$objectID" : "/feed",
        NotificationType.NEWS: "/notifications",
        NotificationType.COMPLAINTS: "/notifications",
        NotificationType.QUERY: "/notifications",
        NotificationType.EXTERNAL: "/notifications",
      }[fromMap.notificationType] ??
      "/notifications";
}

/// Setup notifications with awesome notifications
///
/// [context] is the [BuildContext] of the app
/// [bloc] is the instance of [InstiAppBloc] used in the app
/// [_navigatorKey] is the [GlobalKey] of the [Navigator] used in the app
bool _notificationListenersAttached = false;

/// Attach all notification listeners. Idempotent; safe to call from main()
/// and again from the UI once a context is available.
///
/// The backend sends two kinds of pushes (see instiapp-api helpers/fcm.py):
///  - data-only messages (Android/"rich" devices): our code builds the
///    notification via AwesomeNotifications, so taps arrive through
///    [NotificationController.onActionReceivedMethod].
///  - notification messages (iOS): the OS displays them natively, so taps
///    arrive through [FirebaseMessaging.onMessageOpenedApp] (background) or
///    [FirebaseMessaging.instance.getInitialMessage] (terminated). These two
///    were previously no-ops, which made every iOS notification tap dead.
void attachNotificationListeners() {
  if (_notificationListenersAttached) return;
  _notificationListenersAttached = true;

  if (!_useAwesomeNotifications) {
    /// iOS: the backend always sends notification-type messages, which the
    /// OS displays. Let it also display them in foreground so iOS has
    /// exactly one display pipeline (no local duplicates).
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Foreground messages
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) async {
      debugPrint("NOTIF: onMessage (foreground) data=${message.data}");
      // iOS already presents messages with a notification block natively
      // (see setForegroundNotificationPresentationOptions above); creating
      // a local copy would show the same notification twice
      if (!_useAwesomeNotifications && message.notification != null) return;
      await sendMessage(message);
    },
    onError: (error, stackTrace) {},
  );

  /// Background: user tapped an OS-displayed notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint("NOTIF: onMessageOpenedApp tap data=${message.data}");
    handleNotificationNavigation(richNotificationFromRemoteMessage(message));
  });

  /// Terminated: app was launched by tapping an OS-displayed notification
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      debugPrint("NOTIF: getInitialMessage launch tap data=${message.data}");
      handleNotificationNavigation(richNotificationFromRemoteMessage(message));
    }
  });

  /// Android only. AwesomeNotifications must NOT attach on iOS: it takes
  /// over the iOS notification-center delegate and swallows taps on
  /// FCM-displayed notifications, so onMessageOpenedApp never fires and
  /// tapped notifications just open the homescreen.
  if (_useAwesomeNotifications) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );

    /// Terminated: app was launched by tapping an AwesomeNotifications
    /// notification (the Android data-message path)
    AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true)
        .then((action) {
      if (action != null) {
        debugPrint(
            "NOTIF: initial AwesomeNotifications action payload=${action.payload}");
        NotificationController.onActionReceivedMethod(action);
      }
    });
  }
}

void setupNotifications(BuildContext context, InstiAppBloc bloc) async {
  // Check for permission (if not granted, request it).
  // The AwesomeNotifications permission dialog is Android-only; on iOS the
  // system permission is requested through FirebaseMessaging in main().
  if (_useAwesomeNotifications &&
      await bloc.hasNotificationPermission() == null)
    requestNotificationPermission(context, bloc);

  attachNotificationListeners();
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

/// Build a [RichNotification] from a firebase [RemoteMessage],
/// merging the data payload with the notification block (if any)
RichNotification richNotificationFromRemoteMessage(RemoteMessage message) {
  final payload = Map<String, dynamic>.from(message.data);
  final notification = message.notification;

  if (notification != null) {
    payload.putIfAbsent("title", () => notification.title ?? "");
    payload.putIfAbsent("verb", () => notification.body ?? "");
    payload.putIfAbsent("large_content", () => notification.body ?? "");

    final imageUrl = notification.android?.imageUrl ??
        notification.apple?.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      payload.putIfAbsent("image_url", () => imageUrl);
    }
  }

  RichNotification notif = RichNotification.fromJson(payload);

  if ((notif.notificationTitle == null || notif.notificationTitle!.isEmpty) &&
      notification?.title != null) {
    notif.notificationTitle = notification!.title;
  }
  if ((notif.notificationVerb == null || notif.notificationVerb!.isEmpty) &&
      notification?.body != null) {
    notif.notificationVerb = notification!.body;
  }

  // change notification type for blogs.
  if (notif.notificationType == NotificationType.BLOG) {
    if (notif.notificationExtra?.contains("/internship") ?? false) {
      notif.notificationType = NotificationType.INTERNSHIP;
    } else {
      notif.notificationType = NotificationType.PLACEMENT;
    }
  }

  return notif;
}

/// Send a notification to the user
///
/// [message] is the message recieved from firebase
Future<void> sendMessage(RemoteMessage message) async {
  // Create the actual notification
  await createNotification(richNotificationFromRemoteMessage(message));
}

/// Create a notification
Future<void> createNotification(RichNotification notif) async {
  // Local notifications are only used on Android (see
  // attachNotificationListeners); AwesomeNotifications is not initialized
  // on other platforms
  if (!_useAwesomeNotifications) return;

  await AwesomeNotifications().createNotification(
    content: getNotificationContent(notif),
    actionButtons: getActionButtons(notif),
  );
}

/// Get the content of the notification
NotificationContent getNotificationContent(RichNotification notif) {
  // Modulo by the max 32-bit integer (2,147,483,647) to ensure it fits
  int id = (stringToInt(notif.notificationID ?? "") ??
          DateTime.now().millisecondsSinceEpoch) %
      2147483647;

  /// Get the channel name to which the notification should be sent
  String getChannelKey(RichNotification notif) {
    switch (notif.notificationType) {
      case NotificationType.PLACEMENT:
        return NotificationChannels.PLACEMENT;
      case NotificationType.INTERNSHIP:
        return NotificationChannels.INTERNSHIP;
      case NotificationType.COMMUNITY:
        return NotificationChannels.COMMUNITY;
      case NotificationType.COMMUNITYPOST:
        return NotificationChannels.COMMUNITYPOST;
      case NotificationType.COMMUNITYPOSTUSERREACTION:
        return NotificationChannels.COMMUNITYPOSTUSERREACTION;
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
  // AwesomeNotifications().actionSink.close();
}
