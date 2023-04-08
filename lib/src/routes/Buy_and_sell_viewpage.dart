import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
  final _baseUrl = "https://mocki.io/v1/e9ae0294-fac5-495e-abb4-a1f505f53698";

  int _page = 0;

  final int _limit = 3;

  bool _isFirstLoadRunning = false;
  bool _hasNextPage = true;

  bool _isLoadMoreRunning = false;

  List _posts = [];

  void _firstLoad() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      final res =
      await http.get(Uri.parse("$_baseUrl?_page=$_page&_limit=$_limit"));
      setState(() {
        _posts = json.decode(res.body);
      });
    } catch (err) {
      if (kDebugMode) {
        print('Something went wrong');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _firstLoad();
  }

  Widget build(BuildContext context) {
    double screen_wr = MediaQuery.of(context).size.width;
    double screen_hr = MediaQuery.of(context).size.height;
    double x, y;

    screen_hr >= screen_wr ? x = 0.35 : x = 0.73;
    screen_hr >= screen_wr ? y = 0.9 : y = 0.49;
    double screen_w = screen_wr * y;
    double screen_h = screen_hr * x;
    double myfont = ((18 / 274.4) * screen_h);
    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          color: Colors.blue,
          child: Row(
            children: [

              IconButton(
                onPressed: () {},
                icon: Icon(Icons.menu_rounded, color: Colors.white,),
                iconSize: 30,
              ),
              Spacer(),

              IconButton(
                onPressed: () {},
                icon: Icon(Icons.search,color: Colors.white,),
                iconSize: 30,
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed("/buyandsell/category");
          },
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Icon(
            Icons.add,
            size: 30,
          ),
        ),
        body: _isFirstLoadRunning
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Center(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (_, index) => Center(
                child: (SizedBox(
                  height: screen_h,
                  width: screen_w,
                  child: Card(
                    color: Color.fromARGB(450, 242, 243, 244),
                    margin:
                    EdgeInsets.symmetric(horizontal: 25, vertical: 20),
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
                                      color: Colors.red,
                                      height: screen_h * 0.55,
                                      width: screen_w,
                                      child: Image.network(
                                        "https://images.unsplash.com/photo-1559348349-86f1f65817fe?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8Y3ljbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60" // _posts[index]['imageUrl']
                                        ,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                print("Hello");
                              },
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(
                                  10, screen_h * 0.245 / 0.43, 0, 0),
                              child: Text(
                                _posts[index]['item_name'],
                                style: TextStyle(
                                    fontSize: (myfont.toInt()).toDouble(),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.fromLTRB(
                                    0, screen_h * 0.28 / 0.43, 18, 0),
                                child: Row(
                                  children: [
                                    Spacer(),
                                    Text(
                                      _posts[index]['negotiable']
                                          ? "Negotiable"
                                          : "Non-Negotiable",
                                      style: TextStyle(
                                          fontSize: ((myfont / 18) * 10.toInt())
                                              .toDouble()),
                                    )
                                  ],
                                )),

                            Container(
                                margin: EdgeInsets.fromLTRB(
                                    0, screen_h * 0.245 / 0.43, 18, 0),
                                child: Row(
                                  children: [
                                    Spacer(),
                                    Text(
                                      "₹" + _posts[index]['price'].toString(),
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
                                    size:
                                    ((myfont / 18 * 12).toInt()).toDouble(),
                                  ),
                                  Text(
                                    _posts[index]['time'],
                                    style: TextStyle(
                                        fontSize: ((myfont / 18 * 12).toInt())
                                            .toDouble()),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.fromLTRB(
                                  10, screen_h * 0.283 / 0.417, 0, 0),
                            ),
                            Container(
                                child: Text(
                                  "Condition: " +
                                      _posts[index]['condition'].toString() +
                                      "/10",
                                  style: TextStyle(
                                      fontSize: ((myfont / 18 * 12).toInt())
                                          .toDouble()),
                                ),
                                margin: EdgeInsets.fromLTRB(
                                    10, screen_h * 0.31 / 0.41, 0, 0)),
                            Row(
                              children: [
                                Spacer(),
                                Container(
                                  margin: EdgeInsets.fromLTRB(
                                      0, screen_h * 0.3 / 0.42, 15.2, 0),
                                  child: SizedBox(
                                    height: 30 / 274.4 * screen_h,
                                    width: 80 / 340.5 * screen_w,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          child: Text("Contact",
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize:
                                                  12.5 / 338 * screen_w)),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                )),
              ),
            ),
            ));
    }
}