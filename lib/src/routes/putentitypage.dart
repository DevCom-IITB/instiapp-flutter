import 'dart:async';

import 'package:InstiApp/src/bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class PutEntityPage extends StatefulWidget {
  final String entityID;
  final String cookie;
  final bool isBody;

  PutEntityPage({@required this.cookie, this.entityID, this.isBody = false});

  @override
  _PutEntityPageState createState() => _PutEntityPageState();
}

class _PutEntityPageState extends State<PutEntityPage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final String hostUrl = "https://insti.app/";
  final String addEventStr = "add-event";
  final String editEventStr = "edit-event";
  final String editBodyStr = "edit-body";
  final String loginStr = "login";
  final String sandboxTrueStr = "?sandbox=true";

  bool firstBuild = true;
  bool addedCookie = false;

  StreamSubscription<String> onUrlChangedSub;
  StreamSubscription<WebViewStateChanged> onStateChangedSub;

  @override
  void initState() {
    super.initState();
    var url =
        "$hostUrl${widget.entityID == null ? addEventStr : ((widget.isBody ? editBodyStr : editEventStr) + widget.entityID)}$sandboxTrueStr";
    var loginUrl =
        "$hostUrl$loginStr$sandboxTrueStr";
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

    onStateChangedSub =
        flutterWebviewPlugin.onStateChanged.listen((state) async {
      print(state.type);
      if (state.type == WebViewState.finishLoad) {
        if (state.url == loginUrl) {
          if (!addedCookie) {
            addedCookie = true;
            flutterWebviewPlugin.evalJavascript(
                'document.cookie = "${widget.cookie};domain=insti.app";');
            // print("Cookie injected");
            flutterWebviewPlugin.reloadUrl(url);
            flutterWebviewPlugin.show();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    onUrlChangedSub?.cancel();
    onStateChangedSub?.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;
    var url =
        "$hostUrl${widget.entityID == null ? addEventStr : ((widget.isBody ? editBodyStr : editEventStr) + widget.entityID)}$sandboxTrueStr";
    var loginUrl =
        "$hostUrl$loginStr$sandboxTrueStr";
    return SafeArea(
      child: WebviewScaffold(
        url: addedCookie ? url : loginUrl,
        hidden: true,
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
                tooltip: "Back",
                icon: Icon(
                  OMIcons.arrowBack,
                  semanticLabel: "Go Back",
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
