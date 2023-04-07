import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      home: Test(),
    ));

class Test extends StatefulWidget {
  @override
  Navbar createState() => Navbar();
  }

class Navbar extends State <Test> {
  int choice=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.menu_outlined),
          title: Text('Buy N Sell/Lost N Found'),
        ), //AppBar
        body: Column(children: <Widget>[
          Expanded(
              flex: 1,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.fromLTRB(10.0, 4, 15.0, 2),
                        child: TextButton(
                          onPressed: () {},
                          child: Icon(Icons.arrow_back_ios_outlined),
                        )), //Container
                    Container(
                      padding: EdgeInsets.fromLTRB(10.0, 4, 15.0, 2),
                      child: Text('CLEAR ALL',
                          style: TextStyle(
                              color: Colors.pink, fontWeight: FontWeight.w900)),
                    ) //Container
                  ])), //Row
          const Divider(
            color: Colors.grey,
          ), //Divider
          Expanded(
              flex: 12,
              child: Row(children: <Widget>[
                Expanded(
                    flex: 3,
                    child: Container(
                        color: Color.fromRGBO(230, 230, 230, 1.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.fromLTRB(
                                      10.0, 10.0, 10.0, 10.0),
                                  child: TextButton(
                                    onPressed: () {
                                      int choice = 0;

                                    },
                                    child: Text('Type',
                                        style: TextStyle(color: Colors.black)),
                                  )), //Container
                              const Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ), //Divider
                              Container(
                                  padding: EdgeInsets.fromLTRB(
                                      10.0, 10.0, 10.0, 10.0),
                                  child: TextButton(
                                    onPressed: () {
                                      choice = 1;

                                    },
                                    child: Text('Category',
                                        style: TextStyle(color: Colors.black)),
                                  )), //Container
                              const Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ), //Divider
                              Container(
                                  padding: EdgeInsets.fromLTRB(
                                      10.0, 10.0, 10.0, 10.0),
                                  child: TextButton(
                                    onPressed: () {
                                      choice = 2;
                                    },
                                    child: Text('Status',
                                        style: TextStyle(color: Colors.black)),
                                  )), //Container
                              const Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ), //Divider
                              Container(
                                  padding: EdgeInsets.fromLTRB(
                                      10.0, 10.0, 10.0, 10.0),
                                  child: TextButton(
                                    onPressed: () {
                                      choice = 3;
                                    },
                                    child: Text('My items',
                                        style: TextStyle(color: Colors.black)),
                                  )), //Container
                              const Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ), //Divider
                              Container(
                                  padding: EdgeInsets.fromLTRB(
                                      10.0, 10.0, 10.0, 10.0),
                                  child: TextButton(
                                    onPressed: () {
                                      choice = 4;
                                    },
                                    child: Text('Marked favourite',
                                        style: TextStyle(color: Colors.black)),
                                  )), //Container
                              const Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ), //Divider
                            ]))), //Column
                if (choice == 0) ...[
                  Expanded(
                      flex: 5,
                      child: Column(children: <Widget>[
                        Container(
                            padding:
                                EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                            child: TextButton(
                              onPressed: () {},
                              child: Text('Search',
                                  style: TextStyle(color: Colors.grey)),
                            )), //Container
                        Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            )), //Divider
                        Row(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 10, 2, 10),
                              child: Icon(Icons.check)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(6, 10, 2, 10),
                            child: Text('    Buy Items',
                                style: TextStyle(color: Colors.grey)),
                          )
                        ]), //Row
                        Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            )), //Divider
                        Row(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 10, 2, 10),
                              child: Icon(Icons.check)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(6, 10, 2, 10),
                            child: Text('    Rent Items',
                                style: TextStyle(color: Colors.grey)),
                          )
                        ]), //Row
                        Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            )), //Divider
                        Row(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 10, 2, 10),
                              child: Icon(Icons.check)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(6, 10, 2, 10),
                            child: Text('    Giveaway(free)',
                                style: TextStyle(color: Colors.grey)),
                          )
                        ]), //Row
                        Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            )), //Divider
                        Row(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 10, 2, 10),
                              child: Icon(Icons.check)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(6, 10, 2, 10),
                            child: Text('    Lost Items',
                                style: TextStyle(color: Colors.grey)),
                          )
                        ]), //Row
                        Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            )), //Divider
                        Row(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 10, 2, 10),
                              child: Icon(Icons.check)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(6, 10, 2, 10),
                            child: Text('    Found Items',
                                style: TextStyle(color: Colors.grey)),
                          )
                        ]), //Row
                      ]))
                ], //Column
                if (choice == 1) ...[
                  Expanded(
                      flex: 5,
                      child: Column(children: <Widget>[
                        Container(
                            padding:
                                EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                            child: TextButton(
                              onPressed: () {},
                              child: Text('Search',
                                  style: TextStyle(color: Colors.grey)),
                            )), //Container
                        Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            )), //Divider
                        Row(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 10, 2, 10),
                              child: Icon(Icons.check)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(6, 10, 2, 10),
                            child: Text('    Bsdkfksdfsdf',
                                style: TextStyle(color: Colors.grey)),
                          )
                        ]), //Row
                        Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            )), //Divider
                        Row(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 10, 2, 10),
                              child: Icon(Icons.check)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(6, 10, 2, 10),
                            child: Text('    Rent Isdffsfdsdfsdftms',
                                style: TextStyle(color: Colors.grey)),
                          )
                        ]), //Row
                        Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            )), //Divider
                        Row(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 10, 2, 10),
                              child: Icon(Icons.check)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(6, 10, 2, 10),
                            child: Text('    Giveasdfsdfsee)',
                                style: TextStyle(color: Colors.grey)),
                          )
                        ]), //Row
                        Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            )), //Divider
                        Row(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 10, 2, 10),
                              child: Icon(Icons.check)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(6, 10, 2, 10),
                            child: Text('    Lost Items',
                                style: TextStyle(color: Colors.grey)),
                          )
                        ]), //Row
                        Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            )), //Divider
                        Row(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(25, 10, 2, 10),
                              child: Icon(Icons.check)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(6, 10, 2, 10),
                            child: Text('    Found Items',
                                style: TextStyle(color: Colors.grey)),
                          )
                        ]), //Row
                      ]))
                ], //Column
              ])) //Row
          ,
          Expanded(
              flex: 1,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text('CLOSE',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w900)),
                    const VerticalDivider(
                      width: 20,
                      thickness: 1,
                      indent: 20,
                      endIndent: 0,
                      color: Colors.grey,
                    ),
                    Text('APPLY',
                        style: TextStyle(
                            color: Colors.pink, fontWeight: FontWeight.w900))
                  ])) //Row
        ]) //Column
        ); //Scaffold
  }
}


