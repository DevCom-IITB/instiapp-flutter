import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPage extends StatefulWidget {
  final Future<User> _userFuture;

  UserPage(this._userFuture);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  User user;
  Set<Event> sEvents = Set();
  List<Event> events = [];
  bool _bottomSheetActive = false;

  @override
  void initState() {
    super.initState();

    user = null;
    widget._userFuture.then((u) {
      setState(() {
        user = u;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);
    var footerButtons = <Widget>[];

    if (user != null) {
      sEvents.clear();
      sEvents.addAll(user.userGoingEvents);
      sEvents.addAll(user.userInterestedEvents);

      events = sEvents.toList();

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
        drawer: BottomDrawer(),
        bottomNavigationBar: BottomAppBar(
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
                        _scaffoldKey.currentState.openDrawer();
                        // setState(() {
                        //   //disable button
                        //   _bottomSheetActive = true;
                        // });
                        // _scaffoldKey.currentState
                        //     .showBottomSheet((context) {
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
        body: SafeArea(
          child: Container(
            foregroundDecoration: _bottomSheetActive
                ? BoxDecoration(
                    color: Color.fromRGBO(100, 100, 100, 12),
                  )
                : null,
            child: user == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 28.0, horizontal: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ListTile(
                                  leading: NullableCircleAvatar(
                                    user.userProfilePictureUrl,
                                    OMIcons.personOutline,
                                    radius: 48,
                                    heroTag: "${user.userID}",
                                  ),
                                  title: Text(
                                    user.userName,
                                    style: theme.textTheme.headline.copyWith(
                                        color: Colors.black,
                                        fontFamily: "Bitter"),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(user.userRollNumber,
                                          style: theme.textTheme.title),
                                      InkWell(
                                        onTap: _launchEmail,
                                        child: Tooltip(
                                          message: "E-mail this person",
                                          child: Text(user.userEmail,
                                              style: theme.textTheme.title
                                                  .copyWith(
                                                      color: Colors.lightBlue)),
                                        ),
                                      ),
                                    ]..addAll(user.userContactNumber != null
                                        ? [
                                            InkWell(
                                              onTap: _launchDialer,
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
                                // color: Colors.white,
                                elevation: 4.0,
                                child: TabBar(
                                  labelColor: theme.accentColor,
                                  unselectedLabelColor: Colors.black,
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
                                    return _buildRoleTile(
                                        user.userRoles[index], theme.textTheme);
                                  },
                                  childCount: user.userRoles?.length ?? 0,
                                ),
                                "Following": SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return _buildBodyTile(
                                        user.userFollowedBodies[index],
                                        theme.textTheme);
                                  },
                                  childCount:
                                      user.userFollowedBodies?.length ?? 0,
                                ),
                                "Events": SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return _buildEventTile(
                                        events[index], theme);
                                  },
                                  childCount: events.length,
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
        ),
        floatingActionButton: _bottomSheetActive || user == null
            ? null
            : FloatingActionButton(
                child: Icon(OMIcons.share),
                tooltip: "Share this person's profile",
                onPressed: () async {
                  await Share.share(
                      "Check this cool person: ${ShareURLMaker.getUserURL(user)}");
                },
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        persistentFooterButtons:
            footerButtons.isNotEmpty ? footerButtons : null,
      ),
    );
  }

  Widget _buildEventTile(Event event, ThemeData theme) {
    return ListTile(
      title: Text(
        event.eventName,
        style: theme.textTheme.title,
      ),
      enabled: true,
      leading: NullableCircleAvatar(
          event.eventImageURL ?? event.eventBodies[0].bodyImageURL,
          OMIcons.event),
      subtitle: Text(event.getSubTitle()),
      onTap: () {
        _openEventPage(event);
      },
    );
  }

  Widget _buildBodyTile(Body body, TextTheme theme) {
    return ListTile(
      title: Text(body.bodyName, style: theme.title),
      subtitle: Text(body.bodyShortDescription, style: theme.subtitle),
      leading: NullableCircleAvatar(body.bodyImageURL, OMIcons.peopleOutline),
      onTap: () {
        Navigator.of(context).pushNamed("/body/${body.bodyID}");
      },
    );
  }

  Widget _buildRoleTile(Role role, TextTheme theme) {
    return ListTile(
      title: Text(role.roleBodyDetails.bodyName, style: theme.title),
      subtitle: Text(role.roleName, style: theme.subtitle),
      leading: NullableCircleAvatar(
          role.roleBodyDetails.bodyImageURL, OMIcons.peopleOutline),
      onTap: () {
        Navigator.of(context).pushNamed("/body/${role.roleBodyDetails.bodyID}");
      },
    );
  }

  void _openEventPage(Event event) {
    Navigator.of(context).pushNamed("/event/${event.eventID}");
  }

  _launchEmail() async {
    var url = "mailto:${user.userEmail}?subject=Let's Have Coffee";
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  _launchDialer() async {
    var url = "tel:${user.userContactNumber}";
    if (await canLaunch(url)) {
      await launch(url);
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
