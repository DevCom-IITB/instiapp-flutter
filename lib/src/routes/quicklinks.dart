import 'package:InstiApp/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class Responsive {
  final BuildContext context;
  final double baseWidth;
  final double baseHeight;

  Responsive(this.context, {this.baseWidth = 411, this.baseHeight = 914});

  double w(double px) => MediaQuery.of(context).size.width * (px / baseWidth);
  double h(double px) => MediaQuery.of(context).size.height * (px / baseHeight);
  double sp(double px) => w(px); // scale text with width
}

class Quicklinks extends StatefulWidget {
  const Quicklinks({super.key});

  @override
  State<Quicklinks> createState() => _QuicklinksState();
}

class _QuicklinksState extends State<Quicklinks> {
  Constants myConstants = Constants();
  bool isTop = false;
  bool isBottom = false;
  Widget LinkContainer(String label, String link, bool isTop, bool isBottom) {
    final responsive = Responsive(context);
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(link);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          throw "Could not launch ${url}";
        }
      },
      child: Container(
        height: responsive.h(63),
        width: responsive.w(380),
        decoration: BoxDecoration(
            color: myConstants.instiappGrey,
            borderRadius: BorderRadius.vertical(
                top: isTop ? Radius.circular(16) : Radius.zero,
                bottom: isBottom ? Radius.circular(16) : Radius.zero),
            border: isBottom
                ? null
                : Border(
                    bottom: BorderSide(
                        width: responsive.h(1), color: Color(0x80D2D5DA)))),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: responsive.w(16), vertical: responsive.h(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  color: const Color(0xFF0F1620),
                  fontSize: responsive.sp(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                height: responsive.h(24),
                width: responsive.w(24),
                child: SvgPicture.asset(
                    'assets/quicklinks/icons/external_link.svg'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget LinkSection(String title, Map<String, String> links) {
    final responsive = Responsive(context);
    List<String> keys = links.keys.toList();
    List<String> values = links.values.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: responsive.h(12)),
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xFF1B3252),
              fontSize: responsive.sp(20),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (int i = 0; i < keys.length; i++) ...[
          LinkContainer(keys[i], values[i], i == 0, i == keys.length - 1),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final size = MediaQuery.of(context).size;
    print(
        "Emulator screen size → width: ${size.width}, height: ${size.height}");

    Map<String, Map<String, String>> quickLinks = {
      "DevCom": {
        "Resobin": "https://resobin.gymkhana.iitb.ac.in/login",
        "Mess-I": "https://instamess.gymkhana.iitb.ac.in/dashboard/login",
        "ReaCH": "https://reach.gymkhana.iitb.ac.in/",
        "NewBee": "https://gymkhana.iitb.ac.in/newbee",
        "DevCom Website":"https://devcom.gymkhana.iitb.ac.in/", 
      },
      "Academic": {
        "ASC": "https://asc.iitb.ac.in/",
        "External ASC": "https://portal.iitb.ac.in/asc/",
        "Moodle": "https://moodle.iitb.ac.in",
        "Placement Blog": "https://campus.placements.iitb.ac.in/",
        "Internship Blog": "https://campus.placements.iitb.ac.in/",
        "Central Library": "https://www.library.iitb.ac.in/",
        "AMS": "https://ams.iitb.ac.in/pages/login"
      },
      "Calendar": {
        "Academic Calendar":
            "https://acad.iitb.ac.in/academics/calendar-and-timetable",
        "Academic Timetable":
            "https://acad.iitb.ac.in/academics/calendar-and-timetable",
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
    List<String> linkLabel = quickLinks.keys.toList();
    List<Map<String, String>> links = quickLinks.values.toList();
    Widget emergencyContainer(String label) {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: responsive.w(8), vertical: responsive.h(4)),
        decoration: BoxDecoration(
            border: Border.all(
                color: const Color(0xFFD2D5DA), width: responsive.w(1)),
            borderRadius: BorderRadius.circular(4)),
        child: Text(
          label,
          style: TextStyle(
            color: const Color(0xFF7E8287),
            fontSize: responsive.sp(12),
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsive.h(52)),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFF6F6F6),
          //backgroundColor: Colors.red[200],
          elevation: 0,
          flexibleSpace: SafeArea(
              child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: responsive.w(16), vertical: responsive.h(0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: responsive.h(52),
                  height: responsive.h(52),
                  child: Stack(
                    children: [
                      Positioned(
                          left: responsive.w(4),
                          right: responsive.w(4),
                          top: responsive.h(4),
                          bottom: responsive.h(4),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: myConstants.instiappGrey),
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Center(
                                      child: Container(
                                        width: responsive.h(24),
                                        height: responsive.h(24),
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
                      fontSize: responsive.sp(24),
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700),
                ),
                Container(
                  width: responsive.w(52),
                  height: responsive.h(52),
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
              SizedBox(height: responsive.h(12)),
              Dash(
                direction: Axis.horizontal,
                dashLength: responsive.w(6),
                length: responsive.w(374),
                dashGap: responsive.w(6),
                dashColor: Color(0xFFDADADA),
              ),
              SizedBox(height: responsive.h(24)),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse(
                      "https://www.iitb.ac.in/safety/en/emergency-contact-number");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw "Could not launch ${url}";
                  }
                },
                child: Container(
                  height: responsive.h(96),
                  width: responsive.w(380),
                  //padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: myConstants.instiappGrey,
                      border: Border.all(color: Color(0xFFED0033), width: 1)),
                  child: Stack(
                    children: [
                      Positioned(
                          left: responsive.w(16),
                          // bottom: responsive.h(16),
                          // right: responsive.w(126),
                          top: responsive.h(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            //mainAxisAlignment: MainAxisAlignment.spaceBe,
                            children: [
                              Text(
                                "Emergency Contact",
                                style: TextStyle(
                                  color: const Color(0xFF0F1620),
                                  fontSize: responsive.sp(20),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(
                                height: responsive.h(10),
                              ),
                              // Text("hi"),
                              // Text("hi")

                              Wrap(
                                spacing:
                                    responsive.w(4), // horizontal spacing
                                runSpacing: responsive.h(4), // vertical spacing if wrapped
                                children: [
                                  emergencyContainer("QRT"),
                                  emergencyContainer("Ambulance"),
                                  emergencyContainer("Main Gate"),
                                  Text(
                                    "...",
                                    style: TextStyle(
                                        color: const Color(0xFFD2D5DA),
                                        fontSize: responsive.sp(20),
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                              // SizedBox(height: responsive.h(16))
                            ],
                          )),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          // left: 292,
                          // top: 12,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SvgPicture.asset(
                                'assets/quicklinks/icons/star.svg',
                                height: responsive.h(84),
                                width: responsive.w(88)
                                ),
                          )),
                      Positioned(
                          bottom: responsive.h(18),
                          right: responsive.w(13.3),
                          // top: 45,
                          // left: 324,
                          child: SvgPicture.asset(
                              'assets/quicklinks/icons/bell.svg',
                              width: responsive.w(42.7),
                              height: responsive.h(33),
                              ))
                    ],
                  ),
                ),
              ),
              for (int i = 0; i < linkLabel.length; i++) ...[
                SizedBox(height: responsive.h(24)),
                LinkSection(linkLabel[i], links[i]),
              ],
              SizedBox(height: responsive.h(24))
            ],
          ),
        ),
      ),
    );
  }
}
