import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

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
      bottomNavigationBar: MyBottomAppBar(
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
                        style: theme.textTheme.display2,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                  child: Text(
                    "App settings",
                    style: theme.textTheme.title
                        .copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                  ),
                ),

                Text(
                  "Default Homepage",
                  style: theme.textTheme.body1
                      .copyWith(fontWeight: FontWeight.bold, color: theme.accentColor),
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
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    "App Theme",
                    style: theme.textTheme.body1
                        .copyWith(fontWeight: FontWeight.bold, color: theme.accentColor),
                  ),
                ),
                RadioListTile<AppBrightness>(
                  title: const Text("Light"),
                  value: AppBrightness.light,
                  groupValue: bloc.brightness,
                  onChanged: (v) {
                    bloc.brightness = v;
                  },
                ),
                RadioListTile<AppBrightness>(
                  title: const Text("Dark"),
                  value: AppBrightness.dark,
                  groupValue: bloc.brightness,
                  onChanged: (v) {
                    bloc.brightness = v;
                  },
                ),
                RadioListTile<AppBrightness>(
                  title: const Text("Black"),
                  value: AppBrightness.black,
                  groupValue: bloc.brightness,
                  onChanged: (v) {
                    bloc.brightness = v;
                  },
                ),
                ListTile(
                  title: Text("Primary Color"),
                  subtitle: Text("Choose primary color of the app"),
                  trailing: CircleColor(
                    circleSize: 24,
                    color: bloc.primaryColor,
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Select Primary Color"),
                            content: MaterialColorPicker(
                              onColorChange: (c) {
                                bloc.primaryColor = c;
                              },
                              selectedColor: bloc.primaryColor,
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Okay"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  },
                ),
                ListTile(
                  title: Text("Accent Color"),
                  subtitle: Text("Choose accent color of the app"),
                  trailing: CircleColor(
                    circleSize: 24,
                    color: bloc.accentColor,
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Select Accent Color"),
                            content: MaterialColorPicker(
                              onColorChange: (c) {
                                bloc.accentColor = c;
                              },
                              selectedColor: bloc.accentColor,
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Okay"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  },
                ),
                ListTile(
                  leading: Icon(OMIcons.feedback),
                  trailing: Icon(OMIcons.launch),
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
                          .copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
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
                        heroTag: snapshot.data.profile.userID,
                      ),
                      title: Text(
                        snapshot.data.profile.userName,
                        style: theme.textTheme.title,
                      ),
                      onTap: () {
                        UserPage.navigateWith(context, bloc, snapshot.data.profile);
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(OMIcons.personOutline),
                    trailing: Icon(OMIcons.launch),
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
