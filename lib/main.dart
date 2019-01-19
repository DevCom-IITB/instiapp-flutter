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
import 'package:InstiApp/src/routes/putentitypage.dart';
import 'package:InstiApp/src/routes/quicklinkspage.dart';
import 'package:InstiApp/src/routes/settingspage.dart';
import 'package:InstiApp/src/routes/trainingblogpage.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';

import 'package:InstiApp/src/routes/messpage.dart';
import 'package:InstiApp/src/routes/loginpage.dart';
import 'package:InstiApp/src/routes/placementblogpage.dart';

void main() async {
  GlobalKey<MyAppState> key = GlobalKey();
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

  MyApp({this.key, @required this.bloc}) : super(key: key);

  // This widget is the root of your application.
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  void setTheme(VoidCallback a) {
    setState(a);
  }

  @override
  void dispose() {
    // TODO: backup all state to disk
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      widget.bloc,
      child: MaterialApp(
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

          canvasColor: widget.bloc.brightness == AppBrightness.black
              ? Colors.black
              : null,

          bottomAppBarColor: widget.bloc.primaryColor,
          brightness: widget.bloc.brightness.toBrightness(),

          textTheme: TextTheme(
              display1: TextStyle(
                fontFamily: "SourceSansPro",
                color: widget.bloc.brightness == AppBrightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              display2: TextStyle(
                fontFamily: "SourceSansPro",
                color: widget.bloc.brightness == AppBrightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              display3: TextStyle(
                fontFamily: "SourceSansPro",
                color: widget.bloc.brightness == AppBrightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              display4: TextStyle(
                fontFamily: "SourceSansPro",
                color: widget.bloc.brightness == AppBrightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              headline: TextStyle(
                fontFamily: "SourceSansPro",
              )),
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
            return _buildRoute(
                settings,
                ComplaintPage(
                    complaintFuture: widget.bloc
                        .getComplaint(settings.name.split("/complaint/")[1])));
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
                return _buildRoute(settings, MapPage());
              case "/settings":
                return _buildRoute(settings, SettingsPage());
            }
          }
          return _buildRoute(settings, MessPage());
        },
      ),
    );
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) => builder,
    );
  }
}
