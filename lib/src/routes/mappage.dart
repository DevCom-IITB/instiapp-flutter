import 'dart:async';

// import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
// import 'package:InstiApp/src/utils/safe_webview_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:jaguar/jaguar.dart' as jag;
import 'package:jaguar_flutter_asset/jaguar_flutter_asset.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_webview_pro/webview_flutter.dart' as webview;
// import 'package:webview_flutter/webview_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late jag.Jaguar server;

  final String hostUrl = "insti.app";
  // final String mapUrl = "https://www.gps-coordinates.net/my-location";
  final String mapUrl = "https://insti.app/map/?sandbox=true";

  // final String hostUrl = "127.0.0.1:9999";
  // final String mapUrl = "http://127.0.0.1:9999/";

  // final String hostUrl = "varunpatil.me";
  // final String mapUrl = "https://varunpatil.me/instimapweb-standalone/";

  StreamSubscription<String>? onUrlChangedSub;
  webview.WebViewController? webViewController;

  // Storing for dispose
  ThemeData? theme;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // startMapServerIfNotStarted().then((_) {
    //   flutterWebviewPlugin.reloadUrl(mapUrl);
    //   flutterWebviewPlugin.hide();
    // });
  }

  @override
  void dispose() {
    onUrlChangedSub?.cancel();
    // server.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    // print(theme?.canvasColor);
    // var bloc = BlocProvider.of(context)!.bloc;

    // print("This is the URL: $mapUrl");
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      bottomNavigationBar: MyBottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              tooltip: "Show bottom sheet",
              icon: Icon(
                Icons.menu_outlined,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
            ),
            IconButton(
              tooltip: "Refresh",
              icon: Icon(
                Icons.refresh_outlined,
                semanticLabel: "Refresh",
              ),
              onPressed: () {
                webViewController?.loadUrl(mapUrl);
              },
            ),
          ],
        ),
      ),
      body: webview.WebView(
        initialUrl: mapUrl,
        javascriptMode: webview.JavascriptMode.unrestricted,
        onWebViewCreated: (webview.WebViewController webViewController) {
          this.webViewController = webViewController;
        },
        navigationDelegate: (webview.NavigationRequest request) {
          if (request.url.startsWith(mapUrl)) {
            return webview.NavigationDecision.prevent;
          }
          return webview.NavigationDecision.navigate;
        },
        gestureNavigationEnabled: true,
        geolocationEnabled: true,
      ),
    );
  }

  Future startMapServerIfNotStarted() {
    try {
      server = jag.Jaguar(port: 9999);
      server.addRoute(serveFlutterAssets(prefix: "map/"));
      return server.serve();
    } catch (e) {
      // Already server running
      return Future.delayed(Duration.zero);
    }
  }
}
