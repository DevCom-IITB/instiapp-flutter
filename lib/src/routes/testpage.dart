import 'dart:collection';

import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/drawer_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:InstiApp/src/api/model/notification.dart' as ntf;

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool loggingOutLoading = false;

  void changeSelection(int idx, DrawerBloc bloc) {
    bloc.setPageIndex(idx);
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var drawerState = bloc.drawerState;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Testing"),
      ),
      bottomSheet: DraggableScrollableSheet(
        minChildSize: 0.1,
        initialChildSize: 0.1,
        builder: (_, ScrollController controller) {
          return StreamBuilder<Session>(
            stream: bloc.session,
            builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
              var theme = Theme.of(context);
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  !loggingOutLoading) {
                bloc.updateNotifications();
              }
              return StreamBuilder<int>(
                  stream: drawerState.highlightPageIndex,
                  initialData: 0,
                  builder:
                      (BuildContext context, AsyncSnapshot<int> indexSnapshot) {
                    Map<int, NavListTile> navMap = {
                      0: NavListTile(
                        icon: OMIcons.dashboard,
                        title: "Feed",
                        onTap: () {
                          changeSelection(0, drawerState);
                          var navi = Navigator.of(context);
                          navi.pushNamed('/feed');
                        },
                      ),
                      1: NavListTile(
                        icon: OMIcons.rssFeed,
                        title: "News",
                        onTap: () {
                          changeSelection(1, drawerState);
                          var navi = Navigator.of(context);
                          navi.pushNamed('/news');
                        },
                      ),
                      2: NavListTile(
                        icon: OMIcons.search,
                        title: "Explore",
                        onTap: () {
                          changeSelection(2, drawerState);
                          var navi = Navigator.of(context);
                          navi.pushNamed('/explore');
                        },
                      ),
                      3: NavListTile(
                        icon: OMIcons.restaurant,
                        title: "Mess Menu",
                        onTap: () {
                          changeSelection(3, drawerState);
                          var navi = Navigator.of(context);
                          navi.pushNamed('/mess');
                        },
                      ),
                      4: NavListTile(
                        icon: OMIcons.workOutline,
                        title: "Placement Blog",
                        onTap: () {
                          changeSelection(4, drawerState);
                          var navi = Navigator.of(context);
                          navi.pushNamed('/placeblog');
                        },
                      ),
                      5: NavListTile(
                        icon: OMIcons.workOutline,
                        title: "Internship Blog",
                        onTap: () {
                          changeSelection(5, drawerState);
                          var navi = Navigator.of(context);
                          navi.pushNamed('/trainblog');
                        },
                      ),
                      6: NavListTile(
                        icon: OMIcons.dateRange,
                        title: "Calendar",
                        onTap: () {
                          changeSelection(6, drawerState);
                          var navi = Navigator.of(context);
                          navi.pushNamed('/calendar');
                        },
                      ),
                      7: NavListTile(
                        icon: OMIcons.map,
                        title: "Map",
                        onTap: () {
                          changeSelection(7, drawerState);
                          var navi = Navigator.of(context);
                          navi.pushNamed('/map');
                        },
                      ),
                      8: NavListTile(
                        icon: OMIcons.feedback,
                        title: "Complaints/Suggestions",
                        onTap: () {
                          changeSelection(8, drawerState);
                          var navi = Navigator.of(context);
                          navi.pushNamed('/complaints');
                        },
                      ),
                      9: NavListTile(
                        icon: OMIcons.link,
                        title: "Quick Links",
                        onTap: () {
                          changeSelection(9, drawerState);
                          var navi = Navigator.of(context);
                          navi.pushNamed('/quicklinks');
                        },
                      ),
                      10: NavListTile(
                        icon: OMIcons.settings,
                        title: "Settings",
                        onTap: () {
                          changeSelection(10, drawerState);
                          var navi = Navigator.of(context);
                          navi.pushNamed('/settings');
                        },
                      ),
                      11: NavListTile(
                        icon: OMIcons.textRotationDown,
                        title: "TestPage",
                        onTap: () {
                          changeSelection(11, drawerState);
                          var navi = Navigator.of(context);
                          navi.pushNamed('/test');
                        },
                      ),
                    };

                    List<Widget> navList, navDownList = <Widget>[];
                    navList = <Widget>[
                      SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              decoration: snapshot.data != null &&
                                      indexSnapshot.data == -2
                                  ? BoxDecoration(
                                      color: theme.primaryColor.withAlpha(100),
                                      borderRadius: BorderRadius.only(
                                          bottomRight:
                                              const Radius.circular(48.0),
                                          topRight:
                                              const Radius.circular(48.0)))
                                  : snapshot?.data?.profile?.userName != null
                                      ? BoxDecoration(
                                          color:
                                              theme.primaryColor.withAlpha(60),
                                          borderRadius: BorderRadius.only(
                                              bottomRight:
                                                  const Radius.circular(48.0),
                                              topRight:
                                                  const Radius.circular(48.0)))
                                      : null,
                              child: ListTile(
                                leading: NullableCircleAvatar(
                                  snapshot.data?.profile?.userProfilePictureUrl,
                                  OMIcons.personOutline,
                                ),
                                title: Text(
                                  snapshot?.data?.profile?.userName ??
                                      'Not Logged in',
                                  style: theme.textTheme.body1
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: snapshot.data != null
                                    ? Text(
                                        snapshot.data?.profile?.userRollNumber,
                                        style: theme.textTheme.body1)
                                    : RaisedButton(
                                        child: Text(
                                          "Log in",
                                        ),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushReplacementNamed('/');
                                        },
                                      ),
                                onTap: snapshot.data != null
                                    ? () {
                                        changeSelection(-2, drawerState);
                                        Navigator.pop(context);
                                        UserPage.navigateWith(context, bloc,
                                            bloc.currSession.profile);
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        ]..addAll(snapshot.data != null
                            ? [
                                StreamBuilder(
                                  stream: bloc.notifications,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<
                                              UnmodifiableListView<
                                                  ntf.Notification>>
                                          snapshot) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: <Widget>[
                                          ClipOval(
                                            child: Container(
                                              color: indexSnapshot.data == -1
                                                  ? theme.primaryColor
                                                      .withAlpha(100)
                                                  : null,
                                              child: IconButton(
                                                tooltip: "Notifications",
                                                icon: Icon(
                                                  (snapshot.hasData &&
                                                              snapshot.data
                                                                  .isNotEmpty) ||
                                                          (!snapshot.hasData)
                                                      ? OMIcons
                                                          .notificationsActive
                                                      : OMIcons
                                                          .notificationsNone,
                                                  color:
                                                      indexSnapshot.data == -1
                                                          ? theme.primaryColor
                                                          : null,
                                                ),
                                                onPressed: () {
                                                  changeSelection(
                                                      -1, drawerState);
                                                  var navi =
                                                      Navigator.of(context);
                                                  navi.pushNamed(
                                                      '/notifications');
                                                },
                                              ),
                                            ),
                                          ),
                                        ]..addAll((snapshot.hasData &&
                                                    snapshot.data.isNotEmpty) ||
                                                (!snapshot.hasData)
                                            ? [
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: snapshot.hasData
                                                      ? Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  3.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: theme
                                                                .accentColor,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              "${snapshot.data.length}",
                                                              style: theme
                                                                  .accentTextTheme
                                                                  .overline,
                                                            ),
                                                          ),
                                                        )
                                                      : CircularProgressIndicatorExtended(
                                                          size: 12,
                                                        ),
                                                )
                                              ]
                                            : []),
                                      ),
                                    );
                                  },
                                )
                              ]
                            : []),
                      ),
                      Divider(),
                    ];
                    navList.addAll(navMap.values.take(10));
                    navDownList.addAll(navMap.values.skip(10));
                    if (snapshot.data?.sessionid != null) {
                      navDownList.add(NavListTile(
                        icon: OMIcons.exitToApp,
                        title: "Logout",
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
                      ));
                    }

                    // Selecting which NavListTile to highlight
                    if (indexSnapshot.data > -1) {
                      navMap[indexSnapshot.data].setHighlighted(true);
                    }

                    return ListTileTheme(
                        selectedColor: theme.primaryColor,
                        style: ListTileStyle.drawer,
                        child: ListView(
                          shrinkWrap: true,
                          children: navList + navDownList,
                          controller: controller,
                        ));
                  });
            },
          );
          return Material(
            elevation: 30.0,
            type: MaterialType.canvas,
            child: ListView(
              controller: controller,
              shrinkWrap: true,
              children: <Widget>[
                ListTile(title: const Text('One')),
                ListTile(title: const Text('One312')),
                ListTile(title: const Text('One3')),
                ListTile(title: const Text('One357')),
                ListTile(title: const Text('One3')),
                ListTile(title: const Text('One1')),
                ListTile(title: const Text('One4')),
                ListTile(title: const Text('One5')),
                ListTile(title: const Text('One2')),
                ListTile(title: const Text('On3e')),
                ListTile(title: const Text('On3e')),
                ListTile(title: const Text('On3e')),
                ListTile(title: const Text('On3e')),
                ListTile(title: const Text('On3e')),
                ListTile(title: const Text('On3e')),
                ListTile(title: const Text('On3e')),
              ],
            ),
          );
        },
      ),
    );
  }
}
