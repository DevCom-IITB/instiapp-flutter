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
  String bodyID = "";
  bool searchMode = false;
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context)!.bloc;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(children: [
          Container(
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
                      setState(() {
                        searchMode = true;
                      });
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
                          InkWell(
                            // onTap: () => ExploreClubPage.navigateWith(
                            //   context,
                            //   bloc,
                            //   bodyID: "91199c20-7488-41c5-9f6b-6f6c7c5b897d",
                            // ),
                            onTap: () {
                              bodyID = "91199c20-7488-41c5-9f6b-6f6c7c5b897d";
                              setState(() {});
                            },
                            child: Bodycard(
                                context, "Cult", "assets/explore/cult.png"),
                          ),
                          InkWell(
                            onTap: () {
                              bodyID = "81e05a1a-7fd1-45b5-84f6-074e52c0f085";
                              setState(() {});
                            },
                            child: Bodycard(
                                context, "Tech", "assets/explore/tech.png"),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              bodyID = "a9f81e69-fcc9-4fe3-b261-9e5e7a13f898";
                              setState(() {});
                            },
                            child: Bodycard(
                                context, "Sports", "assets/explore/sport.png"),
                          ),
                          InkWell(
                            onTap: () {
                              bodyID = "44fe710a-8ede-4d59-a25b-a86434373209";
                              setState(() {});
                            },
                            child: Bodycard(context, "Academics",
                                "assets/explore/scenes.png"),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            // onTap: () => ExploreClubPage.navigateWith(
                            //   context,
                            //   bloc,
                            //   bodyID: "f3ae5230-4441-4586-81a8-bf75a2e47318",
                            // ),
                            onTap: () {
                              bodyID = "f3ae5230-4441-4586-81a8-bf75a2e47318";
                              setState(() {});
                            },
                            child: Bodycard(context, "Hostels",
                                "assets/explore/hostels.png"),
                          ),
                          InkWell(
                            onTap: () {
                              bodyID = "252ddc80-910b-4f63-b68a-de30a62a947e";
                              setState(() {});
                            },
                            child: Bodycard(context, "Departments",
                                "assets/explore/departments.png"),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Bodycard(context, "Food", "assets/explore/food.png"),
                          Bodycard(context, "I.Bs", "assets/explore/ibs.png"),
                        ],
                      ),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          )),
          if (searchMode)
            Exploresearch(
              onBack: (String id) {
                setState(() {
                  bodyID = id;
                  searchMode = false;
                });
              },
            ),
          if (bodyID != "")
            ExploreClubPage(
              bodyFuture: bloc.getBody(bodyID),
              heroTag: bodyID,
              onBack: () {
                setState(() {
                  bodyID = "";
                });
              },
            ),
        ]));
  }
}

Widget Bodycard(BuildContext context, String title, String imagePath) {
  return GestureDetector(
      child: InkWell(
    child: Container(
      height: 128,
      width: 182,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
              height: 128,
              width: 182,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0, 0),
                  end: Alignment(0, 1.0),
                  colors: [Colors.black.withOpacity(0), Colors.black],
                ),
              )),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomLeft,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
      ]),
    ),
  ));
}

class Exploresearch extends StatefulWidget {
  final Function(String) onBack;
  Exploresearch({required this.onBack});
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
                            onTap: () {
                              widget.onBack('');
                            },
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
                                if (query.length > 3 || query == '') {
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
                      InkWell(
                        onTap: () {
                          widget.onBack('91199c20-7488-41c5-9f6b-6f6c7c5b897d');
                        },
                        child: SearchBodycard(
                            context, 'Cult', 'assets/explore/cult.png'),
                      ),
                      InkWell(
                        onTap: () {
                          widget.onBack('a9f81e69-fcc9-4fe3-b261-9e5e7a13f898');
                        },
                        child: SearchBodycard(
                            context, 'Sports', 'assets/explore/sport.png'),
                      ),
                      InkWell(
                        onTap: () {
                          widget.onBack('81e05a1a-7fd1-45b5-84f6-074e52c0f085');
                        },
                        child: SearchBodycard(
                            context, 'Tech', 'assets/explore/tech.png'),
                      ),
                      InkWell(
                        onTap: () {
                          widget.onBack('44fe710a-8ede-4d59-a25b-a86434373209');
                        },
                        child: SearchBodycard(
                            context, 'Academics', 'assets/explore/scenes.png'),
                      ),
                      InkWell(
                        onTap: () {
                          widget.onBack('252ddc80-910b-4f63-b68a-de30a62a947e');
                        },
                        child: SearchBodycard(context, 'Departments',
                            'assets/explore/departments.png'),
                      ),
                      InkWell(
                        onTap: () {
                          widget.onBack('f3ae5230-4441-4586-81a8-bf75a2e47318');
                        },
                        child: SearchBodycard(
                            context, 'Hostels', 'assets/explore/hostels.png'),
                      ),
                      InkWell(
                        onTap: () {
                          widget.onBack('b6e2e0e2-9b7e-4e8c-8c2e-1f2e8b2e8c2e');
                        },
                        child: SearchBodycard(
                            context, 'I.Bs', 'assets/explore/ibs.png'),
                      ),
                      InkWell(
                        onTap: () {
                          widget.onBack('d1f2e3c4-b5a6-7d8e-9f0a-b1c2d3e4f5a6');
                        },
                        child: SearchBodycard(
                            context, 'Food', 'assets/explore/food.png'),
                      ),
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
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      image: DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
      ),
    ),
    child: Stack(children: [
      Container(
        height: 144,
        width: 128,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment(0.0, 0.0),
            end: Alignment(0.0, 1.00),
            colors: [Colors.black.withOpacity(0), Colors.black],
          ),
        ),
      ),
      Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.only(left: 10, bottom: 11),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'DM Sans',
            ),
          )),
    ]),
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
