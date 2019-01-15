import 'dart:async';

import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final String hostUrl = "https://insti.app";
  final String mapUrl = "https://insti.app/map/?sandbox=true";

  StreamSubscription<String> onUrlChangedSub;
  StreamSubscription<WebViewStateChanged> onStateChangedSub;
  StreamSubscription<bool> onDrawerStateChanges;

  @override
  void initState() {
    super.initState();
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

    onDrawerStateChanges = BottomDrawer.disposed.listen((opened) {
      print("Drawer state: $opened");
      if (opened) {
        flutterWebviewPlugin.hide();
      }
      else {
        flutterWebviewPlugin.show();
      }
    });
  }

  @override
  void dispose() {
    onDrawerStateChanges?.cancel();
    onStateChangedSub?.cancel();
    onUrlChangedSub?.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;

    print("This is the URL: $mapUrl");
    return SafeArea(
      child: WebviewScaffold(
        scaffoldKey: _scaffoldKey,
        drawer: BottomDrawer(),
        url: mapUrl,
        withJavascript: true,
        withLocalStorage: true,
        headers: {
          "Cookie": bloc.getSessionIdHeader(),
        },
        primary: true,
        // withZoom: true,
        // enableAppScheme:true,
        bottomNavigationBar: BottomAppBar(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                tooltip: "Show navigation drawer",
                icon: Icon(
                  OMIcons.menu,
                  semanticLabel: "Show navigation drawer",
                ),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
                // onPressed: () {
                //   flutterWebviewPlugin.evalJavascript(
                //               'document.cookie = "${bloc.getSessionIdHeader()}";');
                // },
              ),
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
      ),
    );
  }
}
