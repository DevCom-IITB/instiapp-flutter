import 'package:InstiApp/src/api/model/buynsellPost.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/buynsell_post_block.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';

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

  @override
  void initState() {
    super.initState();
    // _firstLoad();
  }

  Widget build(BuildContext context) {
    BuynSellPostBloc buynSellPostBloc =
        BlocProvider.of(context)!.bloc.buynSellPostBloc;
    if (firstBuild) {
      buynSellPostBloc.refresh();
    }

    double screen_wr = MediaQuery.of(context).size.width;
    double screen_hr = MediaQuery.of(context).size.height;
    double x, y;

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
        body: RefreshIndicator(
          onRefresh: () {
            return buynSellPostBloc.refresh();
          },
          child: Center(
            child: StreamBuilder<List<BuynSellPost>>(
                stream: buynSellPostBloc.buynsellposts,
                builder: (BuildContext context,
                    AsyncSnapshot<List<BuynSellPost>> snapshot) {
                  return ListView.builder(
                    itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                    itemBuilder: (_, index) {
                      if (!snapshot.hasData) {
                        return Center(
                            child: CircularProgressIndicatorExtended(
                          label: Text("Loading..."),
                        ));
                      }
                      return _buildContent(
                          screen_h, screen_w, index, myfont, context, snapshot);
                    },
                  );
                }),
          ),
        ));
  }

  Center _buildContent(double screen_h, double screen_w, int index,
      double myfont, BuildContext context, AsyncSnapshot snapshot) {
    List<BuynSellPost> _posts = snapshot.data!;
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
                              .replaceFirst('localhost', '192.168.1.101'),
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
                      (_posts[index].timeOfCreation ?? "").toString() +
                          "Days Ago",
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
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                "/buyandsell/info" + (_posts[index].id ?? ""),
                              );
                            },
                            child: Text("Contact",
                                maxLines: 1,
                                style:
                                    TextStyle(fontSize: 12.5 / 338 * screen_w)),
                          )),
                    ),
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
