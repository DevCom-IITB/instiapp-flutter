import 'package:flutter/material.dart';
import 'package:InstiApp/src/drawer.dart';

class Info extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Container(
        height: (MediaQuery.of(context).size.height),
        width: (MediaQuery.of(context).size.width),
        child: Scaffold(
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
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                    ),
                    iconSize: 30,
                  ),
                  Spacer(),
                  // Text("Buy N Sell"),

                ],
              ),
            ),
            body: SafeArea(
              child: Column(children: <Widget>[
                SizedBox(height: 30,),
                Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Padding(padding: EdgeInsets.fromLTRB(10, 80, 20, 20)),
                        FloatingActionButton(

                            onPressed: (){
                              Navigator.of(context).pushNamed("/buyandsell");
                            },
                          child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black,),
                          backgroundColor: Colors.white,
                        )
                      ],
                    ),), //Row
                Expanded(
                    flex: 6,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(25, 30, 25, 10),
                        child: Image.network(
                            'https://www.google.com/imgres?imgurl=https%3A%2F%2Fwww.herocycles.com%2Fdw%2Fimage%2Fv2%2FBGQH_PRD%2Fon%2Fdemandware.static%2F-%2FSites-cycles-master%2Fdefault%2Fdw70c7b9c3%2FProducts%2FVoltage%2FBSVOL26BKGN001%2F01.png%3Fsh%3D523%26sfrm%3Dpng&tbnid=9Bb-9q8vAByk0M&vet=12ahUKEwi9gt_8zpn-AhUN9nMBHdf3DRAQMygBegUIARDoAQ..i&imgrefurl=https%3A%2F%2Fwww.herocycles.com%2FVoltage-BSVOL26BKGN001.html&docid=2QFXq3a1aAyREM&w=629&h=523&q=cycle&ved=2ahUKEwi9gt_8zpn-AhUN9nMBHdf3DRAQMygBegUIARDoAQ'))),
                Expanded(
                    flex: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 10, 25, 0),
                              child: Text('Title',
                                  style: TextStyle(
                                      fontSize: 35,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)))
                        ])),
                Expanded(
                    flex: 6,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 15, 25, 0),
                              child: Text('Description',
                                  style: TextStyle(color: Colors.grey)))
                        ])),
                Padding(
                    padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: Divider(
                      color: Colors.grey,
                    )),
                Expanded(
                    flex: 2,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 10, 25, 0),
                              child: Text('Contact Details',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)))
                        ])),
              ]),
            ) //Column
            ));
  }
}
