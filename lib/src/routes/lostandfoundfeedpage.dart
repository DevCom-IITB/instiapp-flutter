import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/lost_and_found_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api/model/lostandfoundPost.dart';
import '../api/model/user.dart';
import '../utils/title_with_backbutton.dart';


class LostNFoundPage extends StatefulWidget {
  LostNFoundPage({Key? key, Future<LostAndFoundPost?> item}) : super(key: key);
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  State<LostNFoundPage> createState() => _LostNFoundPageState();
}

class _LostNFoundPageState extends State<LostNFoundPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LostPage(),
    );
  }
}

class LostPage extends StatefulWidget {
  const LostPage({Key? key}) : super(key: key);

  @override
  State<LostPage> createState() => _LostpageState();
}

class _LostpageState extends State<LostPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  lnFType bnstype = lnFType.All;
  bool firstBuild = true;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    LostAndFoundPostBloc lnFPostBloc =
        BlocProvider.of(context)!.bloc.lostAndFoundPostBloc;

    if (firstBuild) {
      lnFPostBloc.refresh();
    }

    double screen_wr = MediaQuery.of(context).size.width;
    double screen_hr = MediaQuery.of(context).size.height;
    double x, y;
    var bloc = BlocProvider.of(context)!.bloc;
    var theme = Theme.of(context);
    bool isLoggedIn = bloc.currSession != null;

    screen_hr >= screen_wr ? x = 0.35 : x = 0.80;
    if (1 >= screen_hr / screen_wr && screen_hr / screen_wr >= 0.5) {
      x = 0.35;
    }
    screen_hr >= screen_wr ? y = 0.9 : y = 0.5;
    double screen_w = screen_wr * y;
    double screen_h = screen_hr * x;

    double myfont = ((18 / 274.4) * screen_h);
    return Scaffold(
        key: _scaffoldKey,
        drawer: NavDrawer(),
        bottomNavigationBar: MyBottomAppBar(
          shape: RoundedNotchedRectangle(),
          notchMargin: 4.0,
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
                        "Login To View Lost and Found Posts",
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
                        "Lost & Found (Beta)",
                        style: theme.textTheme.headline4,
                      ),
                    ),
                        
                        StreamBuilder<List<LostAndFoundPost>>(
                            stream: lnFPostBloc.lostAndFoundPosts,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<LostAndFoundPost>> snapshot) {
                              return ListView.builder(
                                primary: false,
                                shrinkWrap: true,
                                itemCount: snapshot.data?.length ?? 0,
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
                    ));
  }

  Widget _buildContent(
    double screen_h,
    double screen_w,
    int index,
    double myfont, BuildContext context, AsyncSnapshot snapshot
  ) {
    List<LostAndFoundPost> posts = snapshot.data!;
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;

    return Center(
      child: (SizedBox(
        height: screen_h * 0.7,
        width: screen_w * 1.2,
        child: Card(
          color: theme.cardColor,
          margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushNamed("/lostandfound/info" + (posts[index].id ?? ""));
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
                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          height: screen_h,
                          width: screen_h * 0.20 / 0.43,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topLeft: Radius.circular(10)),
                              child: Image(
                                  image: AssetImage(
                                      'assets/buynsell/DevcomLogo.png'))
                              // child: CachedNetworkImage(
                              //    imageUrl: posts[index].imageUrl?[0] ?? '',
                              //   placeholder: (context, url) => Image.asset(
                              //     'assets/buynsell/DevcomLogo.png',
                              //     fit: BoxFit.fill,
                              //   ),
                              //   errorWidget: (context, url, error) =>
                              //       new Image.asset(
                              //     'assets/buynsell/DevcomLogo.png',
                              //     fit: BoxFit.fill,
                              //   ),
                              //   fit: BoxFit.cover,
                              // ),
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      ),
                ),
                Container(
                  margin:
                      EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 105, 10, 0),
                  child: Text('found at '
                      // (posts[index].brand ?? "").length <= 10
                      //     ? posts[index].brand ?? ""
                      //     : (posts[index].brand ?? "").substring(0, 10) + '...',
                      // style: theme.textTheme.bodyText2,
                      // maxLines: 1,
                      ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(
                        screen_w * 0.7, 110, screen_h * 0.04 / 1.5, 1),
                    // child: MyPosts
                    //     ? ClipRRect(
                    //         borderRadius: BorderRadius.circular(5),
                    //         child: ElevatedButton(
                    //           style: ElevatedButton.styleFrom(
                    //             primary: Colors.red,
                    //           ),
                    //           onPressed: () {
                    //             showDialog(
                    //               context: context,
                    //               builder: (ctx) => AlertDialog(
                    //                 title: const Text("Delete Item"),
                    //                 content: const Text(
                    //                     "Are you sure you want to delete this item?"),
                    //                 actions: <Widget>[
                    //                   TextButton(
                    //                     onPressed: () {
                    //                       posts[index].deleted = true;
                    //                       bloc.buynSellPostBloc
                    //                           .updateBuynSellPost(posts[index]);
                    //                       Navigator.of(ctx).pop();
                    //                       bloc.buynSellPostBloc.refresh();
                    //                     },
                    //                     child: Text("Delete",
                    //                         maxLines: 1,
                    //                         style: TextStyle(
                    //                             fontSize:
                    //                                 12.5 / 338 * screen_w)),
                    //                   ),
                    //                 ],
                    //               ),
                    //             );
                    //           },
                    //           child: Text("Delete",
                    //               maxLines: 1,
                    //               style: TextStyle(
                    //                   fontSize: 12.5 / 338 * screen_w)),
                    //         ))
                    child: Row(
                      children: [
                        Spacer(),
                        Text(
                          'not claimed',
                          // (posts[index].action == 'giveaway'
                          //     ? "GiveAway"
                          //     : "₹" +
                          //         (posts[index].price ?? 0).toString()),
                          // style: theme.textTheme.bodyText1,

                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800),
                        )
                      ],
                    )),
                Container(
                  // child: MyPosts
                  //     ? Container()
                  child: Row(children: [
                    Icon(
                      Icons.access_time,
                      size: ((myfont / 18 * 12).toInt()).toDouble(),
                    ),
                    Text('time'
                        // Text(' ' + (posts[index].timeBefore ?? ""),
                        //     style: theme.textTheme.bodyText1!.copyWith(
                        //       fontWeight: FontWeight.bold,
                        )
                    //theme.textTheme.labelSmall
                    // style: TextStyle(
                    //     fontWeight: FontWeight.w600,
                    //     fontSize: ((myfont / 19 * 12).toInt()).toDouble()),
                  ]),

                  margin:
                      EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 135, 0, 0),
                ),
                Container(
                    child: Text('when found'),
                    //   "Condition: " + (posts[index].condition ?? "") + "/10",
                    //   style: //TextStyle(
                    //       theme.textTheme.bodyText2,
                    //   // fontSize: ((myfont / 18 * 12).toInt()).toDouble()),
                    // ),
                    margin:
                        EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 35, 0, 0)),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 13, 10, 0),
                    child: Text('description'
                        // (posts[index].description ?? ""), maxLines: 2,
                        //
                        // overflow: TextOverflow.ellipsis,
                        // style: theme.textTheme.bodyText2,
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
