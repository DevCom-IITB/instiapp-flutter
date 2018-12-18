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
        routes: {
          "/": (_) => LoginPage(),
          "/mess": (_) => MessPage(),
          "/placeblog": (_) => PlacementBlogPage(),
          "/trainblog": (_) => TrainingBlogPage(),
          "/feed": (_) => FeedPage(),
        },
      ),
    );
  }
}
