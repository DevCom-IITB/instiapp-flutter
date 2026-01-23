import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart' as webview;

import 'package:InstiApp/src/api/apiclient.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/notif_settings.dart';
import 'package:InstiApp/src/utils/responsive.dart';

class LoginPage extends StatefulWidget {
  final InstiAppBloc bloc;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final GlobalKey<NavigatorState>? navigatorKey;

  const LoginPage(
    this.bloc, {
    Key? key,
    this.scaffoldMessengerKey,
    this.navigatorKey,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _OnboardingLoginPageState();
}

class _OnboardingLoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  late AnimationController _resizeController;
  late final AnimationController _moveController;
  late AnimationController _welcomeController;
  late AnimationController _homeTransitionController;
  late AnimationController _transitionController;
  bool _showWelcome = false;
  bool _showLoginOptions = false;
  bool _isExitingToHome = false;

  final String successUrl = "https://www.insti.app/login-android.html";
  final String guestUrl = "https://guesturi";
  final String alumniUrl = "https://alumniurl";
  bool _isWebViewVisible = false;
  bool _processingSSO = false;
  bool _isSSOLoading = false;
  String? _webViewUrl;
  String _statusMessage = "Initializing";
  bool _loading = true;

  InstiAppBloc? _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = widget.bloc;

    if (Platform.isAndroid) {
      webview.WebView.platform = webview.SurfaceAndroidWebView();
    }

    /// Always restore session first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setupNotifications(
          widget.navigatorKey?.currentContext ?? context, _bloc!);

      /// Any toast from args
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      if (args != null && widget.scaffoldMessengerKey != null) {
        widget.scaffoldMessengerKey!.currentState?.showSnackBar(
          SnackBar(content: Text(args)),
        );
      }
    });

    _resizeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _homeTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _restoreSessionAndAnimate();
  }

  Future<void> _restoreSessionAndAnimate() async {
    await _bloc?.restorePrefs();

    await Future.delayed(const Duration(milliseconds: 500));
    await _resizeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    if (_bloc?.currSession == null) {
      setState(() => _showWelcome = true);
      _moveController.forward();
      _welcomeController.forward();
    } else {
      setState(() {
        _isExitingToHome = true;
      });

      await Future.wait([
        _homeTransitionController.forward(),
        _bloc!.patchFcmKey(),
        _bloc!.reloadCurrentUser(),
      ]);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(_bloc!.homepageName);
      }
    }
  }

  @override
  void dispose() {
    _resizeController.dispose();
    _welcomeController.dispose();
    _moveController.dispose();
    _homeTransitionController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_processingSSO) return _buildLoadingScreen(context);
    if (_isWebViewVisible) return _buildWebView();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _showLoginOptions
          ? _buildLoginOptionsPage(context)
          : _buildSplashOnboarding(context),
    );
  }

  Widget _buildSplashOnboarding(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(234, 245, 251, 1),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation:
                Listenable.merge([_moveController, _homeTransitionController]),
            builder: (context, _) {
              final screenHeight = MediaQuery.of(context).size.height;
              double offsetY = 0;
              double opacity = 0.2;

              if (_isExitingToHome) {
                final tHome = _homeTransitionController.value;
                final curvedValue = Curves.easeInOutCubic.transform(tHome);

                offsetY = lerpDouble(0, -screenHeight, curvedValue)!;
                opacity = lerpDouble(0.2, 0.0, curvedValue)!;
              } else {
                final tMove = _moveController.value;
                offsetY = lerpDouble(0, -screenHeight, tMove)!;
              }

              return Transform.translate(
                offset: Offset(0, offsetY),
                child: Opacity(
                  opacity: opacity,
                  child: _buildBackgroundLotuses(),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: Listenable.merge([
              _resizeController,
              _moveController,
              _homeTransitionController
            ]),
            builder: (context, _) {
              final tResize = _resizeController.value;
              final tMove = _moveController.value;
              final tHome = _homeTransitionController.value;

              final screen = MediaQuery.of(context).size;
              final centerX = screen.width / 2;
              final centerY = screen.height / 2;

              double logoSize = lerpDouble(
                  RS.sw(context, 300), RS.sw(context, 150), tResize)!;
              double fontSize =
                  lerpDouble(RS.sp(context, 64), RS.sp(context, 48), tResize)!;

              // Phase 1: stacked center
              final logoStartX = centerX - logoSize / 2;
              final logoStartY = centerY - logoSize / 2;

              final textStartX = centerX - fontSize * 2;
              final textStartY = centerY + logoSize / 2 - RS.sh(context, 10);

              // Phase 2: shrink + align horizontally (still centered)
              final totalWidth = logoSize + RS.sw(context, 20) + fontSize * 8;
              final logoMidX = centerX - totalWidth / 3;
              final logoMidY = centerY - logoSize / 2;

              final textMidX = logoMidX + logoSize + RS.sw(context, 20);
              final textMidY = centerY - fontSize / 2;

              // Phase 3: move entire pair to top
              final logoEndX = logoMidX;
              final logoEndY = RS.sh(context, 20);

              final textEndX = textMidX;
              final textEndY = logoEndY + logoSize / 2 - fontSize / 2;

              double currentLogoX = lerpDouble(
                  lerpDouble(logoStartX, logoMidX, tResize)!, logoEndX, tMove)!;
              double currentLogoY = lerpDouble(
                  lerpDouble(logoStartY, logoMidY, tResize)!, logoEndY, tMove)!;

              double currentTextX = lerpDouble(
                  lerpDouble(textStartX, textMidX, tResize)!, textEndX, tMove)!;
              double currentTextY = lerpDouble(
                  lerpDouble(textStartY, textMidY, tResize)!, textEndY, tMove)!;

              double textOpacity = 1.0;

              if (_isExitingToHome) {
                logoSize =
                    lerpDouble(RS.sw(context, 150), RS.sw(context, 40), tHome)!;
                fontSize = lerpDouble(RS.sp(context, 48), 0, tHome)!;

                final startX = centerX - totalWidth / 3;
                final endX = centerX - logoSize / 2;
                final startY = centerY - logoSize / 2;

                currentLogoX = lerpDouble(startX, endX, tHome)!;
                currentLogoY = lerpDouble(startY, RS.sh(context, 32), tHome)!;

                textOpacity = lerpDouble(1.0, 0.0, tHome)!;
              }

              return Stack(
                children: [
                  Positioned(
                    left: currentLogoX,
                    top: currentLogoY,
                    child: Image.asset(
                      'assets/login/lotus.png',
                      width: logoSize,
                      height: logoSize,
                    ),
                  ),
                  Positioned(
                    left: currentTextX,
                    top: currentTextY,
                    child: Opacity(
                      opacity: _isExitingToHome ? textOpacity : 1.0,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Insti',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            TextSpan(
                              text: 'App',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (_showWelcome) ...[
            /// Slide up the illustration
            SlideTransition(
              position: _welcomeController.drive(
                Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOut)),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildClippedIllustrationWithWhiteBackground(),
              ),
            ),

            /// Slide up the text + button
            SlideTransition(
              position: _welcomeController.drive(
                Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOut)),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildGetStartedScreen(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackgroundLotuses() {
    final List<double> tops = [
      RS.sh(context, -28),
      RS.sh(context, 66),
      RS.sh(context, 122),
      RS.sh(context, 217),
      RS.sh(context, 547),
      RS.sh(context, 531),
      RS.sh(context, 625),
      RS.sh(context, 766)
    ];
    final List<double> lefts = [
      RS.sw(context, 42),
      RS.sw(context, 299),
      RS.sw(context, -21),
      RS.sw(context, 249),
      RS.sw(context, -34),
      RS.sw(context, 208),
      RS.sw(context, 0),
      RS.sw(context, 251)
    ];
    final List<double> sizes = [
      RS.sw(context, 236),
      RS.sw(context, 151),
      RS.sw(context, 227),
      RS.sw(context, 102),
      RS.sw(context, 139),
      RS.sw(context, 189),
      RS.sw(context, 278),
      RS.sw(context, 161)
    ];

    return Stack(
      children: List.generate(8, (index) {
        return Positioned(
          left: lefts[index],
          top: tops[index],
          child: Image.asset(
            'assets/login/lotus.png',
            width: sizes[index],
            height: sizes[index],
            color: Colors.blue,
          ),
        );
      }),
    );
  }

  Widget _buildClippedIllustrationWithWhiteBackground() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: RS.sh(context, 412 + 250),
          color: Colors.white,
        ),
        ClipPath(
          clipper: BottomCurveClipper(curveDepth: 25),
          child: Image.asset(
            'assets/login/campus_illustration.png',
            width: MediaQuery.of(context).size.width,
            height: RS.sh(context, 412),
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildGetStartedScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Making Student Life",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Simpler ',
                style: TextStyle(
                  color: Color(0xFF306FDC), // Hex: #306FDC
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: 'and ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: 'Smarter',
                style: TextStyle(
                  color: Color(0xFF306FDC),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: RS.sw(context, 300),
          height: RS.sh(context, 64),
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                _showLoginOptions = true;
              });

              await Future.delayed(const Duration(milliseconds: 100));

              await _transitionController.forward();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Get Started",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: RS.sh(context, 60)),
      ],
    );
  }

  Widget _buildLoginOptionsPage(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_transitionController.value);
        final fadeT = Curves.easeIn.transform(_transitionController.value);

        // DOODLE: slide from above into final top (-10)
        final doodleStartTop = -screen.height * 0.6; // off-screen above
        final doodleEndTop = -10.0;
        final doodleTop = lerpDouble(doodleStartTop, doodleEndTop, t)!;

        // LOGO + TITLE: warp from center (splash) into top-left area of login page
        final centerX = screen.width / 2;
        final centerY = screen.height / 2;

        // approximate start size from splash final (after resize)
        final startLogoSize = RS.sw(context, 150); // near-center smaller size
        final endLogoSize = RS.sw(context, 200); // login page logo size
        final logoSize = lerpDouble(startLogoSize, endLogoSize, t)!;

        // start position (centered), end position (login page coordinates)
        final logoStartX = centerX - startLogoSize / 2;
        final logoStartY = centerY - startLogoSize / 2;
        final logoEndX = 5.0; // matches previous left: 5
        final logoEndY = 291.0; // matches previous top: 291

        final currentLogoX = lerpDouble(logoStartX, logoEndX, t)!;
        final currentLogoY = lerpDouble(logoStartY, logoEndY, t)!;

        // TITLE: fades slightly and moves to align with logo
        final titleStartX = centerX - RS.sp(context, 64) * 2;
        final titleStartY = centerY + startLogoSize / 2 - RS.sh(context, 10);
        final titleEndX = logoEndX + logoSize + RS.sw(context, 8);
        final titleEndY = logoEndY + logoSize / 2 - RS.sp(context, 28);

        final currentTitleX = lerpDouble(titleStartX, titleEndX, t)!;
        final currentTitleY = lerpDouble(titleStartY, titleEndY, t)!;

        final titleOpacity = lerpDouble(1.0, 1.0, t)!; // keep visible

        // CLIPPER + OPTIONS: slide up from bottom and fade
        final clipperStartY = screen.height;
        final clipperEndY = 300;
        final clipperOffsetY = lerpDouble(clipperStartY, clipperEndY, t)!;
        final optionsOpacity = fadeT;

        // small background parallax during transition (subtle)
        final bgParallax = lerpDouble(0, -20, t)!;

        return Scaffold(
          backgroundColor: Color.fromRGBO(15, 22, 32, 1),
          body: Stack(
            children: [
              // top doodle (animated from above)
              Positioned(
                top: doodleTop,
                left: -20,
                child: Opacity(
                  opacity: fadeT,
                  child: Image.asset(
                    'assets/login/doodle.png',
                    height: RS.sh(context, 600),
                  ),
                ),
              ),

              // logo (warping)
              Positioned(
                left: currentLogoX,
                top: currentLogoY,
                child: Image.asset(
                  'assets/login/lotuslight.png',
                  width: logoSize,
                  height: logoSize,
                ),
              ),

              // MAIN CONTENT: clipper image + options card which slides up from bottom
              Positioned(
                top: clipperOffsetY,
                left: 0,
                right: 0,
                bottom: 0,
                child: Opacity(
                  opacity: optionsOpacity,
                  child: Container(
                    // transparent container; clipper inside
                    child: Stack(
                      children: [
                        Positioned(
                          top: RS.sh(context, 110),
                          left: 0,
                          right: 0,
                          child: Image.asset(
                            'assets/login/clipper.png',
                            // optionally animate scale or translate if you want
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: _buildLoginOptions(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginOptions(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(RS.s(context, 24)), // Responsive padding
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: RS.sh(context, 176)), // Use sh for vertical spacing

            // Fix for "InstiApp" text
            Text(
              "InstiApp",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: RS.sp(context, 48), // Responsive text
                color: const Color.fromRGBO(27, 50, 82, 1),
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),

            // Fix for "Your Campus Companion" text
            Text(
              "Your Campus Companion",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: RS.sp(context, 24), // Responsive text
                color: const Color.fromRGBO(27, 50, 82, 1),
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),

            SizedBox(height: RS.s(context, 48)), // Uniform spacing

            SizedBox(
              width: RS.sw(context, 260), // Responsive button width
              height: RS.s(context, 53), // Responsive button height
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(48, 111, 220, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        RS.s(context, 16)), // Responsive radius
                  ),
                ),
                onPressed: _handleSSOLogin,
                child: Text(
                  _isSSOLoading ? "Redirecting to SSO..." : "Log in via SSO",
                  style: TextStyle(
                    fontSize: RS.sp(context, 20), // Responsive text
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ),

            SizedBox(height: RS.s(context, 8)), // Uniform spacing

            Text(
              "or",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: RS.sp(context, 16), // Responsive text
                color: const Color.fromRGBO(33, 45, 60, 1),
                fontWeight: FontWeight.w400,
                fontFamily: 'DM Sans',
              ),
            ),

            SizedBox(height: RS.s(context, 8)), // Uniform spacing

            SizedBox(
              width: RS.sw(context, 260), // Responsive button width
              height: RS.s(context, 53), // Responsive button height
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(48, 111, 220, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        RS.s(context, 16)), // Responsive radius
                  ),
                ),
                onPressed: _handleAlumniLogin,
                child: Text(
                  "Log in as an Alumnus",
                  style: TextStyle(
                    fontSize: RS.sp(context, 20), // Responsive text
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ),

            SizedBox(height: RS.s(context, 8)), // Uniform spacing

            Text(
              "or",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: RS.sp(context, 16), // Responsive text
                color: const Color.fromRGBO(33, 45, 60, 1),
                fontWeight: FontWeight.w400,
                fontFamily: 'DM Sans',
              ),
            ),

            SizedBox(height: RS.s(context, 8)), // Uniform spacing

            Container(
              width: double.infinity,
              child: TextButton(
                onPressed: _handleGuestLogin,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Continue as Guest",
                      style: TextStyle(
                        fontSize: RS.sp(context, 20), // Responsive text
                        fontWeight: FontWeight.w500,
                        color: const Color.fromRGBO(48, 111, 220, 1),
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return Scaffold(
      body: webview.WebView(
        javascriptMode: webview.JavascriptMode.unrestricted,
        initialUrl: _webViewUrl,
        navigationDelegate: (request) {
          if (request.url.startsWith(successUrl)) {
            setState(() {
              _isWebViewVisible = false;
              _processingSSO = true;
              _statusMessage = "Logging you in";
            });
            _handleSuccessUrl(request.url);
            return webview.NavigationDecision.prevent;
          } else if (request.url.startsWith(guestUrl)) {
            _handleGuestLogin();
            return webview.NavigationDecision.prevent;
          } else if (request.url.startsWith(alumniUrl)) {
            _handleAlumniLogin();
            return webview.NavigationDecision.prevent;
          }
          return webview.NavigationDecision.navigate;
        },
        gestureNavigationEnabled: true,
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/login/lotus.png', width: RS.sw(context, 250)),
            const SizedBox(height: 20),
            const Text("InstiApp",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CircularProgressIndicatorExtended(label: Text(_statusMessage)),
          ],
        ),
      ),
    );
  }

  void _handleSSOLogin() {
    setState(() {
      _isSSOLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isWebViewVisible = true;
        _isSSOLoading = false;
        _webViewUrl =
            "https://gymkhana.iitb.ac.in/profiles/oauth/authorize/?client_id=vR1pU7wXWyve1rUkg0fMS6StL1Kr6paoSmRIiLXJ&response_type=code&scope=basic%20profile%20picture%20sex%20ldap%20phone%20insti_address%20program%20secondary_emails&redirect_uri=https://www.insti.app/login-android.html";
      });
    });
  }

  void _handleAlumniLogin() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(_bloc!.alumniLoginPage, (r) => false);
  }

  void _handleGuestLogin() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(_bloc!.homepageName, (r) => false);
  }

  Future<void> _handleSuccessUrl(String url) async {
    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];

    if (code != null) {
      try {
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

class BottomCurveClipper extends CustomClipper<Path> {
  final double curveDepth;

  BottomCurveClipper({this.curveDepth = 80});

  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 26);

    path.quadraticBezierTo(
      size.width / 5,
      size.height + curveDepth,
      0,
      size.height - 132,
    );

    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
