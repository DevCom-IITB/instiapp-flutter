import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:instiapp/src/api/apiclient.dart';

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

  @override
  void initState() {
    super.initState();

    startLoginPageServer().then((_) {
      final url = "http://${server.address.host}:${server.port}/";
      print("Formed URL: $url");
      flutterWebviewPlugin.launch(url);
    });
    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      print("Changed URL: $url");
      if (url.startsWith(successUrl)) {
        var uri = Uri.parse(url);
        var code = uri.queryParameters['code'];
        print(code);

        flutterWebviewPlugin.close();
        server.close(force: true);

        login(code, successUrl);
      }
      else if (url.startsWith(guestUrl)) {
        flutterWebviewPlugin.close();
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 9399);
    server.listen((HttpRequest request) async {
      print("URI: ${request.uri}");
      if (request.uri.toString() == '/') {
        var html = await DefaultAssetBundle.of(context)
            .loadString('assets/login.html');
        request.response
          ..statusCode = 200
          ..headers.set("Content-Type", ContentType.html.mimeType)
          ..write(html);
      } else if (request.uri.toString().contains('lotus')) {
        var binary =
            await DefaultAssetBundle.of(context).load('assets/lotus.png');
        request.response
          ..statusCode = 200
          ..headers.set("Content-Type", "image/png")
          ..add(binary.buffer.asUint8List());
      } else {
        request.response..statusCode = 404;
      }
      await request.response.close();
      // await server.close(force: true);
    });
  }

  login(final String authCode, final String redirectUrl) async {
    var response = await InstiAppApi().login(authCode, redirectUrl);
    if (response.sessionid != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Authentication Failed"),
      ));
    }
  }
}