import 'dart:async';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPage extends StatefulWidget {
  final User initialUser;
  final Future<User> userFuture;

  UserPage({this.userFuture, this.initialUser});

  static void navigateWith(BuildContext context, InstiAppBloc bloc, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/user/${user?.userID ?? ""}",
        ),
        builder: (context) => UserPage(
              initialUser: user,
              userFuture: bloc.getUser(user.userID),
            ),
      ),
    );
  }

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  User user;
  Set<Event> sEvents = Set();
  List<Event> events = [];

  @override
  void initState() {
    super.initState();

    user = widget.initialUser;
    widget.userFuture.then((u) {
      if (this.mounted) {
        setState(() {
          user = u;
        });
      } else {
        user = u;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);
    var footerButtons = <Widget>[];

    if (user != null) {
      sEvents.clear();
      sEvents.addAll(user.userGoingEvents ?? []);
      sEvents.addAll(user.userInterestedEvents ?? []);

      events = user.userGoingEvents != null ? sEvents.toList() : null;

      if ((user.userWebsiteURL ?? "") != "") {
        footerButtons.add(IconButton(
          tooltip: "Open website",
          icon: Icon(OMIcons.language),
          onPressed: () async {
            if (await canLaunch(user.userWebsiteURL)) {
              await launch(user.userWebsiteURL);
            }
          },
        ));
      }
    }
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: NavDrawer(),
        bottomNavigationBar: MyBottomAppBar(
          shape: RoundedNotchedRectangle(),
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  OMIcons.menu,
                  semanticLabel: "Show navigation drawer",
                ),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: user == null
              ? Center(
                  child: CircularProgressIndicatorExtended(
                  label: Text("Loading the user page"),
                ))
              : NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverToBoxAdapter(
                        child: TitleWithBackButton(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 28.0, horizontal: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                leading: NullableCircleAvatar(
                                  user.userProfilePictureUrl,
                                  OMIcons.personOutline,
                                  radius: 48,
                                  heroTag: user.userID,
                                  photoViewable: true,
                                ),
                                title: Text(
                                  user.userName,
                                  style: theme.textTheme.headline.copyWith(
                                      fontFamily:
                                          theme.textTheme.display2.fontFamily),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    user.userRollNumber != null
                                        ? Text(user.userRollNumber,
                                            style: theme.textTheme.title)
                                        : CircularProgressIndicatorExtended(
                                            size: 12,
                                            label: Text("Loading Roll Number"),
                                          ),
                                  ]
                                    ..addAll(user.userEmail != null &&
                                            !user.userEmail
                                                .toLowerCase()
                                                .contains("n/a")
                                        ? [
                                            InkWell(
                                              onTap: user.userEmail != null
                                                  ? () => _launchEmail(context)
                                                  : null,
                                              child: Tooltip(
                                                message: "E-mail this person",
                                                child: user.userEmail != null
                                                    ? Text(user.userEmail,
                                                        style: theme
                                                            .textTheme.title
                                                            .copyWith(
                                                                color: Colors
                                                                    .lightBlue))
                                                    : CircularProgressIndicatorExtended(
                                                        size: 12,
                                                        label: Text(
                                                            "Loading email"),
                                                      ),
                                              ),
                                            ),
                                          ]
                                        : [])
                                    ..addAll(user.userContactNumber != null &&
                                            !user.userContactNumber
                                                .toLowerCase()
                                                .contains("n/a")
                                        ? [
                                            InkWell(
                                              onTap: () =>
                                                  _launchDialer(context),
                                              child: Tooltip(
                                                message: "Call this person",
                                                child: Text(
                                                    user.userContactNumber,
                                                    style: theme.textTheme.title
                                                        .copyWith(
                                                            color: Colors
                                                                .lightBlue)),
                                              ),
                                            )
                                          ]
                                        : []),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        floating: true,
                        pinned: true,
                        delegate: _SliverTabBarDelegate(
                          child: PreferredSize(
                            preferredSize: Size.fromHeight(72),
                            child: Material(
                              elevation: 4.0,
                              child: TabBar(
                                labelColor: theme.accentColor,
                                unselectedLabelColor: theme.disabledColor,
                                tabs: [
                                  Tab(
                                      text: "Associations",
                                      icon: Icon(OMIcons.workOutline)),
                                  Tab(
                                      text: "Following",
                                      icon: Icon(OMIcons.peopleOutline)),
                                  Tab(
                                      text: "Events",
                                      icon: Icon(OMIcons.event)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    // These are the contents of the tab views, below the tabs.
                    children:
                        ["Associations", "Following", "Events"].map((name) {
                      return SafeArea(
                        top: false,
                        bottom: false,
                        child: Builder(
                          // This Builder is needed to provide a BuildContext that is "inside"
                          // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
                          // find the NestedScrollView.
                          builder: (BuildContext context) {
                            var delegates = {
                              "Associations": SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return user.userRoles != null
                                      ? (index >= (user.userRoles?.length ?? 0)
                                          ? _buildFormerRoleTile(
                                              bloc,
                                              theme.textTheme,
                                              user.userFormerRoles[index -
                                                  (user.userRoles?.length ??
                                                      0)])
                                          : _buildRoleTile(
                                              bloc,
                                              theme.textTheme,
                                              user.userRoles[index]))
                                      : Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child:
                                              CircularProgressIndicatorExtended(
                                            label: Text("Loading associations"),
                                          ));
                                },
                                childCount: (user.userRoles?.length ?? 1) +
                                    (user.userFormerRoles?.length ?? 0),
                              ),
                              "Following": SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return user.userFollowedBodies != null
                                      ? _buildBodyTile(bloc, theme.textTheme,
                                          user.userFollowedBodies[index])
                                      : Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child:
                                              CircularProgressIndicatorExtended(
                                            label: Text(
                                                "Loading following bodies"),
                                          ));
                                },
                                childCount:
                                    user.userFollowedBodies?.length ?? 1,
                              ),
                              "Events": SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return events != null
                                      ? _buildEventTile(
                                          bloc, events[index], theme)
                                      : Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child:
                                              CircularProgressIndicatorExtended(
                                            label: Text(
                                                "Loading following events"),
                                          ));
                                },
                                childCount: events?.length ?? 1,
                              ),
                            };
                            return CustomScrollView(
                              // The "controller" and "primary" members should be left
                              // unset, so that the NestedScrollView can control this
                              // inner scroll view.
                              // If the "controller" property is set, then this scroll
                              // view will not be associated with the NestedScrollView.
                              // The PageStorageKey should be unique to this ScrollView;
                              // it allows the list to remember its scroll position when
                              // the tab view is not on the screen.
                              key: PageStorageKey<String>(name),
                              slivers: <Widget>[
                                // SliverOverlapInjector(
                                //   // This is the flip side of the SliverOverlapAbsorber above.
                                //   handle: NestedScrollView
                                //       .sliverOverlapAbsorberHandleFor(context),
                                // ),
                                SliverPadding(
                                  padding: const EdgeInsets.all(8.0),
                                  // In this example, the inner scroll view has
                                  // fixed-height list items, hence the use of
                                  // SliverFixedExtentList. However, one could use any
                                  // sliver widget here, e.g. SliverList or SliverGrid.
                                  sliver: delegates[name].childCount == 0
                                      ? SliverToBoxAdapter(
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "No $name",
                                              ),
                                            ),
                                          ),
                                        )
                                      : SliverList(
                                          delegate: delegates[name],
                                        ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
        floatingActionButton: user == null
            ? null
            : FloatingActionButton(
                child: Icon(OMIcons.share),
                tooltip: "Share this person's profile",
                onPressed: () async {
                  await Share.share(
                      "Check this cool person: ${ShareURLMaker.getUserURL(user)}");
                },
              ),
        floatingActionButtonLocation: footerButtons.isEmpty
            ? FloatingActionButtonLocation.endDocked
            : FloatingActionButtonLocation.endFloat,
        persistentFooterButtons:
            footerButtons.isNotEmpty ? footerButtons : null,
      ),
    );
  }

  Widget _buildEventTile(InstiAppBloc bloc, Event event, ThemeData theme) {
    return ListTile(
      title: Text(
        event.eventName,
        style: theme.textTheme.title,
      ),
      enabled: true,
      leading: NullableCircleAvatar(
        event.eventImageURL ?? event.eventBodies[0].bodyImageURL,
        OMIcons.event,
        heroTag: event.eventID,
      ),
      subtitle: Text(event.getSubTitle()),
      onTap: () {
        EventPage.navigateWith(context, bloc, event);
      },
    );
  }

  Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
    return ListTile(
      title: Text(body.bodyName, style: theme.title),
      subtitle: Text(body.bodyShortDescription, style: theme.subtitle),
      leading: NullableCircleAvatar(
        body.bodyImageURL,
        OMIcons.peopleOutline,
        heroTag: body.bodyID,
      ),
      onTap: () {
        BodyPage.navigateWith(context, bloc, body: body);
      },
    );
  }

  Widget _buildRoleTile(InstiAppBloc bloc, TextTheme theme, Role role) {
    return ListTile(
      title: Text(role.roleBodyDetails.bodyName, style: theme.title),
      subtitle: Text(role.roleName, style: theme.subtitle),
      leading: NullableCircleAvatar(
        role.roleBodyDetails.bodyImageURL,
        OMIcons.peopleOutline,
        heroTag: role.roleID ?? role.roleBodyDetails.bodyID,
      ),
      onTap: () {
        BodyPage.navigateWith(context, bloc, role: role);
      },
    );
  }

  Widget _buildFormerRoleTile(InstiAppBloc bloc, TextTheme theme, Role role) {
    return ListTile(
      title: Text(role.roleBodyDetails.bodyName, style: theme.title),
      subtitle: Text("Former ${role.roleName} ${role.year ?? ""}",
          style: theme.subtitle),
      leading: NullableCircleAvatar(
        role.roleBodyDetails.bodyImageURL,
        OMIcons.peopleOutline,
        heroTag: role.roleID ?? role.roleBodyDetails.bodyID,
      ),
      onTap: () {
        BodyPage.navigateWith(context, bloc, role: role);
      },
    );
  }

  _launchEmail(BuildContext context) async {
    var url = "mailto:${user.userEmail}?subject=Let's Have Coffee";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Mail app failed to open"),
          ),
        );
    }
  }

  _launchDialer(BuildContext context) async {
    var url = "tel:${user.userContactNumber}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Phone app failed to open"),
          ),
        );
    }
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSize child;

  _SliverTabBarDelegate({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => child.preferredSize.height;

  @override
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
