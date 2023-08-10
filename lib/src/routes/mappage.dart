import 'dart:async';

import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:jaguar/jaguar.dart' as jag;
import 'package:flutter_webview_pro/webview_flutter.dart' as webview;

class MapPage extends StatefulWidget {
  final String? location;
  MapPage({this.location});
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late jag.Jaguar server;

  final String hostUrl = "www.insti.app";
  // final String mapUrl = "https://www.insti.app/map/?sandbox=true";
  String mapUrl = "https://www.insti.app/map/?sandbox=true";

  StreamSubscription<String>? onUrlChangedSub;
  webview.WebViewController? webViewController;

  // Storing for dispose
  ThemeData? theme;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    mapUrl =
        ("https://www.insti.app/map/${Uri.encodeComponent(widget.location ?? "")}?sandbox=true");
    super.initState();
  }

  @override
  void dispose() {
    onUrlChangedSub?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
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
        zoomEnabled: false,
        geolocationEnabled: true,
      ),
    );
  }
}
