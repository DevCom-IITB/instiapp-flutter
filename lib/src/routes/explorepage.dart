import 'dart:async';

import 'package:InstiApp/src/api/response/explore_response.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/explore_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart' as bodypage;
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
import 'package:InstiApp/src/utils/responsivenew.dart';

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
// inside _ExplorePageState
  final ScrollController _listController = ScrollController();
  double _maxScrollOffset = double.infinity;
  final double _clampFraction = 0.4; // change to desired fraction (0.0 - 1.0)

  @override
  void initState() {
    super.initState();

    // compute allowed max after first layout (the ListView's maxScrollExtent becomes available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listController.hasClients) {
        final maxExtent = _listController.position.maxScrollExtent;
        // Option A: clamp to a fraction of the full scrollable extent
        _maxScrollOffset = maxExtent * _clampFraction;

        // Option B: clamp to an absolute pixel height (uncomment to use instead)
        // final pixels = MediaQuery.of(context).size.height * 0.6; // e.g. 60% viewport height
        // _maxScrollOffset = pixels.clamp(0.0, maxExtent);
      }
    });

    // prevent going past the allowed offset
    _listController.addListener(() {
      if (_listController.hasClients &&
          _listController.offset > _maxScrollOffset) {
        _listController.jumpTo(_maxScrollOffset);
      }
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context)!.bloc;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Scaffold(
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        extendBodyBehindAppBar: true,
        body: Stack(children: [
          Container(
              child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(Responsive.height(24, context)),
                    bottomRight:
                        Radius.circular(Responsive.height(24, context)),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/explore/searchbackground.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                    bottom: false,
                    child: Column(children: [
                      SizedBox(height: Responsive.height(10.5, context)),
                      Center(
                          child: Text('Explore',
                              style: TextStyle(
                                fontSize: Responsive.text(24, context),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'DM Sans',
                                color: Color.fromRGBO(15, 22, 32, 1),
                              ))),
                      SizedBox(height: Responsive.height(18, context)),
                      InkWell(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Exploresearch(
                                    onBack: (String id) {
                                      setState(() {
                                        bodyID = id;
                                        // searchMode = false;
                                      });
                                    },
                                  ),
                                ),
                              );
                            });
                          },
                          child:
                              // Container(
                              //   margin: EdgeInsets.only(
                              //       left: Responsive.width(16, context),
                              //       right: Responsive.width(16, context)),
                              //   height: Responsive.height(50, context),
                              //   padding: EdgeInsets.only(
                              //       left: Responsive.width(14, context),
                              //       right: Responsive.width(14, context),
                              //       top: Responsive.height(13, context),
                              //       bottom: Responsive.height(13, context)),
                              //   decoration: BoxDecoration(
                              //     color: Colors.white,
                              //     borderRadius: BorderRadius.circular(
                              //         Responsive.height(25, context)),
                              //   ),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     children: [
                              //       Image(
                              //         image: AssetImage('assets/blogs/search.png'),
                              //         height: Responsive.height(24, context),
                              //         width: Responsive.width(24, context),
                              //       ),
                              //       SizedBox(width: Responsive.width(20, context)),
                              //       Text('Search clubs, events, users...',
                              //           style: TextStyle(
                              //             fontSize: Responsive.text(16, context),
                              //             fontWeight: FontWeight.w400,
                              //             fontFamily: 'DM Sans',
                              //             color: Color.fromRGBO(0, 0, 0, 0.4),
                              //           )),
                              //     ],
                              //   ),
                              // ),
                              Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            height: Responsive.height(50, context),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  Responsive.height(50, context)),
                              image: DecorationImage(
                                image: AssetImage("assets/blogs/searchbar.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                children: [
                                  Image(
                                    image:
                                        AssetImage('assets/blogs/search.png'),
                                    height: Responsive.height(24, context),
                                    width: Responsive.width(24, context),
                                  ),
                                  SizedBox(
                                      width: Responsive.width(20, context)),
                                  Text('Search clubs, events, users...',
                                      style: TextStyle(
                                        fontSize: Responsive.text(16, context),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'DM Sans',
                                        color: Color.fromRGBO(0, 0, 0, 0.4),
                                      )),
                                ],
                              ),
                            ),
                          )),
                      Container(
                          margin: EdgeInsets.only(
                              left: Responsive.width(32, context),
                              right: Responsive.width(32, context),
                              top: Responsive.height(12, context),
                              bottom: Responsive.height(20, context)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Around ',
                                          style: TextStyle(
                                            fontSize:
                                                Responsive.text(36, context),
                                            fontWeight: FontWeight.w900,
                                            color:
                                                Color.fromRGBO(15, 22, 32, 1),
                                            fontFamily: 'DM Sans',
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Insti',
                                          style: TextStyle(
                                            fontSize:
                                                Responsive.text(36, context),
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
                                      fontSize: Responsive.text(16, context),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'DM Sans',
                                      color: Color.fromRGBO(15, 22, 32, 1),
                                    ),
                                  ),
                                ),
                              ])),
                    ])),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                    top: Responsive.height(10, context),
                  ),
                  child: ListView(
                    // controller: _listController,
                    physics: ClampingScrollPhysics(),
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
                          // Bodycard(context, "I.Bs", "assets/explore/ibs.png"),
                          InkWell(
                            onTap: () {
                              bodyID = "de55aa06-7f0a-46d4-bad4-d0150671e56c";
                              setState(() {});
                            },
                            child: Bodycard(
                                context, "I.B.s", "assets/explore/ibs.png"),
                          ),
                          Bodycard(context, "Coming Soon!",
                              "assets/explore/food_explore.png"),
                        ],
                      ),
                      SizedBox(height: Responsive.height(100, context)),
                    ],
                  ),
                ),
              ),
            ],
          )),
          // if (searchMode)
          //   Exploresearch(
          //     onBack: (String id) {
          //       setState(() {
          //         bodyID = id;
          //         searchMode = false;
          //       });
          //     },
          //   ),
          if (bodyID != "")
            ExploreClubPage(
              loadBody: () => bloc.getBody(bodyID),
              heroTag: bodyID,
              headerTitle: _resolveTitleFromBodyId(bodyID),
              headerDescription: null,
              onBack: () {
                setState(() {
                  bodyID = "";
                });
              },
            ),
        ]));
  }
}

String _resolveTitleFromBodyId(String id) {
  switch (id) {
    case "91199c20-7488-41c5-9f6b-6f6c7c5b897d":
      return "Cult";
    case "81e05a1a-7fd1-45b5-84f6-074e52c0f085":
      return "Tech";
    case "a9f81e69-fcc9-4fe3-b261-9e5e7a13f898":
      return "Sports";
    case "44fe710a-8ede-4d59-a25b-a86434373209":
      return "Academics";
    case "f3ae5230-4441-4586-81a8-bf75a2e47318":
      return "Hostels";
    case "252ddc80-910b-4f63-b68a-de30a62a947e":
      return "Departments";
    case "de55aa06-7f0a-46d4-bad4-d0150671e56c":
      return "I.B.s";
    default:
      return "Explore";
  }
}

Widget Bodycard(BuildContext context, String title, String imagePath) {
  return GestureDetector(
      child: InkWell(
    child: Container(
      height: Responsive.height(128, context),
      width: Responsive.width(182, context),
      margin: EdgeInsets.only(
        left: Responsive.width(8, context),
        right: Responsive.width(8, context),
        bottom: Responsive.height(8, context),
        top: Responsive.height(8, context),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Responsive.height(14, context)),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Responsive.height(14, context)),
          child: Container(
              height: Responsive.height(128, context),
              width: Responsive.width(182, context),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0, 0),
                  end: Alignment(0, 1.0),
                  colors: [Colors.black.withOpacity(0), Colors.black],
                ),
              )),
        ),
        Container(
          padding: EdgeInsets.all(Responsive.height(12, context)),
          alignment: Alignment.bottomLeft,
          child: Text(
            title,
            style: TextStyle(
              fontSize: Responsive.text(16, context),
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
  String currquery = "";
  Timer? _debounce;

  List<String> recentSearches = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFieldController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

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
        child: Column(
          children: [
            // Fixed Search Bar at top
            GestureDetector(
              onTap: () {
                _focusNode.unfocus();
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: EdgeInsets.only(
                      left: Responsive.width(16, context),
                      right: Responsive.width(16, context),
                      top: Responsive.height(20, context),
                      bottom: Responsive.height(8, context)),
                  padding: EdgeInsets.only(
                      left: Responsive.width(14, context),
                      right: Responsive.width(14, context),
                      top: Responsive.height(13, context),
                      bottom: Responsive.height(13, context)),
                  height: Responsive.height(50, context),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(246, 246, 246, 1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Color.fromRGBO(48, 111, 220, 1),
                      width: Responsive.width(2, context),
                    ),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          widget.onBack('');
                        },
                        child: SvgPicture.asset(
                          'assets/explore/arrow-left.svg',
                          height: Responsive.height(24, context),
                          width: Responsive.width(24, context),
                        ),
                      ),
                      SizedBox(
                        width: Responsive.width(20, context),
                      ),
                      Hero(
                        tag: 'search',
                        child: SvgPicture.asset(
                          'assets/explore/search.svg',
                          height: Responsive.height(24, context),
                          width: Responsive.width(24, context),
                        ),
                      ),
                      SizedBox(
                        width: Responsive.width(20, context),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchFieldController,
                          focusNode: _focusNode,
                          style: TextStyle(
                            fontSize: Responsive.text(16, context),
                            color: Color.fromRGBO(0, 0, 0, 0.8),
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search clubs, events, users...',
                            hintStyle: TextStyle(
                              fontSize: Responsive.text(16, context),
                              color: Color.fromRGBO(0, 0, 0, 0.4),
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (query) {
                            setState(() {
                              currquery = query;
                            });

                            final trimmed = query.trim();
                            _debounce?.cancel();

                            if (trimmed.isEmpty) {
                              exploreBloc.query = '';
                              exploreBloc.refresh();
                              return;
                            }
                            if (query.length < 3) {
                              return;
                            }
                            _debounce = Timer(
                              const Duration(milliseconds: 300),
                              () async {
                                exploreBloc.query = trimmed;
                                await exploreBloc.refresh();
                              },
                            );
                          },
                          onSubmitted: (query) async {
                            setState(() {
                              currquery = query;
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
                      ),
                      SizedBox(width: Responsive.width(8, context)),
                      if (currquery.isNotEmpty)
                        InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            _searchFieldController.clear();
                            _focusNode.unfocus();
                            setState(() {
                              currquery = '';
                              exploreBloc.query = '';
                            });
                            exploreBloc.refresh();
                          },
                          child: Padding(
                            padding:
                                EdgeInsets.all(Responsive.width(1, context)),
                            child: SvgPicture.asset(
                              'assets/explore/x.svg',
                              width: Responsive.width(24, context),
                              height: Responsive.height(24, context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Scrollable content below search bar
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (exploreBloc.query == '' &&
                        recentSearches.isNotEmpty) ...[
                      Container(
                          margin: EdgeInsets.only(
                              left: Responsive.width(16, context),
                              right: Responsive.width(16, context),
                              top: Responsive.height(20, context)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Recent Search',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: Responsive.text(18, context),
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
                                          fontSize:
                                              Responsive.text(15, context),
                                          fontFamily: 'DM Sans',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                                SizedBox(
                                    height: Responsive.height(18, context)),
                                Container(
                                    child: Wrap(
                                  spacing: Responsive.width(8, context),
                                  runSpacing: Responsive.height(8, context),
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  children: recentSearches
                                      .map((search) => RecentSearch(search, () {
                                            setState(() {
                                              _searchFieldController.text =
                                                  search;
                                              exploreBloc.query = search;
                                              exploreBloc.refresh();
                                            });
                                          }, () async {
                                            setState(() {
                                              recentSearches.remove(search);
                                            });
                                            await saveRecentSearches();
                                          }, context))
                                      .toList(),
                                )),
                              ])),
                      SizedBox(height: Responsive.height(20, context)),
                      Dash(
                        direction: Axis.horizontal,
                        length: Responsive.width(368, context),
                        dashLength: Responsive.width(6, context),
                        dashGap: Responsive.width(7, context),
                        dashColor: Color(0xFFDADADA),
                      ),
                    ],
                    if (exploreBloc.query == '')
                      Container(
                        margin: EdgeInsets.only(
                            left: Responsive.width(16, context),
                            right: Responsive.width(8, context),
                            top: Responsive.height(15, context)),
                        height: Responsive.height(144, context),
                        child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onBack(
                                      '91199c20-7488-41c5-9f6b-6f6c7c5b897d');
                                },
                                child: SearchBodycard(
                                    context, 'Cult', 'assets/explore/cult.png'),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onBack(
                                      'a9f81e69-fcc9-4fe3-b261-9e5e7a13f898');
                                },
                                child: SearchBodycard(context, 'Sports',
                                    'assets/explore/sport.png'),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onBack(
                                      '81e05a1a-7fd1-45b5-84f6-074e52c0f085');
                                },
                                child: SearchBodycard(
                                    context, 'Tech', 'assets/explore/tech.png'),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onBack(
                                      '44fe710a-8ede-4d59-a25b-a86434373209');
                                },
                                child: SearchBodycard(context, 'Academics',
                                    'assets/explore/scenes.png'),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onBack(
                                      '252ddc80-910b-4f63-b68a-de30a62a947e');
                                },
                                child: SearchBodycard(context, 'Departments',
                                    'assets/explore/departments.png'),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onBack(
                                      'f3ae5230-4441-4586-81a8-bf75a2e47318');
                                },
                                child: SearchBodycard(context, 'Hostels',
                                    'assets/explore/hostels.png'),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onBack(
                                      'de55aa06-7f0a-46d4-bad4-d0150671e56c');
                                },
                                child: SearchBodycard(
                                    context, 'I.B.s', 'assets/explore/ibs.png'),
                              ),
                              // InkWell(
                              //   onTap: () {
                              //     Navigator.pop(context);
                              //     widget.onBack(
                              //         'd1f2e3c4-b5a6-7d8e-9f0a-b1c2d3e4f5a6');
                              //   },
                              //   child: SearchBodycard(
                              //       context, 'Food', 'assets/explore/food.png'),
                              // ),
                            ]),
                      ),
                    if (exploreBloc.query == '')
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(
                            top: Responsive.height(22, context),
                            left: Responsive.width(16, context),
                            right: Responsive.width(16, context),
                            bottom: Responsive.height(8, context)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  bottom: Responsive.height(8, context)),
                              child: Text(
                                'Popular',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: Responsive.text(18, context),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            StreamBuilder<ExploreResponse>(
                              stream: exploreBloc.explore,
                              builder: (BuildContext context,
                                  AsyncSnapshot<ExploreResponse> snapshot) {
                                return Column(
                                  children: _buildContent(
                                      context, snapshot, theme, exploreBloc),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    if (exploreBloc.query != '')
                      Container(
                          margin: EdgeInsets.only(
                              left: Responsive.width(16, context),
                              right: Responsive.width(16, context),
                              top: Responsive.height(11, context)),
                          child: StreamBuilder<ExploreResponse>(
                            stream: exploreBloc.explore,
                            builder: (BuildContext context,
                                AsyncSnapshot<ExploreResponse> snapshot) {
                              return Column(
                                children: _buildContent(
                                    context, snapshot, theme, exploreBloc),
                              );
                            },
                          )),
                    SizedBox(height: Responsive.height(20, context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget SearchBodycard(BuildContext context, String title, String imagePath) {
  return GestureDetector(
      child: Container(
    height: Responsive.height(144, context),
    width: Responsive.width(128, context),
    margin: EdgeInsets.only(
      right: Responsive.width(8, context),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Responsive.height(14, context)),
      image: DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
      ),
    ),
    child: Stack(children: [
      Container(
        height: Responsive.height(144, context),
        width: Responsive.width(128, context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.height(14, context)),
          gradient: LinearGradient(
            begin: Alignment(0.0, 0.0),
            end: Alignment(0.0, 1.00),
            colors: [Colors.black.withOpacity(0), Colors.black],
          ),
        ),
      ),
      Container(
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.only(
              left: Responsive.width(10, context),
              bottom: Responsive.height(11, context)),
          child: Text(
            title,
            style: TextStyle(
              fontSize: Responsive.text(16, context),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'DM Sans',
            ),
          )),
    ]),
  ));
}

Widget RecentSearch(String searchtext, VoidCallback onTap,
    VoidCallback onDelete, BuildContext context) {
  return Container(
    padding: EdgeInsets.only(
        top: Responsive.height(8, context),
        bottom: Responsive.height(8, context),
        left: Responsive.width(16, context),
        right: Responsive.width(16, context)),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Responsive.height(50, context)),
      color: Color.fromRGBO(239, 239, 239, 1),
      border: Border.all(
        color: Color.fromRGBO(210, 213, 218, 1),
        width: Responsive.width(1, context),
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
                fontSize: Responsive.text(14, context),
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(width: Responsive.width(8, context)),
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
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.width(28.0, context),
              vertical: Responsive.height(8.0, context)),
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
    return (bodies
                ?.map((b) => _buildListTile(
                    b.bodyID ?? "",
                    b.bodyName ?? "",
                    b.bodyShortDescription ?? "",
                    b.bodyImageURL ?? "",
                    Icons.people_outline_outlined,
                    () => bodypage.BodyPage.navigateWith(
                          context,
                          exploreBloc.bloc,
                          body: b,
                        ),
                    context))
                .toList() ??
            []) +
        (events
                ?.map((e) => _buildListTile(
                    e.eventID ?? "",
                    e.eventName ?? "",
                    e.getSubTitle(),
                    e.eventImageURL ?? e.eventBodies?[0].bodyImageURL ?? "",
                    Icons.event_outlined,
                    () => EventPage.navigateWith(context, exploreBloc.bloc, e),
                    context))
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
                    context))
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
    IconData fallbackIcon, VoidCallback onClick, BuildContext context) {
  return Container(
      margin: EdgeInsets.only(
        top: Responsive.height(16, context),
      ),
      child: InkWell(
        onTap: onClick,
        child: Row(children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(Responsive.height(18.0, context)),
            child: CachedNetworkImage(
              imageUrl: url,
              height: Responsive.height(63, context),
              width: Responsive.width(63, context),
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(child: Icon(fallbackIcon)),
              errorWidget: (context, url, error) => Icon(Icons.people),
            ),
          ),
          SizedBox(width: Responsive.width(16, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: Responsive.text(18, context),
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Responsive.height(4, context)),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: Responsive.text(14, context),
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.width(16, context)),
          SvgPicture.asset(
            'assets/explore/chevron-right.svg',
            height: Responsive.height(24, context),
            width: Responsive.width(24, context),
          ),
        ]),
      ));
}
