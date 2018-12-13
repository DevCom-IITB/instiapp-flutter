import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:instiapp/src/api/apiclient.dart';
import 'package:instiapp/src/api/model/serializers.dart';
import 'package:instiapp/src/api/model/user.dart';
import 'package:instiapp/src/bloc_provider.dart';
import 'package:instiapp/src/blocs/ia_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';

const String api = "https://api.insti.app/api";
const String authority = "api.insti.app";

class LoginPage extends StatefulWidget {
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

  String url;
  Session currSession;

  @override
  void dispose() {
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    checkLogin().then((Session sess) {
      // If session already exists, continue to homepage with current session
      if (sess != null) {
        _bloc?.updateSession(sess);
        Navigator.of(context).pushReplacementNamed("/mess");
        return;
      }

      // No stored session found 
      startLoginPageServer().then((_) async {
        url = "http://${server.address.host}:${server.port}/";
        print("Formed URL: $url");
        print("startLoginPageServer.then: Launching Web View");
        flutterWebviewPlugin.launch(
          url,
          hidden: false,
          withJavascript: true,
          rect: new Rect.fromLTWH(
            0.0,
            0.0,
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
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

          server.close(force: true);

          Navigator.of(context).pushReplacementNamed('/mess');
        } else if (url.startsWith(gymkhanaUrl)) {
          print("onUrlChanged: Hiding Web View");
          flutterWebviewPlugin.hide();
        } else if (url.startsWith(httpGymkhanaUrl)) {
          print("onUrlChanged: http gymkhana");
          flutterWebviewPlugin.reloadUrl(url.replaceFirst("http", "https"));
        }
      });
      onStateChangedSub = flutterWebviewPlugin.onStateChanged
          .listen((WebViewStateChanged state) {
        print(state.type);
        if (state.type == WebViewState.finishLoad) {
          if (state.url.startsWith(gymkhanaUrl)) {
            print("onStateChanged: Showing Web View");
            flutterWebviewPlugin.show();
          }
        }
      });
    });
  }

  Future<Session> checkLogin() async {    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getKeys().contains("session")){
      standardSerializers.decodeOne(prefs.getString("session"));
      Session sess = standardSerializers.decodeOne(prefs.getString("session"));
      if (sess?.sessionid != null) {
        return sess;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of(context).bloc;

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
            CircularProgressIndicator(
              backgroundColor: Theme.of(context).accentColor,
            ),
            Text(
              "InstiApp",
              style: Theme.of(context).textTheme.display1.copyWith(
                  fontFamily: "Bitter", color: Theme.of(context).accentColor),
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
        var html = await defAssets.loadString('assets/login.html');
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
      // await server.close(force: true);
    });
  }

  login(final String authCode, final String redirectUrl) async {
    var response = await InstiAppApi().login(authCode, redirectUrl);
    if (response.sessionid != null) {
      _bloc.updateSession(response);
      Navigator.of(context).pushReplacementNamed('/mess');

      this.onUrlChangedSub.cancel();
      this.onStateChangedSub.cancel();
      print("login: Closing Web View");
      flutterWebviewPlugin.close();
      server.close(force: true);
    } else {
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
