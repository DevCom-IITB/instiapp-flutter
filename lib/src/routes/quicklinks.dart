import 'package:InstiApp/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class Quicklinks extends StatefulWidget {
  const Quicklinks({super.key});

  @override
  State<Quicklinks> createState() => _QuicklinksState();
}

class _QuicklinksState extends State<Quicklinks> {
  Constants myConstants=Constants();
  bool isTop=false;
  bool isBottom=false;
  Widget LinkContainer(String label,String link,bool isTop,bool isBottom){
    return GestureDetector(
      onTap: () async{
        final url=Uri.parse(link);
        if(await canLaunchUrl(url)){
          await launchUrl(url);
        } else{
          throw "Could not launch ${url}";
        }
      },
      child: Container(
                height: 63,
                width: 380,
                decoration: BoxDecoration(
                  color: myConstants.instiappGrey,
                  borderRadius: BorderRadius.vertical(
                      top: isTop?Radius.circular(16):Radius.zero,
                      bottom: isBottom?Radius.circular(16):Radius.zero
                  ),
                  border: isBottom?null:Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Color(0x80D2D5DA)
                    )
                  )
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          color: const Color(0xFF0F1620),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 24,
                        child: SvgPicture.asset('assets/quicklinks/icons/external_link.svg'),
                      )
                    ],
                  ),
                  ),
              ),
    );
  }

Widget LinkSection(String title,Map<String,String> links){
  List<String> keys=links.keys.toList();
  List<String> values=links.values.toList();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF1B3252),
            fontSize: 20,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
          ),
      ),
      for(int i=0;i<keys.length;i++) ...[
        LinkContainer(keys[i],values[i],i==0,i==keys.length-1),
      ],
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    Map<String,Map<String,String>> quickLinks={
      "Devcom": {
        "Leave Portal": "https://google.com",
        "Resume Portal": "https://google.com",
        "AMS": "https://ams.iitb.ac.in/pages/login"
      },
      "Academic": {
        "ASC": "https://asc.iitb.ac.in/acadmenu/",
        "External ASC": "https://portal.iitb.ac.in/asc/Login",
        "Moodle": "https://moodle.iitb.ac.in/login/index.php",
        "Placement Blog": "https://campus.placements.iitb.ac.in/",
        "Internship Blog": "https://google.com",
        "Central Library": "https://www.library.iitb.ac.in/"
      },
      "Calendar": {
        "Academic Calendar": "https://acad.iitb.ac.in/academics/calendar-and-timetable",
        "Academic Timetable": "https://acad.iitb.ac.in/academics/calendar-and-timetable",
        "Holidays List": "https://www.iitb.ac.in/holidays-list",
        "Circulars": "https://www.iitb.ac.in/newacadhome/circular.jsp",
        "Course List": "https://portal.iitb.ac.in/asc/Courses",
      },
      // "Services": {
      //   "WebMail": "https://webmail-sso.iitb.ac.in/",
      //   "CAMP": "https://camp.iitb.ac.in/",
      //   "Microsoft Store": "https://www.cc.iitb.ac.in/attachments/microsoft/ReadMe.pdf",
      //   "BigHome Cloud": "https://bighome.iitb.ac.in/index.php/login",
      // },
      // "Miscellaneous": {
      //   "Intercom Extensions": "https://portal.iitb.ac.in/telephone/",
      //   "Hospital": "https://www.iitb.ac.in/hospital/",
      // }
    };
    List<String> linkLabel=quickLinks.keys.toList();
    List<Map<String,String>> links=quickLinks.values.toList();
    Widget emergencyContainer(String label){
      return Container(
              padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFD2D5DA),
                  width: 1
                ),
                borderRadius: BorderRadius.circular(4)
              ),
              child: Text(
                label,
                style: TextStyle(
                color: const Color(0xFF7E8287),
                fontSize: 12,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                ),
              ),
            );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFF6F6F6),
          //backgroundColor: Colors.red[200],
          elevation: 0,
          flexibleSpace: SafeArea(
          child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 4,
                                right: 4,
                                top: 4,
                                bottom: 4,
                                child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: myConstants.instiappGrey),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/feed');
                                },
                                child: Center(
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(
                                      'assets/quicklinks/icons/arrow_left.svg',
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )))
                ],
              ),
            ),
            Text(
              "Quick Links",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700
              ),
            ),
            Container(
              width: 52,
              height: 52,
            ),
          ],
        ),
      )),
    ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Dash(
                direction: Axis.horizontal,
                dashLength: 6,
                length: 378,
                dashGap: 7,
                dashColor: Color(0xFFDADADA),
              ),
              SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  final url=Uri.parse("https://www.iitb.ac.in/safety/en/emergency-contact-number");
                  if(await canLaunchUrl(url)){
                    await launchUrl(url);
                  } else{
                    throw "Could not launch ${url}";
                  }
                },
                child: Container(
                  height: 96,
                  width: 380,
                  //padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFFED0033),
                      width: 1
                    )
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 126,
                        top: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          //mainAxisAlignment: MainAxisAlignment.spaceBe,
                          children: [
                            Text(
                              "Emergency Contact",
                              style: TextStyle(
                                color: const Color(0xFF0F1620),
                                fontSize: 20,
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                emergencyContainer("QRT"),
                                SizedBox(width: 4),
                                emergencyContainer("Ambulance"),
                                SizedBox(width: 4),
                                emergencyContainer("Main Gate"),
                                SizedBox(width: 4),
                                Text(
                                  "...",
                                  style: TextStyle(
                                    color: const Color(0xFFD2D5DA),
                                    fontSize: 20,
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w400
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 292,
                        top: 12,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SvgPicture.asset('assets/quicklinks/icons/star.svg'),
                        )
                      ),
                      Positioned(
                        bottom: 16,
                        right: 13.29,
                        top: 45,
                        left: 324,
                        child: SvgPicture.asset('assets/quicklinks/icons/bell.svg')
                        )
                    ],
                  ),
                ),
              ),
              for(int i=0;i<linkLabel.length;i++) ...[
                SizedBox(height: 24),
                LinkSection(linkLabel[i], links[i]),
              ],
              SizedBox(height: 24)
            ],
          ),
        ),
      ),
    );
  }
}