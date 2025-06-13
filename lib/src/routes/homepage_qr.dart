import 'package:InstiApp/constants.dart';
import 'package:InstiApp/src/routes/homepage.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/homepage_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomepageQr extends StatefulWidget {
  const HomepageQr({super.key});

  @override
  State<HomepageQr> createState() => _HomepageQrState();
}

class _HomepageQrState extends State<HomepageQr> {
  Constants myConstants=Constants();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myConstants.instiappWhite,
      appBar: customAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: myConstants.instiappBlue,
                        width: 6,
                        strokeAlign: BorderSide.strokeAlignInside
                      )
                    ),
                    child: Container(
                      width: 380,
                      height: 380,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEBEBEB),
                                    borderRadius: BorderRadius.circular(25)
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      child: SvgPicture.asset(
                                        'assets/icons/refresh.svg'
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  "My QR",
                                  style: TextStyle(
                                    color: myConstants.instiappBlue,
                                    fontSize: 20,
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w900
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    /*
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context)=>Homepage())
                                    );
                                    */
                                    //showQR=false;
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEBEBEB),
                                      borderRadius: BorderRadius.circular(25)
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 29,
                                        height: 29,
                                        child: SvgPicture.asset(
                                          'assets/icons/arrow_down.svg'
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 26,bottom: 32),
                                child: Container(
                                  width: 197,
                                  height: 197,
                                  child: SvgPicture.asset(
                                    'assets/icons/bigqr.svg'
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                'Mess • Gym • Swimming & more...',
                                style: TextStyle(
                                  color:const Color(0xFF15202D),
                                  fontSize: 14,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  servicesWidget()
                ],
              ),
            ),
          ),

          Align(alignment: Alignment.bottomCenter,child: navBar())
        ],
      ),
    );
  }
}