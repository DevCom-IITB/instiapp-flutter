import 'package:InstiApp/src/api/response/explore_response.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/explore_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/testgroup.dart';

import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

class GroupsPage extends StatefulWidget {
  //final String title = "Groups";
  final bool searchMode;
  final bool fromNavigate;

  GroupsPage({this.searchMode = false, this.fromNavigate = false});

  @override
  _GroupsPageState createState() => _GroupsPageState();

  static void navigateWith(BuildContext context, bool searchMode) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/groups?searchMode=${searchMode ? "true" : "false"}",
        ),
        builder: (context) => GroupsPage(
          searchMode: searchMode,
          fromNavigate: true,
        ),
      ),
    );
  }
}

class _GroupsPageState extends State<GroupsPage> {
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
    var bloc = BlocProvider.of(context)!.bloc;
    var exploreBloc = bloc.exploreBloc;
    if (firstBuild) {
      exploreBloc.query = "";
      exploreBloc.refresh();
      searchMode = widget.searchMode;
      if (widget.fromNavigate) {
        bloc.drawerState.setPageIndex(2);
      }
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
                  // children: <Widget>[
                  //   Container(
                  //       decoration: ShapeDecoration(
                  //           // shape: CircleBorder(
                  //           //     side: BorderSide(
                  //           //         color: theme.primaryColor,
                  //           //         width: 8,
                  //           //         style: BorderStyle.solid))),
                  //       child: SizedBox())
                  // ],
                ),
              ),
            ),
            PreferredSize(
              preferredSize: Size.fromHeight(40),
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
                        borderSide:
                            BorderSide(color: Colors.blue.shade800, width: 5.0),
                        borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blue.shade800, width: 5.0),
                        borderRadius: BorderRadius.circular(10)),
                    labelStyle: theme.textTheme.bodyText2,
                    hintStyle: theme.textTheme.bodyText2,
                    prefixIcon: Icon(
                      Icons.search_outlined,
                    ),
                    suffixIcon: IconButton(
                      tooltip: "Search for groups",
                      icon: Icon(Icons.close_outlined),
                      onPressed: () {
                        setState(() {
                          actionIcon = Icons.search_outlined;
                          exploreBloc.query = "";
                          exploreBloc.refresh();
                          searchMode = !searchMode;
                        });
                      },
                    ),
                    hintText: "Search for groups",
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
                  autofocus: true,
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
                    children: _buildContent(snapshot, theme),
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
    ThemeData theme) {
    if (snapshot.hasData) {
      var bodies = snapshot.data!.bodies;
      List<Group> groups = [
        Group(ID: "1", name: "Insight Discussion Forum", followerCount: "200"),
        Group(ID: "2", name: "CSE group", followerCount: "70"),
      ];
      if (bodies?.isEmpty == true) {
        return [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child:
                Text.rich(TextSpan(style: theme.textTheme.headline6, children: [
              TextSpan(text: "Nothing found for the query "),
              TextSpan(
                  text: "here",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: "."),
            ])),
          )
        ];
      }
      //move to next page
      return (groups
              .map((g) => _buildListTile(
                  g.ID ?? "",
                  g.name ?? "",
                  g.followerCount ?? "",
                  "https://play-lh.googleusercontent.com/8ddL1kuoNUB5vUvgDVjYY3_6HwQcrg1K2fd_R8soD-e2QYj8fT9cfhfh3G0hnSruLKec",
                  Icons.people_outline_outlined,
                  () => {Group.navigateWith(context, g)},
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

//RELATED TO TILES
  Widget _buildListTile(String id, String title, String subtitle, String url,
      IconData fallbackIcon, VoidCallback onClick, ThemeData theme) {
    var borderRadius = const BorderRadius.all(Radius.circular(10));
    return Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          leading: NullableCircleAvatar(
            url,
            fallbackIcon,
            heroTag: id,
          ),
          title: Text(
            title,
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          textColor: Colors.white,
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Colors.white,
            size: 50,
          ),
          subtitle: Text(subtitle + " followers"),
          onTap: onClick,
          tileColor: Colors.blue[700],
        ));
  }
}
