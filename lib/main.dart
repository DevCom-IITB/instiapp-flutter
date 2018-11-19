import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instiapp/src/json_parsing.dart';
import 'package:instiapp/src/api/model/mess.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'dart:io';
import 'package:http/http.dart' as http;

const String api = "https://api.insti.app/api";
const String authority = "api.insti.app";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      // home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        "/": (_) => LoginPage(),
        "/home": (_) => MyHomePage(
              title: 'InstiApp',
            ),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();
  HttpServer server;
  int port;
  final String successUrl = "https://redirecturi";

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

        login(code, url);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.deepPurple,
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
    var uri = Uri.https(
        authority, "/api/login/", {'code': authCode, 'redir': redirectUrl});
    var response = await http.get(uri.toString());
    print(response.body);
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Hostel> hostels = parseMess(hostelsJsonString);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: hostels.map(_buildItem).toList(),
        physics: BouncingScrollPhysics(),
      ),
    );
  }

  Widget _buildItem(Hostel hostel) {
    return Center(
      child: ListTile(
        title: Text(
          hostel.longName,
          style: Theme.of(context).textTheme.title,
        ),
        subtitle: Text(
          hostel.name,
          style: Theme.of(context).textTheme.subtitle,
        ),
        onTap: _launchURL,
      ),
    );
  }

  _launchURL() async {
    const url = 'https://flutter.io';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
