import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickLinksPage extends StatefulWidget {
  final links = {
    "CMS": {
      "CMS": "https://gymkhana.iitb.ac.in/cms_new/",
      "CMS - Maintenance": "https://support.iitb.ac.in",
      "CMS - Network": "https://help-cc.iitb.ac.in/",
    },
    "Academics": {
      "ASC": "https://asc.iitb.ac.in",
      "External ASC": "https://portal.iitb.ac.in/asc",
      "Moodle": "https://moodle.iitb.ac.in",
      "Placement Blog": "http://placements.iitb.ac.in/placements/login.jsp",
      "Internship Blog": "http://placements.iitb.ac.in/internship/login.jsp",
      "Central Library": "http://www.library.iitb.ac.in/",
    },
    "Calendar": {
      "Academic Calendar":
          "http://www.iitb.ac.in/newacadhome/toacadcalender.jsp",
      "Academic Timetable": "http://www.iitb.ac.in/newacadhome/timetable.jsp",
      "Holidays List":
          "http://www.iitb.ac.in/en/about-iit-bombay/iit-bombay-holidays-list",
      "Circulars": "http://www.iitb.ac.in/newacadhome/circular.jsp",
      "Course List": "https://portal.iitb.ac.in/asc/Courses",
    },
    "Services": {
      "WebMail": "https://webmail.iitb.ac.in",
      "GPO": "https://gpo.iitb.ac.in",
      "CAMP": "https://camp.iitb.ac.in/",
      "Microsoft Store": "http://msstore.iitb.ac.in/",
      "BigHome Cloud": "https://home.iitb.ac.in/",
    },
    "Miscellaneous": {
      "Intercom Extensions": "https://portal.iitb.ac.in/TelephoneDirectory/",
      "Hospital": "http://www.iitb.ac.in/hospital/",
      "VPN Guide":
          "https://www.cc.iitb.ac.in/engservices/engaccessingiitffromoutside/19-vpn",
    },
  };

  @override
  _QuickLinksPageState createState() => _QuickLinksPageState();
}

class _QuickLinksPageState extends State<QuickLinksPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _bottomSheetActive = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;

    return Scaffold(
      key: _scaffoldKey,
      drawer: BottomDrawer(),
      bottomNavigationBar: MyBottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                OMIcons.menu,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: _bottomSheetActive
                  ? null
                  : () {
                      BottomDrawer.setPageIndex(bloc, 9);
                      _scaffoldKey.currentState.openDrawer();
                      // setState(() {
                      //   //disable button
                      //   _bottomSheetActive = true;
                      // });
                      // _scaffoldKey.currentState
                      //     .showBottomSheet((context) {
                      //       BottomDrawer.setPageIndex(bloc, 9);
                      //       return BottomDrawer();
                      //     })
                      //     .closed
                      //     .whenComplete(() {
                      //       setState(() {
                      //         _bottomSheetActive = false;
                      //       });
                      //     });
                    },
            ),
          ],
        ),
      ),
      // bottomSheet: ,
      body: SafeArea(
        child: Container(
          foregroundDecoration: _bottomSheetActive
              ? BoxDecoration(
                  color: Color.fromRGBO(100, 100, 100, 12),
                )
              : null,
          child: ListView(
              children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Quick Links",
                    style: theme.textTheme.display2,
                  ),
                ],
              ),
            ),
            Divider(),
          ]..addAll(_parseLinks(widget.links))),
        ),
      ),
    );
  }

  Iterable<Widget> _parseLinks(Map<String, Map<String, String>> links) {
    return links.entries.expand(_parseEachSection);
  }

  Iterable<Widget> _parseEachSection(
      MapEntry<String, Map<String, String>> section) {
    return [
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 28),
        title: Text(section.key,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
      )
    ]..addAll(section.value.entries.map(_parseLink));
  }

  Widget _parseLink(MapEntry<String, String> link) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 28),
      title: Text(link.key, style: TextStyle(fontSize: 24)),
      onTap: () async {
        if (await canLaunch(link.value)) {
          await launch(link.value);
        }
      },
    );
  }
}
