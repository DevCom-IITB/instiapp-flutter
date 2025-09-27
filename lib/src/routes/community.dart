import 'package:InstiApp/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/svg.dart';
class Responsive {
  final BuildContext context;
  final double baseWidth;  
  final double baseHeight;

  Responsive(this.context, {this.baseWidth = 411, this.baseHeight = 914});

  double w(double px) => MediaQuery.of(context).size.width * (px / baseWidth);
  double h(double px) => MediaQuery.of(context).size.height * (px / baseHeight);
  double sp(double px) => w(px); // scale text with width
}
class Communities extends StatefulWidget {
  const Communities({super.key});

  @override
  State<Communities> createState() => _CommunitiesState();
}

class _CommunitiesState extends State<Communities> {
  Constants myConstants = Constants();
  List<String> subContLabels=["Hostel Affairs","Interns","Tech"];
  Widget subCont(String label){
    return Container(
      height: 24,
      // width: 94,
      padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
      decoration: BoxDecoration(
        border:Border.all(
          color: myConstants.instiappBlue,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(8)
      ),
      child: Center(
        child: Text(
          label, 
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: myConstants.instiappBlue
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 32),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                height: 153,
                width: 412,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  image: DecorationImage(
                    image: AssetImage('assets/explore/symphony.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: responsive.w(16)),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                        child: Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: Color(0x99FFFFFF),
                            borderRadius: BorderRadius.circular(25)
                          ),
                          child: Center(
                            child: Container(
                              height: responsive.h(24),
                              width: responsive.w(24),
                                child: SvgPicture.asset('assets/quicklinks/icons/arrow_left.svg'),
                              ),
                            ),
                          ),
                        ),
                      ),
                  Padding(
                    padding: EdgeInsets.only(right: responsive.w(16)),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                        child: Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: Color(0x99FFFFFF),
                            borderRadius: BorderRadius.circular(25)
                          ),
                          child: Center(
                            child: Container(
                              height: responsive.h(24),
                              width: responsive.w(24),
                                child: SvgPicture.asset('assets/homepage/icons/bell.svg'),
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              )
              ]
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                children: [
                  Container(
                    height: 63,
                    width: 63,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(31.5),
                      image: DecorationImage(
                        image: AssetImage('assets/explore/symphony.png'),
                          fit: BoxFit.cover
                      )
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    height: 63,
                    width: 214,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Insight Discussion",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F1620),
                          ),
                        ),
                        Text(
                          "Music Club of IITB",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0F1620),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "422",
                              style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF306FDC),
                            ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Members",
                              style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF306FDC),
                            ),
                            ),
                            
                          ],
                        ),
                        
                        
                      ],
                      
                    ),
                  ),
                  SizedBox(width: 25),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 35,
                        width: 61,
                        decoration: BoxDecoration(
                          color: myConstants.instiappBlue,
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Center(
                          child: Text(
                            "Join",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: myConstants.instiappWhite,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(25)
                        ),
                        child: Center(child: Container(
                          height: 12,
                          width: 2,
                          child: SvgPicture.asset('assets/communities/icons/dots.svg',fit: BoxFit.contain))),
                      )
                    ],
                  )
                ],
              ),
            SizedBox(height: 10),
            Text(
              "Use this forum to Lorem ipsum dolorajhds Read More" 
            ),
            SizedBox(height: 10),
            Row(
              children: [
                for(int i=0; i<subContLabels.length; i++)...[
                  subCont(subContLabels[i]),
                  SizedBox(width: 8)
                ],

              ],
            ),
            SizedBox(height: 16),
            Dash(
              direction: Axis.horizontal,
              length: responsive.w(379),
              dashLength: 6,
              dashGap: 5,
              dashColor: Color(0xFFDADADA),
            ),
            SizedBox(height: 10),
            DefaultTabController(
              length: 3, 
              child: Stack(
                children: [
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: responsive.h(1.5),
                        color: Color(0xFFD0D5DD), // light grey line
                      ),
                    ),
                  TabBar(
                indicatorColor: myConstants.instiappBlue,
                labelColor: myConstants.instiappBlue,
                unselectedLabelColor: Colors.black54,
                  labelStyle: TextStyle(
                    fontSize: responsive.sp(16),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                  tabs: [
                    Tab(text: 'Posts'),
                    Tab(text: 'About'),
                    Tab(text: 'Links'),
                  ],
                                          
                ),
                ],
              )
              
              )
          ],
          ),
          ), 
          ],
        ),
      ),
    );
  }
}