import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instiapp/src/api/model/user.dart';
import 'package:instiapp/src/bloc_provider.dart';
import 'package:instiapp/src/ia_bloc.dart';

import 'package:instiapp/src/routes/homepage.dart';
import 'package:instiapp/src/routes/loginpage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var _bloc = InstiAppBloc();
    return BlocProvider(
      _bloc,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: "SourceSansPro",
          primarySwatch: Colors.deepPurple,
        ),
        routes: {
          "/": (_) => LoginPage(),
          "/home": (_) => MyHomePage(),
        },
      ),
    );
  }
}
