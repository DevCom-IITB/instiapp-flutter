import 'package:InstiApp/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class Quicklinks extends StatefulWidget {
  const Quicklinks({super.key});

  @override
  State<Quicklinks> createState() => _QuicklinksState();
}

class _QuicklinksState extends State<Quicklinks> {
  Constants myConstants=Constants();
  Widget LinkContainer(String label,String link){
    return Container(
              height: 63,
              width: 380,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: const Color(0xFFD2D5DA),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
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
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF306FDC),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async{
                        final url=Uri.parse(link);
                        if(await canLaunchUrl(url)){
                          await launchUrl(url);
                        }
                        else {
                          throw "Could not launch ${url}";
                        }

                      },
                      child: Container(
                        height: 24,
                        width: 24,
                        child: SvgPicture.asset('assets/quicklinks/icons/export.svg'),
                      ),
                    )
                  ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
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
        LinkContainer(keys[i],values[i]),
        if(i!=keys.length-1)
          SizedBox(height: 8),
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
        "AMS": "https://google.com"
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
        "Academic Calendar": "https://google.com",
        "Academic Timetable": "https://google.com",
        "Holidays List": "https://google.com",
        "Circulars": "https://google.com",
        "Course List": "https://google.com",
      },
      "Services": {
        "WebMail": "https://google.com",
        "CAMP": "https://google.com",
        "Microsoft Store": "https://google.com",
        "BigHome Cloud": "https://google.com",
      },
      "Miscellaneous": {
        "Intercom Extensions": "https://google.com",
        "Hospital": "https://google.com",
      }
    };
    List<String> linkLabel=quickLinks.keys.toList();
    List<Map<String,String>> links=quickLinks.values.toList();

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFF6F6F6),
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