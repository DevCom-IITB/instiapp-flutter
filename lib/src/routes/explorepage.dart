import 'package:InstiApp/src/api/response/explore_response.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/explore_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  ScrollController? _hideButtonController;
  TextEditingController? _searchFieldController;
  double isFabVisible = 0;

  bool searchMode = false;
  IconData actionIcon = Icons.search_outlined;

  bool firstBuild = true;

  @override
  void initState() {
    super.initState();
    _searchFieldController = TextEditingController();
    _hideButtonController = ScrollController();
    _hideButtonController!.addListener(() {
      if (isFabVisible == 1 && _hideButtonController!.offset < 100) {
        setState(() {
          isFabVisible = 0;
        });
      } else if (isFabVisible == 0 && _hideButtonController!.offset > 100) {
        setState(() {
          isFabVisible = 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchFieldController?.dispose();
    _hideButtonController?.dispose();
    super.dispose();
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
      resizeToAvoidBottomInset: true,
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
                Icons.menu_outlined,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
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
          child: ListView(controller: _hideButtonController, children: <Widget>[
            RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () {
                return exploreBloc.refresh();
              },
              child: TitleWithBackButton(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.headline3,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: searchMode ? 0.0 : null,
                      height: searchMode ? 0.0 : null,
                      decoration: ShapeDecoration(
                          shape: CircleBorder(
                              side: BorderSide(color: theme.primaryColor))),
                      child: searchMode
                          ? SizedBox()
                          : IconButton(
                              tooltip: "Search ${widget.title}",
                              padding: EdgeInsets.all(16.0),
                              icon: Icon(
                                actionIcon,
                                color: theme.primaryColor,
                              ),
                              color: theme.cardColor,
                              onPressed: () {
                                setState(() {
                                  actionIcon = Icons.close_outlined;
                                  searchMode = !searchMode;
                                });
                              },
                            ),
                    )
                  ],
                ),
              ),
            ),
            !searchMode
                ? SizedBox(
                    height: 0,
                  )
                : PreferredSize(
                    preferredSize: Size.fromHeight(72),
                    child: AnimatedContainer(
                      color: theme.canvasColor,
                      padding: EdgeInsets.all(8.0),
                      duration: Duration(milliseconds: 500),
                      child: TextField(
                        controller: _searchFieldController,
                        cursorColor: theme.textTheme.bodyText2?.color,
                        style: theme.textTheme.bodyText2,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                          labelStyle: theme.textTheme.bodyText2,
                          hintStyle: theme.textTheme.bodyText2,
                          prefixIcon: Icon(
                            Icons.search_outlined,
                          ),
                          suffixIcon: IconButton(
                            tooltip: "Search events, bodies, users...",
                            icon: Icon(
                              actionIcon,
                            ),
                            onPressed: () {
                              setState(() {
                                actionIcon = Icons.search_outlined;
                                exploreBloc.query = "";
                                exploreBloc.refresh();
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<ExploreResponse>(
                stream: exploreBloc.explore,
                builder: (BuildContext context,
                    AsyncSnapshot<ExploreResponse> snapshot) {
                  return Column(
                    children: _buildContent(snapshot, theme, exploreBloc),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: isFabVisible == 0
          ? null
          : FloatingActionButton(
              tooltip: "Go to the Top",
              onPressed: () {
                _hideButtonController!.animateTo(0.0,
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(milliseconds: 600));
              },
              child: Icon(Icons.keyboard_arrow_up_outlined),
            ),
    );
  }

  List<Widget> _buildContent(AsyncSnapshot<ExploreResponse> snapshot,
      ThemeData theme, ExploreBloc exploreBloc) {
    if (snapshot.hasData) {
      var bodies = snapshot.data!.bodies;
      var events = snapshot.data!.events;
      var users = snapshot.data!.users;
      if (bodies?.isEmpty == true &&
          events?.isEmpty == true &&
          users?.isEmpty == true) {
        return [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child:
                Text.rich(TextSpan(style: theme.textTheme.headline6, children: [
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
                      b.bodyID ?? "",
                      b.bodyName ?? "",
                      b.bodyShortDescription ?? "",
                      b.bodyImageURL ?? "",
                      Icons.people_outline_outlined,
                      () => BodyPage.navigateWith(context, exploreBloc.bloc,
                          body: b),
                      theme))
                  .toList() ??
              []) +
          (events
                  ?.map((e) => _buildListTile(
                      e.eventID ?? "",
                      e.eventName ?? "",
                      e.getSubTitle(),
                      e.eventImageURL ?? e.eventBodies?[0].bodyImageURL ?? "",
                      Icons.event_outlined,
                      () =>
                          EventPage.navigateWith(context, exploreBloc.bloc, e),
                      theme))
                  .toList() ??
              []) +
          (users
                  ?.map((u) => _buildListTile(
                      u.userID ?? "",
                      u.userName ?? "",
                      u.userLDAPId ?? "",
                      u.userProfilePictureUrl ?? "",
                      Icons.person_outline_outlined,
                      () => UserPage.navigateWith(context, exploreBloc.bloc, u),
                      theme))
                  .toList() ??
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
        style: theme.textTheme.headline6,
      ),
      subtitle: Text(subtitle),
      onTap: onClick,
    );
  }
}
