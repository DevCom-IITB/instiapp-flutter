import 'package:flutter/material.dart';



class CategoryPage extends StatelessWidget {
  @override
  const CategoryPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ////////////////////////////////////////////////////////////////////////
      appBar: AppBar(
        title: Text("Buy N Sell/ Lost N Found"),

        leading: GestureDetector(
          onTap: () {
            /* Write listener code here */ },
          child: Icon(
            Icons.menu_rounded,  // add custom icons also
          ),
        ),

        actions: <Widget>[
          GestureDetector(
            onTap: () {/* Write listener code here */ },
            child: Padding(
              padding: EdgeInsets.only(right: 0.0),
              child: Icon(Icons.filter_list)
            ),
          ),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {/* Write listener code here */ },
                child: Icon(
                  Icons.search,
                  size: 26.0,
                ),
              )
          ),

        ],
        backgroundColor: Colors.indigo,
      ),
      ///////////////////////////////////////////////////////////////////////

      body:
      Column (
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children : <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 14.0),
              child: Row(
                children : <Widget>[
                  FlatButton.icon(
                    onPressed: (){},
                    icon: Icon(Icons.arrow_back_ios_rounded),
                    label : Text(""),
                  ),
                  //Icon(Icons.arrow_back_ios_new_sharp),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(45.0, 0.0, 0.0, 60.0),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      onPressed: (){},
                      //color : Colors.amber,
                      child: Image.asset('assets/buy&sell/Group 10799.png'),

                    ),
                  ),

                  Expanded(
                    child: FlatButton(
                        onPressed: (){},
                        //color : Colors.amber,
                        child: Image.asset('assets/buy&sell/Group 10800.png')
                    ),
                  ),

                  Expanded(
                    child: FlatButton(
                        onPressed: (){},
                        //color : Colors.amber,
                        child: Image.asset('assets/buy&sell/Group 10801.png')
                    ),
                  ),
                ],
              ),


            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("            Electronics"),
                  Text("                  Stationary"),
                  Text("                      Bicycle"),

                ],

              ),
            ),


            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row (
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Expanded(
                    child: FlatButton(
                        onPressed: (){},
                        //color : Colors.amber,
                        child: Image.asset('assets/buy&sell/Group 10802.png')
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                        onPressed: (){},
                        //color : Colors.amber,
                        child: Image.asset('assets/buy&sell/Group 10803.png')
                    ),
                  ),

                  Expanded(
                    child: FlatButton(
                        onPressed: (){},
                        //color : Colors.amber,
                        child: Image.asset('assets/buy&sell/Group 10804.png')
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("                Books"),
                  Text("                     Daily Needs"),
                  Text("                 Acessories"),

                ],

              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row (
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  FlatButton(
                    onPressed: (){},
                    child: Expanded(
                      child: Image.asset('assets/buy&sell/Group 10805.png'),
                    ),
                  ),
                  FlatButton(
                    onPressed: (){},
                    child: Expanded(
                      child: Image.asset('assets/buy&sell/Group 10806.png'),
                    ),
                  ),


                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("                Sports"),
                Text("                    Miscellaneous"),
                //Text("Bicycle"),

              ],

            ),



          ]
      ),
//
    );
  }
}
