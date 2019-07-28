import 'dart:async';
import 'dart:io';

import 'package:InstiApp/src/api/model/rich_notification.dart';
import 'package:InstiApp/src/routes/aboutpage.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/routes/calendarpage.dart';
import 'package:InstiApp/src/routes/complaintpage.dart';
import 'package:InstiApp/src/routes/complaintspage.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/routes/explorepage.dart';
import 'package:InstiApp/src/routes/feedpage.dart';
import 'package:InstiApp/src/routes/mappage.dart';
import 'package:InstiApp/src/routes/newcomplaintpage.dart';
import 'package:InstiApp/src/routes/newspage.dart';
import 'package:InstiApp/src/routes/notificationspage.dart';
import 'package:InstiApp/src/routes/putentitypage.dart';
import 'package:InstiApp/src/routes/quicklinkspage.dart';
import 'package:InstiApp/src/routes/settingspage.dart';
import 'package:InstiApp/src/routes/testpage.dart';
import 'package:InstiApp/src/routes/trainingblogpage.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/app_brightness.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:InstiApp/src/routes/messpage.dart';
import 'package:InstiApp/src/routes/loginpage.dart';
import 'package:InstiApp/src/routes/placementblogpage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';

class MyAndroidApp extends StatefulWidget {
  final Key key;
  final InstiAppBloc bloc;

  MyAndroidApp({this.key, @required this.bloc}) : super(key: key);

  // This widget is the root of your application.
  @override
  MyAndroidAppState createState() {
    return new MyAndroidAppState();
  }
}

class MyAndroidAppState extends State<MyAndroidApp>  with WidgetsBindingObserver {
  // Notifications plugin to show rich notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription _appLinksSub;

  void setTheme(VoidCallback a) {
    setState(a);
  }

  @override
  void initState() {
    super.initState();
    setupNotifications();
    initAppLinksState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() async {
    _appLinksSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.suspending) {
      widget?.bloc?.saveToCache();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: widget.bloc.primaryColor,
      systemNavigationBarIconBrightness: Brightness.values[1 -
          ThemeData.estimateBrightnessForColor(widget.bloc.primaryColor).index],
      statusBarColor: widget.bloc.brightness
          .toColor(), //or set color with: Color(0xFF0000FF)
      statusBarIconBrightness:
          Brightness.values[1 - widget.bloc.brightness.toBrightness().index],
      statusBarBrightness:
          Brightness.values[widget.bloc.brightness.toBrightness().index],
    ));

    return BlocProvider(
      widget.bloc,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'InstiApp',
        theme: ThemeData(
          // fontFamily: "SourceSansPro",
          fontFamily: "IBMPlexSans",

          primaryColor: widget.bloc.primaryColor,
          accentColor: widget.bloc.accentColor,
          primarySwatch: Colors.primaries.singleWhere(
              (c) => c.value == widget.bloc.accentColor.value,
              orElse: () => null),

          toggleableActiveColor: widget.bloc.accentColor,
          textSelectionHandleColor: widget.bloc.accentColor,

          canvasColor: widget.bloc.brightness.toColor(),

          bottomAppBarColor: widget.bloc.primaryColor,
          brightness: widget.bloc.brightness.toBrightness(),

          textTheme: TextTheme(
              display1: TextStyle(
                color: widget.bloc.brightness == AppBrightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              display2: TextStyle(
                color: widget.bloc.brightness == AppBrightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              display3: TextStyle(
                color: widget.bloc.brightness == AppBrightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              display4: TextStyle(
                color: widget.bloc.brightness == AppBrightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              headline: TextStyle()),
        ),
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name.startsWith("/event/")) {
            return _buildRoute(
                settings,
                EventPage(
                  eventFuture:
                      widget.bloc.getEvent(settings.name.split("/event/")[1]),
                ));
          } else if (settings.name.startsWith("/body/")) {
            return _buildRoute(
                settings,
                BodyPage(
                    bodyFuture:
                        widget.bloc.getBody(settings.name.split("/body/")[1])));
          } else if (settings.name.startsWith("/user/")) {
            return _buildRoute(
                settings,
                UserPage(
                    userFuture:
                        widget.bloc.getUser(settings.name.split("/user/")[1])));
          } else if (settings.name.startsWith("/complaint/")) {
            Uri uri = Uri.parse(settings.name);

            return _buildRoute(
                settings,
                ComplaintPage(
                    complaintFuture: widget.bloc.getComplaint(
                        uri.pathSegments[1],
                        reload: uri.queryParameters.containsKey("reload") &&
                            uri.queryParameters["reload"] == "true")));
          } else if (settings.name.startsWith("/putentity/event/")) {
            return _buildRoute(
                settings,
                PutEntityPage(
                    entityID: settings.name.split("/putentity/event/")[1],
                    cookie: widget.bloc.getSessionIdHeader()));
          } else if (settings.name.startsWith("/putentity/body/")) {
            return _buildRoute(
                settings,
                PutEntityPage(
                    isBody: true,
                    entityID: settings.name.split("/putentity/body/")[1],
                    cookie: widget.bloc.getSessionIdHeader()));
          } else {
            switch (settings.name) {
              case "/":
                return _buildRoute(settings, LoginPage(widget.bloc));
              case "/mess":
                return _buildRoute(settings, MessPage());
              case "/placeblog":
                return _buildRoute(settings, PlacementBlogPage());
              case "/trainblog":
                return _buildRoute(settings, TrainingBlogPage());
              case "/feed":
                return _buildRoute(settings, FeedPage());
              case "/quicklinks":
                return _buildRoute(settings, QuickLinksPage());
              case "/news":
                return _buildRoute(settings, NewsPage());
              case "/explore":
                return _buildRoute(settings, ExplorePage());
              case "/calendar":
                return _buildRoute(settings, CalendarPage());
              case "/complaints":
                return _buildRoute(settings, ComplaintsPage());
              case "/newcomplaint":
                return _buildRoute(settings, NewComplaintPage());
              case "/putentity/event":
                return _buildRoute(settings,
                    PutEntityPage(cookie: widget.bloc.getSessionIdHeader()));
              case "/map":
                // return _buildRoute(settings, NativeMapPage());
                return _buildRoute(settings, MapPage());
              case "/settings":
                return _buildRoute(settings, SettingsPage());
              case "/notifications":
                return _buildRoute(settings, NotificationsPage());
              case "/about":
                return _buildRoute(settings, AboutPage());
              case "/test":
                return _buildRoute(settings, TestPage());
            }
          }
          return _buildRoute(settings, MessPage());
        },
        navigatorObservers: [widget.bloc.navigatorObserver],
      ),
    );
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) => builder,
    );
  }

  // Section
  // Handling Notifications
  void setupNotifications() {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher_foreground');

    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    widget.bloc.firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        var appDocDir = await getApplicationDocumentsDirectory();

        String payload = jsonEncode(message["data"]);

        var notif = RichNotificationSerializer().fromMap(message["data"]);

        StyleInformation style;
        AndroidNotificationStyle styleType;

        if (notif.notificationImage != null) {
          var bigPictureResponse = await http.get(notif.notificationImage);
          var bigPicturePath =
              '${appDocDir.path}/bigPicture-${notif.notificationID}';
          var file = new File(bigPicturePath);
          await file.writeAsBytes(bigPictureResponse.bodyBytes);

          style = BigPictureStyleInformation(
            bigPicturePath,
            BitmapSource.FilePath,
            summaryText: notif.notificationLargeContent,
          );
          styleType = AndroidNotificationStyle.BigPicture;
        } else if (notif.notificationLargeContent != null) {
          style = BigTextStyleInformation(
            notif.notificationLargeContent,
          );
          styleType = AndroidNotificationStyle.BigText;
        } else {
          style = DefaultStyleInformation(false, false);
          styleType = AndroidNotificationStyle.Default;
        }

        String largeIconPath;
        BitmapSource largeIconSource;
        if (notif.notificationLargeIcon != null) {
          var largeIconResponse = await http.get(notif.notificationLargeIcon);
          largeIconPath = '${appDocDir.path}/largeIcon-${notif.notificationID}';
          var file = new File(largeIconPath);
          await file.writeAsBytes(largeIconResponse.bodyBytes);
        }

        var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          'Very Important',
          'Placement Blog Notifications',
          'All Placement Blog Notifications go here with high importance',
          importance: Importance.Max,
          priority: Priority.High,
          largeIcon: largeIconPath,
          largeIconBitmapSource: largeIconSource,
          style: styleType,
          styleInformation: style,
        );
        var iOSPlatformChannelSpecifics =
            new IOSNotificationDetails(presentAlert: true);
        var platformChannelSpecifics = new NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

        await flutterLocalNotificationsPlugin.show(
          0,
          notif.notificationTitle,
          notif.notificationVerb,
          platformChannelSpecifics,
          payload: payload,
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        navigateFromNotification(RichNotificationSerializer().fromMap(message));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        navigateFromNotification(RichNotificationSerializer().fromMap(message));
      },
    );
    widget.bloc.firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    widget.bloc.firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    widget.bloc.firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
    });
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    navigateFromNotification(
        RichNotificationSerializer().fromMap(jsonDecode(payload)));
  }

  Future navigateFromNotification(RichNotification fromMap) async {
    // Navigating to correct page
    var routeName = {
      "blogentry": fromMap.notificationExtra?.contains("/trainingblog") ?? false
          ? "/trainblog"
          : "/placeblog",
      "body": "/body/${fromMap.notificationObjectID ?? ""}",
      "event": "/event/${fromMap.notificationObjectID ?? ""}",
      "userprofile": "/user/${fromMap.notificationObjectID ?? ""}",
      "newsentry": "/news",
      "complaintcomment":
          "/complaint/${fromMap.notificationExtra ?? ""}?reload=true",
    }[fromMap.notificationType];

    _navigatorKey.currentState.pushNamed(routeName);

    // marking the notification as read
    widget.bloc.clearNotificationUsingID(fromMap.notificationID);
  }

  void handleAppLink(Uri uri) {
    if (uri == null) return;
    var routeName = {
      "user": "/user/${uri.pathSegments[1] ?? ""}",
      "event": "/event/${uri.pathSegments[1] ?? ""}",
      "map": "/map",
      "org": "/body/${uri.pathSegments[1] ?? ""}",
    }[uri.pathSegments[0]];
    _navigatorKey.currentState.pushNamed(routeName);
  }

  Future initAppLinksState() async {
    _appLinksSub = getUriLinksStream().listen((Uri uri) {
      if (!mounted) return;
      handleAppLink(uri);
    }, onError: (err) {
      if (!mounted) return;
      print('Failed to get latest link: $err.');
    });
    try {
      Uri initialUri = await getInitialUri();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      handleAppLink(initialUri);
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    } on FormatException {
      print('Bad parse the initial link as Uri.');
    }
  }
}
