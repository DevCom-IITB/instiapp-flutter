import 'package:InstiApp/src/routes/categorypagebuyandsell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
            Navigator.of(context).pushNamed("/lib/src/routes/categorypagebuyandsell.dart");
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
                  itemBuilder: (_, index) => (SizedBox(
                    height: 290,
                    width: 400,
                    child: Card(
                      color: Color.fromARGB(450, 242, 243, 244),
                      margin:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      child: SizedBox(
                          child: Stack(
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 170,
                                width: 400,
                                child: FittedBox(
                                  child: Center(
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(70),
                                            topRight: Radius.circular(70),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0)),
                                        child: Image.network(
                                          _posts[index]['imageUrl'],
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed("/lib/src/routes/infoBuyAndSell.dart");
                            },
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 177, 0, 0),
                            child: Text(
                              _posts[index]['item_name'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.fromLTRB(0, 196, 18, 0),
                              child: Row(
                                children: [
                                  Spacer(),
                                  Text(
                                    _posts[index]['negotiable']
                                        ? "Negotiable"
                                        : "Non-Negotiable",
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              )),
                          Container(
                              height: 33,
                              margin: EdgeInsets.fromLTRB(226, 209, 0, 0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                      color: Colors.lightBlueAccent,
                                      child: TextButton(
                                        onPressed: () {
                                          print("Hiiiii");
                                        },
                                        child: Text(
                                          "Contact",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )))),
                          Container(
                              margin: EdgeInsets.fromLTRB(0, 175, 18, 0),
                              child: Row(
                                children: [
                                  Spacer(),
                                  Text(
                                    "₹" + _posts[index]['price'].toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800),
                                  )
                                ],
                              )),
                          Container(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                ),
                                Text(
                                  _posts[index]['time'],
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            margin: EdgeInsets.fromLTRB(10, 206, 0, 0),
                          ),
                          Container(
                              child: Text(
                                "Condition: " +
                                    _posts[index]['condition'].toString() +
                                    "/10",
                                style: TextStyle(fontSize: 12),
                              ),
                              margin: EdgeInsets.fromLTRB(10, 225, 0, 0))
                          // Container(
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
              ));
  }
}
