import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/routes/feedpage.dart';
import 'package:InstiApp/src/routes/trainingblogpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/api/model/user.dart';
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
          else {
            switch (settings.name) {
              case "/": return _buildRoute(settings, LoginPage());
              case "/mess": return _buildRoute(settings, MessPage());
              case "/placeblog": return _buildRoute(settings, PlacementBlogPage());
              case "/trainblog": return _buildRoute(settings, TrainingBlogPage());
              case "/feed": return _buildRoute(settings, FeedPage());
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
