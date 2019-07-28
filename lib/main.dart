import 'package:InstiApp/src/android_app.dart';
import 'package:InstiApp/src/ios_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';

void main() async {
  // GlobalKey<MyAndroidAppState> key = GlobalKey();
  GlobalKey<MyIOSAppState> key = GlobalKey();

  InstiAppBloc bloc = InstiAppBloc(wholeAppKey: key);
  await bloc.restorePrefs();

  // runApp(MyAndroidApp(
  //   key: key,
  //   bloc: bloc,
  // ));

  runApp(MyIOSApp(
    key: key,
    bloc: bloc,
  ));
}
