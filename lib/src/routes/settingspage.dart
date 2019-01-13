import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final String updateProfileUrl = "https://gymkhana.iitb.ac.in/sso/user";
  final String feedbackUrl = "https://insti.app/feedback";

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;

    return Scaffold(
      key: _scaffoldKey,
      drawer: BottomDrawer(),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              tooltip: "Show Navigation Drawer",
              icon: Icon(
                OMIcons.menu,
                semanticLabel: "Show Navigation Drawer",
              ),
              onPressed: () {
                BottomDrawer.setPageIndex(bloc, 10);
                _scaffoldKey.currentState.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
            stream: bloc.session,
            builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
              var children = <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Settings",
                        style: theme.textTheme.display2.copyWith(
                            color: Colors.black, fontFamily: "Bitter"),
                      ),
                    ],
                  ),
                ),

                Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                    child: Text(
                      "App settings",
                      style: theme.textTheme.title
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                
                Text(
                  "Default Homepage",
                  style: theme.textTheme.body1
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                DropdownButton(
                  isExpanded: true,
                  items: {
                    "/mess": "Mess",
                    "/placeblog": "Placement Blog",
                    "/trainblog": "Internship Blog",
                    "/feed": "Feed",
                    "/quicklinks": "Quick Links",
                    "/news": "News",
                    "/explore": "Explore",
                    "/calendar": "Calendar",
                    "/complaints": "Complaints/Suggestions",
                    "/map": "Insti Map",
                    // "/settings": "Settings",
                  }.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (String s) {
                    bloc.updateHomepage(s);
                    setState(() {});
                  },
                  value: bloc.homepageName,
                ),
                ListTile(
                  leading: Icon(OMIcons.feedback),
                  title: Text("Feedback"),
                  onTap: () async {
                    if (await canLaunch(feedbackUrl)) {
                      await launch(feedbackUrl);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(OMIcons.info),
                  title: Text("About"),
                ),
              ];

              if (snapshot.data != null) {
                children.addAll([
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      "Profile settings",
                      style: theme.textTheme.title
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      border: Border.all(color: theme.accentColor),
                    ),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      leading: NullableCircleAvatar(
                        snapshot.data.profile.userProfilePictureUrl,
                        OMIcons.personOutline,
                      ),
                      title: Text(
                        snapshot.data.profile.userName,
                        style: theme.textTheme.title,
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed("/user/${snapshot.data.profileId}");
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(OMIcons.personOutline),
                    title: Text("Update Profile"),
                    onTap: () async {
                      if (await canLaunch(updateProfileUrl)) {
                        await launch(updateProfileUrl);
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(OMIcons.exitToApp),
                    title: Text("Logout"),
                    onTap: () {
                      bloc.logout();
                    },
                  ),
                ]);
              }

              return ListView(
                children: children
                    .map((c) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: c))
                    .toList(),
              );
            }),
      ),
    );
  }
}
