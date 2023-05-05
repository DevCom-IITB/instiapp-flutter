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
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 28.0, vertical: 0),
                        child: OutlinedButton(
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            MyPosts = !MyPosts;
                            buynSellPostBloc.refresh();
                          },
                          child: Text("Your Posts"),
                        ),
                      ),
                    ),
                    Center(
                      child: StreamBuilder<List<BuynSellPost>>(
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
                                          .where((post) => post.deleted != true)
                                          .length
                                      : 0),
                              itemBuilder: (_, index) {
                                if (!snapshot.hasData) {
                                  return Center(
                                      child: CircularProgressIndicatorExtended(
                                    label: Text("Loading..."),
                                  ));
                                }
                                return _buildContent(screen_h, screen_w, index,
                                    myfont, context, snapshot);
                              },
                            );
                          }),
                    ),
                  ],
                )),
        ));
  }

  Widget _buildContent(double screen_h, double screen_w, int index,
      double myfont, BuildContext context, AsyncSnapshot snapshot) {
    List<BuynSellPost> posts = snapshot.data!;

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
                          imageUrl: (posts[index].imageUrl ?? ""),
                          placeholder: (context, url) => new Image.asset(
                            'assets/buynsell/noimg.png',
                            fit: BoxFit.fill,
                          ),
                          errorWidget: (context, url, error) => new Image.asset(
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
                margin: EdgeInsets.fromLTRB(10, screen_h * 0.245 / 0.43, 0, 0),
                child: Text(
                  posts[index].name ?? "",
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
                        (posts[index].negotiable ?? false)
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
                        (posts[index].action == 'giveaway'
                            ? "Give Away"
                            : "₹" + (posts[index].price ?? 0).toString()),
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
                      ' ' + (posts[index].timeBefore ?? ""),
                      style: TextStyle(
                          fontSize: ((myfont / 18 * 12).toInt()).toDouble()),
                    ),
                  ],
                ),
                margin: EdgeInsets.fromLTRB(10, screen_h * 0.283 / 0.417, 0, 0),
              ),
              Container(
                  child: Text(
                    "Condition: " + (posts[index].condition ?? "") + "/10",
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
                                                  .updateBuynSellPost(
                                                      posts[index]);
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
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/buyandsell/info" +
                                          (posts[index].id ?? ""),
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
