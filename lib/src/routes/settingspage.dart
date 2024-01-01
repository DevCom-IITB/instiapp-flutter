import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/app_brightness.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/switch_list_tile.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';
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

  bool updatingSCN = false;
  bool loggingOutLoading = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;

    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      bottomNavigationBar: MyBottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              tooltip: "Show Navigation Drawer",
              icon: Icon(
                Icons.menu_outlined,
                semanticLabel: "Show Navigation Drawer",
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
            stream: bloc.session,
            builder: (BuildContext context, AsyncSnapshot<Session?> snapshot) {
              var children = <Widget>[
                TitleWithBackButton(
                  child: Text(
                    "Settings",
                    style: theme.textTheme.headline3,
                  ),
                )
              ];
              if (snapshot.data != null) {
                children.addAll([
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28.0, vertical: 12.0),
                    child: Text(
                      "Profile settings",
                      style: theme.textTheme.headline6?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor),
                    ),
                  ),
                  MySwitchListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 28.0),
                    secondary: updatingSCN
                        ? CircularProgressIndicatorExtended()
                        : Icon(Icons.contact_phone_outlined),
                    title: Text("Show contact number"),
                    subtitle: Text("Toggle visibility on your profile"),
                    value:
                        snapshot.data?.profile?.userShowContactNumber ?? false,
                    onChanged: updatingSCN
                        ? (_) {}
                        : (bool showContactNumber) async {
                            setState(() {
                              updatingSCN = true;
                            });
                            await bloc
                                .patchUserShowContactNumber(showContactNumber);
                            setState(() {
                              updatingSCN = false;
                            });
                          },
                  ),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 28.0),
                    leading: Icon(Icons.person_outline_outlined),
                    trailing: Icon(Icons.launch_outlined),
                    title: Text("Update Profile"),
                    subtitle: Text("Update personal details on SSO"),
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse(updateProfileUrl))) {
                        await launchUrl(
                          Uri.parse(updateProfileUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 28.0),
                    leading: Icon(Icons.exit_to_app_outlined),
                    title: Text("Logout"),
                    subtitle: Text("Sign out of InstiApp"),
                    onTap: loggingOutLoading
                        ? null
                        : () async {
                            setState(() {
                              loggingOutLoading = true;
                            });
                            await bloc.logout();
                            setState(() {
                              loggingOutLoading = false;
                            });
                          },
                    trailing: loggingOutLoading
                        ? CircularProgressIndicatorExtended()
                        : null,
                  ),
                ]);
              }
              children.addAll([
                Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, right: 28.0, top: 8.0, bottom: 24.0),
                  child: Text(
                    "App settings",
                    style: theme.textTheme.headline6?.copyWith(
                        fontWeight: FontWeight.bold, color: theme.primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Text(
                    "Default Homepage",
                    style: theme.textTheme.bodyText2?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: DropdownButton(
                    isExpanded: true,
                    items: {
                      "/mess": "Mess",
                      "/placeblog": "Placement Blog",
                      "/trainblog": "Internship Blog",
                      "/feed": "Feed",
                      "/quicklinks": "Quick Links",
                      "/news": "News",
                      "/InSeek": "InSeek",
                      "/explore": "Explore",
                      "/calendar": "Calendar",
                      // "/complaints": "Complaints/Suggestions",
                      "/map": "Map",
                      // "/settings": "Settings",
                      "/groups": "Communities",
                      //"/groups": "Communities",
                    }.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (String? s) {
                      bloc.updateHomepage(s ?? "");
                      setState(() {});
                    },
                    value: bloc.homepageName,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0, bottom: 12.0, left: 28.0, right: 28.0),
                  child: Text(
                    "App Theme",
                    style: theme.textTheme.bodyText2?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary),
                  ),
                ),
                RadioListTile<AppBrightness>(
                  title: const Text("Light"),
                  value: AppBrightness.light,
                  groupValue: bloc.brightness,
                  onChanged: (v) {
                    if (v != null) bloc.brightness = v;
                  },
                ),
                RadioListTile<AppBrightness>(
                  title: const Text("Dark"),
                  value: AppBrightness.dark,
                  groupValue: bloc.brightness,
                  onChanged: (v) {
                    if (v != null) bloc.brightness = v;
                  },
                ),
                RadioListTile<AppBrightness>(
                  title: const Text("Black"),
                  value: AppBrightness.black,
                  groupValue: bloc.brightness,
                  onChanged: (v) {
                    if (v != null) bloc.brightness = v;
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 28.0),
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
                              onMainColorChange: (c) {
                                bloc.primaryColor = c ?? appColors[0];
                              },
                              selectedColor: bloc.primaryColor,
                              colors: appColors,
                            ),
                            actions: <Widget>[
                              TextButton(
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 28.0),
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
                              onMainColorChange: (c) {
                                bloc.accentColor = c ?? appColors[0];
                              },
                              selectedColor: bloc.accentColor,
                              colors: appColors,
                            ),
                            actions: <Widget>[
                              TextButton(
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.0),
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.restore_outlined),
                    label: Text("Restore Default Theme"),
                    onPressed: () {
                      bloc.primaryColor = bloc.defaultThemes[0][0];
                      bloc.accentColor = bloc.defaultThemes[0][1];
                    },
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 28.0),
                  leading: Icon(Icons.feedback_outlined),
                  trailing: Icon(Icons.launch_outlined),
                  title: Text("Feedback"),
                  subtitle:
                      Text("Report technical issues or suggest new features"),
                  onTap: () async {
                    if (await canLaunchUrl(Uri.parse(feedbackUrl))) {
                      await launchUrl(
                        Uri.parse(feedbackUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 28.0),
                  leading: Icon(Icons.info_outline),
                  title: Text("About"),
                  subtitle: Text("The InstiApp Team"),
                  onTap: () {
                    Navigator.pushNamed(context, '/about');
                  },
                ),
              ]);

              return ListView(
                children: children,
              );
            }),
      ),
    );
  }
}
