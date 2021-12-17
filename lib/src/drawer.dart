import 'dart:collection';
import 'dart:developer';

import 'package:InstiApp/src/blocs/drawer_bloc.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/api/model/notification.dart' as ntf;
import 'package:rxdart/rxdart.dart';

// A Navigation Drawer
class NavDrawer extends StatefulWidget {
  static void setPageIndex(InstiAppBloc bloc, int pageIndex) {
    bloc.drawerState.setPageIndex(pageIndex);
  }

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  bool loggingOutLoading = false;

  void changeSelection(int idx, DrawerBloc bloc) {
    bloc.setPageIndex(idx);
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context)?.bloc;
    var drawerState = bloc?.drawerState;

    return Drawer(
      child: SafeArea(
        child: StreamBuilder<Session?>(
          stream: bloc?.session,
          builder: (BuildContext context, AsyncSnapshot<Session?> snapshot) {
            var theme = Theme.of(context);
            if (snapshot.hasData &&
                snapshot.data != null &&
                !loggingOutLoading) {
              bloc?.updateNotifications();
            }
            return StreamBuilder<int>(
                stream: drawerState?.highlightPageIndex,
                initialData: 0,
                builder:
                    (BuildContext context, AsyncSnapshot<int> indexSnapshot) {
                  Map<int, Widget> navMap = {
                    0: NavListTile(
                      icon: Icons.dashboard_outlined,
                      title: "Feed",
                      onTap: () {
                        changeSelection(0, drawerState!);
                        var navi = Navigator.of(context);
                        navi.pushReplacementNamed('/feed');
                      },
                      highlight: indexSnapshot.data == 0,
                    ),
                    1: NavListTile(
                      icon: Icons.rss_feed_outlined,
                      title: "News",
                      onTap: () {
                        changeSelection(1, drawerState!);
                        var navi = Navigator.of(context);
                        navi.pushReplacementNamed('/news');
                      },
                      highlight: indexSnapshot.data == 1,
                    ),
                    2: NavListTile(
                      icon: Icons.search_outlined,
                      title: "Explore",
                      onTap: () {
                        changeSelection(2, drawerState!);
                        var navi = Navigator.of(context);
                        navi.pushReplacementNamed('/explore');
                      },
                      highlight: indexSnapshot.data == 2,
                    ),
                    3: NavListTile(
                      icon: Icons.restaurant_outlined,
                      title: "Mess Menu",
                      onTap: () {
                        changeSelection(3, drawerState!);
                        var navi = Navigator.of(context);
                        navi.pushReplacementNamed('/mess');
                      },
                      highlight: indexSnapshot.data == 3,
                    ),
                    4: NavExpansionTile(
                      leading: Icons.work_outline,
                      title: "Blogs",
                      initiallyExpanded:
                          indexSnapshot.data! <= 6 && indexSnapshot.data! >= 4,
                      children: [
                        NavListTile(
                          icon: Icons.work_outline,
                          title: "Placement Blog",
                          onTap: () {
                            changeSelection(4, drawerState!);
                            var navi = Navigator.of(context);
                            navi.pushReplacementNamed('/placeblog');
                          },
                          highlight: indexSnapshot.data == 4,
                        ),
                        NavListTile(
                          icon: Icons.work_outline,
                          title: "Internship Blog",
                          onTap: () {
                            changeSelection(5, drawerState!);
                            var navi = Navigator.of(context);
                            navi.pushReplacementNamed('/trainblog');
                          },
                          highlight: indexSnapshot.data == 5,
                        ),
                        NavListTile(
                          icon: Icons.work_outline,
                          title: "External Blog",
                          onTap: () {
                            changeSelection(6, drawerState!);
                            var navi = Navigator.of(context);
                            navi.pushReplacementNamed('/externalblog');
                          },
                          highlight: indexSnapshot.data == 6,
                        ),
                      ],
                    ),
                    7: NavListTile(
                      icon: Icons.date_range_outlined,
                      title: "Calendar",
                      onTap: () {
                        changeSelection(7, drawerState!);
                        var navi = Navigator.of(context);
                        navi.pushReplacementNamed('/calendar');
                      },
                      highlight: indexSnapshot.data == 7,
                    ),
                    9: NavListTile(
                      icon: Icons.verified_outlined,
                      title: "Achievements",
                      onTap: () {
                        changeSelection(9, drawerState!);
                        var navi = Navigator.of(context);
                        navi.pushReplacementNamed('/achievements');
                      },
                      highlight: indexSnapshot.data == 9,
                    ),
                    8: NavExpansionTile(
                      title: "Utilities",
                      initiallyExpanded: indexSnapshot.data == 8 ||
                          indexSnapshot.data == 11 ||
                          indexSnapshot.data == 12,
                      leading: Icons.construction_outlined,
                      children: [
                        NavListTile(
                          icon: Icons.map_outlined,
                          title: "Map",
                          onTap: () {
                            changeSelection(8, drawerState!);
                            var navi = Navigator.of(context);
                            navi.pushReplacementNamed('/map');
                          },
                          highlight: indexSnapshot.data == 8,
                        ),
                        NavListTile(
                          icon: Icons.link_outlined,
                          title: "Quick Links",
                          onTap: () {
                            changeSelection(11, drawerState!);
                            var navi = Navigator.of(context);
                            navi.pushReplacementNamed('/quicklinks');
                          },
                          highlight: indexSnapshot.data == 11,
                        ),
                        NavListTile(
                          icon: Icons.settings_outlined,
                          title: "Settings",
                          onTap: () {
                            changeSelection(12, drawerState!);
                            var navi = Navigator.of(context);
                            navi.pushReplacementNamed('/settings');
                          },
                          highlight: indexSnapshot.data == 12,
                        ),
                      ],
                    ),
                    13: NavListTile(
                      icon: Icons.query_stats,
                      title: "FAQs",
                      onTap: () {
                        changeSelection(13, drawerState!);
                        var navi = Navigator.of(context);
                        navi.pushReplacementNamed('/query');
                      },
                      highlight: indexSnapshot.data == 13,
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
                                        topRight: const Radius.circular(48.0)))
                                : snapshot.data?.profile?.userName != null
                                    ? BoxDecoration(
                                        color: theme.primaryColor.withAlpha(60),
                                        borderRadius: BorderRadius.only(
                                            bottomRight:
                                                const Radius.circular(48.0),
                                            topRight:
                                                const Radius.circular(48.0)))
                                    : null,
                            child: ListTile(
                              leading: NullableCircleAvatar(
                                snapshot.data?.profile?.userProfilePictureUrl ??
                                    "",
                                Icons.person_outline_outlined,
                              ),
                              title: Text(
                                snapshot.data?.profile?.userName ??
                                    'Not Logged in',
                                style: theme.textTheme.bodyText2
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: snapshot.data != null
                                  ? Text(
                                      snapshot.data?.profile?.userRollNumber ??
                                          "",
                                      style: theme.textTheme.bodyText2)
                                  : ElevatedButton(
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
                                      changeSelection(-2, drawerState!);
                                      Navigator.pop(context);
                                      UserPage.navigateWith(context, bloc!,
                                          bloc.currSession?.profile);
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ]..addAll(snapshot.data != null
                          ? [
                              StreamBuilder(
                                stream: bloc?.notifications,
                                builder: (BuildContext context,
                                    AsyncSnapshot<
                                            UnmodifiableListView<
                                                ntf.Notification>>
                                        snapshot) {
                                  bool ex = snapshot.data?.isNotEmpty ?? false;
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
                                                (snapshot.hasData && ex) ||
                                                        (!snapshot.hasData)
                                                    ? Icons
                                                        .notifications_active_outlined
                                                    : Icons
                                                        .notifications_none_outlined,
                                                color: indexSnapshot.data == -1
                                                    ? theme.primaryColor
                                                    : null,
                                              ),
                                              onPressed: () {
                                                changeSelection(
                                                    -1, drawerState!);
                                                var navi =
                                                    Navigator.of(context);
                                                navi.pop();
                                                navi.pushNamed(
                                                    '/notifications');
                                              },
                                            ),
                                          ),
                                        ),
                                      ]..addAll((snapshot.hasData && ex) ||
                                              (!snapshot.hasData)
                                          ? [
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: snapshot.hasData
                                                    ? Container(
                                                        padding:
                                                            EdgeInsets.all(3.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: theme
                                                              .colorScheme
                                                              .secondary,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "${snapshot.data?.length}",
                                                            style: theme
                                                                .textTheme
                                                                .overline
                                                                ?.copyWith(
                                                              color: theme
                                                                  .colorScheme
                                                                  .onSecondary,
                                                            ),
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
                      icon: Icons.exit_to_app_outlined,
                      title: "Logout",
                      onTap: loggingOutLoading
                          ? null
                          : () async {
                              setState(() {
                                loggingOutLoading = true;
                              });
                              await bloc?.logout();
                              setState(() {
                                loggingOutLoading = false;
                              });
                              Navigator.pushReplacementNamed(context, "/");
                            },
                      trailing: loggingOutLoading
                          ? CircularProgressIndicatorExtended()
                          : null,
                    ));
                  }

                  // Selecting which NavListTile to highlight
                  if (indexSnapshot.data! > -1) {
                    // navMap[indexSnapshot.data]?.setHighlighted(true);
                  }

                  return ListTileTheme(
                      selectedColor: theme.primaryColor,
                      style: ListTileStyle.drawer,
                      child: ListView(
                        children: navList + navDownList,
                      ));
                });
          },
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class NavListTile extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final GestureTapCallback? onTap;
  bool selected;
  bool highlight;
  final Widget? trailing;

  void setHighlighted(bool selection) {
    highlight = selection;
    selected = selection;
  }

  NavListTile(
      {this.icon,
      this.title,
      this.onTap,
      this.selected = false,
      this.highlight = false,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    ListTileThemeData listTileTheme = ListTileTheme.of(context);
    return Container(
      decoration: !highlight
          ? null
          : BoxDecoration(
              color: listTileTheme.selectedColor?.withAlpha(100),
              borderRadius: BorderRadius.only(
                  bottomRight: const Radius.circular(48.0),
                  topRight: const Radius.circular(48.0))),
      child: ListTile(
        selected: selected,
        enabled: true,
        leading: Icon(this.icon),
        dense: true,
        title: Text(
          this.title!,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _iconAndTextColor(theme, listTileTheme)),
        ),
        onTap: this.onTap,
        trailing: this.trailing,
      ),
    );
  }

  Color? _iconAndTextColor(ThemeData theme, ListTileThemeData tileTheme) {
    if (selected && tileTheme.selectedColor != null)
      return tileTheme.selectedColor!;

    if (!selected && tileTheme.iconColor != null) return tileTheme.iconColor!;
    // assert(theme.brightness != null);
    print(theme.brightness);
    switch (theme.brightness) {
      case Brightness.light:
        return selected ? theme.primaryColor : Colors.black54;
      case Brightness.dark:
        return selected
            ? null
            : theme
                .colorScheme.secondary; // null - use current icon theme color
    }
    // return null;
  }
}

class NavExpansionTile extends StatefulWidget {
  final IconData? leading;
  final String title;
  final bool initiallyExpanded;
  final List<Widget> children;

  const NavExpansionTile({
    Key? key,
    this.leading,
    required this.title,
    this.initiallyExpanded = false,
    this.children = const [],
  }) : super(key: key);

  @override
  State<NavExpansionTile> createState() => _NavExpansionTileState();
}

class _NavExpansionTileState extends State<NavExpansionTile> {
  bool isOpened = false;

  @override
  void initState() {
    super.initState();
    isOpened = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    ListTileThemeData listTileTheme = ListTileTheme.of(context);
    return ListTileTheme(
      dense: true,
      child: ExpansionTile(
        key: Key(widget.initiallyExpanded.toString()),
        title: Text(
          widget.title,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _iconAndTextColor(theme, listTileTheme)),
        ),
        leading: Icon(widget.leading),
        initiallyExpanded: widget.initiallyExpanded,
        children: widget.children,
        // textColor: _iconAndTextColor(theme, listTileTheme),
        iconColor: listTileTheme.iconColor,
        collapsedIconColor: listTileTheme.iconColor,
        onExpansionChanged: (val) {
          setState(() {
            isOpened = val;
          });
        },
      ),
    );
  }

  Color? _iconAndTextColor(ThemeData theme, ListTileThemeData tileTheme) {
    if (isOpened && tileTheme.selectedColor != null) {
      // log("Hi");
      return tileTheme.selectedColor!;
    }

    if (!isOpened && tileTheme.iconColor != null) {
      // log("Hi2");
      return tileTheme.iconColor!;
    }
    // assert(theme.brightness != null);
    print(theme.brightness);
    switch (theme.brightness) {
      case Brightness.light:
        return isOpened ? theme.primaryColor : Colors.black54;
      case Brightness.dark:
        return isOpened
            ? null
            : theme
                .colorScheme.secondary; // null - use current icon theme color
    }
    // return null;
  }
}

class MNavigatorObserver extends NavigatorObserver {
  InstiAppBloc bloc;

  static Map<String, int> routeToNavPos = {
    "/notifications": -1,
    "/feed": 0,
    "/putentity/event": 0,
    "/news": 1,
    "/explore": 2,
    "/mess": 3,
    "/placeblog": 4,
    "/trainblog": 5,
    "/externalblog": 6,
    "/calendar": 7,
    "/map": 8,
    "/achievements": 9,
    "/achievements/add": 9,
    "/complaints": 10,
    "/newcomplaint": 10,
    "/quicklinks": 11,
    "/settings": 12,
    "/query": 13,
  };

  static Map<String, String> routeToName = {
    "/mess": "Mess",
    "/placeblog": "Placement Blog",
    "/trainblog": "Internship Blog",
    "/feed": "Feed",
    "/quicklinks": "Quick Links",
    "/news": "News",
    "/explore": "Explore",
    "/calendar": "Calendar",
    "/complaints": "Complaints",
    "/newcomplaint": "New Complaint",
    "/putentity/event": "New Event",
    "/map": "Map",
    "/settings": "Settings",
    "/notifications": "Notifications",
    "/achievements": "Achievements",
    "/achievements/add": "New Achievement",
    "/externalblog": "External Blog",
    "/query": "Query",
    "n/a": "",
  };

  String startsWith(String routeName) {
    if (routeName.startsWith("/event/")) {
      return "Event";
    } else if (routeName.startsWith("/body/")) {
      return "Body";
    } else if (routeName.startsWith("/user/")) {
      return "User";
    } else if (routeName.startsWith("/complaint/")) {
      return "Complaint";
    } else if (routeName.startsWith("/putentity/event/")) {
      return "New Event";
    }
    return "";
  }

  Queue<String> navStack = Queue<String>();
  MNavigatorObserver(this.bloc);

  ValueStream<String?> get secondTopRouteName =>
      _secondTopRouteNameSubject.stream;
  final _secondTopRouteNameSubject = BehaviorSubject<String?>();

  @override
  void didPush(Route route, Route? previousRoute) {
    navStack.addLast(route.settings.name ?? "n/a");
    try {
      var el = navStack.elementAt(navStack.length - 2);
      _secondTopRouteNameSubject.add(routeToName[el] ?? startsWith(el));
    } catch (e) {
      _secondTopRouteNameSubject.add("");
    }
    int? pageIndex = routeToNavPos[route.settings.name];

    NavDrawer.setPageIndex(bloc, pageIndex ?? -1);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    try {
      navStack.removeLast();
    } catch (e) {}
    try {
      var el = navStack.elementAt(navStack.length - 2);
      _secondTopRouteNameSubject.add(routeToName[el] ?? startsWith(el));
    } catch (e) {
      _secondTopRouteNameSubject.add("");
    }
    int? pageIndex = routeToNavPos[previousRoute?.settings.name];

    NavDrawer.setPageIndex(bloc, pageIndex ?? -1);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    try {
      navStack.removeLast();
    } catch (e) {}
    navStack.addLast(newRoute?.settings.name ?? "n/a");
    try {
      var el = navStack.elementAt(navStack.length - 2);
      _secondTopRouteNameSubject.add(routeToName[el] ?? startsWith(el));
    } catch (e) {
      _secondTopRouteNameSubject.add("");
    }

    int? pageIndex = routeToNavPos[newRoute?.settings.name];

    NavDrawer.setPageIndex(bloc, pageIndex ?? -1);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    _secondTopRouteNameSubject.add(null);
  }

  @override
  void didStopUserGesture() {
    try {
      var el = navStack.elementAt(navStack.length - 2);
      _secondTopRouteNameSubject.add(routeToName[el] ?? startsWith(el));
    } catch (e) {
      _secondTopRouteNameSubject.add("");
    }
  }
}
