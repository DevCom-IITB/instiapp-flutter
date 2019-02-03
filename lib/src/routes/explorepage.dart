import 'package:InstiApp/src/api/response/explore_response.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/explore_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class ExplorePage extends StatefulWidget {
  final String title = "Explore";

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  FocusNode _focusNode = FocusNode();
  ScrollController _hideButtonController;
  double isFabVisible = 0;

  bool searchMode = false;
  IconData actionIcon = OMIcons.search;

  bool firstBuild = true;

  @override
  void initState() {
    super.initState();
    _hideButtonController = ScrollController();
    _hideButtonController.addListener(() {
      if ((_hideButtonController.position.userScrollDirection ==
                  ScrollDirection.reverse &&
              isFabVisible == 1) ||
          _hideButtonController.offset < 100) {
        setState(() {
          isFabVisible = 0;
        });
      } else if (_hideButtonController.position.userScrollDirection ==
              ScrollDirection.forward &&
          isFabVisible == 0) {
        setState(() {
          isFabVisible = 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;
    var exploreBloc = bloc.exploreBloc;
    if (firstBuild) {
      exploreBloc.query = "";
      exploreBloc.refresh();
      firstBuild = false;
    }

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      key: _scaffoldKey,
      drawer: NavDrawer(),
      bottomNavigationBar: MyBottomAppBar(
        shape: RoundedNotchedRectangle(),
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
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _focusNode.unfocus();
          },
          child: NestedScrollView(
            controller: _hideButtonController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            widget.title,
                            style: theme.textTheme.display2,
                          ),
                        ),
                      ]..addAll(searchMode
                          ? []
                          : [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                decoration: ShapeDecoration(
                                    shape: CircleBorder(
                                        side: BorderSide(
                                            color: theme.primaryColor))),
                                child: IconButton(
                                  tooltip: !searchMode
                                      ? "Search ${widget.title}"
                                      : "Clear search results",
                                  padding: EdgeInsets.all(16.0),
                                  icon: Icon(
                                    actionIcon,
                                    color: theme.primaryColor,
                                  ),
                                  color: theme.cardColor,
                                  onPressed: () {
                                    setState(() {
                                      if (searchMode) {
                                        actionIcon = OMIcons.search;
                                        exploreBloc.query = "";
                                        exploreBloc.refresh();
                                      } else {
                                        actionIcon = OMIcons.close;
                                      }
                                      searchMode = !searchMode;
                                    });
                                  },
                                ),
                              )
                            ]),
                    ),
                  ),
                ),
              ]..addAll(!searchMode
                  ? []
                  : [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 16.0,
                        ),
                      ),
                      SliverPersistentHeader(
                        floating: true,
                        pinned: true,
                        delegate: SliverHeaderDelegate(
                          child: PreferredSize(
                            preferredSize: Size.fromHeight(72),
                            child: AnimatedContainer(
                              color: theme.canvasColor,
                              padding: EdgeInsets.all(8.0),
                              duration: Duration(milliseconds: 500),
                              child: TextField(
                                cursorColor: theme.textTheme.body1.color,
                                style: theme.textTheme.body1,
                                autofocus: true,
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  labelStyle: theme.textTheme.body1,
                                  hintStyle: theme.textTheme.body1,
                                  prefixIcon: Icon(
                                    OMIcons.search,
                                  ),
                                  suffixIcon: IconButton(
                                    tooltip: !searchMode
                                        ? "Search events, bodies, users..."
                                        : "Clear search results",
                                    icon: Icon(
                                      actionIcon,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (searchMode) {
                                          actionIcon = OMIcons.search;
                                          exploreBloc.query = "";
                                          exploreBloc.refresh();
                                        } else {
                                          actionIcon = OMIcons.close;
                                        }
                                        searchMode = !searchMode;
                                      });
                                    },
                                  ),
                                  hintText: "Search events, bodies, users...",
                                ),
                                onChanged: (query) async {
                                  if (query.length > 4) {
                                    exploreBloc.query = query;
                                    exploreBloc.refresh();
                                  }
                                },
                                onSubmitted: (query) async {
                                  exploreBloc.query = query;
                                  await exploreBloc.refresh();
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                    ]);
            },
            body: StreamBuilder<ExploreResponse>(
              stream: exploreBloc.explore,
              builder: (BuildContext context,
                  AsyncSnapshot<ExploreResponse> snapshot) {
                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: () {
                    return exploreBloc.refresh();
                  },
                  child: Builder(builder: (context) {
                    return CustomScrollView(
                      // The "controller" and "primary" members should be left
                      // unset, so that the NestedScrollView can control this
                      // inner scroll view.
                      // If the "controller" property is set, then this scroll
                      // view will not be associated with the NestedScrollView.
                      // The PageStorageKey should be unique to this ScrollView;
                      // it allows the list to remember its scroll position when
                      // the tab view is not on the screen.
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
                            sliver: SliverList(
                              delegate: SliverChildListDelegate(
                                _buildContent(snapshot, theme, exploreBloc),
                              ),
                            )),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: isFabVisible == 0
          ? null
          : FloatingActionButton(
              tooltip: "Go to the Top",
              onPressed: () {
                _hideButtonController
                    .animateTo(0.0,
                        curve: Curves.fastOutSlowIn,
                        duration: const Duration(milliseconds: 600))
                    .then((_) {
                  setState(() {
                    isFabVisible = 0.0;
                  });
                });
                setState(() {
                  isFabVisible = 0.0;
                });
              },
              child: Icon(OMIcons.keyboardArrowUp),
            ),
    );
  }

  List<Widget> _buildContent(AsyncSnapshot<ExploreResponse> snapshot,
      ThemeData theme, ExploreBloc exploreBloc) {
    if (snapshot.hasData) {
      var bodies = snapshot.data.bodies;
      var events = snapshot.data.events;
      var users = snapshot.data.users;
      if (bodies.isEmpty && events.isEmpty && users.isEmpty) {
        return [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: Text.rich(TextSpan(style: theme.textTheme.title, children: [
              TextSpan(text: "Nothing found for the query "),
              TextSpan(
                  text: "\"${exploreBloc.query}\"",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: "."),
            ])),
          )
        ];
      }
      return (bodies
                  ?.map((b) => _buildListTile(
                      b.bodyID,
                      b.bodyName,
                      b.bodyShortDescription,
                      b.bodyImageURL,
                      OMIcons.peopleOutline,
                      () => BodyPage.navigateWith(context, exploreBloc.bloc, body: b),
                      theme))
                  ?.toList() ??
              []) +
          (events
                  ?.map((e) => _buildListTile(
                      e.eventID,
                      e.eventName,
                      e.getSubTitle(),
                      e.eventImageURL ?? e.eventBodies[0]?.bodyImageURL,
                      OMIcons.event,
                      () =>
                          EventPage.navigateWith(context, exploreBloc.bloc, e),
                      theme))
                  ?.toList() ??
              []) +
          (users
                  ?.map((u) => _buildListTile(
                      u.userID,
                      u.userName,
                      u.userLDAPId,
                      u.userProfilePictureUrl,
                      OMIcons.personOutline,
                      () => UserPage.navigateWith(context, exploreBloc.bloc, u),
                      theme))
                  ?.toList() ??
              []);
    } else {
      return [
        Center(
            child: CircularProgressIndicatorExtended(
          label: Text("Loading the some default bodies"),
        ))
      ];
    }
  }

  Widget _buildListTile(String id, String title, String subtitle, String url,
      IconData fallbackIcon, VoidCallback onClick, ThemeData theme) {
    return ListTile(
      leading: NullableCircleAvatar(
        url,
        fallbackIcon,
        heroTag: id,
      ),
      title: Text(
        title,
        style: theme.textTheme.title,
      ),
      subtitle: Text(subtitle),
      onTap: onClick,
    );
  }
}
