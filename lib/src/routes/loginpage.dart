// import 'dart:async';
// import 'dart:io';

// import 'package:InstiApp/src/api/interceptors.dart';
// import 'package:InstiApp/src/utils/common_widgets.dart';
// import 'package:InstiApp/src/utils/notif_settings.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webview_pro/webview_flutter.dart' as webview;
// import 'package:InstiApp/src/api/apiclient.dart';
// import 'package:InstiApp/src/api/model/user.dart';
// import 'package:InstiApp/src/bloc_provider.dart';
// import 'package:InstiApp/src/blocs/ia_bloc.dart';
// import 'package:jaguar/jaguar.dart' as jag;
// import 'package:jaguar_flutter_asset/jaguar_flutter_asset.dart';

// class LoginPage extends StatefulWidget {
//   final InstiAppBloc bloc;
//   final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
//   final GlobalKey<NavigatorState>? navigatorKey;
//   LoginPage(this.bloc, {this.scaffoldMessengerKey, this.navigatorKey});

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   jag.Jaguar? server;
//   final Dio dio = Dio();

//   final String successUrl = "https://www.insti.app/login-android.html";
//   final String guestUrl = "https://guesturi";
//   final String alumniUrl = "https://alumniurl";
//   final String gymkhanaUrl = "https://gymkhana.iitb.ac.in";
//   final String httpGymkhanaUrl = "http://gymkhana.iitb.ac.in";
//   final String ssoLogin = "https://sso.iitb.ac.in/login";
//   final String ssoAuth = "https://sso.iitb.ac.in/authorize";
//   InstiAppBloc? _bloc;
//   StreamSubscription<String>? onUrlChangedSub;
//   var loading = true;
//   bool firstBuild = true;
//   // StreamSubscription<WebViewStateChanged>? onStateChangedSub;

//   String statusMessage = "Initializing";

//   String? loginurl;
//   Session? currSession;

//   @override
//   void dispose() {
//     server?.close();

//     onUrlChangedSub?.cancel();
//     // onStateChangedSub?.cancel();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) => setupNotifications(
//         widget.navigatorKey?.currentContext ?? context, widget.bloc));
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       String? args = ModalRoute.of(context)?.settings.arguments as String?;
//       if (args != null) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(args),
//           duration: Duration(seconds: 2),
//         ));
//       }
//     });

//     _bloc = widget.bloc;
//     if (Platform.isAndroid) {
//       webview.WebView.platform = webview.SurfaceAndroidWebView();
//     }

//     // Creating login url
//     loginurl = "http://127.0.0.1:9399/" +
//         ((_bloc!.brightness.toBrightness() == Brightness.dark)
//             ? "login_dark.html"
//             : "login.html");

//     checkLogin().then((Session? sess) {
//       // If session already exists, continue to homepage with current session
//       if (sess != null) {
//         _bloc!.patchFcmKey().then((_) {
//           _bloc?.reloadCurrentUser();
//         });

//         Navigator.of(context).pushReplacementNamed(_bloc!.homepageName);
//         return;
//       }

//       // No stored session found
//       startLoginPageServer().then((_) async {
//         await Future.delayed(Duration(milliseconds: 200));
//         setState(() {
//           loading = false;
//         });
//       });
//     });
//   }

//   Future<Session?> checkLogin() async {
//     await _bloc?.restorePrefs();
//     return _bloc?.currSession;
//   }

//   @override
//   Widget build(BuildContext context) {
//     _bloc = BlocProvider.of(context)!.bloc;

//     if (firstBuild) {
//       if (widget.scaffoldMessengerKey?.currentContext != null &&
//           widget.navigatorKey != null) {
//         if (widget.bloc.dio.interceptors.length == 0)
//           widget.bloc.dio
//             ..interceptors.add(ErrorInterceptor(
//                 context: widget.scaffoldMessengerKey!.currentContext!,
//                 navigatorKey: widget.navigatorKey!));
//       }
//       firstBuild = false;
//     }

//     return loading
//         ? Material(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   Image(
//                     color: Theme.of(context).colorScheme.secondary,
//                     image: AssetImage('assets/login/lotus.png'),
//                     width: 250.0,
//                     fit: BoxFit.scaleDown,
//                   ),
//                   Text(
//                     "InstiApp",
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                         color: Theme.of(context).colorScheme.secondary),
//                   ),
//                   CircularProgressIndicatorExtended(
//                     label: Text(statusMessage),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         : webview.WebView(
//             javascriptMode: webview.JavascriptMode.unrestricted,
//             initialUrl: loginurl,
//             onPageStarted: checkPageUrl,
//             onPageFinished: checkPageUrl,
//             gestureNavigationEnabled: true,
//           );
//   }

//   Future<void> checkPageUrl(String url) async {
//     if (url.startsWith(successUrl)) {
//       var uri = Uri.parse(url);
//       var code = uri.queryParameters['code'];

//       setState(() {
//         loading = true;
//       });
//       await login(code ?? "", "https://www.insti.app/login-android.html");
//       setState(() {
//         loading = false;
//       });
//     } else if (url.startsWith(guestUrl)) {
//       setState(() {
//         loading = true;
//       });
//       Navigator.of(context)
//           .pushNamedAndRemoveUntil(_bloc!.homepageName, (r) => false);
//     } else if (url.startsWith(alumniUrl)) {
//       // print(alumniUrl);
//       setState(() {
//         loading = true;
//       });
//       Navigator.of(context)
//           .pushNamedAndRemoveUntil(_bloc!.alumniLoginPage, (r) => false);
//     }
//   }

//   Future<void> startLoginPageServer() async {
//     server = jag.Jaguar(port: 9399, multiThread: true);
//     server?.addRoute(serveFlutterAssets(prefix: "login/"));
//     return server?.serve();
//   }

//   login(final String authCode, final String redirectUrl) async {
//     setState(() {
//       statusMessage = "Logging you in";
//     });
//     var response;
//     try {
//       response = await InstiAppApi(dio).login(authCode, redirectUrl);
//     } catch (e) {
//       // print(e);
//     }
//     if (response?.sessionid != null) {
//       _bloc?.updateSession(response);
//       setState(() {
//         statusMessage = "Logged in";
//       });
//       _bloc?.patchFcmKey();

//       Navigator.of(context).pushReplacementNamed(_bloc?.homepageName ?? "");

//       this.onUrlChangedSub?.cancel();
//     } else {
//       setState(() {
//         statusMessage = "Log in failed. Reinitializing.";
//       });
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Authentication Failed"),
//       ));
//     }
//   }
// }

import 'dart:async';
import 'dart:io';

import 'package:InstiApp/src/api/apiclient.dart';
import 'package:InstiApp/src/api/interceptors.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/notif_settings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart' as webview;

class LoginPage extends StatefulWidget {
  final InstiAppBloc bloc;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final GlobalKey<NavigatorState>? navigatorKey;
  
  LoginPage(this.bloc, {this.scaffoldMessengerKey, this.navigatorKey});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final String successUrl = "https://www.insti.app/login-android.html";
  final String guestUrl = "https://guesturi";
  final String alumniUrl = "https://alumniurl";
  InstiAppBloc? _bloc;
  bool _loading = true;
  bool _isWebViewVisible = false;
  bool _isSSOLoading = false;
  String _statusMessage = "Initializing";
  String? _webViewUrl;
  Session? currSession;
  bool _processingSSO = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => setupNotifications(
        widget.navigatorKey?.currentContext ?? context, widget.bloc));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      if (args != null && widget.scaffoldMessengerKey != null) {
        widget.scaffoldMessengerKey!.currentState?.showSnackBar(SnackBar(
          content: Text(args),
          duration: const Duration(seconds: 2),
        ));
      }
    });

    _bloc = widget.bloc;
    if (Platform.isAndroid) {
      webview.WebView.platform = webview.SurfaceAndroidWebView();
    }

    checkLogin().then((Session? sess) {
      if (sess != null) {
        _bloc!.patchFcmKey().then((_) {
          _bloc?.reloadCurrentUser();
        });
        Navigator.of(context).pushReplacementNamed(_bloc!.homepageName);
        return;
      }
      
      setState(() {
        _loading = false;
      });
    });
  }

  Future<Session?> checkLogin() async {
    await _bloc?.restorePrefs();
    return _bloc?.currSession;
  }

  @override
  Widget build(BuildContext context) {
    if (_processingSSO) {
      return _buildLoadingScreen(context);
    }
    
    if (_isWebViewVisible) {
      return _buildWebView();
    }

    return _buildLoginOptions(context);
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image(
              color: Theme.of(context).colorScheme.secondary,
              image: const AssetImage('assets/login/lotus.png'),
              width: 250.0,
              fit: BoxFit.scaleDown,
            ),
            Text(
              "InstiApp",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary),
            ),
            CircularProgressIndicatorExtended(
              label: Text(_statusMessage),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF0028BF) : const Color(0xFFFFD740);
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    if (_loading) {
      return _buildLoadingScreen(context);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                margin: const EdgeInsets.only(top: 50),
                child: Image.asset(
                  'assets/login/lotus.png',
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "InstiApp",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w200,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 100),
              
              // Login Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    if (_isSSOLoading)
                      Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Redirecting to SSO...",
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: _handleSSOLogin,
                          child: const Text(
                            "LOG IN VIA SSO",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      "or",
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: _handleAlumniLogin,
                        child: const Text(
                          "LOG IN AS AN ALUMNUS",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "or",
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _handleGuestLogin,
                      child: Text(
                        "CONTINUE AS A GUEST",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w200,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return Scaffold(
      body: Stack(
        children: [
          webview.WebView(
            javascriptMode: webview.JavascriptMode.unrestricted,
            initialUrl: _webViewUrl,
            onPageStarted: (url) {
              if (url.startsWith(successUrl)) {
                // Immediately hide the WebView and show loading
                setState(() {
                  _isWebViewVisible = false;
                  _processingSSO = true;
                  _statusMessage = "Logging you in";
                });
                _handleSuccessUrl(url);
              } else if (url.startsWith(guestUrl)) {
                _handleGuestLogin();
              } else if (url.startsWith(alumniUrl)) {
                _handleAlumniLogin();
              }
            },
            gestureNavigationEnabled: true,
          ),
        ],
      ),
    );
  }

  void _handleSSOLogin() {
    setState(() {
      _isSSOLoading = true;
    });

    // Simulate the delay from the HTML loading animation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isWebViewVisible = true;
        _isSSOLoading = false;
        _webViewUrl = "https://gymkhana.iitb.ac.in/profiles/oauth/authorize/?client_id=vR1pU7wXWyve1rUkg0fMS6StL1Kr6paoSmRIiLXJ&response_type=code&scope=basic%20profile%20picture%20sex%20ldap%20phone%20insti_address%20program%20secondary_emails&redirect_uri=https://www.insti.app/login-android.html";
      });
    });
  }

  void _handleAlumniLogin() {
    setState(() {
      _loading = true;
      _statusMessage = "Redirecting to alumni login";
    });
    Navigator.of(context)
        .pushNamedAndRemoveUntil(_bloc!.alumniLoginPage, (r) => false);
  }

  void _handleGuestLogin() {
    setState(() {
      _loading = true;
      _statusMessage = "Continuing as guest";
    });
    Navigator.of(context)
        .pushNamedAndRemoveUntil(_bloc!.homepageName, (r) => false);
  }

  Future<void> _handleSuccessUrl(String url) async {
    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];
    
    if (code != null) {
      try {
        // Use the bloc's dio instance instead of creating a new one
        final response = await InstiAppApi(_bloc!.dio).login(
          code, 
          "https://www.insti.app/login-android.html",
        );
        
        if (response.sessionid != null) {
          _bloc?.updateSession(response);
          setState(() {
            _statusMessage = "Logged in";
          });
          await _bloc?.patchFcmKey();

          Navigator.of(context).pushReplacementNamed(_bloc?.homepageName ?? "");
        } else {
          setState(() {
            _statusMessage = "Log in failed. Reinitializing.";
          });
          if (widget.scaffoldMessengerKey != null) {
            widget.scaffoldMessengerKey!.currentState?.showSnackBar(
              const SnackBar(content: Text("Authentication Failed")),
            );
          }
          setState(() {
            _processingSSO = false;
          });
        }
      } catch (e) {
        setState(() {
          _statusMessage = "Error: ${e.toString()}";
        });
        if (widget.scaffoldMessengerKey != null) {
          widget.scaffoldMessengerKey!.currentState?.showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
        }
        setState(() {
          _processingSSO = false;
        });
      }
    } else {
      setState(() {
        _statusMessage = "Authorization code not found";
      });
      if (widget.scaffoldMessengerKey != null) {
        widget.scaffoldMessengerKey!.currentState?.showSnackBar(
          const SnackBar(content: Text("Authorization failed")),
        );
      }
      setState(() {
        _processingSSO = false;
      });
    }
  }
}