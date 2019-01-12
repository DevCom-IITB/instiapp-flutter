import 'dart:async';

import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  final String addEventUrl = "https://insti.app/add-event?sandbox=true";

  StreamSubscription<String> onUrlChangedSub;

  @override
  void initState() {
    super.initState();
    onUrlChangedSub = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      print("Changed URL: $url");
      if (url.contains("/event/")) {
        var uri = url.substring(url.lastIndexOf("/") + 1);

        Navigator.of(context).pushReplacementNamed("/event/$uri");
      } else if (url.contains("/org/")) {
        var uri = url.substring(url.lastIndexOf("/") + 1);

        Navigator.of(context).pushReplacementNamed("/body/$uri");
      }
    });
  }

  @override
    void dispose() {
      onUrlChangedSub?.cancel();
      flutterWebviewPlugin.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;

    return WebviewScaffold(
      url: addEventUrl,
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
              tooltip: "Show bottom sheet",
              icon: Icon(
                OMIcons.menu,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: null,
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
    );
  }
}
