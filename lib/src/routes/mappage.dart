import 'dart:async';

import 'package:InstiApp/src/utils/responsivenew.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaguar/jaguar.dart' as jag;
import 'package:flutter_webview_pro/webview_flutter.dart' as webview;

class MapPage extends StatefulWidget {
  final String? location;
  MapPage({this.location});
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const String _locationInputFixScript = r'''
    (function () {
      if (window.__instiappLocationInputFixInstalled) return;
      window.__instiappLocationInputFixInstalled = true;

      var clearedByUser = false;
      var input = null;
      var locationLabel = "My current location";

      document.addEventListener("input", function (event) {
        if (event.target && event.target.id === "fromInput" && event.isTrusted) {
          clearedByUser = event.target.value.trim() === "";
        }
      }, true);

      document.addEventListener("click", function (event) {
        var button = event.target && event.target.closest(
          '[aria-label="Use my current location"], [title="Use my current location"]'
        );
        if (button) clearedByUser = false;
      }, true);

      window.setInterval(function () {
        input = document.getElementById("fromInput");
        if (!input || !clearedByUser || input.value !== locationLabel) return;

        var setter = Object.getOwnPropertyDescriptor(
          HTMLInputElement.prototype, "value"
        ).set;
        setter.call(input, "");
      }, 100);
    })();
  ''';

  late jag.Jaguar server;

  static const String mapBaseUrl = "https://iitbmap.pages.dev/";

  String get mapUrl {
    final location = widget.location?.trim();
    if (location == null || location.isEmpty) return mapBaseUrl;

    final slug = location
        .toLowerCase()
        .replaceAll("&", " and ")
        .replaceAll(RegExp(r"[^a-z0-9]+"), "-")
        .replaceAll(RegExp(r"^-|-$"), "");
    return "${mapBaseUrl}b/${Uri.encodeComponent(slug)}/";
  }

  StreamSubscription<String>? onUrlChangedSub;
  webview.WebViewController? webViewController;

  // Storing for dispose
  ThemeData? theme;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

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
              onPageFinished: (String url) {
                if (!url.startsWith(mapBaseUrl)) return;
                webViewController
                    ?.runJavascript(_locationInputFixScript)
                    .catchError((Object error) {
                  debugPrint('Failed to adjust map location input: $error');
                });
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
        ],
      ),
    );
  }
}
