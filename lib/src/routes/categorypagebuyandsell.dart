
import 'package:flutter/material.dart';
import 'package:InstiApp/src/drawer.dart';

class category extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  category({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ////////////////////////////////////////////////////////////////////////
      key: _scaffoldKey,
      drawer: NavDrawer(),
        bottomNavigationBar: BottomAppBar(
          // color: Colors.blue,
          child: Row(
            children: [

              IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                icon: Icon(Icons.menu_rounded, color: Colors.white,),
                iconSize: 30,
              ),
              Spacer(),
             // Text("Buy N Sell"),


            ],
          ),
        ),
      //
      //       ///////////////////////////////////////////////////////////////////////

      body:
      SingleChildScrollView(
        child: Column (
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children : <Widget>[

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 80, 0, 0),
                child: Container(
                    padding: EdgeInsets.fromLTRB(10.0, 4, 15.0, 20),
                    child: FloatingActionButton(

                      onPressed: () {
                        Navigator.of(context).pushNamed("/buyandsell");
                      },
                      child: Icon(Icons.arrow_back_ios_outlined,color: Colors.black),
                      backgroundColor: Colors.white,
                    )
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(45.0, 0.0, 0.0, 30.0),
                child: Row(
                  children: <Widget>[

                    Container(
                      child : Text("Choose post category ",
                        style: TextStyle(fontSize: 30),
                      ),


                    ),
                  ],
                ),
              ),
////////////////////////////////////Options ?????????????????????????/////////////////
            
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: <Widget>[
                     Expanded(
                       child: Center(
                         child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: (){
                                    Navigator.of(context).pushNamed("/buyandsell/createPost");

                                  },
                                  child: Expanded(
                                  child: Image.asset('assets/buy&sell/Group 10799.png'),

                                  ),
                                ),
                                Text("        Electronics"),

                              ],
                            ),
                       ),
                     ),


                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FlatButton(
                                onPressed: (){
                                  Navigator.of(context).pushNamed("/buyandsell/createPost");
                                },
                                child: Expanded(
                                  child: Image.asset('assets/buy&sell/Group 10800.png'),

                                ),
                              ),
                              Text("        Stationary"),

                            ],
                          ),
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FlatButton(
                                onPressed: (){
                                  Navigator.of(context).pushNamed("/buyandsell/createPost");
                                },
                                child: Expanded(
                                  child: Image.asset('assets/buy&sell/Group 10801.png'),

                                ),
                              ),
                              Text("            Bicycle"),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ),




              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FlatButton(
                                onPressed: (){
                                  Navigator.of(context).pushNamed("/buyandsell/createPost");
                                },
                                child: Expanded(
                                  child: Image.asset('assets/buy&sell/Group 10802.png'),

                                ),
                              ),
                              Text("            Books"),

                            ],
                          ),
                        ),
                      ),


                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FlatButton(
                                onPressed: (){
                                  Navigator.of(context).pushNamed("/buyandsell/createPost");
                                },
                                child: Expanded(
                                  child: Image.asset('assets/buy&sell/Group 10803.png'),

                                ),
                              ),
                              Text("      Daily Needs"),

                            ],
                          ),
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FlatButton(
                                onPressed: (){
                                  Navigator.of(context).pushNamed("/buyandsell/createPost");
                                },
                                child: Expanded(
                                  child: Image.asset('assets/buy&sell/Group 10804.png'),

                                ),
                              ),
                              Text("        Acessories"),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ),


              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FlatButton(
                                onPressed: (){
                                  Navigator.of(context).pushNamed("/buyandsell/createPost");
                                },
                                child: Expanded(
                                  child: Image.asset('assets/buy&sell/Group 10805.png'),

                                ),
                              ),
                              Text("            Sports"),

                            ],
                          ),
                        ),
                      ),


                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FlatButton(
                                onPressed: (){
                                  Navigator.of(context).pushNamed("/buyandsell/createPost");
                                },
                                child: Expanded(
                                  child: Image.asset('assets/buy&sell/Group 10806.png'),

                                ),
                              ),
                              Text("    Miscellaneous"),

                            ],
                          ),
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              Text(""),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ),







            ]
        ),
      ),
//
    );
  }
}
