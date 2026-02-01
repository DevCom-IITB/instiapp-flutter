import 'dart:async';

import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaguar/jaguar.dart' as jag;
import 'package:flutter_webview_pro/webview_flutter.dart' as webview;
import 'package:InstiApp/constants.dart';

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
  Constants myConstants = Constants();

  // Storing for dispose
  ThemeData? theme;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    mapUrl =
        ("https://www.insti.app/map/${Uri.encodeComponent(widget.location ?? "")}?sandbox=true");
    super.initState();
    print(mapUrl);
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
      body: Stack(
        children: [
          
          Positioned.fill(
            child: webview.WebView(
              initialUrl: mapUrl,
              javascriptMode: webview.JavascriptMode.unrestricted,
              onWebViewCreated: (webview.WebViewController webViewController) {
                this.webViewController = webViewController;
              },
              zoomEnabled: false,
              geolocationEnabled: true,
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(235, 235, 235, 0.8),
                  borderRadius: BorderRadius.circular(32.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4.0,
                      spreadRadius: 2.0,
                      offset: Offset(0.0, 2.0),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  elevation: 2,
                  shape: CircleBorder(),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/blogs/arrow-left.svg',
                      height: Responsive.height(24.0, context),
                      width: Responsive.width(24.0, context),
                      fit: BoxFit.none,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            child: SafeArea(
              child: Container(
                width: Responsive.width(300, context),
                margin: EdgeInsets.symmetric(horizontal: Responsive.width(70, context)),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: myConstants.instiappGrey,
                  borderRadius: BorderRadius.circular(32.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4.0,
                      spreadRadius: 2.0,
                      offset: Offset(0.0, 2.0),
                    ),
                  ],
                ),                
                child: Text(
                  "This Page is Under Development",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: Responsive.text(18, context),
                  fontWeight: FontWeight.w900,
                  color: myConstants.instiappBlue,
                ),
                            ),
              ),
          ),)
          
        ],
      ),
    );
  }
}
