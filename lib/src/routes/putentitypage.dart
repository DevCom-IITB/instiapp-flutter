import 'dart:async';

import 'package:InstiApp/src/utils/common_widgets.dart';
// import 'package:InstiApp/src/utils/safe_webview_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PutEntityPage extends StatefulWidget {
  final String? entityID;
  final String cookie;
  final bool isBody;

  PutEntityPage({required this.cookie, this.entityID, this.isBody = false});

  @override
  _PutEntityPageState createState() => _PutEntityPageState();
}

class _PutEntityPageState extends State<PutEntityPage> {

  final String hostUrl = "https://insti.app/";
  final String addEventStr = "add-event";
  final String editEventStr = "edit-event";
  final String editBodyStr = "edit-body";
  final String loginStr = "login";
  final String sandboxTrueQParam = "sandbox=true";

  bool firstBuild = true;
  bool addedCookie = false;

  StreamSubscription<String>? onUrlChangedSub;
  WebViewController? webViewController;

  // Storing for dispose
  ThemeData? theme;

  @override
  void initState() {
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
    var url =
        "$hostUrl${widget.entityID == null ? addEventStr : ((widget.isBody ? editBodyStr : editEventStr) + "/" + widget.entityID!)}?${widget.cookie}&$sandboxTrueQParam";
    return Scaffold(bottomNavigationBar: MyBottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            BackButton(),
            IconButton(
              tooltip: "Refresh",
              icon: Icon(
                Icons.refresh_outlined,
                semanticLabel: "Refresh",
              ),
              onPressed: () {
                webViewController?.reload();
              },
            ),
          ],
        ),
      ),
      body: WebView(
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (controller){
        webViewController = controller;
      },
      initialUrl: url,
      onPageStarted: (url) async{
        print("Changed URL: $url");
        if (url.contains("/event/")) {
          var uri = url.substring(url.lastIndexOf("/") + 1);

          Navigator.of(context).pushReplacementNamed("/event/$uri");
        } else if (url.contains("/org/")) {
          var uri = url.substring(url.lastIndexOf("/") + 1);

          Navigator.of(context).pushReplacementNamed("/body/$uri");
        }
      },
      onPageFinished: (url){
        
      },
      gestureNavigationEnabled: true,
    ),);
  }
}
