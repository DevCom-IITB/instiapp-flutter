import 'package:InstiApp/src/api/model/buynsellPost.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/buynsell_post_block.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';

import '../api/model/user.dart';
import '../utils/title_with_backbutton.dart';

class BuySellPage extends StatefulWidget {
  BuySellPage({Key? key}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  State<BuySellPage> createState() => _BuySellPageState();
}

class _BuySellPageState extends State<BuySellPage> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Sellpage(),
    );
  }
}

class Sellpage extends StatefulWidget {
  const Sellpage({Key? key}) : super(key: key);

  @override
  State<Sellpage> createState() => _SellpageState();
}

class _SellpageState extends State<Sellpage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool firstBuild = true;
  bool MyPosts = false;

  @override
  void initState() {
    super.initState();
    // _firstLoad();
  }

  Widget build(BuildContext context) {
    BuynSellPostBloc buynSellPostBloc =
        BlocProvider.of(context)!.bloc.buynSellPostBloc;
    User? profile = BlocProvider.of(context)!.bloc.currSession?.profile;
    if (firstBuild) {
      buynSellPostBloc.refresh();
    }

    double screen_wr = MediaQuery.of(context).size.width;
    double screen_hr = MediaQuery.of(context).size.height;
    double x, y;
    var theme = Theme.of(context);

    screen_hr >= screen_wr ? x = 0.35 : x = 0.73;
    screen_hr >= screen_wr ? y = 0.9 : y = 0.49;
    double screen_w = screen_wr * y;
    double screen_h = screen_hr * x;
    double myfont = ((18 / 274.4) * screen_h);
    return Scaffold(
        key: _scaffoldKey,
        drawer: NavDrawer(),
        bottomNavigationBar: MyBottomAppBar(
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
              IconButton(
                icon: Icon(
                  Icons.sailing,
                  semanticLabel: "Show navigation drawer",
                ),
                onPressed: () {
                  MyPosts = !MyPosts;
                  buynSellPostBloc.refresh();
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed("/buyandsell/category");
          },
          backgroundColor: Colors.blue[600],
          child: Icon(
            Icons.add,
            size: 30,
          ),
        ),
        body: SafeArea(
             child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
         
                    Center(
            child: StreamBuilder<List<BuynSellPost>>(
                stream: buynSellPostBloc.buynsellposts,
                builder: (BuildContext context,
                    AsyncSnapshot<List<BuynSellPost>> snapshot) {
                  var length;
                  if (MyPosts) {
                    length = snapshot.data!
                        .where((post) => post.user?.userID == profile?.userID)
                        .toList()
                        .length;
                  } else {
                    length = snapshot.data!.length;
                  }
                  return ListView.builder(
                    itemCount: snapshot.hasData ? length : 0,
                    itemBuilder: (_, index) {
                      if (!snapshot.hasData) {
                        return Center(
                            child: CircularProgressIndicatorExtended(
                          label: Text("Loading..."),
                        ));
                      }

                      if (snapshot.data!.isEmpty == true) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 28.0, vertical: 8.0),
                          child: Text.rich(TextSpan(
                              style: theme.textTheme.headline6,
                              children: [
                                TextSpan(text: "Nothing here yet!"),
                              ])),
                        );
                      } else
                        return _buildContent(screen_h, screen_w, index, myfont,
                            context, snapshot);
                    },
                  );
                }),
          ),],)
        ));
  }

  Widget _buildContent(double screen_h, double screen_w, int index,
      double myfont, BuildContext context, AsyncSnapshot snapshot) {
    List<BuynSellPost> _posts;
    List<BuynSellPost> _postscopy = snapshot.data!;

    var bloc = BlocProvider.of(context)!.bloc;
    User? profile = bloc.currSession?.profile;
    if (MyPosts) {
      _posts = _postscopy
          .where((post) => post.user?.userID == profile?.userID)
          .toList();
    } else {
      _posts = snapshot.data!;
    }
    var theme = Theme.of(context);

    TitleWithBackButton(
      child: Text(
        "Create Post",
        style: theme.textTheme.headline3,
      ),
    );

    return Center(
      child: (SizedBox(
        height: screen_h,
        width: screen_w,
        child: Card(
          color: Color.fromARGB(450, 242, 243, 244),
          margin: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: SizedBox(
              child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10)),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        height: screen_h * 0.55,
                        width: screen_w,
                        child: CachedNetworkImage(
                          imageUrl: (_posts[index].imageUrl ?? "")
                              .replaceFirst('localhost', '192.168.0.103'),
                          placeholder: (context, url) => new Image.asset(
                            'assets/buy&sell/No-image-found.jpg',
                            fit: BoxFit.fill,
                          ),
                          errorWidget: (context, url, error) => new Image.asset(
                            'assets/buy&sell/No-image-found.jpg',
                            fit: BoxFit.fill,
                          ),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.fromLTRB(10, screen_h * 0.245 / 0.43, 0, 0),
                child: Text(
                  _posts[index].name ?? "",
                  style: TextStyle(
                      fontSize: (myfont.toInt()).toDouble(),
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(0, screen_h * 0.28 / 0.43, 18, 0),
                  child: Row(
                    children: [
                      Spacer(),
                      Text(
                        (_posts[index].negotiable ?? false)
                            ? "Negotiable"
                            : "Non-Negotiable",
                        style: TextStyle(
                            fontSize: ((myfont / 18) * 10.toInt()).toDouble()),
                      )
                    ],
                  )),

              Container(
                  margin:
                      EdgeInsets.fromLTRB(0, screen_h * 0.245 / 0.43, 18, 0),
                  child: Row(
                    children: [
                      Spacer(),
                      Text(
                        "₹" + (_posts[index].price ?? 0).toString(),
                        style: TextStyle(
                            fontSize: (myfont.toInt()).toDouble(),
                            fontWeight: FontWeight.w800),
                      )
                    ],
                  )),
              Container(
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: ((myfont / 18 * 12).toInt()).toDouble(),
                    ),
                    Text(
                      _posts[index].timeBefore ?? "",
                      style: TextStyle(
                          fontSize: ((myfont / 18 * 12).toInt()).toDouble()),
                    ),
                  ],
                ),
                margin: EdgeInsets.fromLTRB(10, screen_h * 0.283 / 0.417, 0, 0),
              ),
              Container(
                  child: Text(
                    "Condition: " + (_posts[index].condition ?? "") + "/10",
                    style: TextStyle(
                        fontSize: ((myfont / 18 * 12).toInt()).toDouble()),
                  ),
                  margin:
                      EdgeInsets.fromLTRB(10, screen_h * 0.31 / 0.41, 0, 0)),
              Row(
                children: [
                  Spacer(),
                  Container(
                    margin:
                        EdgeInsets.fromLTRB(0, screen_h * 0.3 / 0.42, 15.2, 0),
                    child: SizedBox(
                        height: 30 / 274.4 * screen_h,
                        width: 80 / 340.5 * screen_w,
                        child: MyPosts
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                  ),
                                  onPressed: () {
                                    bloc.buynSellPostBloc.deleteBuynSellPost(
                                        _posts[index].id ?? "");
                                    MyPosts = false;
                                    bloc.buynSellPostBloc.refresh();
                                  },
                                  child: Text("Delete",
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 12.5 / 338 * screen_w)),
                                ))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/buyandsell/info" +
                                          (_posts[index].id ?? ""),
                                    );
                                  },
                                  child: Text("Contact",
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 12.5 / 338 * screen_w)),
                                ))),
                  ),
                ],
              )
              // Container(co
              //     child: SizedBox(
              //       child: Container(
              //         child: LikeButton(
              //           bubblesSize: 0,
              //         ),
              //       ),
              //       height: 40,
              //       width: 40,
              //     ))
            ],
          )),
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      )),
    );
  }
}
