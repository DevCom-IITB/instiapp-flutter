import 'dart:async';
import 'dart:io';

import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:InstiApp/src/api/apiclient.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';

class LoginPage extends StatefulWidget {
  final InstiAppBloc bloc;
  LoginPage(this.bloc);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();
  HttpServer server;

  int port;
  final String successUrl = "https://redirecturi";
  final String guestUrl = "https://guesturi";
  final String gymkhanaUrl = "https://gymkhana.iitb.ac.in";
  final String httpGymkhanaUrl = "http://gymkhana.iitb.ac.in";
  InstiAppBloc _bloc;
  StreamSubscription<String> onUrlChangedSub;
  StreamSubscription<WebViewStateChanged> onStateChangedSub;

  String statusMessage = "Initializing";

  String url;
  Session currSession;

  @override
  void dispose() {
    server?.close(force: true);
    flutterWebviewPlugin.dispose();

    onUrlChangedSub?.cancel();
    onStateChangedSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc;

    checkLogin().then((Session sess) {
      // If session already exists, continue to homepage with current session
      if (sess != null) {
        _bloc.patchFcmKey().then((_) {
          _bloc?.reloadCurrentUser();
        });

        Navigator.of(context).pushReplacementNamed(_bloc?.homepageName);
        return;
      }

      // No stored session found
      startLoginPageServer().then((_) async {
        url = "http://${server.address.host}:${server.port}/";
        print("Formed URL: $url");
        print("startLoginPageServer.then: Launching Web View");
        // await Future.delayed(Duration(milliseconds: 200));
        var mqdata = MediaQuery.of(context);
        flutterWebviewPlugin.launch(
          url,
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
        if (url.startsWith(successUrl)) {
          var uri = Uri.parse(url);
          var code = uri.queryParameters['code'];
          print(code);

          print("onUrlChanged: Hiding Web View");
          flutterWebviewPlugin.hide();
          login(code, successUrl);
        } else if (url.startsWith(guestUrl)) {
          this.onUrlChangedSub.cancel();
          this.onStateChangedSub.cancel();
          print("onUrlChanged: Closing Web View");
          flutterWebviewPlugin.close();

          Navigator.of(context)
              .pushNamedAndRemoveUntil(_bloc?.homepageName, (r) => false);
          // Navigator.of(context).pushReplacementNamed(_bloc?.homepageName);
        } else if (url.startsWith(gymkhanaUrl)) {
          print("onUrlChanged: Hiding Web View");
          flutterWebviewPlugin.hide();
        } else if (url.startsWith(httpGymkhanaUrl)) {
          print("onUrlChanged: http gymkhana");
          flutterWebviewPlugin.reloadUrl(url.replaceFirst("http", "https"));
        } else if (!url.startsWith("http://${server.address.host}")) {
          print("Going to unintented website");
          flutterWebviewPlugin
              .reloadUrl("http://${server.address.host}:${server.port}/");
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

  Future<Session> checkLogin() async {
    // await _bloc.restorePrefs();
    return _bloc?.currSession;
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of(context).bloc;
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
              color: Theme.of(context).accentColor,
              image: AssetImage('assets/lotus.png'),
              width: 250.0,
              fit: BoxFit.scaleDown,
            ),
            Text(
              "InstiApp",
              style: Theme.of(context)
                  .textTheme
                  .display1
                  .copyWith(color: Theme.of(context).accentColor),
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
    var defAssets = DefaultAssetBundle.of(context);
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 9399);
    server.listen((HttpRequest request) async {
      print("URI: ${request.uri}");
      if (request.uri.toString() == '/') {
        var html = await defAssets.loadString(
            _bloc.brightness.toBrightness() == Brightness.dark
                ? 'assets/login_dark.html'
                : 'assets/login.html');
        request.response
          ..statusCode = 200
          ..headers.set("Content-Type", ContentType.html.mimeType)
          ..write(html);
      } else if (request.uri.toString().contains('lotus')) {
        var binary = await defAssets.load('assets/lotus.png');
        request.response
          ..statusCode = 200
          ..headers.set("Content-Type", "image/png")
          ..add(binary.buffer.asUint8List());
      } else {
        request.response..statusCode = 404;
      }
      await request.response.close();
      print("Served");
    });
  }

  login(final String authCode, final String redirectUrl) async {
    setState(() {
      statusMessage = "Logging you in";
    });
    var response;
    try {
      response = await InstiAppApi().login(authCode, redirectUrl);
    } catch (e) {}
    if (response?.sessionid != null) {
      _bloc.updateSession(response);
      setState(() {
        statusMessage = "Logged in";
      });
      _bloc.patchFcmKey();

      Navigator.of(context).pushReplacementNamed(_bloc?.homepageName);

      this.onUrlChangedSub.cancel();
      this.onStateChangedSub.cancel();
      print("login: Closing Web View");
      flutterWebviewPlugin.close();
    } else {
      setState(() {
        statusMessage = "Log in failed. Reinitializing.";
      });
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Authentication Failed"),
      ));
      print("login: Showing Web View");
      flutterWebviewPlugin.show();
      print("login: Launching Web View");
      flutterWebviewPlugin.launch(url);
    }
  }
}
