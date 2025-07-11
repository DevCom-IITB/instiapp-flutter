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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_processingSSO) return _buildLoadingScreen(context);
    if (_isWebViewVisible) return _buildWebView();

    return _showLoginOptions
        ? _buildLoginOptionsPage(context)
        : _buildSplashOnboarding(context);
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

              double logoSize = lerpDouble(300, 150, tResize)!;
              double fontSize = lerpDouble(64, 48, tResize)!;

              // Phase 1: stacked center
              final logoStartX = centerX - logoSize / 2;
              final logoStartY = centerY - logoSize / 2;

              final textStartX = centerX - fontSize * 2;
              final textStartY = centerY + logoSize / 2 - 10;

              // Phase 2: shrink + align horizontally (still centered)
              final totalWidth = logoSize + 20 + fontSize * 8;
              final logoMidX = centerX - totalWidth / 3;
              final logoMidY = centerY - logoSize / 2;

              final textMidX = logoMidX + logoSize + 20;
              final textMidY = centerY - fontSize / 2;

              // Phase 3: move entire pair to top
              final logoEndX = logoMidX;
              final logoEndY = 20;

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
                logoSize = lerpDouble(150, 40, tHome)!;
                fontSize = lerpDouble(48, 0, tHome)!;

                final startX = centerX - totalWidth / 3;
                final endX = centerX - logoSize / 2;
                final startY = centerY - logoSize / 2;

                currentLogoX = lerpDouble(startX, endX, tHome)!;
                currentLogoY = lerpDouble(startY, 32, tHome)!;

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
    final List<double> tops = [-28, 66, 122, 217, 547, 531, 625, 766];
    final List<double> lefts = [42, 299, -21, 249, -34, 208, 0, 251];
    final List<double> sizes = [236, 151, 227, 102, 139, 189, 278, 161];

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
          width: 412,
          height: 412 + 250,
          color: Colors.white,
        ),
        ClipPath(
          clipper: BottomCurveClipper(curveDepth: 25),
          child: Image.asset(
            'assets/login/campus_illustration.png',
            width: 412,
            height: 412,
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
          width: 300,
          height: 64,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _showLoginOptions = true;
              });
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
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildLoginOptionsPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Get Started.",
                    style: TextStyle(
                        fontSize: 36,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "All Things Insti",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                  ),
                  Text(
                    "Right at your fingertips.",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 50),
                  Image.asset(
                    'assets/login/person_illustration.png',
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildLoginOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginOptions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color.fromRGBO(15, 22, 32, 1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: _handleGuestLogin,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Continue as Guest",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(48, 111, 220, 1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _handleSSOLogin,
              child: Text(
                _isSSOLoading ? "Redirecting to SSO..." : "Log in via SSO",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(48, 111, 220, 1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _handleAlumniLogin,
              child: const Text(
                "Log in as an Alumnus",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return Scaffold(
      body: webview.WebView(
        javascriptMode: webview.JavascriptMode.unrestricted,
        initialUrl: _webViewUrl,
        onPageStarted: (url) {
          if (url.startsWith(successUrl)) {
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
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/login/lotus.png', width: 250),
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
