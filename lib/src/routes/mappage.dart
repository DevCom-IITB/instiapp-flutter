import 'dart:async';

import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/safe_webview_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:jaguar/jaguar.dart' as jag;
import 'package:jaguar_flutter_asset/jaguar_flutter_asset.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  jag.Jaguar server;

  // final String hostUrl = "insti.app";
  // final String mapUrl = "https://insti.app/map/?sandbox=true";

  // final String hostUrl = "127.0.0.1:9999";
  // final String mapUrl = "http://127.0.0.1:9999/";

  final String hostUrl = "pulsejet.github.io";
  final String mapUrl = "https://pulsejet.github.io/instimapweb-standalone/";

  StreamSubscription<String> onUrlChangedSub;
  StreamSubscription<WebViewStateChanged> onStateChangedSub;

  // Storing for dispose
  ThemeData theme;

  @override
  void initState() {
    super.initState();

    // startMapServerIfNotStarted().then((_) {
    //   flutterWebviewPlugin.reloadUrl(mapUrl);
    //   flutterWebviewPlugin.hide();
    // });

    onUrlChangedSub = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      print("Changed URL: $url");
      if (!url.contains(hostUrl)) {
        flutterWebviewPlugin.reloadUrl(mapUrl);
        flutterWebviewPlugin.hide();
      }
    });

    onStateChangedSub =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      print(state.type);
      if (state.type == WebViewState.finishLoad) {
        if (state.url.startsWith(hostUrl)) {
          print("onStateChanged: Showing Web View");
          flutterWebviewPlugin.show();
        }
      }
    });
  }

  @override
  void dispose() {
    onStateChangedSub?.cancel();
    onUrlChangedSub?.cancel();
    flutterWebviewPlugin.dispose();
    server?.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    print(theme.canvasColor);
    var bloc = BlocProvider.of(context).bloc;

    print("This is the URL: $mapUrl");
    return SafeWebviewScaffold(
      url: mapUrl,
      hidden: true,
      withZoom: false,
      scrollBar: false,
      withJavascript: true,
      withLocalStorage: true,
      headers: {
        "Cookie": bloc.getSessionIdHeader(),
      },
      primary: true,
      bottomNavigationBar: MyBottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            BackButton(),
            IconButton(
              tooltip: "Refresh",
              icon: Icon(
                OMIcons.refresh,
                semanticLabel: "Refresh",
              ),
              onPressed: () {
                flutterWebviewPlugin.reload();
              },
            ),
          ],
        ),
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
