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

  final List<Map<String, String>> bodyTitles = [
    {
      "bodyname": "Culturals@IITB",
      "title": "Culturals",
      "image": "assets/explore/cult.png"
    },
    {
      "bodyname": "Tech@IITB",
      "title": "Tech",
      "image": "assets/explore/tech.png"
    },
    {
      "bodyname": "IITB Sports",
      "title": "Sports",
      "image": "assets/explore/sports.png"
    },
    {
      "bodyname": "Departments",
      "title": "Departments",
      "image": "assets/explore/departments.png"
    },
    {
      "bodyname": "Hostel Affairs",
      "title": "Hostel Affairs",
      "image": "assets/explore/hostels.png"
    },
    {
      "bodyname": "IIT Bombay",
      "title": "Institute",
      "image": "assets/explore/ibs.png"
    },
    {
      "bodyname": "DevCom",
      "title": "DevCom",
      "image": "assets/explore/tech.png"
    },
    {
      "bodyname": "Placement Cell",
      "title": "Placement",
      "image": "assets/explore/tech.png"
    },
  ];
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
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () => exploreBloc.refresh(),
            child: ListView(
              controller: _hideButtonController,
              children: [
                // Header section with image, title and search
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Image.asset(
                        'assets/explore/explore.png',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
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
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Main content area
                Padding(
                  padding: const EdgeInsets.all(2.0),
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
              ],
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
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 182 / 128,
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

  Widget _buildBodyCard(
    String id,
    String title,
    String subtitle,
    String assetPath,
    IconData fallbackIcon,
    VoidCallback onClick,
    ThemeData theme,
  ) {
    // Get the image path and display title from bodyTitles based on the title (bodyname)
    final bodyData = widget.bodyTitles.firstWhere(
      (element) => element["bodyname"] == title,
      orElse: () => {"title": title, "image": ""},
    );

    final imagePath = bodyData["image"] ?? "";
    final displayTitle = bodyData["title"] ?? title;

    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: 182,
        height: 128,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background image
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              // Semi-transparent overlay for readability
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                ),
              ),
              // Title text at bottom-left
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  displayTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
