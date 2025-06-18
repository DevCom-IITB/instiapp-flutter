import 'package:InstiApp/src/api/response/explore_response.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/explore_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/routes/explore_club.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

class ExplorePage extends StatefulWidget {
  final String title = "Explore";
  final bool searchMode;
  final bool fromNavigate;
  final String? parent;

  ExplorePage(
      {this.searchMode = false, this.fromNavigate = false, this.parent});

  @override
  _ExplorePageState createState() => _ExplorePageState();

  static void navigateWith(BuildContext context, bool searchMode) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/explore?searchMode=${searchMode ? "true" : "false"}",
        ),
        builder: (context) => ExplorePage(
          searchMode: searchMode,
          fromNavigate: true,
        ),
      ),
    );
  }
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

    // debugPrint("ExplorePage loaded with parent: ${widget.parent}");
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
      // bottomNavigationBar: MyBottomAppBar(
      //   shape: RoundedNotchedRectangle(),
      //   child: new Row(
      //     mainAxisSize: MainAxisSize.max,
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: <Widget>[
      //       IconButton(
      //         tooltip: "Show bottom sheet",
      //         icon: Icon(
      //           Icons.menu_outlined,
      //           semanticLabel: "Show bottom sheet",
      //         ),
      //         onPressed: () {
      //           _scaffoldKey.currentState?.openDrawer();
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _focusNode.unfocus();
          },
          child: ListView(
            controller: _hideButtonController,
            children: <Widget>[
              RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () {
                  return exploreBloc.refresh();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleWithBackButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              widget.title,
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _searchFieldController,
                          focusNode: _focusNode,
                          cursorColor: theme.textTheme.bodyMedium?.color,
                          style: theme.textTheme.bodyMedium,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.search_outlined),
                            hintText: "Search events, bodies, users...",
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              tooltip: "Clear search",
                              icon: const Icon(Icons.close_outlined),
                              onPressed: () {
                                setState(() {
                                  _searchFieldController?.clear();
                                  exploreBloc.query = "";
                                  exploreBloc.refresh();
                                });
                              },
                            ),
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
                            children:
                                _buildContent(snapshot, theme, exploreBloc),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      // debugPrint(snapshot.data?.bodies.toString());
      // bodies?.forEach((b) {
      //   debugPrint("Body: ${b.bodyName}");
      //   debugPrint(
      //       "Body Parents: ${b.bodyParents?.map((p) => p.bodyName).toList()}");
      // });
      // debugPrint(snapshot.data.);
      var events = snapshot.data!.events;
      var users = snapshot.data!.users;
      if (bodies?.isEmpty == true &&
          events?.isEmpty == true &&
          users?.isEmpty == true) {
        return [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: Text.rich(
                TextSpan(style: theme.textTheme.titleLarge, children: [
              TextSpan(text: "Nothing found for the query "),
              TextSpan(
                  text: "\"${exploreBloc.query}\"",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: "."),
            ])),
          )
        ];
      }
      // if (bodies != null && bodies.length > 24) {
      //   var tenthBody = bodies[24];
      //   debugPrint("10th body name: ${tenthBody.bodyName}");
      //   debugPrint("10th body parents: ${tenthBody.bodyParents}");
      //   if (tenthBody.bodyParents != null &&
      //       tenthBody.bodyParents!.isNotEmpty) {
      //     for (var parent in tenthBody.bodyParents!) {
      //       debugPrint("Parent name: ${parent.bodyName}");
      //     }
      //   } else {
      //     debugPrint("No parents found for this body.");
      //   }
      // } else {
      //   debugPrint("Less than 10 bodies available.");
      // }
      //move to next page
      // body?.bodyParents
      //                     ?.map((b) {
      //                     debugPrint(b.toString());
      //                     return _buildBodyTile(bloc, theme.textTheme, b);
      //                     })
      //                     .toList(),
      // b.bodyParents?.map((p) {
      //   debugPrint(p.toString());
      // });
      // debugPrint("Body: ${b.bodyRoles}");
      // debugPrint("bodyParents type: ${b.bodyParents.runtimeType}");
      // debugPrint("bodyParents value: ${b.bodyParents}");
      // debugPrint("bodyParents == null: ${b.bodyParents == null}");
      // debugPrint("bodyParents?.isEmpty: ${b.bodyParents?.isEmpty}");
      // debugPrint("---");

      // b.bodyParents?.forEach((p) {
      //   debugPrint("Parent: ${p.toString()}");
      // });
      //
      return bodies == null || bodies.isEmpty
          ? []
          : [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics:
                      NeverScrollableScrollPhysics(), // so parent scroll works
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: bodies
                      .where((b) =>
                          b.bodyName == "Culturals@IITB" ||
                          b.bodyName == "Tech@IITB" ||
                          b.bodyName == "IITB Sports" ||
                          b.bodyName == "Departments" ||
                          b.bodyName == "Hostel Affairs" ||
                          b.bodyName == "IIT Bombay" ||
                          b.bodyName == "DevCom" ||
                          b.bodyName == "Placement Cell")
                      .map((b) {
                    return _buildBodyCard(
                      b.bodyID ?? "",
                      b.bodyName ?? "",
                      b.bodyShortDescription ?? "",
                      b.bodyImageURL ?? "",
                      Icons.people_outline_outlined,
                      () => ExploreClubPage.navigateWith(
                          context, exploreBloc.bloc,
                          body: b),
                      theme,
                    );
                  }).toList(),
                ),
              ),
            ];
      //     +
      // (events
      //         ?.map((e) => _buildListTile(
      //             e.eventID ?? "",
      //             e.eventName ?? "",
      //             e.getSubTitle(),
      //             e.eventImageURL ?? e.eventBodies?[0].bodyImageURL ?? "",
      //             Icons.event_outlined,
      //             () =>
      //                 EventPage.navigateWith(context, exploreBloc.bloc, e),
      //             theme))
      //         .toList() ??
      //     []) +
      // (users
      //         ?.map((u) => _buildListTile(
      //             u.userID ?? "",
      //             u.userName ?? "",
      //             u.userLDAPId ?? "",
      //             u.userProfilePictureUrl ?? "",
      //             Icons.person_outline_outlined,
      //             () => UserPage.navigateWith(context, exploreBloc.bloc, u),
      //             theme))
      //         .toList() ??
      //     []);
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
  // Widget _buildListTile(String id, String title, String subtitle, String url,
  //     IconData fallbackIcon, VoidCallback onClick, ThemeData theme) {
  //   return ListTile(
  //     leading: NullableCircleAvatar(
  //       url,
  //       fallbackIcon,
  //       heroTag: id,
  //     ),
  //     title: Text(
  //       title,
  //       style: theme.textTheme.titleLarge,
  //     ),
  //     subtitle: Text(subtitle),
  //     onTap: onClick,
  //   );
  // }
  Widget _buildBodyCard(String id, String title, String subtitle, String url,
      IconData fallbackIcon, VoidCallback onClick, ThemeData theme) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NullableCircleAvatar(
              url,
              fallbackIcon,
              heroTag: id,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
