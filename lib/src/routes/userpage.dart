import 'dart:async';
import 'dart:math';
import 'package:dropdown_search/dropdown_search.dart';
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
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPage extends StatefulWidget {
  final User? initialUser;
  final Future<User>? userFuture;

  UserPage({this.userFuture, this.initialUser});

  static void navigateWith(BuildContext context, InstiAppBloc bloc, User? user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/user/${user?.userID ?? ""}",
        ),
        builder: (context) => UserPage(
          initialUser: user,
          userFuture: bloc.getUser(user?.userID ?? ""),
        ),
      ),
    );
  }

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  User? user;
  Set<Event> sEvents = Set();
  List<Event>? events = [];
  Interest? _selectedInterest;
  late bool editable;
  List<Interest>? interests=[];

  void onBodyChange(Interest? body) async {
    var bloc = BlocProvider.of(context)?.bloc;
    var res = await bloc?.achievementBloc.postInterest(body?.id??"",body!);
    if(res != null) {
      setState(() {
        List<Interest>? k= interests;
        k?.add(body!);
        interests=k;
      });
    }
    else{
        ScaffoldMessenger.of(
            context)
            .showSnackBar(SnackBar(
          content:
          new Text('Error: Interest already exists'),
          duration: new Duration(
              seconds: 10),
        ));
    }
  }

  bool cansee = false;

  Widget _buildChips(BuildContext context){
    List<Widget> w=[];
    var bloc = BlocProvider.of(context)?.bloc;
    int length= interests?.length ?? 0;
    for(int i=0;i< length;i++){
      w.add(cansee?Chip(
        labelPadding: EdgeInsets.all(2.0),
        label: Text(
          interests?[i].title?? "",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
        elevation: 6.0,
        shadowColor: Colors.grey[60],
        padding: EdgeInsets.all(8.0),

        onDeleted: () async {
          await bloc?.achievementBloc.postDelInterest(interests![i].title!);
          interests?.removeAt(i);
          //_selected.removeAt(i);
          setState(() {
            interests = interests;
            //_selected = _selected;
          });
        },
      ):Chip(
        labelPadding: EdgeInsets.all(2.0),
        label: Text(
          interests?[i].title?? "",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
        elevation: 6.0,
        shadowColor: Colors.grey[60],
        padding: EdgeInsets.all(8.0),
      ));
      //w.add(_buildChip(interest.title, Colors.primaries[Random().nextInt(Colors.primaries.length)]));
    }
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0,
      children: w,
    );
  }

  Widget buildDropdownMenuItemsInterest(
      BuildContext context, Interest? body) {
    print("Entered build dropdown menu items");
    if (body == null) {
      return Container(
        child: Text(
          "Search for an organisation",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
    }
    print(body);
    return Container(
      child: ListTile(
        title: Text(body.title!),
      ),
    );
  }
  Widget _customPopupItemBuilderInterest(
      BuildContext context, Interest body, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: ListTile(
        selected: isSelected,
        title: Text(body.title!),
      ),
    );
  }




  @override
  void initState() {
    super.initState();

    user = widget.initialUser;

    //interests=[Interest(id:"123",title: "lll")];
    widget.userFuture?.then((u) {
      if (this.mounted) {
        setState(() {
          user = u;
          interests = user?.interests!;
        });
      } else {
        user = u;
      }
    });
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      var bloc = BlocProvider.of(context)?.bloc;
      bloc?.getUser("me").then((result){
        if(result.userLDAPId == widget.initialUser?.userLDAPId){
          setState(() {cansee = true;});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context)!.bloc;
    var theme = Theme.of(context);
    var footerButtons = <Widget>[];

    if (user != null) {
      sEvents.clear();
      sEvents.addAll(user!.userGoingEvents ?? []);
      sEvents.addAll(user!.userInterestedEvents ?? []);

      events = user!.userGoingEvents != null ? sEvents.toList() : null;

      if ((user!.userWebsiteURL ?? "") != "") {
        footerButtons.add(IconButton(
          tooltip: "Open website",
          icon: Icon(Icons.language_outlined),
          onPressed: () async {
            if (user!.userWebsiteURL != null) {
              if (await canLaunch(user!.userWebsiteURL!)) {
                await launch(user!.userWebsiteURL!);
              }
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
                  Icons.menu_outlined,
                  semanticLabel: "Show navigation drawer",
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
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
                                  user!.userProfilePictureUrl ?? "",
                                  Icons.person_outline_outlined,
                                  radius: 48,
                                  heroTag: user!.userID ?? "",
                                  photoViewable: true,
                                ),
                                title: Text(
                                  user!.userName ?? "",
                                  style: theme.textTheme.headline5?.copyWith(
                                      fontFamily: theme
                                          .textTheme.headline3?.fontFamily),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    user!.userRollNumber != null
                                        ? Text(user!.userRollNumber ?? "",
                                            style: theme.textTheme.headline6)
                                        : CircularProgressIndicatorExtended(
                                            size: 12,
                                            label: Text("Loading Roll Number"),
                                          ),
                                  ]
                                    ..addAll(user!.userEmail != null &&
                                            !user!.userEmail!
                                                .toLowerCase()
                                                .contains("n/a")
                                        ? [
                                            InkWell(
                                              onTap: user!.userEmail != null
                                                  ? () => _launchEmail(context)
                                                  : null,
                                              child: Tooltip(
                                                message: "E-mail this person",
                                                child: user!.userEmail != null
                                                    ? Text(user!.userEmail!,
                                                        style: theme
                                                            .textTheme.headline6
                                                            ?.copyWith(
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
                                    ..addAll(user!.userContactNumber != null &&
                                            !user!.userContactNumber!
                                                .toLowerCase()
                                                .contains("n/a")
                                        ? [
                                            InkWell(
                                              onTap: () =>
                                                  _launchDialer(context),
                                              child: Tooltip(
                                                message: "Call this person",
                                                child: Text(
                                                    user!.userContactNumber!,
                                                    style: theme
                                                        .textTheme.headline6
                                                        ?.copyWith(
                                                            color: Colors
                                                                .lightBlue)),
                                              ),
                                            )
                                          ]
                                        : []),
                                ),
                              ),

                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      // width: double.infinity,
                                        margin:
                                        EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
                                        child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              SizedBox(
                                                height: 20.0,
                                              ),
                                              cansee?
                                              DropdownSearch<Interest>(
                                                mode: Mode.DIALOG,
                                                maxHeight: 700,
                                                isFilteredOnline: true,
                                                showSearchBox: true,
                                                dropdownSearchDecoration: InputDecoration(
                                                  labelText: "Interests",
                                                  hintText: "Interests",
                                                ),
                                                validator: (value) {
                                                  if (value == null) {
                                                    return 'Please select a organization';
                                                  }
                                                  return null;
                                                },
                                                onChanged: onBodyChange,
                                                onFind:
                                                bloc.achievementBloc.searchForInterest,
                                                dropdownBuilder:
                                                buildDropdownMenuItemsInterest,
                                                popupItemBuilder:
                                                _customPopupItemBuilderInterest,
                                                // popupSafeArea:
                                                // PopupSafeArea(
                                                //     top: true,
                                                //     bottom: true),
                                                scrollbarProps:
                                                ScrollbarProps(
                                                  isAlwaysShown: true,
                                                  thickness: 7,
                                                ),
                                                selectedItem:
                                                _selectedInterest,
                                                emptyBuilder:
                                                    (BuildContext context,
                                                    String? _) {
                                                  return Container(
                                                    alignment:
                                                    Alignment.center,
                                                    padding:
                                                    EdgeInsets.all(
                                                        20),
                                                    child: Text(
                                                      "No verifying authorities found. Refine your search!",
                                                      style: theme
                                                          .textTheme
                                                          .subtitle1,
                                                      textAlign: TextAlign
                                                          .center,
                                                    ),
                                                  );
                                                },
                                              ):SizedBox(),
                                              _buildChips(context),
                                              //_buildChip('Gamer', Color(0xFFff6666))
                                              // SizedBox(
                                              // height: this.selectedB
                                              // ? 20.0
                                              //     : 0,
                                              // ),
                                              // BodyCard(
                                              // thing:
                                              // this._selectedBody,
                                              // selected:
                                              // this.selectedB),
                                              //_buildEvent(theme, bloc, snapshot.data[0]);//verify_card(thing: this._selectedCompany, selected: this.selected);
                                            ])),
                                  ]),
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
                                labelColor: theme.colorScheme.secondary,
                                unselectedLabelColor: theme.disabledColor,
                                tabs: [
                                  Tab(
                                      text: "Associations",
                                      icon: Icon(Icons.work_outline_outlined)),
                                  Tab(
                                      text: "Following",
                                      icon:
                                          Icon(Icons.people_outline_outlined)),
                                  Tab(
                                      text: "Events",
                                      icon: Icon(Icons.event_outlined)),
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
                                  return user!.userRoles != null
                                      ? (index >= (user!.userRoles?.length ?? 0)
                                          ? _buildFormerRoleTile(
                                              bloc,
                                              theme.textTheme,
                                              user!.userFormerRoles![index -
                                                  (user!.userRoles?.length ??
                                                      0)])
                                          : _buildRoleTile(
                                              bloc,
                                              theme.textTheme,
                                              user!.userRoles![index]))
                                      : Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child:
                                              CircularProgressIndicatorExtended(
                                            label: Text("Loading associations"),
                                          ));
                                },
                                childCount: (user!.userRoles?.length ?? 1) +
                                    (user!.userFormerRoles?.length ?? 0),
                              ),
                              "Following": SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return user!.userFollowedBodies != null
                                      ? _buildBodyTile(bloc, theme.textTheme,
                                          user!.userFollowedBodies![index])
                                      : Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child:
                                              CircularProgressIndicatorExtended(
                                            label: Text(
                                                "Loading following bodies"),
                                          ));
                                },
                                childCount:
                                    user!.userFollowedBodies?.length ?? 1,
                              ),
                              "Events": SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return events != null
                                      ? _buildEventTile(
                                          bloc, events![index], theme)
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
                                  sliver: delegates[name]?.childCount == 0
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
                                          delegate: delegates[name]!,
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
                child: Icon(Icons.share_outlined),
                tooltip: "Share this person's profile",
                onPressed: () async {
                  await Share.share(
                      "Check this cool person: ${ShareURLMaker.getUserURL(user!)}");
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
        event.eventName ?? "",
        style: theme.textTheme.headline6,
      ),
      enabled: true,
      leading: NullableCircleAvatar(
        event.eventImageURL ?? event.eventBodies?[0].bodyImageURL ?? "",
        Icons.event_outlined,
        heroTag: event.eventID ?? "",
      ),
      subtitle: Text(event.getSubTitle()),
      onTap: () {
        EventPage.navigateWith(context, bloc, event);
      },
    );
  }

  Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
    return ListTile(
      title: Text(body.bodyName ?? "", style: theme.headline6),
      subtitle: Text(body.bodyShortDescription ?? "", style: theme.subtitle2),
      leading: NullableCircleAvatar(
        body.bodyImageURL ?? "",
        Icons.people_outline_outlined,
        heroTag: body.bodyID ?? "",
      ),
      onTap: () {
        BodyPage.navigateWith(context, bloc, body: body);
      },
    );
  }

  Widget _buildRoleTile(InstiAppBloc bloc, TextTheme theme, Role role) {
    return ListTile(
      title: Text(role.roleBodyDetails?.bodyName ?? "", style: theme.headline6),
      subtitle: Text(role.roleName ?? "", style: theme.subtitle2),
      leading: NullableCircleAvatar(
        role.roleBodyDetails?.bodyImageURL ?? "",
        Icons.people_outline_outlined,
        heroTag: role.roleID ?? role.roleBodyDetails?.bodyID ?? "",
      ),
      onTap: () {
        BodyPage.navigateWith(context, bloc, role: role);
      },
    );
  }

  Widget _buildFormerRoleTile(InstiAppBloc bloc, TextTheme theme, Role role) {
    return ListTile(
      title: Text(role.roleBodyDetails?.bodyName ?? "", style: theme.headline6),
      subtitle: Text("Former ${role.roleName} ${role.year ?? ""}",
          style: theme.subtitle2),
      leading: NullableCircleAvatar(
        role.roleBodyDetails?.bodyImageURL ?? "",
        Icons.people_outline_outlined,
        heroTag: role.roleID ?? role.roleBodyDetails?.bodyID ?? "",
      ),
      onTap: () {
        BodyPage.navigateWith(context, bloc, role: role);
      },
    );
  }

  _launchEmail(BuildContext context) async {
    var url = "mailto:${user?.userEmail}?subject=Let's Have Coffee";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Mail app failed to open"),
          ),
        );
    }
  }

  _launchDialer(BuildContext context) async {
    var url = "tel:${user?.userContactNumber}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context)
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

  _SliverTabBarDelegate({required this.child});

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
