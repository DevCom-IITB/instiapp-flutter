import 'package:InstiApp/src/blocs/drawer_bloc.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

// A Bottom Navigation Drawer
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
    return Drawer(
      // snapAbove: true,
      // initialHeight: MediaQuery.of(context).size.height / 2 - 20,
      child: StreamBuilder<Session>(
        stream: bloc.session,
        builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
          var theme = Theme.of(context);

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
                    selected: true,
                    onTap: () {
                      changeSelection(1, drawerState);
                      var navi = Navigator.of(context);
                      navi.pop();
                      navi.pushNamed('/news');
                    },
                  ),
                  2: NavListTile(
                    icon: OMIcons.search,
                    title: "Explore",
                    selected: true,
                    onTap: () {
                      changeSelection(2, drawerState);
                      var navi = Navigator.of(context);
                      navi.pop();
                      navi.pushNamed('/explore');
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
                    title: "Calendar",
                    selected: true,
                    onTap: () {
                      changeSelection(6, drawerState);
                      var navi = Navigator.of(context);
                      navi.pop();
                      navi.pushNamed('/calendar');
                    },
                  ),
                  7: NavListTile(
                    icon: OMIcons.map,
                    title: "Map",
                    selected: true,
                    onTap: () {
                      changeSelection(7, drawerState);
                      var navi = Navigator.of(context);
                      navi.pop();
                      navi.pushNamed('/map');
                    },
                  ),
                  8: NavListTile(
                    icon: OMIcons.feedback,
                    title: "Complaints/Suggestions",
                    selected: true,
                    onTap: () {
                      changeSelection(8, drawerState);
                      var navi = Navigator.of(context);
                      navi.pop();
                      navi.pushNamed('/complaints');
                    },
                  ),
                  9: NavListTile(
                    icon: OMIcons.link,
                    title: "Quick Links",
                    selected: true,
                    onTap: () {
                      changeSelection(9, drawerState);
                      var navi = Navigator.of(context);
                      navi.pop();
                      navi.pushNamed('/quicklinks');
                    },
                  ),
                  10: NavListTile(
                    icon: OMIcons.settings,
                    title: "Settings",
                    selected: true,
                    onTap: () {
                      changeSelection(10, drawerState);
                      var navi = Navigator.of(context);
                      navi.pop();
                      navi.pushNamed('/settings');
                    },
                  ),
                };

                List<Widget> navList;
                navList = <Widget>[
                  SizedBox(
                    height: 18.0,
                  ),
                  ListTile(
                    leading: NullableCircleAvatar(
                      snapshot.data?.profile?.userProfilePictureUrl,
                      OMIcons.personOutline,
                    ),
                    title: Text(
                      snapshot?.data?.profile?.userName ?? 'Not Logged in',
                      style: theme.textTheme.body1
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: snapshot.data != null
                        ? Text(snapshot.data?.profile?.userRollNumber,
                            style: theme.textTheme.body1)
                        : RaisedButton(
                            child: Text(
                              "Log in",
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed('/');
                            },
                          ),
                    onTap: snapshot.data != null
                        ? () {
                            UserPage.navigateWith(context, bloc, bloc.currSession.profile);
                          }
                        : null,
                  ),
                  Divider(),
                ];
                navList.addAll(navMap.values);
                if (snapshot.data?.sessionid != null) {
                  navList.add(NavListTile(
                    icon: OMIcons.exitToApp,
                    title: "Logout",
                    selected: true,
                    onTap: () {
                      bloc.logout();
                    },
                  ));
                }

                // Selecting which NavListTile to highlight
                navMap[indexSnapshot.data].setHighlighted(true);

                return ListTileTheme(
                  selectedColor: theme.primaryColor,
                  iconColor: theme.primaryColorDark,
                  style: ListTileStyle.drawer,
                  child: ListView(
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
    var listTileTheme = ListTileTheme.of(context);
    return Container(
      decoration: !highlight
          ? null
          : BoxDecoration(
              color: listTileTheme.selectedColor.withAlpha(100),
              borderRadius: BorderRadius.only(
                  bottomRight: const Radius.circular(48.0),
                  topRight: const Radius.circular(48.0))),
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
