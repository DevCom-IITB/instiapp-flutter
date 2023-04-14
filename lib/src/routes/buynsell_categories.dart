import 'package:flutter/material.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';

class ScreenArguments {
  final String title;
  ScreenArguments(this.title);
}

class BuyAndSellCategoryPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  BuyAndSellCategoryPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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

      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 45.0, 0, 10),
                child: Row(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed("/buyandsell");
                      },
                      child: Icon(Icons.arrow_back_ios_outlined,
                          color: Colors.black),
                      backgroundColor: Colors.white,
                    ),
                    Center(
                      child: Text(
                        "Choose post category ",
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              "/buyandsell/createPost",
                              arguments: ScreenArguments(
                                'Electronics',
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/buy&sell/Electronics.png'),
                              Text(
                                "Electronics",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              "/buyandsell/createPost",
                              arguments: ScreenArguments(
                                'Stationary',
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/buy&sell/Group 10800.png'),
                              Text(
                                "Stationary",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              "/buyandsell/createPost",
                              arguments: ScreenArguments(
                                'Bicycle',
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/buy&sell/Group 10801.png'),
                              Text(
                                "Bicycle",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              "/buyandsell/createPost",
                              arguments: ScreenArguments(
                                'Books',
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/buy&sell/Group 10802.png'),
                              Text(
                                "Books",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              "/buyandsell/createPost",
                              arguments: ScreenArguments(
                                'Daily Needs',
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/buy&sell/Group 10803.png'),
                              Text(
                                "Daily Needs",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              "/buyandsell/createPost",
                              arguments: ScreenArguments(
                                'Acessories',
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/buy&sell/Group 10804.png'),
                              Text(
                                "Acessories",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              "/buyandsell/createPost",
                              arguments: ScreenArguments(
                                'Sports',
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/buy&sell/Group 10805.png'),
                              Text(
                                " Sports",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              "/buyandsell/createPost",
                              arguments: ScreenArguments(
                                'Miscellaneous',
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/buy&sell/Group 10806.png'),
                              Text(
                                "Miscellaneous",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ]),
      ),
//
    );
  }
}
