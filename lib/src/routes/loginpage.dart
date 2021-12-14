import 'dart:async';

import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:InstiApp/src/api/apiclient.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:jaguar/jaguar.dart' as jag;
import 'package:jaguar_flutter_asset/jaguar_flutter_asset.dart';

class LoginPage extends StatefulWidget {
  final InstiAppBloc bloc;
  LoginPage(this.bloc);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();
  late jag.Jaguar server;
  final Dio dio = Dio();

  final String successUrl = "instiapp://insti.app/login";
  final String guestUrl = "https://guesturi";
  final String gymkhanaUrl = "https://gymkhana.iitb.ac.in";
  final String httpGymkhanaUrl = "http://gymkhana.iitb.ac.in";
  final String ssoLogin = "https://sso.iitb.ac.in/login";
  final String ssoAuth = "https://sso.iitb.ac.in/authorize";
  InstiAppBloc? _bloc;
  StreamSubscription<String>? onUrlChangedSub;
  StreamSubscription<WebViewStateChanged>? onStateChangedSub;

  String statusMessage = "Initializing";

  String? loginurl;
  Session? currSession;

  @override
  void dispose() {
    server.close();
    flutterWebviewPlugin.dispose();

    onUrlChangedSub?.cancel();
    onStateChangedSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc;

    // Creating login url
    loginurl = "http://127.0.0.1:9399/" +
        ((_bloc!.brightness.toBrightness() == Brightness.dark)
            ? "login_dark.html"
            : "login.html");
    print("Formed URL: $loginurl");

    checkLogin().then((Session? sess) {
      // If session already exists, continue to homepage with current session
      if (sess != null) {
        _bloc!.patchFcmKey().then((_) {
          _bloc?.reloadCurrentUser();
        });

        Navigator.of(context).pushReplacementNamed(_bloc!.homepageName);
        return;
      }

      // No stored session found
      startLoginPageServer().then((_) async {
        print("startLoginPageServer.then: Launching Web View");
        await Future.delayed(Duration(milliseconds: 200));
        var mqdata = MediaQuery.of(context);
        flutterWebviewPlugin.launch(
          loginurl!,
          hidden: false,
          withJavascript: true,
          clearCookies: true,
          rect: Rect.fromLTWH(
            mqdata.padding.left,
            mqdata.padding.top,
            mqdata.size.width - mqdata.padding.right - mqdata.padding.left,
            mqdata.size.height - mqdata.padding.bottom - mqdata.padding.top,
          ),
        );
      });

      onUrlChangedSub = flutterWebviewPlugin.onUrlChanged.listen((String url) {
        print("Changed URL: $url");
        if (url.startsWith(ssoLogin)) {
          print("onUrlChanged: Going to sso authorize");
        } else if (url.startsWith(guestUrl)) {
          this.onUrlChangedSub!.cancel();
          this.onStateChangedSub?.cancel();
          print("onUrlChanged: Closing Web View");
          flutterWebviewPlugin.close();

          Navigator.of(context)
              .pushNamedAndRemoveUntil(_bloc!.homepageName, (r) => false);
        } else if (url.startsWith(gymkhanaUrl)) {
          print("onUrlChanged: Hiding Web View");
          flutterWebviewPlugin.hide();
        } else if (url.startsWith(httpGymkhanaUrl)) {
          print("onUrlChanged: http gymkhana");
          flutterWebviewPlugin.reloadUrl(url.replaceFirst("http", "https"));
        } else if (url.startsWith(ssoAuth)) {
          print("onUrlChanged: Going to sso login");
          // flutterWebviewPlugin.reloadUrl(sso);
          // flutterWebviewPlugin.hide();
        } else if (url.startsWith(successUrl)) {
          var uri = Uri.parse(url);
          var code = uri.queryParameters['code'];
          print(code);

          print("onUrlChanged: Hiding Web View");
          flutterWebviewPlugin.hide();
          login(code ?? "", "https://www.insti.app/login-android.html");
        } else if (!url.startsWith("http://127.0.0.1")) {
          print("Going to unintented website");
          // flutterWebviewPlugin.reloadUrl(loginurl);
        }
      });
      onStateChangedSub = flutterWebviewPlugin.onStateChanged
          .listen((WebViewStateChanged state) async {
        print(state.type);
        if (state.type == WebViewState.startLoad) {
          if (state.url.startsWith(gymkhanaUrl)) {
            setState(() {
              statusMessage = "Loading IITB SSO";
            });
          }
          print("onStateChanged: Hide Web View");
          flutterWebviewPlugin.hide();
          print("onStateChanged: Hiding Web View");
        } else if (state.type == WebViewState.finishLoad) {
          if (state.url.startsWith(successUrl)) {
            return;
          }
          print("onStateChanged: Show Web View");
          flutterWebviewPlugin.show();
          setState(() {
            statusMessage = "Loaded IITB SSO";
          });
          print("onStateChanged: Showing Web View");
        }
      });
    });
  }

  Future<Session?> checkLogin() async {
    await _bloc?.restorePrefs();
    return _bloc?.currSession;
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of(context)!.bloc;
    var mqdata = MediaQuery.of(context);

    flutterWebviewPlugin.resize(Rect.fromLTWH(
      mqdata.padding.left,
      mqdata.padding.top,
      mqdata.size.width - mqdata.padding.right - mqdata.padding.left,
      mqdata.size.height - mqdata.padding.bottom - mqdata.padding.top,
    ));
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image(
              color: Theme.of(context).colorScheme.secondary,
              image: AssetImage('assets/login/lotus.png'),
              width: 250.0,
              fit: BoxFit.scaleDown,
            ),
            Text(
              "InstiApp",
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  ?.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
            CircularProgressIndicatorExtended(
              label: Text(statusMessage),
              // backgroundColor: Theme.of(context).accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> startLoginPageServer() async {
    server = jag.Jaguar(port: 9399);
    server.addRoute(serveFlutterAssets(prefix: "login/"));
    return server.serve();
  }

  login(final String authCode, final String redirectUrl) async {
    setState(() {
      statusMessage = "Logging you in";
    });
    var response;
    try {
      response = await InstiAppApi(dio).login(authCode, redirectUrl);
    } catch (e) {}
    if (response?.sessionid != null) {
      _bloc?.updateSession(response);
      setState(() {
        statusMessage = "Logged in";
      });
      _bloc?.patchFcmKey();

      Navigator.of(context).pushReplacementNamed(_bloc?.homepageName ?? "");

      this.onUrlChangedSub?.cancel();
      this.onStateChangedSub?.cancel();
      print("login: Closing Web View");
      flutterWebviewPlugin.close();
    } else {
      setState(() {
        statusMessage = "Log in failed. Reinitializing.";
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Authentication Failed"),
      ));
      print("login: Showing Web View");
      flutterWebviewPlugin.show();
      print("login: Launching Web View");
      flutterWebviewPlugin.launch(loginurl ?? "");
    }
  }
}
