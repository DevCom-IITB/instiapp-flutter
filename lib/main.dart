import 'package:InstiApp/src/routes/addeventpage.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/routes/calendarpage.dart';
import 'package:InstiApp/src/routes/complaintpage.dart';
import 'package:InstiApp/src/routes/complaintspage.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/routes/explorepage.dart';
import 'package:InstiApp/src/routes/feedpage.dart';
import 'package:InstiApp/src/routes/newcomplaintpage.dart';
import 'package:InstiApp/src/routes/newspage.dart';
import 'package:InstiApp/src/routes/quicklinkspage.dart';
import 'package:InstiApp/src/routes/trainingblogpage.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';

import 'package:InstiApp/src/routes/messpage.dart';
import 'package:InstiApp/src/routes/loginpage.dart';
import 'package:InstiApp/src/routes/placementblogpage.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  InstiAppBloc _bloc = InstiAppBloc();

  @override
  void initState() {
    super.initState();
    _bloc = InstiAppBloc();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      _bloc,
      child: MaterialApp(
        title: 'InstiApp',
        theme: ThemeData(
          fontFamily: "SourceSansPro",
          primarySwatch: Colors.deepPurple,
        ),
        // routes: {
        //   "/": (_) => LoginPage(),
        //   "/mess": (_) => MessPage(),
        //   "/placeblog": (_) => PlacementBlogPage(),
        //   "/trainblog": (_) => TrainingBlogPage(),
        //   "/feed": (_) => FeedPage(),
        //   "/event": (_) => EventPage(),
        // },
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name.startsWith("/event/") ) {
            return _buildRoute(settings, EventPage(_bloc.getEvent(settings.name.split("/event/")[1])));
          }
          else if (settings.name.startsWith("/body/")) {
            return _buildRoute(settings, BodyPage(_bloc.getBody(settings.name.split("/body/")[1])));
          }
          else if (settings.name.startsWith("/user/")) {
            return _buildRoute(settings, UserPage(_bloc.getUser(settings.name.split("/user/")[1])));
          }
          else if (settings.name.startsWith("/complaint/")) {
            return _buildRoute(settings, ComplaintPage(_bloc.getComplaint(settings.name.split("/complaint/")[1])));
          }
          else {
            switch (settings.name) {
              case "/": return _buildRoute(settings, LoginPage());
              case "/mess": return _buildRoute(settings, MessPage());
              case "/placeblog": return _buildRoute(settings, PlacementBlogPage());
              case "/trainblog": return _buildRoute(settings, TrainingBlogPage());
              case "/feed": return _buildRoute(settings, FeedPage());
              case "/quicklinks": return _buildRoute(settings, QuickLinksPage());
              case "/news": return _buildRoute(settings, NewsPage());
              case "/explore": return _buildRoute(settings, ExplorePage());
              case "/calendar": return _buildRoute(settings, CalendarPage());
              case "/complaints": return _buildRoute(settings, ComplaintsPage());
              case "/newcomplaint": return _buildRoute(settings, NewComplaintPage());
              case "/addevent": return _buildRoute(settings, AddEventPage());
            }
          }
          return _buildRoute(settings, MessPage());
        },
      ),
    );
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder){
    return new MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) => builder,
    );
  }
}
