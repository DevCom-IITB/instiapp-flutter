import 'dart:collection';

import 'package:InstiApp/src/blocs/drawer_bloc.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_bottom_sheet/scrollable_bottom_sheet.dart';

class DrawerOnly extends StatelessWidget {
  // For now not highlighting the current page in the drawer
  // void changeSelection(int pos, List<Widget> navList) {
  //   NavListTile tile = navList[activeTile];
  //   tile.setSelection(false);
  //   activeTile = pos;
  //   tile = navList[activeTile];
  //   tile.setSelection(true);
  // }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    return StreamBuilder<Session>(
      stream: bloc.session,
      builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
        var theme = Theme.of(context);
        var textStyle = TextStyle(fontWeight: FontWeight.bold);
        List<Widget> navList;
        navList = <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: snapshot.data?.profile?.profilePicUrl == null
                ? CircleAvatar(child: Icon(OMIcons.person))
                : CircleAvatar(
                    backgroundImage:
                        NetworkImage(snapshot.data?.profile?.profilePicUrl),
                  ),
            accountName: Text(
              snapshot?.data?.profile?.name ?? 'Not Logged in',
              style: theme.textTheme.body1
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            accountEmail: snapshot.data != null
                ? Text(snapshot.data?.profile?.rollNo,
                    style: theme.textTheme.body1.copyWith(color: Colors.white))
                : RaisedButton(
                    child: Text("Log in"),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                  ),
            decoration: BoxDecoration(
              color: theme.accentColor,
            ),
          ),
          NavListTile(
            icon: OMIcons.dashboard,
            selected: true,
            title: "Feed",
            onTap: () {
              // changeSelection(1, navList);
              var navi = Navigator.of(context);
              navi.pop();
              navi.pushNamed('/feed');
            },
          ),
          NavListTile(
            icon: OMIcons.rssFeed,
            title: "News",
            onTap: () {
              // changeSelection(2, navList);
            },
          ),
          NavListTile(
            icon: OMIcons.search,
            title: "Explore",
            onTap: () {
              // changeSelection(3, navList);
            },
          ),
          NavListTile(
            icon: OMIcons.restaurant,
            title: "Mess Menu",
            selected: true,
            onTap: () {
              // changeSelection(4, navList);
              var navi = Navigator.of(context);
              navi.pop();
              navi.pushNamed('/mess');
            },
          ),
          NavListTile(
            icon: OMIcons.workOutline,
            title: "Placement Blog",
            selected: true,
            onTap: () {
              // changeSelection(5, navList);
              var navi = Navigator.of(context);
              navi.pop();
              navi.pushNamed('/placeblog');
            },
          ),
          NavListTile(
            icon: OMIcons.workOutline,
            title: "Internship Blog",
            selected: true,
            onTap: () {
              // changeSelection(6, navList);
              var navi = Navigator.of(context);
              navi.pop();
              navi.pushNamed('/trainblog');
            },
          ),
          NavListTile(
            icon: OMIcons.dateRange,
            title: "Calender",
            onTap: () {
              // changeSelection(7, navList);
            },
          ),
          NavListTile(
            icon: OMIcons.map,
            title: "Map",
            onTap: () {
              // changeSelection(8, navList);
            },
          ),
          NavListTile(
            icon: OMIcons.feedback,
            title: "Complaints/Suggestions",
            onTap: () {
              // changeSelection(9, navList);
            },
          ),
          NavListTile(
            icon: OMIcons.link,
            title: "Quick Links",
            onTap: () {
              // changeSelection(10, navList);
            },
          ),
          NavListTile(
            icon: OMIcons.settings,
            title: "Settings",
            onTap: () {
              // changeSelection(11, navList);
            },
          ),
        ];
        if (snapshot.data?.sessionid != null) {
          navList.add(NavListTile(
            icon: OMIcons.exitToApp,
            title: "Logout",
            onTap: () {
              bloc.logout();
            },
          ));
        }

        // For now not highlighting the current page
        // NavListTile a = navList[activeTile];
        // a.setSelection(true);

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: navList,
          ),
        );
      },
    );
  }
}

class BottomDrawer extends StatefulWidget {
  static void setPageIndex(InstiAppBloc bloc, int pageIndex) {
    bloc.drawerState.setPageIndex(pageIndex);
  }

  @override
  _BottomDrawerState createState() => _BottomDrawerState();
}

class _BottomDrawerState extends State<BottomDrawer> {
  void changeSelection(int idx, DrawerBloc bloc) {
    bloc.setPageIndex(idx);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var drawerState = bloc.drawerState;
    return ScrollableBottomSheet(
      snapAbove: true,
      initialHeight: 300.0,
      child: StreamBuilder<Session>(
        stream: bloc.session,
        builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
          var theme = Theme.of(context);
          var textStyle = TextStyle(fontWeight: FontWeight.bold);

          return StreamBuilder<int>(
              stream: drawerState.highlightPageIndex,
              initialData: 0,
              builder:
                  (BuildContext context, AsyncSnapshot<int> indexSnapshot) {
                Map<int, NavListTile> navMap = {
                  0: NavListTile(
                    icon: OMIcons.dashboard,
                    selected: true,
                    title: "Feed",
                    onTap: () {
                      changeSelection(0, drawerState);
                      var navi = Navigator.of(context);
                      navi.pop();
                      navi.pushNamed('/feed');
                    },
                  ),
                  1: NavListTile(
                    icon: OMIcons.rssFeed,
                    title: "News",
                    onTap: () {
                      changeSelection(1, drawerState);
                    },
                  ),
                  2: NavListTile(
                    icon: OMIcons.search,
                    title: "Explore",
                    onTap: () {
                      changeSelection(2, drawerState);
                    },
                  ),
                  3: NavListTile(
                    icon: OMIcons.restaurant,
                    title: "Mess Menu",
                    selected: true,
                    onTap: () {
                      changeSelection(3, drawerState);
                      var navi = Navigator.of(context);
                      navi.pop();
                      navi.pushNamed('/mess');
                    },
                  ),
                  4: NavListTile(
                    icon: OMIcons.workOutline,
                    title: "Placement Blog",
                    selected: true,
                    onTap: () {
                      changeSelection(4, drawerState);
                      var navi = Navigator.of(context);
                      navi.pop();
                      navi.pushNamed('/placeblog');
                    },
                  ),
                  5: NavListTile(
                    icon: OMIcons.workOutline,
                    title: "Internship Blog",
                    selected: true,
                    onTap: () {
                      changeSelection(5, drawerState);
                      var navi = Navigator.of(context);
                      navi.pop();
                      navi.pushNamed('/trainblog');
                    },
                  ),
                  6: NavListTile(
                    icon: OMIcons.dateRange,
                    title: "Calender",
                    onTap: () {
                      changeSelection(6, drawerState);
                    },
                  ),
                  7: NavListTile(
                    icon: OMIcons.map,
                    title: "Map",
                    onTap: () {
                      changeSelection(7, drawerState);
                    },
                  ),
                  8: NavListTile(
                    icon: OMIcons.feedback,
                    title: "Complaints/Suggestions",
                    onTap: () {
                      changeSelection(8, drawerState);
                    },
                  ),
                  9: NavListTile(
                    icon: OMIcons.link,
                    title: "Quick Links",
                    onTap: () {
                      changeSelection(9, drawerState);
                    },
                  ),
                  10: NavListTile(
                    icon: OMIcons.settings,
                    title: "Settings",
                    onTap: () {
                      changeSelection(10, drawerState);
                    },
                  ),
                };

                List<Widget> navList;
                navList = <Widget>[
                  SizedBox(
                    height: 18.0,
                  ),
                  // Divider(),
                  ListTile(
                    leading: snapshot.data?.profile?.profilePicUrl == null
                        ? CircleAvatar(child: Icon(OMIcons.person))
                        : CircleAvatar(
                            backgroundImage: NetworkImage(
                                snapshot.data?.profile?.profilePicUrl),
                          ),
                    title: Text(
                      snapshot?.data?.profile?.name ?? 'Not Logged in',
                      style: theme.textTheme.body1
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: snapshot.data != null
                        ? Text(snapshot.data?.profile?.rollNo,
                            style: theme.textTheme.body1)
                        : RaisedButton(
                            child: Text("Log in"),
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed('/');
                            },
                          ),
                  ),
                  Divider(),
                ];
                navList.addAll(navMap.values);
                if (snapshot.data?.sessionid != null) {
                  navList.add(NavListTile(
                    icon: OMIcons.exitToApp,
                    title: "Logout",
                    onTap: () {
                      bloc.logout();
                    },
                  ));
                }

                // Selecting which NavListTile to highlight
                navMap[indexSnapshot.data].setHighlighted(true);

                return Material(
                  child: Column(
                    children: navList,
                  ),
                );
              });
        },
      ),
    );
  }
}

class NavListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final GestureTapCallback onTap;
  final bool selected;
  bool highlight;

  void setHighlighted(bool selection) {
    highlight = selection;
  }

  NavListTile(
      {this.icon,
      this.title,
      this.onTap,
      this.selected = false,
      this.highlight = false});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      decoration: !highlight
          ? null
          : BoxDecoration(
              color: theme.accentColor.withAlpha(20),
              borderRadius: BorderRadius.all(const Radius.circular(48.0))),
      child: ListTile(
        selected: selected,
        enabled: true,
        leading: Icon(this.icon),
        title: Text(
          this.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: this.onTap,
      ),
    );
  }
}
