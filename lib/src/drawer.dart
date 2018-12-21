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
  final Widget child;

  BottomDrawer({@required this.child});
  @override
  _BottomDrawerState createState() => _BottomDrawerState();
}

class _BottomDrawerState extends State<BottomDrawer> {
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    return ScrollableBottomSheet(
      snapAbove: true,
      minimumHeight: 60.0,
      initialHeight: 60.0,
      child: StreamBuilder<Session>(
        stream: bloc.session,
        builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
          var theme = Theme.of(context);
          var textStyle = TextStyle(fontWeight: FontWeight.bold);
          List<Widget> navList;
          navList = <Widget>[
            Container(
              // decoration: BoxDecoration(
              //   border: Border(top: BorderSide(width: 2)),
              // ),
              color: Colors.transparent,
              child: SizedBox(
                height: 12.0,
                width: 24.0,
                child: Icon(OMIcons.maximize, size: 24)
              ),
            ),
            widget.child ??
                BottomAppBar(
                    child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      tooltip: "Show bottom sheet",
                      icon: Icon(
                        OMIcons.menu,
                        semanticLabel: "Show bottom sheet",
                      ),
                      onPressed: () {},
                    ),
                  ],
                )),
            SizedBox(
              height: 18.0,
            ),
            // Divider(),
            ListTile(
              leading: snapshot.data?.profile?.profilePicUrl == null
                  ? CircleAvatar(child: Icon(OMIcons.person))
                  : CircleAvatar(
                      backgroundImage:
                          NetworkImage(snapshot.data?.profile?.profilePicUrl),
                    ),
              title: Text(
                snapshot?.data?.profile?.name ?? 'Not Logged in',
                style:
                    theme.textTheme.body1.copyWith(fontWeight: FontWeight.bold),
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
            NavListTile(
              icon: OMIcons.dashboard,
              selected: true,
              title: "Feed",
              onTap: () {
                // changeSelection(1, navList);
                var navi = Navigator.of(context);
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

          return Material(
            // elevation: 16.0,
            // decoration: BoxDecoration(
            //     border: Border(top: BorderSide(color: theme.disabledColor))),
            child: Column(
              children: navList,
            ),
          );
        },
      ),
    );
  }
}

class NavListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final GestureTapCallback onTap;
  final bool selected;

  Stream<bool> get selectedStream => _selectedSubject.stream;
  final _selectedSubject = BehaviorSubject<bool>();

  void setSelection(bool selection) {
    _selectedSubject.add(selection);
  }

  NavListTile({this.icon, this.title, this.onTap, this.selected = false});

  @override
  NavListTileState createState() {
    return new NavListTileState(this.selected);
  }
}

class NavListTileState extends State<NavListTile> {
  bool selected;

  NavListTileState(this.selected);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.selectedStream,
        initialData: selected,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return ListTile(
            selected: snapshot.data,
            enabled: true,
            leading: Icon(this.widget.icon),
            title: Text(
              this.widget.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: this.widget.onTap,
          );
        });
  }
}
