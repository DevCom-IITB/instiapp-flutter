import 'package:flutter/material.dart';


class category extends StatelessWidget {
  @override
  const category({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ////////////////////////////////////////////////////////////////////////
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 33, 150, 243),
        title: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.menu_rounded),
              iconSize: 30,
            ),
            Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.filter_list),
              iconSize: 30,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search),
              iconSize: 30,
            )
          ],
        ),
      ),

      ///////////////////////////////////////////////////////////////////////

      body:
      SingleChildScrollView(
        child: Column (
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children : <Widget>[

              Padding(
                padding: const EdgeInsets.fromLTRB(45.0, 50.0, 0.0, 30.0),
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
                                  onPressed: (){},
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
                                onPressed: (){},
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
                                onPressed: (){},
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
                                onPressed: (){},
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
                                onPressed: (){},
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
                                onPressed: (){},
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
                                onPressed: (){},
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
                                onPressed: (){},
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
                              FlatButton(
                                onPressed: (){},
                                child: Expanded(
                                  child: Image.asset('assets/buy&sell/blank.png'),

                                ),
                              ),
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
