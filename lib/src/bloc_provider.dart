import 'package:flutter/material.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';

class BlocProvider extends InheritedWidget {
  final InstiAppBloc bloc;

  BlocProvider(this.bloc, {child, key}) : super(child: child, key: key);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

  static BlocProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(BlocProvider);
  }
}