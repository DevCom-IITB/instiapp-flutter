import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ErrorInterceptor extends Interceptor {
  BuildContext context;
  GlobalKey<NavigatorState> navigatorKey;

  ErrorInterceptor({required this.context, required this.navigatorKey});

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // print("Error");
    final res = err.response;
    InstiAppBloc bloc = BlocProvider.of(context)!.bloc;
    if (res != null) {
      // print("Res not null: " + res.statusCode.toString());
      if (res.statusCode == 401) {
        // print("Logging out");
        await bloc.logout();
        navigatorKey.currentState?.pushReplacementNamed('/',
            arguments: "You have been logged out! Please login again.");
      }
    }
    handler.next(err);
  }
}
