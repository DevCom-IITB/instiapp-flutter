import 'package:InstiApp/src/api/model/buynsellPost.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/buynsell_post_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';

import '../api/model/user.dart';
import '../utils/title_with_backbutton.dart';

class BuySellPage extends StatefulWidget {
  BuySellPage({Key? key}) : super(key: key);
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  State<BuySellPage> createState() => _BuySellPageState();
}

class _BuySellPageState extends State<BuySellPage> {
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

  BnSType bnstype = BnSType.All;
  bool firstBuild = true;
  bool MyPosts = false;

  @override
  void initState() {
    super.initState();
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
    var bloc = BlocProvider.of(context)!.bloc;
    var theme = Theme.of(context);
    bool isLoggedIn = bloc.currSession != null;

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
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: isLoggedIn
            ? FloatingActionButton.extended(
                icon: Icon(Icons.add_outlined),
                label: Text("Add Item"),
                onPressed: () {
                  Navigator.of(context).pushNamed("/buyandsell/category");
                },
              )
            : SizedBox(
                height: 0,
                width: 0,
              ),
        body: SafeArea(
          child: !isLoggedIn
              ? Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(50),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud,
                        size: 200,
                        color: Colors.grey[600],
                      ),
                      Text(
                        "Login To View Buy and Sell Posts",
                        style: theme.textTheme.headline5,
                        textAlign: TextAlign.center,
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TitleWithBackButton(
                      child: Text(
                        "Buy & Sell (Beta)",
                        style: theme.textTheme.headline4,
                      ),
                    ),
                    Center(
                        child: Column(
                      children: [
                        Row(children: [
                          Expanded(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(15)),
                                        primary: theme.cardColor,
                                        side: BorderSide(
                                          width: 2,
                                          color: MyPosts
                                              ? theme.cardColor
                                              : Colors.blue,
                                        )),
                                    // color: !MyPosts
                                    //     ? theme.bottomAppBarColor
                                    //     : theme.cardColor,
                                    onPressed: () => {
                                      setState(() {
                                        MyPosts = false;
                                      }),
                                      buynSellPostBloc.refresh()
                                    },
                                    child: Text(
                                      "All Posts",
                                      style: theme.textTheme.headline6,
                                    )),
                              )),
                          Expanded(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                                child: ElevatedButton(
                                  child: Text("Your Posts",
                                      style: theme.textTheme.headline6),
                                  onPressed: () => {
                                    setState(() {
                                      MyPosts = true;
                                    }),
                                    buynSellPostBloc.refresh()
                                  },
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15)),
                                      primary: theme.cardColor,
                                      side: BorderSide(
                                        width: 2,
                                        color: !MyPosts
                                            ? theme.cardColor
                                            : Colors.blue,
                                      )),
                                  // color: MyPosts
                                  //     ? theme.bottomAppBarColor
                                  //     : theme.cardColor,
                                ),
                              )),
                        ]),
                        StreamBuilder<List<BuynSellPost>>(
                            stream: buynSellPostBloc.buynsellposts,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<BuynSellPost>> snapshot) {
                              return ListView.builder(
                                primary: false,
                                shrinkWrap: true,
                                itemCount: MyPosts
                                    ? (snapshot.hasData
                                        ? snapshot.data!
                                            .where((post) =>
                                                post.user?.userID ==
                                                    profile?.userID &&
                                                post.deleted != true)
                                            .length
                                        : 0)
                                    : (snapshot.hasData
                                        ? snapshot.data!
                                            .where(
                                                (post) => post.deleted != true)
                                            .length
                                        : 0),
                                itemBuilder: (_, index) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                        child:
                                            CircularProgressIndicatorExtended(
                                      label: Text("Loading..."),
                                    ));
                                  }
                                  return _buildContent(screen_h, screen_w,
                                      index, myfont, context, snapshot);
                                },
                              );
                            }),
                      ],
                    )),
                  ],
                )),
        ));
  }

  Widget _buildContent(double screen_h, double screen_w, int index,
      double myfont, BuildContext context, AsyncSnapshot snapshot) {
    List<BuynSellPost> posts = snapshot.data!;
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    User? profile = bloc.currSession?.profile;
    if (MyPosts) {
      posts = posts
          .where((post) =>
              post.user?.userID == profile?.userID && post.deleted != true)
          .toList();
    } else {
      posts = snapshot.data;
      posts = posts.where((post) => post.deleted != true).toList();
    }

    return Center(
      child: (SizedBox(
        height: screen_h * 0.65,
        width: screen_w * 1.2,
        child: Card(
          color: theme.cardColor,
          margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushNamed("/buyandsell/info" + (posts[index].id ?? ""));
            },
            child: SizedBox(
                child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10)),
                  child: Row(
                    children: [
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          height: screen_h * 0.6,
                          width: screen_w * 0.4,
                          child: CachedNetworkImage(
                            imageUrl: (posts[index].imageUrl?[0] ?? ''),
                            placeholder: (context, url) => new Image.asset(
                              'assets/buynsell/noimg.png',
                              fit: BoxFit.fill,
                            ),
                            errorWidget: (context, url, error) =>
                                new Image.asset(
                              'assets/buynsell/noimg.png',
                              fit: BoxFit.fill,
                            ),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  margin:
                      EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 11, 0, 50),
                  child: Text(
                    posts[index].name ?? "",
                    style: theme.textTheme.headline6,
                    //style: TextStyle(
                    //     fontSize: (myfont.toInt()).toDouble(),
                    //     fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 105, 10, 0),
                  child: Text(
                    posts[index].brand ?? "",
                    style: theme.textTheme.bodyText2,
                    // style: TextStyle(
                    //     fontSize: (myfont.toInt()).toDouble() * 0.7,
                    //     fontWeight: FontWeight.w600),
                    maxLines: 1,
                  ),
                ),
                Container(
                    margin:
                        EdgeInsets.fromLTRB(0, screen_h * 0.28 / 0.43, 18, 0),
                    child: Row(
                      children: [
                        Spacer(),
                        Text(
                          (posts[index].negotiable ?? false)
                              ? "Negotiable"
                              : "Non-Negotiable",
                          style: theme.textTheme.bodyText2,
                        )
                      ],
                    )),
                Container(
                    margin: EdgeInsets.fromLTRB(
                        screen_w * 0.7, 110, screen_h * 0.04 / 1.5, 1),
                    child: MyPosts
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Delete Item"),
                                    content: const Text(
                                        "Are you sure you want to delete this item?"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          posts[index].deleted = true;
                                          bloc.buynSellPostBloc
                                              .updateBuynSellPost(posts[index]);
                                          Navigator.of(ctx).pop();
                                          bloc.buynSellPostBloc.refresh();
                                        },
                                        child: Text("Delete",
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize:
                                                    12.5 / 338 * screen_w)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text("Delete",
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 12.5 / 338 * screen_w)),
                            ))
                        : Row(
                            children: [
                              Spacer(),
                              Text(
                                (posts[index].action == 'giveaway'
                                    ? "GiveAway"
                                    : "₹" +
                                        (posts[index].price ?? 0).toString()),
                                style: theme.textTheme.bodyText1,

                                // style:
                                //     TextStyle(fontSize: w, fontWeight: FontWeight.w800),
                              )
                            ],
                          )),
                Container(
                  child: MyPosts
                      ? Container()
                      : Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: ((myfont / 18 * 12).toInt()).toDouble(),
                            ),
                            Text(' ' + (posts[index].timeBefore ?? ""),
                                style: theme.textTheme.bodyText1!.copyWith(
                                  fontWeight: FontWeight.bold,
                                )
                                //theme.textTheme.labelSmall
                                // style: TextStyle(
                                //     fontWeight: FontWeight.w600,
                                //     fontSize: ((myfont / 19 * 12).toInt()).toDouble()),
                                ),
                          ],
                        ),
                  margin:
                      EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 135, 0, 0),
                ),
                Container(
                    child: Text(
                      "Condition: " + (posts[index].condition ?? "") + "/10",
                      style: //TextStyle(
                          theme.textTheme.bodyText2,
                      // fontSize: ((myfont / 18 * 12).toInt()).toDouble()),
                    ),
                    margin:
                        EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 35, 0, 0)),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 8, 10, 0),
                    child: Text(
                      (posts[index].description ?? ""),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyText2,
                      // style: TextStyle(
                      //     fontWeight: FontWeight.w500,
                      //     fontSize: ((myfont / 16 * 12).toInt()).toDouble()),
                    ),
                    margin:
                        EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 43, 0, 0)),
                Row(
                  children: [
                    Spacer(),
                    Container(),
                  ],
                )
              ],
            )),
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.blue),
          ),
        ),
      )),
    );
  }
}
