import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';
import 'package:flutter_svg/svg.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String bodyID = "";
  bool searchMode = false;
// inside _ExplorePageState
  final ScrollController _listController = ScrollController();
  double _maxScrollOffset = double.infinity;
  final double _clampFraction = 0.4; // change to desired fraction (0.0 - 1.0)

  @override
  void initState() {
    super.initState();

    // compute allowed max after first layout (the ListView's maxScrollExtent becomes available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listController.hasClients) {
        final maxExtent = _listController.position.maxScrollExtent;
        _maxScrollOffset = maxExtent * _clampFraction;
      }
    });

    // prevent going past the allowed offset
    _listController.addListener(() {
      if (_listController.hasClients &&
          _listController.offset > _maxScrollOffset) {
        _listController.jumpTo(_maxScrollOffset);
      }
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Scaffold(
        // backgroundColor: Color.from(alpha: 1, red: 0.965, green: 0.965, blue: 0.965),
        backgroundColor: Color(0xFFF6F6F6),
        extendBodyBehindAppBar: true,
        body: Stack(children: [
          Container(
              child: Column(
            spacing: Responsive.width(20, context),
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(16, context)),
                child: SafeArea(
                    bottom: false,
                    child: Column(children: [
                      // SizedBox(height: Responsive.height(10.5, context)),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Text('My Calendar',
                                style: TextStyle(
                                  fontSize: Responsive.text(24, context),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'DM Sans',
                                  color: Color.fromRGBO(15, 22, 32, 1),
                                )),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: Responsive.width(52, context),
                              height: Responsive.height(52, context),
                              decoration: ShapeDecoration(
                                color: const Color(0xCCEBEBEB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: SizedBox(
                                width: Responsive.width(16, context),
                                height: Responsive.height(16, context),
                                child: SvgPicture.asset(
                                  'assets/calendar/list.svg',
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ])),
              ),
              Container(
                width: double.infinity,
                padding:
                    EdgeInsets.only(bottom: Responsive.height(12, context)),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFFD2D5DA),
                      width: Responsive.height(1, context),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: Responsive.height(16, context),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.width(16, context)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: Responsive.height(16, context),
                        children: [
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: Responsive.height(8, context),
                              children: [
                                Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: Responsive.width(12, context),
                                    children: [
                                      Text(
                                        'June 2025',
                                        style: TextStyle(
                                          color: const Color(
                                              0xFF306FDC) /* InstiApp-blue */,
                                          fontSize:
                                              Responsive.width(20, context),
                                          fontFamily: 'DM Sans',
                                          fontWeight: FontWeight.w600,
                                          height: 1.20,
                                          letterSpacing: 0.38,
                                        ),
                                      ),
                                      Container(
                                        width: Responsive.width(12, context),
                                        height: Responsive.height(35, context),
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                Responsive.height(12, context)),
                                        child: SvgPicture.asset(
                                          'assets/calendar/down.svg',
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: Responsive.width(197, context),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: Responsive.width(4, context),
                                    children: [
                                      Container(
                                        width: Responsive.width(70, context),
                                        height: Responsive.height(40, context),
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Responsive.width(12, context),
                                            vertical:
                                                Responsive.height(4, context)),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width:
                                                  Responsive.width(1, context),
                                              color: const Color(
                                                  0xFFD2D5DA) /* instiappgrey3 */,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                Responsive.width(185, context)),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          spacing: Responsive.width(8, context),
                                          children: [
                                            Text(
                                              'Today',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: Responsive.width(
                                                    14, context),
                                                fontFamily: 'DM Sans',
                                                fontWeight: FontWeight.w400,
                                                height: Responsive.height(
                                                    1.71, context),
                                                letterSpacing: Responsive.width(
                                                    0.38, context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: Responsive.height(40, context),
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Responsive.width(16, context),
                                            vertical: Responsive.height(
                                                10.95, context)),
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFEFEFEF),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: Responsive.width(
                                                  1.37, context),
                                              color: const Color(0xFFD2D5DA),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                Responsive.width(
                                                    68.42, context)),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          spacing: Responsive.width(8, context),
                                          children: [
                                            SvgPicture.asset(
                                              'assets/calendar/filter.svg',
                                              fit: BoxFit.scaleDown,
                                            ),
                                            Text(
                                              'Filter',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: const Color(0xCC0F1620),
                                                fontSize: Responsive.width(
                                                    14, context),
                                                fontFamily: 'DM Sans',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: Responsive.width(6, context),
                              children: [
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: Responsive.width(18.47, context),
                                    children: [
                                      Container(
                                        width: Responsive.width(28, context),
                                        height: Responsive.width(15, context),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: Responsive.width(
                                                  10.68, context),
                                              top: 0,
                                              child: Text(
                                                'S',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      const Color(0x4C3C3C43),
                                                  fontSize: Responsive.width(
                                                      14, context),
                                                  fontFamily: 'DM Sans',
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.08,
                                                  letterSpacing: -0.07,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: Responsive.width(33, context),
                                        height: Responsive.width(15, context),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: Responsive.width(
                                                  11.68, context),
                                              top: 0,
                                              child: Text(
                                                'M',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      const Color(0x4C3C3C43),
                                                  fontSize: Responsive.width(
                                                      14, context),
                                                  fontFamily: 'DM Sans',
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.08,
                                                  letterSpacing: -0.07,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: Responsive.width(26.86, context),
                                        height:
                                            Responsive.width(15.11, context),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: Responsive.width(
                                                  9.52, context),
                                              top: 0,
                                              child: Text(
                                                'T',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      const Color(0x4C3C3C43),
                                                  fontSize: Responsive.width(
                                                      14, context),
                                                  fontFamily: 'DM Sans',
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.08,
                                                  letterSpacing: -0.07,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: Responsive.width(25, context),
                                        height: Responsive.width(15, context),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: Responsive.width(
                                                  5.58, context),
                                              top: 0,
                                              child: Text(
                                                'W',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      const Color(0x4C3C3C43),
                                                  fontSize: Responsive.width(
                                                      14, context),
                                                  fontFamily: 'DM Sans',
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.08,
                                                  letterSpacing: -0.07,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: Responsive.width(26.86, context),
                                        height:
                                            Responsive.width(15.11, context),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: Responsive.width(
                                                  8.68, context),
                                              top: 0,
                                              child: Text(
                                                'T',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      const Color(0x4C3C3C43),
                                                  fontSize: Responsive.width(
                                                      14, context),
                                                  fontFamily: 'DM Sans',
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.08,
                                                  letterSpacing: -0.07,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: Responsive.width(23, context),
                                        height: Responsive.width(15, context),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: Responsive.width(
                                                  7.62, context),
                                              top: 0,
                                              child: Text(
                                                'F',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      const Color(0x4C3C3C43),
                                                  fontSize: Responsive.width(
                                                      14, context),
                                                  fontFamily: 'DM Sans',
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.08,
                                                  letterSpacing: -0.07,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: Responsive.width(26.86, context),
                                        height:
                                            Responsive.width(15.11, context),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: Responsive.width(
                                                  9.52, context),
                                              top: 0,
                                              child: Text(
                                                'S',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      const Color(0x4C3C3C43),
                                                  fontSize: Responsive.width(
                                                      14, context),
                                                  fontFamily: 'DM Sans',
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.08,
                                                  letterSpacing: -0.07,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          spacing: 24.34,
                                          children: [
                                            Container(
                                              width: Responsive.width(
                                                  26.86, context),
                                              height: Responsive.width(
                                                  26.86, context),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: Responsive.width(
                                                        0, context),
                                                    top: Responsive.width(
                                                        3.36, context),
                                                    child: SizedBox(
                                                      width: Responsive.width(
                                                          26.86, context),
                                                      child: Text(
                                                        '6',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize:
                                                              Responsive.width(
                                                                  20, context),
                                                          fontFamily: 'DM Sans',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 1.01,
                                                          letterSpacing: 0.32,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width:
                                                  Responsive.width(44, context),
                                              height:
                                                  Responsive.width(44, context),
                                              decoration: ShapeDecoration(
                                                color: const Color(
                                                    0xFF306FDC) /* InstiApp-blue */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          83.95),
                                                ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: Responsive.width(
                                                        0, context),
                                                    top: Responsive.width(
                                                        12.36, context),
                                                    child: SizedBox(
                                                      width: Responsive.width(
                                                          43.86, context),
                                                      child: Text(
                                                        '7',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize:
                                                              Responsive.width(
                                                                  20, context),
                                                          fontFamily: 'DM Sans',
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          height: 1.01,
                                                          letterSpacing: 0.32,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: Responsive.width(
                                                  26.86, context),
                                              height: Responsive.width(
                                                  26.86, context),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: Responsive.width(
                                                        0, context),
                                                    top: Responsive.width(
                                                        3.36, context),
                                                    child: SizedBox(
                                                      width: Responsive.width(
                                                          26.86, context),
                                                      child: Text(
                                                        '8',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize:
                                                              Responsive.width(
                                                                  20, context),
                                                          fontFamily: 'DM Sans',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 1.01,
                                                          letterSpacing: 0.32,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: Responsive.width(
                                                  26.86, context),
                                              height: Responsive.width(
                                                  26.86, context),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: Responsive.width(
                                                        0, context),
                                                    top: Responsive.width(
                                                        3.36, context),
                                                    child: SizedBox(
                                                      width: Responsive.width(
                                                          26.86, context),
                                                      child: Text(
                                                        '9',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize:
                                                              Responsive.width(
                                                                  20, context),
                                                          fontFamily: 'DM Sans',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 1.01,
                                                          letterSpacing: 0.32,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: Responsive.width(
                                                  26.86, context),
                                              height: Responsive.width(
                                                  26.86, context),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: Responsive.width(
                                                        0, context),
                                                    top: Responsive.width(
                                                        3.36, context),
                                                    child: SizedBox(
                                                      width: Responsive.width(
                                                          26.86, context),
                                                      child: Text(
                                                        '10',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize:
                                                              Responsive.width(
                                                                  20, context),
                                                          fontFamily: 'DM Sans',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 1.01,
                                                          letterSpacing: 0.32,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: Responsive.width(
                                                  26.86, context),
                                              height: Responsive.width(
                                                  26.86, context),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: Responsive.width(
                                                        0, context),
                                                    top: Responsive.width(
                                                        0, context),
                                                    child: SizedBox(
                                                      width: Responsive.width(
                                                          26.86, context),
                                                      height: Responsive.width(
                                                          26.86, context),
                                                      child: Text(
                                                        '11',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize:
                                                              Responsive.width(
                                                                  20, context),
                                                          fontFamily: 'DM Sans',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 1.01,
                                                          letterSpacing: 0.32,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: Responsive.width(
                                                  26.86, context),
                                              height: Responsive.width(
                                                  26.86, context),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: Responsive.width(
                                                        0, context),
                                                    top: Responsive.width(
                                                        3.36, context),
                                                    child: SizedBox(
                                                      width: Responsive.width(
                                                          26.86, context),
                                                      height: Responsive.width(
                                                          26.86, context),
                                                      child: Text(
                                                        '12',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize:
                                                              Responsive.width(
                                                                  20, context),
                                                          fontFamily: 'DM Sans',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 1.01,
                                                          letterSpacing: 0.32,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: Responsive.height(12, context),
                      children: [
                        Container(
                          width: Responsive.width(50, context),
                          height: Responsive.height(5, context),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFD2D5DA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  Responsive.width(100, context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Responsive.height(20, context),
                children: [
                  Container(
                    width: Responsive.width(380, context),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // spacing: Responsive.height(12, context),
                      children: [
                        Container(
                          width: double.infinity,
                          // height: Responsive.height(36, context),
                          // padding: EdgeInsets.only(
                          //     bottom: Responsive.height(12, context)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // spacing: Responsive.height(4, context),
                            children: [
                              Container(
                                width: double.infinity,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  // spacing: Responsive.width(10, context),
                                  children: [
                                    Text(
                                      'Mon, 7th April',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: Responsive.width(16, context),
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w700,
                                        height: 1.50,
                                        letterSpacing: 0.38,
                                      ),
                                    ),
                                    Text(
                                      '8 events',
                                      style: TextStyle(
                                        color: const Color(
                                            0xFF7E8287) /* instiappgrey */,
                                        fontSize: Responsive.width(16, context),
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400,
                                        height: 1.50,
                                        letterSpacing: 0.38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Responsive.width(4, context),
                    children: [
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEFEFEF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFB7DC89),
                                shape: OvalBorder(),
                              ),
                            ),
                            Text(
                              'Independence day',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF000000),
                                fontSize: 12,
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEFEFEF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFB7DC89),
                                shape: OvalBorder(),
                              ),
                            ),
                            Text(
                              'Exam',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF000000),
                                fontSize: 12,
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Responsive.height(10, context),
                    // padding: EdgeInsets.only(top: Responsive.height(10, context)),
                    children: [
                      Container(
                        // alignment: Alignment.center,
                        width: Responsive.width(380, context),
                        // height: Responsive.height(101, context),
                        padding: EdgeInsets.only(
                          top: Responsive.height(12, context),
                          left: Responsive.width(18, context),
                          right: Responsive.width(16, context),
                          bottom: Responsive.height(12, context),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            left: BorderSide(
                              color: const Color(0xFF306FDC),
                              width: 6,
                            ),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mood I Meet',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: Responsive.height(16,context),
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                              ),
                            ),
                          Text(
                                '7 AM- 8 AM',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: Responsive.height(12, context),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.38,
                                ),
                              ),
                          
                          ],
                        ),
                      ),
                      Container(
                        // alignment: Alignment.center,
                        width: Responsive.width(380, context),
                        // height: Responsive.height(101, context),
                        padding: EdgeInsets.only(
                          top: Responsive.height(12, context),
                          left: Responsive.width(18, context),
                          right: Responsive.width(16, context),
                          bottom: Responsive.height(12, context),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            left: BorderSide(
                              color: const Color(0xFF306FDC),
                              width: 6,
                            ),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Devcom Orientation',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: Responsive.height(16,context),
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                              ),
                            ),
                          Text(
                                '9 PM - 10:30 PM',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: Responsive.height(12, context),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.38,
                                ),
                              ),
                          
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          )),
        ]));
  }
}
