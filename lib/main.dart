import 'dart:async';

import 'package:InstiApp/src/routes/aboutpage.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/routes/calendarpage.dart';
import 'package:InstiApp/src/routes/communitydetails.dart';
import 'package:InstiApp/src/routes/communitypostpage.dart';
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
import 'package:InstiApp/src/routes/chatbot.dart';
import 'package:InstiApp/src/routes/communitypage.dart';
import 'package:InstiApp/src/routes/notificationspage.dart';
import 'package:InstiApp/src/routes/putentitypage.dart';
import 'package:InstiApp/src/routes/createpost_form.dart';
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
import 'package:InstiApp/src/utils/notif_settings.dart';
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
import 'package:uni_links/uni_links.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  // print("Runnning main");
  GlobalKey<MyAppState> key = GlobalKey();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  InstiAppBloc bloc = InstiAppBloc(wholeAppKey: key);
  FirebaseMessaging.onBackgroundMessage(sendMessage);

  AwesomeNotifications().initialize(
    'resource://drawable/ic_launcher_foreground',
    notifChannels,
    channelGroups: notifGroups,
  );

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
      initAppLinksState();
    }

    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() async {
    _appLinksSub.cancel();
    WidgetsBinding.instance?.removeObserver(this);
    disposeNotification();
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
            primary: widget.bloc.primaryColor,
            secondary: widget.bloc.accentColor,
            primaryContainer: widget.bloc.primaryColor[200],
            secondaryContainer: widget.bloc.accentColor[200],
            brightness: widget.bloc.brightness.toBrightness(),
            onBackground: widget.bloc.brightness == AppBrightness.light
                ? Colors.black
                : Colors.white,
            surface: widget.bloc.brightness == AppBrightness.light
                ? Colors.white
                : widget.bloc.brightness.toColor(),
            surfaceVariant: widget.bloc.brightness == AppBrightness.light
                ? Color(0xFFE8ECF2)
                : Color(0xFF121212),
            onSurface: widget.bloc.brightness == AppBrightness.light
                ? Colors.black
                : Colors.white,
            onSurfaceVariant: widget.bloc.brightness == AppBrightness.light
                ? Color(0xFF767881)
                : Colors.white,
            inverseSurface: widget.bloc.brightness == AppBrightness.light
                ? Color(0xFFE8ECF2)
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
            } else if (temp.startsWith("/group/")) {
              widget.bloc.drawerState.setPageIndex(15);
              return _buildRoute(
                  settings,
                  CommunityDetails(
                      communityFuture: widget.bloc.communityBloc
                          .getCommunity(temp.split("/group/")[1])));
            } else if (temp.startsWith("/communitypost/")) {
              widget.bloc.drawerState.setPageIndex(15);
              return _buildRoute(
                  settings,
                  CommunityPostPage(
                      communityPostFuture: widget.bloc.communityPostBloc
                          .getCommunityPost(temp.split("/communitypost/")[1])));
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
                case "/InSeek":
                  return _buildRoute(settings, ChatPage());
                case "/groups":
                  return _buildRoute(settings, CommunityPage());
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
                case "/posts/add":
                  return _buildRoute(settings, CreatePostPage());
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
            return _buildRoute(
                settings,
                LoginPage(
                  widget.bloc,
                  scaffoldMessengerKey: scaffoldMessengerKey,
                  navigatorKey: _navigatorKey,
                ));
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

  void handleAppLink(Uri? uri) {
    if (uri == null) return;
    // print(uri.pathSegments);
    String routeName = "/";
    if (uri.pathSegments.length == 1) {
      routeName = {
            "map": "/map",
          }[uri.pathSegments[0]] ??
          routeName;
    } else if (uri.pathSegments.length > 1) {
      routeName = {
            "user": "/user/${uri.pathSegments[1]}",
            "event": "/event/${uri.pathSegments[1]}",
            "org": "/body/${uri.pathSegments[1]}",
            "group-feed": "/group/${uri.pathSegments[1]}",
            "view-post": "/groups",
            "discussions": "/groups",
            "group": "/group/${uri.pathSegments[1]}",
          }[uri.pathSegments[0]] ??
          routeName;
    }
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  Future initAppLinksState() async {
    _appLinksSub = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      // print(uri);
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
