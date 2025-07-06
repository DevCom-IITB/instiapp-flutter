import 'package:InstiApp/src/api/response/explore_response.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/explore_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/routes/explore_club.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/rendering.dart';

// class ExplorePage extends StatefulWidget {
//   final String title = "Explore";
//   final bool searchMode;
//   final bool fromNavigate;
//   final String? parent;

//   final List<Map<String, String>> bodyTitles = [
//     {
//       "bodyname": "Culturals@IITB",
//       "title": "Culturals",
//       "image": "assets/explore/cult.png"
//     },
//     {
//       "bodyname": "Tech@IITB",
//       "title": "Tech",
//       "image": "assets/explore/tech.png"
//     },
//     {
//       "bodyname": "IITB Sports",
//       "title": "Sports",
//       "image": "assets/explore/sports.png"
//     },
//     {
//       "bodyname": "Departments",
//       "title": "Departments",
//       "image": "assets/explore/departments.png"
//     },
//     {
//       "bodyname": "Hostel Affairs",
//       "title": "Hostel Affairs",
//       "image": "assets/explore/hostels.png"
//     },
//     {
//       "bodyname": "IIT Bombay",
//       "title": "Institute",
//       "image": "assets/explore/ibs.png"
//     },
//     {
//       "bodyname": "DevCom",
//       "title": "DevCom",
//       "image": "assets/explore/tech.png"
//     },
//     {
//       "bodyname": "Placement Cell",
//       "title": "Placement",
//       "image": "assets/explore/tech.png"
//     },
//   ];
//   ExplorePage(
//       {this.searchMode = false, this.fromNavigate = false, this.parent});

//   @override
//   _ExplorePageState createState() => _ExplorePageState();

//   static void navigateWith(BuildContext context, bool searchMode) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         settings: RouteSettings(
//           name: "/explore?searchMode=${searchMode ? "true" : "false"}",
//         ),
//         builder: (context) => ExplorePage(
//           searchMode: searchMode,
//           fromNavigate: true,
//         ),
//       ),
//     );
//   }
// }

// class _ExplorePageState extends State<ExplorePage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       GlobalKey<RefreshIndicatorState>();

//   FocusNode _focusNode = FocusNode();
//   ScrollController? _hideButtonController;
//   TextEditingController? _searchFieldController;
//   double isFabVisible = 0;

//   bool searchMode = false;
//   IconData actionIcon = Icons.search_outlined;

//   bool firstBuild = true;

//   @override
//   void initState() {
//     super.initState();

//     // debugPrint("ExplorePage loaded with parent: ${widget.parent}");
//     _searchFieldController = TextEditingController();
//     _hideButtonController = ScrollController();
//     _hideButtonController!.addListener(() {
//       if (isFabVisible == 1 && _hideButtonController!.offset < 100) {
//         setState(() {
//           isFabVisible = 0;
//         });
//       } else if (isFabVisible == 0 && _hideButtonController!.offset > 100) {
//         setState(() {
//           isFabVisible = 1;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchFieldController?.dispose();
//     _hideButtonController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     var bloc = BlocProvider.of(context)!.bloc;
//     var exploreBloc = bloc.exploreBloc;
//     if (firstBuild) {
//       exploreBloc.query = "";
//       exploreBloc.refresh();
//       searchMode = widget.searchMode;
//       if (widget.fromNavigate) {
//         bloc.drawerState.setPageIndex(2);
//       }
//       firstBuild = false;
//     }

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       key: _scaffoldKey,
//       drawer: NavDrawer(),
//       // bottomNavigationBar: MyBottomAppBar(
//       //   shape: RoundedNotchedRectangle(),
//       //   child: new Row(
//       //     mainAxisSize: MainAxisSize.max,
//       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       //     children: <Widget>[
//       //       IconButton(
//       //         tooltip: "Show bottom sheet",
//       //         icon: Icon(
//       //           Icons.menu_outlined,
//       //           semanticLabel: "Show bottom sheet",
//       //         ),
//       //         onPressed: () {
//       //           _scaffoldKey.currentState?.openDrawer();
//       //         },
//       //       ),
//       //     ],
//       //   ),
//       // ),
//       body: SafeArea(
//         child: GestureDetector(
//           onTap: () {
//             _focusNode.unfocus();
//           },
//           child: RefreshIndicator(
//             key: _refreshIndicatorKey,
//             onRefresh: () => exploreBloc.refresh(),
//             child: ListView(
//               controller: _hideButtonController,
//               children: [
//                 // Header section with image, title and search
//                 Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: const BorderRadius.only(
//                         bottomLeft: Radius.circular(20),
//                         bottomRight: Radius.circular(20),
//                       ),
//                       child: Image.asset(
//                         'assets/explore/explore.png',
//                         height: 180,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     Positioned(
//                       top: 16,
//                       left: 16,
//                       right: 16,
//                       child: Column(
//                         children: [
//                           Text(
//                             widget.title,
//                             style: theme.textTheme.displaySmall?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               letterSpacing: 1.2,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 16),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.9),
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: TextField(
//                               controller: _searchFieldController,
//                               focusNode: _focusNode,
//                               cursorColor: theme.textTheme.bodyMedium?.color,
//                               style: theme.textTheme.bodyMedium,
//                               decoration: InputDecoration(
//                                 icon: const Icon(Icons.search_outlined),
//                                 hintText: "Search events, bodies, users...",
//                                 border: InputBorder.none,
//                                 suffixIcon: IconButton(
//                                   tooltip: "Clear search",
//                                   icon: const Icon(Icons.close_outlined),
//                                   onPressed: () {
//                                     setState(() {
//                                       _searchFieldController?.clear();
//                                       exploreBloc.query = "";
//                                       exploreBloc.refresh();
//                                     });
//                                   },
//                                 ),
//                               ),
//                               onChanged: (query) async {
//                                 if (query.length > 4) {
//                                   exploreBloc.query = query;
//                                   exploreBloc.refresh();
//                                 }
//                               },
//                               onSubmitted: (query) async {
//                                 exploreBloc.query = query;
//                                 await exploreBloc.refresh();
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 16),

//                 // Main content area
//                 Padding(
//                   padding: const EdgeInsets.all(2.0),
//                   child: StreamBuilder<ExploreResponse>(
//                     stream: exploreBloc.explore,
//                     builder: (BuildContext context,
//                         AsyncSnapshot<ExploreResponse> snapshot) {
//                       return Column(
//                         children: _buildContent(snapshot, theme, exploreBloc),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),

//       floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
//       floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
//       floatingActionButton: isFabVisible == 0
//           ? null
//           : FloatingActionButton(
//               tooltip: "Go to the Top",
//               onPressed: () {
//                 _hideButtonController!.animateTo(0.0,
//                     curve: Curves.fastOutSlowIn,
//                     duration: const Duration(milliseconds: 600));
//               },
//               child: Icon(Icons.keyboard_arrow_up_outlined),
//             ),
//     );
//   }

//   List<Widget> _buildContent(AsyncSnapshot<ExploreResponse> snapshot,
//       ThemeData theme, ExploreBloc exploreBloc) {
//     if (snapshot.hasData) {
//       var bodies = snapshot.data!.bodies;
//       // debugPrint(snapshot.data?.bodies.toString());
//       // bodies?.forEach((b) {
//       //   debugPrint("Body: ${b.bodyName}");
//       //   debugPrint(
//       //       "Body Parents: ${b.bodyParents?.map((p) => p.bodyName).toList()}");
//       // });
//       // debugPrint(snapshot.data.);
//       var events = snapshot.data!.events;
//       var users = snapshot.data!.users;
//       if (bodies?.isEmpty == true &&
//           events?.isEmpty == true &&
//           users?.isEmpty == true) {
//         return [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
//             child: Text.rich(
//                 TextSpan(style: theme.textTheme.titleLarge, children: [
//               TextSpan(text: "Nothing found for the query "),
//               TextSpan(
//                   text: "\"${exploreBloc.query}\"",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               TextSpan(text: "."),
//             ])),
//           )
//         ];
//       }
//       // if (bodies != null && bodies.length > 24) {
//       //   var tenthBody = bodies[24];
//       //   debugPrint("10th body name: ${tenthBody.bodyName}");
//       //   debugPrint("10th body parents: ${tenthBody.bodyParents}");
//       //   if (tenthBody.bodyParents != null &&
//       //       tenthBody.bodyParents!.isNotEmpty) {
//       //     for (var parent in tenthBody.bodyParents!) {
//       //       debugPrint("Parent name: ${parent.bodyName}");
//       //     }
//       //   } else {
//       //     debugPrint("No parents found for this body.");
//       //   }
//       // } else {
//       //   debugPrint("Less than 10 bodies available.");
//       // }
//       //move to next page
//       // body?.bodyParents
//       //                     ?.map((b) {
//       //                     debugPrint(b.toString());
//       //                     return _buildBodyTile(bloc, theme.textTheme, b);
//       //                     })
//       //                     .toList(),
//       // b.bodyParents?.map((p) {
//       //   debugPrint(p.toString());
//       // });
//       // debugPrint("Body: ${b.bodyRoles}");
//       // debugPrint("bodyParents type: ${b.bodyParents.runtimeType}");
//       // debugPrint("bodyParents value: ${b.bodyParents}");
//       // debugPrint("bodyParents == null: ${b.bodyParents == null}");
//       // debugPrint("bodyParents?.isEmpty: ${b.bodyParents?.isEmpty}");
//       // debugPrint("---");

//       // b.bodyParents?.forEach((p) {
//       //   debugPrint("Parent: ${p.toString()}");
//       // });
//       //
//       return bodies == null || bodies.isEmpty
//           ? []
//           : [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: GridView.count(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 182 / 128,
//                   children: bodies
//                       .where((b) =>
//                           b.bodyName == "Culturals@IITB" ||
//                           b.bodyName == "Tech@IITB" ||
//                           b.bodyName == "IITB Sports" ||
//                           b.bodyName == "Departments" ||
//                           b.bodyName == "Hostel Affairs" ||
//                           b.bodyName == "IIT Bombay" ||
//                           b.bodyName == "DevCom" ||
//                           b.bodyName == "Placement Cell")
//                       .map((b) {
//                     return _buildBodyCard(
//                       b.bodyID ?? "",
//                       b.bodyName ?? "",
//                       b.bodyShortDescription ?? "",
//                       b.bodyImageURL ?? "",
//                       Icons.people_outline_outlined,
//                       () => ExploreClubPage.navigateWith(
//                           context, exploreBloc.bloc,
//                           body: b),
//                       theme,
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ];

//       //     +
//       // (events
//       //         ?.map((e) => _buildListTile(
//       //             e.eventID ?? "",
//       //             e.eventName ?? "",
//       //             e.getSubTitle(),
//       //             e.eventImageURL ?? e.eventBodies?[0].bodyImageURL ?? "",
//       //             Icons.event_outlined,
//       //             () =>
//       //                 EventPage.navigateWith(context, exploreBloc.bloc, e),
//       //             theme))
//       //         .toList() ??
//       //     []) +
//       // (users
//       //         ?.map((u) => _buildListTile(
//       //             u.userID ?? "",
//       //             u.userName ?? "",
//       //             u.userLDAPId ?? "",
//       //             u.userProfilePictureUrl ?? "",
//       //             Icons.person_outline_outlined,
//       //             () => UserPage.navigateWith(context, exploreBloc.bloc, u),
//       //             theme))
//       //         .toList() ??
//       //     []);
//     } else {
//       return [
//         Center(
//             child: CircularProgressIndicatorExtended(
//           label: Text("Loading the some default bodies"),
//         ))
//       ];
//     }
//   }

// //RELATED TO TILES
//   // Widget _buildListTile(String id, String title, String subtitle, String url,
//   //     IconData fallbackIcon, VoidCallback onClick, ThemeData theme) {
//   //   return ListTile(
//   //     leading: NullableCircleAvatar(
//   //       url,
//   //       fallbackIcon,
//   //       heroTag: id,
//   //     ),
//   //     title: Text(
//   //       title,
//   //       style: theme.textTheme.titleLarge,
//   //     ),
//   //     subtitle: Text(subtitle),
//   //     onTap: onClick,
//   //   );
//   // }

//   Widget _buildBodyCard(
//     String id,
//     String title,
//     String subtitle,
//     String assetPath,
//     IconData fallbackIcon,
//     VoidCallback onClick,
//     ThemeData theme,
//   ) {
//     // Get the image path and display title from bodyTitles based on the title (bodyname)
//     final bodyData = widget.bodyTitles.firstWhere(
//       (element) => element["bodyname"] == title,
//       orElse: () => {"title": title, "image": ""},
//     );

//     final imagePath = bodyData["image"] ?? "";
//     final displayTitle = bodyData["title"] ?? title;

//     return GestureDetector(
//       onTap: onClick,
//       child: Container(
//         width: 182,
//         height: 128,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Stack(
//             children: [
//               // Background image
//               Image.asset(
//                 imagePath,
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: double.infinity,
//               ),
//               // Semi-transparent overlay for readability
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.25),
//                 ),
//               ),
//               // Title text at bottom-left
//               Positioned(
//                 bottom: 8,
//                 left: 8,
//                 right: 8,
//                 child: Text(
//                   displayTitle,
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     letterSpacing: 0.5,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  FocusNode _focusNode = FocusNode();
  TextEditingController? _searchFieldController;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
            child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/explore/searchbackground.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                  child: Column(children: [
                SizedBox(height: 10.5),
                Center(
                    child: Text('Explore',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DM Sans',
                          color: Color.fromRGBO(15, 22, 32, 1),
                        ))),
                SizedBox(height: 30.5),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Exploresearch(),
                        ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 16, right: 16),
                    height: 50,
                    padding: const EdgeInsets.only(
                        left: 14, right: 14, top: 13, bottom: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image(
                          image: AssetImage('assets/blogs/search.png'),
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 20),
                        Text('Search clubs, events, users...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'DM Sans',
                              color: Color.fromRGBO(0, 0, 0, 0.4),
                            )),
                      ],
                    ),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(
                        left: 32, right: 32, top: 18, bottom: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Around ',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Color.fromRGBO(15, 22, 32, 1),
                                      fontFamily: 'DM Sans',
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Insti',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Color.fromRGBO(
                                          48, 111, 220, 1), // blue
                                      fontFamily: 'DM Sans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: Text(
                              'Heard about the new hostels',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'DM Sans',
                                color: Color.fromRGBO(15, 22, 32, 1),
                              ),
                            ),
                          ),
                        ]))
              ])),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 12),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Bodycard(context, "Cult", "assets/explore/cult.png"),
                        Bodycard(context, "Tech", "assets/explore/tech.png"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Bodycard(context, "Sports", "assets/explore/sport.png"),
                        Bodycard(context, "I.Bs", "assets/explore/ibs.png"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Bodycard(
                            context, "Hostels", "assets/explore/hostels.png"),
                        Bodycard(context, "Departments",
                            "assets/explore/departments.png"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Bodycard(context, "Food", "assets/explore/food.png"),
                        Bodycard(
                            context, "Scenes", "assets/explore/scenes.png"),
                      ],
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        )));
  }
}

Widget Bodycard(BuildContext context, String title, String imagePath) {
  return GestureDetector(
      child: Container(
    height: 128,
    width: 182,
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      image: DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
      ),
    ),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        fontFamily: 'DM Sans',
      ),
    ),
  ));
}

class Exploresearch extends StatefulWidget {
  @override
  _ExploresearchState createState() => _ExploresearchState();
}

class _ExploresearchState extends State<Exploresearch> {
  FocusNode _focusNode = FocusNode();
  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  Future<void> saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentSearches', recentSearches);
  }

  @override
  void initState() {
    super.initState();
    loadRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var bloc = BlocProvider.of(context)!.bloc;
      var exploreBloc = bloc.exploreBloc;
      exploreBloc.query = "";
      exploreBloc.refresh();
    });
  }

  bool firstBuild = true;

  TextEditingController _searchFieldController = TextEditingController();

  List<String> recentSearches = [];
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    var exploreBloc = bloc.exploreBloc;
    if (firstBuild) {
      firstBuild = false;
    }
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
            onTap: () {
              _focusNode.unfocus();
            },
            child: Column(
              children: [
                SizedBox(height: 20),
                Container(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.only(left: 16, right: 16),
                      padding: const EdgeInsets.only(
                          left: 14, right: 14, top: 13, bottom: 13),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(246, 246, 246, 1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Color.fromRGBO(48, 111, 220, 1),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: SvgPicture.asset(
                              'assets/explore/arrow-left.svg',
                              height: 24,
                              width: 24,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Hero(
                            tag: 'search',
                            child: SvgPicture.asset(
                              'assets/explore/search.svg',
                              height: 24,
                              width: 24,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchFieldController,
                              focusNode: _focusNode,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(0, 0, 0, 0.8),
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search clubs',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(0, 0, 0, 0.4),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (query) async {
                                if (query.length > 3) {
                                  setState(() {
                                    exploreBloc.query = query;
                                  });
                                  await exploreBloc.refresh();
                                }
                              },
                              onSubmitted: (query) async {
                                setState(() {
                                  if (query.isNotEmpty &&
                                      !recentSearches.contains(query)) {
                                    recentSearches.insert(0, query);
                                    if (recentSearches.length > 20) {
                                      recentSearches.removeLast();
                                    }
                                  }
                                  exploreBloc.query = query;
                                });
                                await saveRecentSearches();                                
                                await exploreBloc.refresh();
                              },
                              autofocus: true,
                              maxLines: 1,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                if (exploreBloc.query == '' && recentSearches.isNotEmpty) ...[
                  Container(
                      margin: EdgeInsets.only(left: 16, right: 16, top: 23),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Search',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    setState(() {
                                      recentSearches.clear();
                                    });
                                    await saveRecentSearches();
                                  },
                                  child: Text(
                                    'Clear All',
                                    style: TextStyle(
                                      color: const Color(0xFF306FDC),
                                      fontSize: 15,
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            SizedBox(height: 18),
                            Container(
                                child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: recentSearches
                                  .map((search) => RecentSearch(
                                        search,
                                        () {
                                          setState(() {
                                            _searchFieldController.text =
                                                search;
                                            exploreBloc.query = search;
                                            exploreBloc.refresh();
                                          });
                                        },
                                        () async {
                                          setState(() {
                                            recentSearches.remove(search);
                                          });
                                          await saveRecentSearches();
                                        },
                                      ))
                                  .toList(),
                            )),
                          ])),
                  SizedBox(height: 20),
                  Dash(
                    direction: Axis.horizontal,
                    length: 368,
                    dashLength: 6,
                    dashGap: 7,
                    dashColor: Color(0xFFDADADA),
                  ),
                ],
                if (exploreBloc.query == '')
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 8, top: 20),
                    height: 144,
                    child:
                        ListView(scrollDirection: Axis.horizontal, children: [
                      SearchBodycard(
                          context, 'Cult', 'assets/explore/cult.png'),
                      SearchBodycard(
                          context, 'Sports', 'assets/explore/sport.png'),
                      SearchBodycard(
                          context, 'Tech', 'assets/explore/tech.png'),
                      SearchBodycard(
                          context, 'Hostels', 'assets/explore/hostels.png'),
                      SearchBodycard(context, 'I.Bs', 'assets/explore/ibs.png'),
                      SearchBodycard(
                          context, 'Food', 'assets/explore/food.png'),
                      SearchBodycard(
                          context, 'Scenes', 'assets/explore/scenes.png'),
                      SearchBodycard(context, 'Departments',
                          'assets/explore/departments.png'),
                    ]),
                  ),
                if (exploreBloc.query == '')
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          top: 22, left: 16, right: 16, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Popular',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: StreamBuilder<ExploreResponse>(
                                stream: exploreBloc.explore,
                                builder: (BuildContext context,
                                    AsyncSnapshot<ExploreResponse> snapshot) {
                                  return Column(
                                    children: _buildContent(
                                        context, snapshot, theme, exploreBloc),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (exploreBloc.query != '')
                  Expanded(
                    child: Container(
                        margin: EdgeInsets.only(left: 16, right: 16, top: 11),
                        child: SingleChildScrollView(
                          child: StreamBuilder<ExploreResponse>(
                            stream: exploreBloc.explore,
                            builder: (BuildContext context,
                                AsyncSnapshot<ExploreResponse> snapshot) {
                              return Column(
                                children: _buildContent(
                                    context, snapshot, theme, exploreBloc),
                              );
                            },
                          ),
                        )),
                  ),
              ],
            )),
      ),
    );
  }
}

Widget SearchBodycard(BuildContext context, String title, String imagePath) {
  return GestureDetector(
      child: Container(
    height: 144,
    width: 128,
    margin: const EdgeInsets.only(
      right: 8,
    ),
    padding: const EdgeInsets.only(left: 10, bottom: 11),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      image: DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFamily: 'DM Sans',
          ),
        )),
  ));
}

Widget RecentSearch(
    String searchtext, VoidCallback onTap, VoidCallback onDelete) {
  return Container(
    padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      color: Color.fromRGBO(239, 239, 239, 1),
      border: Border.all(
        color: Color.fromRGBO(210, 213, 218, 1),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            child: Text(
              searchtext,
              style: TextStyle(
                color: const Color(0xFF0F1620),
                fontSize: 14,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        InkWell(
          onTap: onDelete,
          child: SvgPicture.asset('assets/explore/x.svg'),
        ),
      ],
    ),
  );
}

// import 'package:InstiApp/src/api/response/explore_response.dart';
// import 'package:InstiApp/src/bloc_provider.dart';
// import 'package:InstiApp/src/blocs/explore_bloc.dart';
// import 'package:InstiApp/src/drawer.dart';
// import 'package:InstiApp/src/routes/bodypage.dart';
// import 'package:InstiApp/src/routes/eventpage.dart';
// import 'package:InstiApp/src/routes/userpage.dart';
// import 'package:InstiApp/src/utils/common_widgets.dart';
// import 'package:InstiApp/src/utils/title_with_backbutton.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

// class ExplorePage extends StatefulWidget {
//   final String title = "Explore";
//   final bool searchMode;
//   final bool fromNavigate;

//   ExplorePage({this.searchMode = false, this.fromNavigate = false});

//   @override
//   _ExplorePageState createState() => _ExplorePageState();

//   static void navigateWith(BuildContext context, bool searchMode) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         settings: RouteSettings(
//           name: "/explore?searchMode=${searchMode ? "true" : "false"}",
//         ),
//         builder: (context) => ExplorePage(
//           searchMode: searchMode,
//           fromNavigate: true,
//         ),
//       ),
//     );
//   }
// }

// class _ExplorePageState extends State<ExplorePage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       GlobalKey<RefreshIndicatorState>();

//   FocusNode _focusNode = FocusNode();
//   ScrollController? _hideButtonController;
//   TextEditingController? _searchFieldController;
//   double isFabVisible = 0;

//   bool searchMode = false;
//   IconData actionIcon = Icons.search_outlined;

//   bool firstBuild = true;

//   @override
//   void initState() {
//     super.initState();

//     _searchFieldController = TextEditingController();
//     _hideButtonController = ScrollController();
//     _hideButtonController!.addListener(() {
//       if (isFabVisible == 1 && _hideButtonController!.offset < 100) {
//         setState(() {
//           isFabVisible = 0;
//         });
//       } else if (isFabVisible == 0 && _hideButtonController!.offset > 100) {
//         setState(() {
//           isFabVisible = 1;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchFieldController?.dispose();
//     _hideButtonController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     var bloc = BlocProvider.of(context)!.bloc;
//     var exploreBloc = bloc.exploreBloc;
//     if (firstBuild) {
//       exploreBloc.query = "";
//       exploreBloc.refresh();
//       searchMode = widget.searchMode;
//       if (widget.fromNavigate) {
//         bloc.drawerState.setPageIndex(2);
//       }
//       firstBuild = false;
//     }

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       key: _scaffoldKey,
//       drawer: NavDrawer(),
//       bottomNavigationBar: MyBottomAppBar(
//         shape: RoundedNotchedRectangle(),
//         child: new Row(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
//             IconButton(
//               tooltip: "Show bottom sheet",
//               icon: Icon(
//                 Icons.menu_outlined,
//                 semanticLabel: "Show bottom sheet",
//               ),
//               onPressed: () {
//                 _scaffoldKey.currentState?.openDrawer();
//               },
//             ),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: GestureDetector(
//           onTap: () {
//             _focusNode.unfocus();
//           },
//           child: ListView(controller: _hideButtonController, children: <Widget>[
//             RefreshIndicator(
//               key: _refreshIndicatorKey,
//               onRefresh: () {
//                 return exploreBloc.refresh();
//               },
//               child: TitleWithBackButton(
//                 child: Row(
//                   mainAxisSize: MainAxisSize.max,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     Expanded(
//                       child: Text(
//                         widget.title,
//                         style: theme.textTheme.displaySmall,
//                       ),
//                     ),
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 500),
//                       width: searchMode ? 0.0 : null,
//                       height: searchMode ? 0.0 : null,
//                       decoration: ShapeDecoration(
//                           shape: CircleBorder(
//                               side: BorderSide(color: theme.primaryColor))),
//                       child: searchMode
//                           ? SizedBox()
//                           : IconButton(
//                               tooltip: "Search ${widget.title}",
//                               padding: EdgeInsets.all(16.0),
//                               icon: Icon(
//                                 actionIcon,
//                                 color: theme.primaryColor,
//                               ),
//                               color: theme.cardColor,
//                               onPressed: () {
//                                 setState(() {
//                                   actionIcon = Icons.close_outlined;
//                                   searchMode = !searchMode;
//                                 });
//                               },
//                             ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             !searchMode
//                 ? SizedBox(
//                     height: 0,
//                   )
//                 : PreferredSize(
//                     preferredSize: Size.fromHeight(72),
//                     child: AnimatedContainer(
//                       color: theme.canvasColor,
//                       padding: EdgeInsets.all(8.0),
//                       duration: Duration(milliseconds: 500),
//                       child: TextField(
//                         controller: _searchFieldController,
//                         cursorColor: theme.textTheme.bodyMedium?.color,
//                         style: theme.textTheme.bodyMedium,
//                         focusNode: _focusNode,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30)),
//                           labelStyle: theme.textTheme.bodyMedium,
//                           hintStyle: theme.textTheme.bodyMedium,
//                           prefixIcon: Icon(
//                             Icons.search_outlined,
//                           ),
//                           suffixIcon: IconButton(
//                             tooltip: "Search events, bodies, users...",
//                             icon: Icon(Icons.close_outlined),
//                             onPressed: () {
//                               setState(() {
//                                 actionIcon = Icons.search_outlined;
//                                 exploreBloc.query = "";
//                                 exploreBloc.refresh();
//                                 searchMode = !searchMode;
//                               });
//                             },
//                           ),
//                           hintText: "Search events, bodies, users...",
//                         ),
//                         onChanged: (query) async {
//                           if (query.length > 4) {
//                             exploreBloc.query = query;
//                             exploreBloc.refresh();
//                           }
//                         },
//                         onSubmitted: (query) async {
//                           exploreBloc.query = query;
//                           await exploreBloc.refresh();
//                         },
//                         autofocus: true,
//                       ),
//                     ),
//                   ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: StreamBuilder<ExploreResponse>(
//                 stream: exploreBloc.explore,
//                 builder: (BuildContext context,
//                     AsyncSnapshot<ExploreResponse> snapshot) {
//                   return Column(
//                     children: _buildContent(snapshot, theme, exploreBloc),
//                   );
//                 },
//               ),
//             ),
//           ]),
//         ),
//       ),
//       floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
//       floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
//       floatingActionButton: isFabVisible == 0
//           ? null
//           : FloatingActionButton(
//               tooltip: "Go to the Top",
//               onPressed: () {
//                 _hideButtonController!.animateTo(0.0,
//                     curve: Curves.fastOutSlowIn,
//                     duration: const Duration(milliseconds: 600));
//               },
//               child: Icon(Icons.keyboard_arrow_up_outlined),
//             ),
//     );
//   }

List<Widget> _buildContent(
  BuildContext context,
  AsyncSnapshot<ExploreResponse> snapshot,
  ThemeData theme,
  ExploreBloc exploreBloc,
) {
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
              Text.rich(TextSpan(style: theme.textTheme.titleLarge, children: [
            TextSpan(text: "Nothing found for the query "),
            TextSpan(
                text: "\"${exploreBloc.query}\"",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: "."),
          ])),
        )
      ];
    }
    //move to next page
    return (bodies
                ?.map((b) => _buildListTile(
                    b.bodyID ?? "",
                    b.bodyName ?? "",
                    b.bodyShortDescription ?? "",
                    b.bodyImageURL ?? "",
                    Icons.people_outline_outlined,
                    () => BodyPage.navigateWith(context, exploreBloc.bloc,
                        body: b)))
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
                    ))
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
                    ))
                .toList() ??
            []);
  } else {
    return [
      Center(
          child: CircularProgressIndicatorExtended(
        label: Text("Loading bodies"),
      ))
    ];
  }
}

//RELATED TO TILES
Widget _buildListTile(String id, String title, String subtitle, String url,
    IconData fallbackIcon, VoidCallback onClick) {
  return Container(
      margin: EdgeInsets.only(
        top: 16,
      ),
      child: InkWell(
        onTap: onClick,
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: CachedNetworkImage(
              imageUrl: url,
              height: 63,
              width: 63,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(child: Icon(fallbackIcon)),
              errorWidget: (context, url, error) => Icon(Icons.people),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          SvgPicture.asset(
            'assets/explore/chevron-right.svg',
            height: 24,
            width: 24,
          ),
        ]),
      ));
}
