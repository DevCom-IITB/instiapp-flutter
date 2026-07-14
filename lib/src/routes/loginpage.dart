import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_webview_pro/webview_flutter.dart' as webview;

import 'package:InstiApp/src/api/apiclient.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/notif_settings.dart';
import 'package:InstiApp/src/utils/responsive.dart';

double figmaFontSize(
  BuildContext context,
  double figmaPx, {
  double baseWidth = 375,
}) {
  final media = MediaQuery.of(context);
  final screenWidth = media.size.width;
  final scaleFactor = screenWidth / baseWidth;

  return figmaPx * scaleFactor * media.textScaleFactor;
}

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
  bool _showLoadingDesign = false;

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
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && widget.scaffoldMessengerKey != null) {
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

  Future<void> safeNetworkCall(Future<void> Function() fn) async {
    try {
      await fn().timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  // Future<void> _restoreSessionAndAnimate() async {
  //   await _bloc?.restorePrefs();

  //   await Future.delayed(const Duration(milliseconds: 500));
  //   await _resizeController.forward();
  //   await Future.delayed(const Duration(milliseconds: 300));

  //   if (_bloc?.currSession == null) {
  //     setState(() => _showWelcome = true);
  //     _moveController.forward();
  //     _welcomeController.forward();
  //   } else {
  //     setState(() {
  //       _isExitingToHome = true;
  //     });

  //     await _homeTransitionController.forward();

  //     await Future.wait([
  //       safeNetworkCall(() => _bloc!.patchFcmKey()),
  //       safeNetworkCall(() => _bloc!.reloadCurrentUser()),
  //     ]);

  //     if (mounted) {
  //       Navigator.of(context).pushReplacementNamed(_bloc!.homepageName);
  //     }
  //   }
  // }
  // Future<void> _restoreSessionAndAnimate() async {
  //   await _bloc?.restorePrefs();

  //   if (_bloc?.currSession == null) {
  //     // No session - show splash animation
  //     await Future.delayed(const Duration(milliseconds: 500));
  //     await _resizeController.forward();
  //     await Future.delayed(const Duration(milliseconds: 300));
  //     setState(() => _showWelcome = true);
  //     _moveController.forward();
  //     _welcomeController.forward();
  //   } else {
  //     // User is already logged in - immediately show loading design
  //     setState(() {
  //       _showLoadingDesign = true;
  //     });

  //     // Keep the loading design on screen for 3-4 seconds
  //     await Future.delayed(const Duration(milliseconds: 500)); // 3.5 seconds

  //     // Start fade transition
  //     await _homeTransitionController.forward();

  //     await Future.wait([
  //       safeNetworkCall(() => _bloc!.patchFcmKey()),
  //       safeNetworkCall(() => _bloc!.reloadCurrentUser()),
  //     ]);

  //     // if (mounted) {
  //     //   Navigator.of(context).pushReplacementNamed(_bloc!.homepageName);
  //     // }
  //     if (mounted) {
  //       Navigator.of(context).pushReplacementNamed(
  //         _bloc!.homepageName,
  //         arguments: {'fadeIn': false},
  //       );
  //     }
  //   }
  // }
  Future<void> _restoreSessionAndAnimate() async {
    await _bloc?.restorePrefs();

    if (_bloc?.currSession == null) {
      // No session - show splash animation then go directly to login options
      await Future.delayed(const Duration(milliseconds: 300));
      await _resizeController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _showLoginOptions = true;
      });
      await _transitionController.forward();
    } else {
      // User is already logged in - immediately show loading design
      setState(() {
        _showLoadingDesign = true;
      });

      // Keep the loading design on screen for a short time (optional)
      await Future.delayed(const Duration(milliseconds: 500));

      // NO fade-out here; stay on loading screen while doing work
      await Future.wait([
        safeNetworkCall(() => _bloc!.patchFcmKey()),
        safeNetworkCall(() => _bloc!.reloadCurrentUser()),
      ]);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          _bloc!.homepageName,
          arguments: {'fadeIn': false},
        );
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

    // Show loading design for logged-in users
    if (_showLoadingDesign) {
      // return AnimatedBuilder(
      //   animation: _homeTransitionController,
      //   builder: (context, child) {
      //     return AnimatedOpacity(
      //       opacity: 1.0 - _homeTransitionController.value,
      //       duration: Duration(milliseconds: 50),
      //       child: _buildLoadingPageDesign(),
      //     );
      //   },
      // );
      return _buildLoadingPageDesign();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 10),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _showLoginOptions
          // ? _buildLoginOptionsPage(context)
          ? _buildNewLoginOptions(context)
          : _buildLoadingPageDesign(),
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
                                fontSize: figmaFontSize(context, 40),
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF306FDC),
                              ),
                            ),
                            TextSpan(
                              text: 'App',
                              style: TextStyle(
                                fontSize: figmaFontSize(context, 40),
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Positioned(
                  //   left: currentTextX,
                  //   top: currentTextY,
                  //   child: Opacity(
                  //     opacity: _isExitingToHome ? textOpacity : 1.0,
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Text(
                  //           'Insti',
                  //           style: TextStyle(
                  //             fontSize: figmaFontSize(context, 40),
                  //             fontWeight: FontWeight.w800,
                  //             color: Colors.blue,
                  //             height: 1.0, // important for alignment
                  //           ),
                  //         ),
                  //         Text(
                  //           'App',
                  //           style: TextStyle(
                  //             fontSize: figmaFontSize(context, 40),
                  //             fontWeight: FontWeight.w800,
                  //             color: Colors.black,
                  //             height: 1.0,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
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

  // Widget _buildClippedIllustrationWithWhiteBackground() {
  //   return Stack(
  //     alignment: Alignment.topCenter,
  //     children: [
  //       Container(
  //         width: MediaQuery.of(context).size.width,
  //         height: RS.sh(context, 412 + 250),
  //         color: Colors.white,
  //       ),
  //       ClipPath(
  //         clipper: BottomCurveClipper(curveDepth: 25),
  //         child: Image.asset(
  //           'assets/login/campus_illustration.png',
  //           width: MediaQuery.of(context).size.width,
  //           height: RS.sh(context, 412),
  //           fit: BoxFit.cover,
  //         ),
  //       ),
  //     ],
  //   );
  // }
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
  // Widget _buildGetStartedScreen() {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       const Text(
  //         "Making Student Life",
  //         style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
  //       ),
  //       Text.rich(
  //         TextSpan(
  //           children: [
  //             TextSpan(
  //               text: 'Simpler ',
  //               style: TextStyle(
  //                 color: Color(0xFF306FDC), // Hex: #306FDC
  //                 fontSize: 28,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             TextSpan(
  //               text: 'and ',
  //               style: TextStyle(
  //                 color: Colors.black,
  //                 fontSize: 28,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             TextSpan(
  //               text: 'Smarter',
  //               style: TextStyle(
  //                 color: Color(0xFF306FDC),
  //                 fontSize: 28,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 40),
  //       SizedBox(
  //         width: RS.sw(context, 300),
  //         height: RS.sh(context, 64),
  //         child: ElevatedButton(
  //           onPressed: () async {
  //             setState(() {
  //               _showLoginOptions = true;
  //             });

  //             await Future.delayed(const Duration(milliseconds: 100));

  //             await _transitionController.forward();
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.blue.shade700,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //           ),
  //           child: const Text(
  //             "Get Started",
  //             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: RS.sh(context, 60)),
  //     ],
  //   );
  // }
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
                  color: Color(0xFF306FDC),
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

// Widget _buildNewLoginOptions(BuildContext context) {
//   return Scaffold(
//     body: SafeArea(
//       child: Stack(
//         children: [
//           // LOGO (240 from top)
//           Positioned(
//             top: 240,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 Stack(
//                   alignment: Alignment.center,
//                   clipBehavior: Clip.none,
//                   children: [
//                     Image.asset(
//                       'assets/login/logo.png',
//                       width: 193,
//                       height: 193,
//                       fit: BoxFit.contain,
//                     ),
//                     Positioned(
//                       top: 173,
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             "Insti",
//                             style: TextStyle(
//                               fontFamily: 'DMSans',
//                               fontWeight: FontWeight.w800,
//                               fontSize: figmaFontSize(context, 40),
//                               letterSpacing: 1.3,
//                               color: const Color(0xFF306FDC),
//                             ),
//                           ),
//                           Text(
//                             "App",
//                             style: TextStyle(
//                               fontFamily: 'DMSans',
//                               fontWeight: FontWeight.w800,
//                               fontSize: figmaFontSize(context, 40),
//                               letterSpacing: 1.3,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // LOGIN OPTIONS (fully at bottom)
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   GestureDetector(
//                     onTap: _handleSSOLogin,
//                     child: Container(
//                       width: 364,
//                       height: 52,
//                       decoration: BoxDecoration(
//                         color: Color(0xFF306FDC),
//                         borderRadius: BorderRadius.circular(50),
//                       ),
//                       child: const Center(
//                         child: Text(
//                           "Log In via SSO",
//                           style: TextStyle(
//                             fontFamily: 'DMSans',
//                             fontWeight: FontWeight.w700,
//                             fontSize: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   GestureDetector(
//                     onTap: _handleAlumniLogin,
//                     child: Container(
//                       width: 364,
//                       height: 52,
//                       decoration: BoxDecoration(
//                         color: Color(0xFF306FDC),
//                         borderRadius: BorderRadius.circular(50),
//                       ),
//                       child: const Center(
//                         child: Text(
//                           "Log In as an Alumnus",
//                           style: TextStyle(
//                             fontFamily: 'DMSans',
//                             fontWeight: FontWeight.w700,
//                             fontSize: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 27),
//                   Row(
//                     children: const [
//                       Expanded(child: Divider(thickness: 1, color: Color(0xFFDADADA))),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 10),
//                         child: Text(
//                           "or",
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Color(0xFF8A8A8A),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       Expanded(child: Divider(thickness: 1, color: Color(0xFFDADADA))),
//                     ],
//                   ),
//                   const SizedBox(height: 27),
//                   GestureDetector(
//                     onTap: _handleGuestLogin,
//                     child: Container(
//                       width: 364,
//                       height: 52,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(50),
//                         border: Border.all(
//                           color: Color(0xFF306FDC),
//                           width: 2,
//                         ),
//                       ),
//                       child: const Center(
//                         child: Text(
//                           "Continue as guest",
//                           style: TextStyle(
//                             fontFamily: 'DMSans',
//                             fontWeight: FontWeight.w700,
//                             fontSize: 16,
//                             color: Color(0xFF306FDC),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
// Widget _buildNewLoginOptions(BuildContext context) {
//   return AnimatedBuilder(
//     animation: _transitionController,
//     builder: (context, child) {
//       final t = Curves.easeInOut.transform(_transitionController.value);
//       final slideOffset = lerpDouble(1, 0, t)!; // Slide from bottom to position

//       return Transform.translate(
//         offset: Offset(0, slideOffset * MediaQuery.of(context).size.height),
//         child: Scaffold(
//           body: SafeArea(
//             child: Stack(
//               children: [
//                 // LOGO (responsive top positioning)
//                 Positioned(
//                   top: RS.sh(context, 240),
//                   left: 0,
//                   right: 0,
//                   child: Column(
//                     children: [
//                       Stack(
//                         alignment: Alignment.center,
//                         clipBehavior: Clip.none,
//                         children: [
//                           Image.asset(
//                             'assets/login/logo.png',
//                             width: RS.sw(context, 193),
//                             height: RS.sh(context, 193),
//                             fit: BoxFit.contain,
//                           ),
//                           Positioned(
//                             top: RS.sh(context, 173),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   "Insti",
//                                   style: TextStyle(
//                                     fontFamily: 'DMSans',
//                                     fontWeight: FontWeight.w800,
//                                     fontSize: RS.sp(context, 40),
//                                     letterSpacing: 1.3,
//                                     color: const Color(0xFF306FDC),
//                                   ),
//                                 ),
//                                 Text(
//                                   "App",
//                                   style: TextStyle(
//                                     fontFamily: 'DMSans',
//                                     fontWeight: FontWeight.w800,
//                                     fontSize: RS.sp(context, 40),
//                                     letterSpacing: 1.3,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 // LOGIN OPTIONS (responsive positioning and sizing)
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   bottom: 0,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: RS.sw(context, 24),
//                       vertical: RS.sh(context, 48)
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         GestureDetector(
//                           onTap: _handleSSOLogin,
//                           child: Container(
//                             width: RS.sw(context, 364),
//                             height: RS.sh(context, 52),
//                             decoration: BoxDecoration(
//                               color: Color(0xFF306FDC),
//                               borderRadius: BorderRadius.circular(RS.s(context, 50)),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "Log In via SSO",
//                                 style: TextStyle(
//                                   fontFamily: 'DMSans',
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: RS.sp(context, 16),
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: RS.sh(context, 24)),
//                         GestureDetector(
//                           onTap: _handleAlumniLogin,
//                           child: Container(
//                             width: RS.sw(context, 364),
//                             height: RS.sh(context, 52),
//                             decoration: BoxDecoration(
//                               color: Color(0xFF306FDC),
//                               borderRadius: BorderRadius.circular(RS.s(context, 50)),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "Log In as an Alumnus",
//                                 style: TextStyle(
//                                   fontFamily: 'DMSans',
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: RS.sp(context, 16),
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: RS.sh(context, 27)),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Divider(
//                                 thickness: 1,
//                                 color: Color(0xFFDADADA)
//                               )
//                             ),
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: RS.sw(context, 10)),
//                               child: Text(
//                                 "or",
//                                 style: TextStyle(
//                                   fontSize: RS.sp(context, 13),
//                                   color: Color(0xFF8A8A8A),
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Divider(
//                                 thickness: 1,
//                                 color: Color(0xFFDADADA)
//                               )
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: RS.sh(context, 27)),
//                         GestureDetector(
//                           onTap: _handleGuestLogin,
//                           child: Container(
//                             width: RS.sw(context, 364),
//                             height: RS.sh(context, 52),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(RS.s(context, 50)),
//                               border: Border.all(
//                                 color: Color(0xFF306FDC),
//                                 width: 2,
//                               ),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "Continue as guest",
//                                 style: TextStyle(
//                                   fontFamily: 'DMSans',
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: RS.sp(context, 16),
//                                   color: Color(0xFF306FDC),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
  Widget _buildNewLoginOptions(BuildContext context) {
    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_transitionController.value);
        final fadeOpacity = lerpDouble(0, 1, t)!; // Fade from 0 to 1

        return Opacity(
          opacity: fadeOpacity,
          child: Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                      top: RS.sh(context, 97),
                      right: RS.sw(context, 70),
                      child: SizedBox(
                        width: RS.sw(context, 268),
                        height: RS.sh(context, 69),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Your Digital ',
                                style: TextStyle(
                                  color: const Color(0xFF0F1620),
                                  fontSize: RS.sp(context, 28),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: 'Wingie',
                                style: TextStyle(
                                  color: const Color(0xFF306FDC),
                                  fontSize: RS.sp(context, 28),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: ' at Insti.',
                                style: TextStyle(
                                  color: const Color(0xFF0F1620),
                                  fontSize: RS.sp(context, 28),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                  // LOGO (responsive top positioning)
                  Positioned(
                    top: RS.sh(context, 200),
                    left: 0,
                    right: 0,
                    child: SvgPicture.asset(
                      'assets/login/loginillus.svg',
                      width: RS.sw(context, 410),
                      height: RS.sh(context, 316),
                      fit: BoxFit.contain,
                    ),
                  ),
                  // LOGIN OPTIONS (responsive positioning and sizing)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                          left: RS.sw(context, 24),
                          right: RS.sw(context, 24),
                          top: RS.sh(context, 48),
                          bottom: RS.sh(context, 32)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _handleSSOLogin,
                            child: Container(
                              width: RS.sw(context, 364),
                              height: RS.sh(context, 52),
                              decoration: BoxDecoration(
                                color: Color(0xFF306FDC),
                                borderRadius:
                                    BorderRadius.circular(RS.s(context, 50)),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.vpn_key,
                                      color: Colors.white,
                                      size: RS.sp(context, 20),
                                    ),
                                    SizedBox(width: RS.sw(context, 8)),
                                    Text(
                                      "Log In via SSO",
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        fontWeight: FontWeight.w700,
                                        fontSize: RS.sp(context, 16),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: RS.sh(context, 24)),
                          // "or" divider
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                      thickness: 1, color: Color(0xFFDADADA))),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: RS.sw(context, 10)),
                                child: Text(
                                  "or",
                                  style: TextStyle(
                                    fontSize: RS.sp(context, 13),
                                    color: Color(0xFF8A8A8A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Divider(
                                      thickness: 1, color: Color(0xFFDADADA))),
                            ],
                          ),
                          SizedBox(height: RS.sh(context, 24)),
                          // Log In as an Alumnus - outlined button
                          GestureDetector(
                            onTap: _handleAlumniLogin,
                            child: Container(
                              width: RS.sw(context, 364),
                              height: RS.sh(context, 52),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(RS.s(context, 50)),
                                border: Border.all(
                                  color: Color(0xFF306FDC),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Log In as an Alumnus",
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: RS.sp(context, 16),
                                    color: Color(0xFF306FDC),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: RS.sh(context, 16)),
                          // Continue as guest - outlined button
                          GestureDetector(
                            onTap: _handleGuestLogin,
                            child: Container(
                              width: RS.sw(context, 364),
                              height: RS.sh(context, 52),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(RS.s(context, 50)),
                                border: Border.all(
                                  color: Color(0xFF306FDC),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Continue as guest",
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: RS.sp(context, 16),
                                    color: Color(0xFF306FDC),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildLoadingPageDesign() {
    return Scaffold(
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1),
          curve: Curves.easeIn,
          builder: (context, opacity, child) {
            return Opacity(
              opacity: opacity,
              child: child,
            );
          },
          child: Stack(
            children: [
              // LOGO (240 from top)
              Positioned(
                top: RS.sh(context, 280),
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset(
                          'assets/login/logo2.png',
                          width: RS.sw(context, 146),
                          height: RS.sh(context, 121),
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          top: RS.sh(context, 110),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Insti',
                                style: TextStyle(
                                  color: const Color(0xFF306FDC),
                                  fontSize: 34,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'App',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 34,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Bottom illustration
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SvgPicture.asset(
                  'assets/login/Union.svg', // Use .png if .svg doesn't work
                  fit: BoxFit.cover,
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
