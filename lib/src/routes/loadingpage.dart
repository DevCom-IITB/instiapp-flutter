import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Responsive {
  final BuildContext context;
  final double baseWidth;
  final double baseHeight;

  Responsive(this.context, {this.baseWidth = 412, this.baseHeight = 917});

  double w(double px) => MediaQuery.of(context).size.width * (px / baseWidth);
  double h(double px) => MediaQuery.of(context).size.height * (px / baseHeight);
  double sp(double px) => w(px);
}

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

class Loadingpage extends StatefulWidget {
  const Loadingpage({super.key});

  @override
  State<Loadingpage> createState() => _LoadingpageState();
}

class _LoadingpageState extends State<Loadingpage> {
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          // 🔹 LOGO (240 from top)
          Positioned(
            top: 240,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      'assets/login/logo.png',
                      width: 193,
                      height: 193,
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      top: 173,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Insti",
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontWeight: FontWeight.w800,
                              fontSize: figmaFontSize(context, 40),
                              letterSpacing: 1.3,
                              color: const Color(0xFF306FDC),
                            ),
                          ),
                          Text(
                            "App",
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontWeight: FontWeight.w800,
                              fontSize: figmaFontSize(context, 40),
                              letterSpacing: 1.3,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // bottom illustration
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SvgPicture.asset('assets/login/bottomillustration.svg', fit: BoxFit.cover),
          ),
        ],
      ),
    ),
  );
}

}
