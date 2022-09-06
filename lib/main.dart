import 'dart:async';
import 'dart:io';

import 'package:InstiApp/src/api/model/rich_notification.dart';
import 'package:InstiApp/src/routes/aboutpage.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/routes/calendarpage.dart';
import 'package:InstiApp/src/routes/event_form.dart';
// import 'package:InstiApp/src/routes/complaintpage.dart';
// import 'package:InstiApp/src/routes/complaintspage.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/routes/explorepage.dart';
import 'package:InstiApp/src/routes/externalblogpage.dart';
import 'package:InstiApp/src/routes/feedpage.dart';
import 'package:InstiApp/src/routes/mappage.dart';
import 'package:InstiApp/src/routes/messcalendarpage.dart';
// import 'package:InstiApp/src/routes/newcomplaintpage.dart';
import 'package:InstiApp/src/routes/newspage.dart';
import 'package:InstiApp/src/routes/notificationspage.dart';
import 'package:InstiApp/src/routes/putentitypage.dart';
import 'package:InstiApp/src/routes/qrpage.dart';
import 'package:InstiApp/src/routes/queryaddpage.dart';
import 'package:InstiApp/src/routes/querypage.dart';
import 'package:InstiApp/src/routes/quicklinkspage.dart';
import 'package:InstiApp/src/routes/settingspage.dart';
import 'package:InstiApp/src/routes/trainingblogpage.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/routes/achievement_form.dart';
import 'package:InstiApp/src/routes/your_achievements.dart';
import 'package:InstiApp/src/utils/app_brightness.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:InstiApp/src/routes/messpage.dart';
import 'package:InstiApp/src/routes/loginpage.dart';
import 'package:InstiApp/src/routes/alumniLoginPage.dart';
import 'package:InstiApp/src/routes/alumni_OTP_Page.dart';
import 'package:InstiApp/src/routes/placementblogpage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // print("Runnning main");
  GlobalKey<MyAppState> key = GlobalKey();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  InstiAppBloc bloc = InstiAppBloc(wholeAppKey: key);

  await bloc.restorePrefs();

  runApp(MyApp(
    key: key,
    bloc: bloc,
  ));
}

class MyApp extends StatefulWidget {
  final Key key;
  final InstiAppBloc bloc;

  MyApp({required this.key, required this.bloc}) : super(key: key);

  // This widget is the root of your application.
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Notifications plugin to show rich notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late StreamSubscription _appLinksSub;
  final ThemeData theme = ThemeData();

  void setTheme(VoidCallback a) {
    setState(a);
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      setupNotifications();
      initAppLinksState();
    }

    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() async {
    _appLinksSub.cancel();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      widget.bloc.saveToCache();
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
        scaffoldMessengerKey: scaffoldMessengerKey,
        navigatorKey: _navigatorKey,
        title: 'InstiApp',
        theme: ThemeData(
          // fontFamily: "SourceSansPro",
          fontFamily: "IBMPlexSans",

          primaryColor: widget.bloc.primaryColor,
          colorScheme: theme.colorScheme.copyWith(
            secondary: widget.bloc.accentColor,
            brightness: widget.bloc.brightness.toBrightness(),
            onBackground: widget.bloc.brightness == AppBrightness.light
                ? Colors.black
                : Colors.white,
          ),
          primarySwatch: Colors.primaries.firstWhereOrNull(
              (c) => c.value == widget.bloc.accentColor.value),

          toggleableActiveColor: widget.bloc.accentColor,
          textSelectionTheme:
              TextSelectionThemeData(selectionColor: widget.bloc.accentColor),

          canvasColor: widget.bloc.brightness.toColor(),

          bottomAppBarColor: widget.bloc.primaryColor,
          brightness: widget.bloc.brightness.toBrightness(),

          textTheme: TextTheme(
              headline4: TextStyle(
                color: widget.bloc.brightness == AppBrightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              headline3: TextStyle(
                color: widget.bloc.brightness == AppBrightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              headline2: TextStyle(
                color: widget.bloc.brightness == AppBrightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              headline1: TextStyle(
                color: widget.bloc.brightness == AppBrightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              headline5: TextStyle()),
        ),
        onGenerateRoute: (RouteSettings settings) {
          // print(settings.name);
          var temp = settings.name;
          if (temp != null) {
            if (temp.startsWith("/event/")) {
              return _buildRoute(
                  settings,
                  EventPage(
                    eventFuture: widget.bloc.getEvent(temp.split("/event/")[1]),
                  ));
            } else if (temp.startsWith("/body/")) {
              return _buildRoute(
                  settings,
                  BodyPage(
                      bodyFuture:
                          widget.bloc.getBody(temp.split("/body/")[1])));
            } else if (temp.startsWith("/user/")) {
              return _buildRoute(
                  settings,
                  UserPage(
                      userFuture:
                          widget.bloc.getUser(temp.split("/user/")[1])));

              // } else if (temp.startsWith("/complaint/")) {
              //   Uri uri = Uri.parse(temp);

              //   return _buildRoute(
              //       settings,
              //       ComplaintPage(
              //           complaintFuture: widget.bloc.getComplaint(
              //               uri.pathSegments[1],
              //               reload: uri.queryParameters.containsKey("reload") &&
              //                   uri.queryParameters["reload"] == "true")));
            } else if (temp.startsWith("/putentity/event/")) {
              return _buildRoute(
                settings,
                EventForm(
                  entityID: temp.split("/putentity/event/")[1],
                  cookie: widget.bloc.getSessionIdHeader(),
                  creator: widget.bloc.currSession!.profile!,
                ),
              );
            } else if (temp.startsWith("/putentity/body/")) {
              return _buildRoute(
                  settings,
                  PutEntityPage(
                      isBody: true,
                      entityID: temp.split("/putentity/body/")[1],
                      cookie: widget.bloc.getSessionIdHeader()));
            } else {
              switch (settings.name) {
                case "/":
                  return _buildRoute(
                      settings,
                      LoginPage(
                        widget.bloc,
                        scaffoldMessengerKey: scaffoldMessengerKey,
                        navigatorKey: _navigatorKey,
                      ));
                case "/mess":
                  // print("Entereing here mess");
                  return _buildRoute(settings, MessPage());
                case "/placeblog":
                  return _buildRoute(settings, PlacementBlogPage());
                case "/trainblog":
                  return _buildRoute(settings, TrainingBlogPage());
                case "/feed":
                  return _buildRoute(settings, FeedPage());
                case "/alumniLoginPage":
                  return _buildRoute(settings, AlumniLoginPage());
                case "/alumni-OTP-Page":
                  return _buildRoute(settings, AlumniOTPPage());
                case "/quicklinks":
                  return _buildRoute(settings, QuickLinksPage());
                case "/news":
                  return _buildRoute(settings, NewsPage());
                case "/explore":
                  return _buildRoute(settings, ExplorePage());
                case "/calendar":
                  return _buildRoute(settings, CalendarPage());
                // case "/complaints":
                //   return _buildRoute(settings, ComplaintsPage());
                // case "/newcomplaint":
                //   return _buildRoute(settings, NewComplaintPage());
                case "/putentity/event":
                  return _buildRoute(settings,
                      EventForm(cookie: widget.bloc.getSessionIdHeader()));
                case "/map":
                  // return _buildRoute(settings, NativeMapPage());
                  return _buildRoute(settings, MapPage());
                case "/settings":
                  return _buildRoute(settings, SettingsPage());
                case "/notifications":
                  return _buildRoute(settings, NotificationsPage());
                case "/about":
                  return _buildRoute(settings, AboutPage());
                case "/achievements":
                  return _buildRoute(settings, YourAchievementPage());
                case "/achievements/add":
                  return _buildRoute(settings, Home());
                case "/externalblog":
                  return _buildRoute(settings, ExternalBlogPage());
                case "/query":
                  return _buildRoute(settings, QueryPage());
                case "/query/add":
                  return _buildRoute(settings, QueryAddPage());
                case "/messcalendar":
                  return _buildRoute(settings, MessCalendarPage());
                case "/messcalendar/qr":
                  return _buildRoute(settings, QRPage());
              }
            }
            return _buildRoute(settings, MessPage());
          }
          return null;
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
  void setupNotifications() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher_foreground');

    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        // print("onMessage: $message");
        var appDocDir = await getApplicationDocumentsDirectory();

        String payload = jsonEncode(message.data);

        RichNotification notif = RichNotification.fromJson(message.data);

        StyleInformation style;
        // AndroidNotificationStyle styleType;

        if (notif.notificationImage != null) {
          var bigPictureResponse =
              await http.get(Uri.parse(notif.notificationImage ?? ""));
          var bigPicturePath =
              '${appDocDir.path}/bigPicture-${notif.notificationID}';
          var file = new File(bigPicturePath);
          await file.writeAsBytes(bigPictureResponse.bodyBytes);

          style = BigPictureStyleInformation(
            FilePathAndroidBitmap(bigPicturePath),
            summaryText: notif.notificationLargeContent,
          );
          // styleType = AndroidNotificationStyle.bigPicture;
        } else if (notif.notificationLargeContent != null) {
          style = BigTextStyleInformation(
            notif.notificationLargeContent ?? "",
          );
          // styleType = AndroidNotificationStyle.bigText;
        } else {
          style = DefaultStyleInformation(false, false);
          // styleType = AndroidNotificationStyle.defaultStyle;
        }

        String largeIconPath = "";
        if (notif.notificationLargeIcon != null) {
          var largeIconResponse =
              await http.get(Uri.parse(notif.notificationLargeIcon ?? ""));
          largeIconPath = '${appDocDir.path}/largeIcon-${notif.notificationID}';
          var file = new File(largeIconPath);
          await file.writeAsBytes(largeIconResponse.bodyBytes);
        }

        var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          'Very Important',
          'Placement Blog Notifications',
          channelDescription:
              'All Placement Blog Notifications go here with high importance',
          importance: Importance.max,
          priority: Priority.high,
          largeIcon: FilePathAndroidBitmap(largeIconPath),
          // style: styleType,
          styleInformation: style,
        );
        var iOSPlatformChannelSpecifics =
            new IOSNotificationDetails(presentAlert: true);
        var platformChannelSpecifics = new NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: iOSPlatformChannelSpecifics);

        await flutterLocalNotificationsPlugin.show(
          0,
          notif.notificationTitle,
          notif.notificationVerb,
          platformChannelSpecifics,
          payload: payload,
        );
      },
    );

    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await widget.bloc.firebaseMessaging.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Called when app is open in background and message is opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    if (Platform.isIOS) {
      widget.bloc.firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    // widget.bloc.firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    //   print("Settings registered: $settings");
    // });

    widget.bloc.firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      // print("Push Messaging token: $token");
    });
  }

  void _handleMessage(RemoteMessage message) {
    // print('A new onMessageOpenedApp event was published!');
    navigateFromNotification(RichNotification.fromJson(message.data));
  }

  Future onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    navigateFromNotification(
        RichNotification.fromJson(jsonDecode(payload ?? "")));
  }

  Future navigateFromNotification(dynamic fromMap) async {
    // Navigating to correct page
    print(fromMap.notificationType);
    print(fromMap.notificationExtra?.contains("/trainingblog"));
    var routeName = {
      "blogentry": fromMap.notificationExtra?.contains("/internship") ?? false
          ? "/trainblog"
          : "/placeblog",
      "body": "/body/${fromMap.notificationObjectID ?? ""}",
      "event": "/event/${fromMap.notificationObjectID ?? ""}",
      "userprofile": "/user/${fromMap.notificationObjectID ?? ""}",
      "newsentry": "/news",
      "complaintcomment":
          "/complaint/${fromMap.notificationExtra ?? ""}?reload=true",
      "unresolvedquery": "/query",
    }[fromMap.notificationType];

    _navigatorKey.currentState?.pushNamed(routeName ?? '/');

    // marking the notification as read
    widget.bloc.clearNotificationUsingID(fromMap.notificationID!);
  }

  void handleAppLink(Uri? uri) {
    if (uri == null) return;
    var routeName = {
      "user": "/user/${uri.pathSegments[1]}",
      "event": "/event/${uri.pathSegments[1]}",
      "map": "/map",
      "org": "/body/${uri.pathSegments[1]}",
    }[uri.pathSegments[0]];
    _navigatorKey.currentState?.pushNamed(routeName!);
  }

  Future initAppLinksState() async {
    _appLinksSub = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      handleAppLink(uri);
    }, onError: (err) {
      if (!mounted) return;
      // print('Failed to get latest link: $err.');
    });
    try {
      Uri? initialUri = await getInitialUri();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      handleAppLink(initialUri);
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    } on FormatException {
      // print('Bad parse the initial link as Uri.');
    }
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
