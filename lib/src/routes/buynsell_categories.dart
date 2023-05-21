import 'package:flutter/material.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';

import '../utils/title_with_backbutton.dart';

class ScreenArguments {
  final String title;
  ScreenArguments(this.title);
}

// widget for generic category button
class CategoryButton extends StatelessWidget {
  final String name;
  CategoryButton(this.name);

  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              "/buyandsell/createPost",
              arguments: ScreenArguments(
                name,
              ),
            );
          },
          child: Column(
            children: [
              Image.asset('assets/buynsell/' + name + '.png'),
              Text(
                name,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//widget for category page
class BuyAndSellCategoryPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  BuyAndSellCategoryPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
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
        child: Flexible(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 45.0, 0, 10),
                  child: Row(
                    children: [
                      Center(
                        child: TitleWithBackButton(
                          child: Text(
                            "Choose Category",
                            style: theme.textTheme.headline4,
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
                      CategoryButton("Electronics"),
                      CategoryButton("Stationary"),
                      CategoryButton("Bicycle")
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CategoryButton("Books"),
                      CategoryButton("Daily Needs"),
                      CategoryButton("Acessories")
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CategoryButton("Sports"),
                      CategoryButton("Miscellaneous"),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

class Buyandsell_information extends StatelessWidget {
  const Buyandsell_information({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screen_wr = MediaQuery.of(context).size.width;
    double screen_hr = MediaQuery.of(context).size.height;
    double x, y;

    var theme = Theme.of(context);

    screen_hr >= screen_wr ? x = 0.35 : x = 1.1;
    screen_hr >= screen_wr ? y = 0.9 : y = 0.9;
    double screen_w = screen_wr * y;
    double screen_h = screen_hr * x;
    double myfont = ((15 / 274.4) * screen_h);

    return Scaffold(
      bottomNavigationBar: MyBottomAppBar(
        shape: RoundedNotchedRectangle(),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu_outlined,
                color: Colors.blue.withOpacity(0),
                semanticLabel: "Show navigation drawer",
              ),
              onPressed: () {
                // _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            padding: EdgeInsets.only(top: 32, left: 16),
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.only(top: 32, left: 16),
              alignment: Alignment.topLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blueAccent,
                    width: 2.0,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_outlined,
                      color: Colors.blueAccent),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(screen_w * 0.1, 15, 0, 0),
                child: SizedBox(
                  height: screen_h / 1.5,
                  width: screen_w / 1.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        topLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25)),
                    child: Card(
                      child: Image.network(
                        'https://images.unsplash.com/photo-1684489453425-c6234e0b7850?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2940&q=80',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(screen_w * 0.1, 6, 0, 0),
                  child: Text(
                    "Brand Name",
                    style: TextStyle(
                        fontSize: myfont / 1.3, fontWeight: FontWeight.w100),
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(screen_w * 0.1, 5, 0, 0),
                  child: Text(
                    "Name of product",
                    style: TextStyle(
                        fontSize: myfont * 1.5, fontWeight: FontWeight.w700),
                  )),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              margin: EdgeInsets.fromLTRB(screen_w * 0.1, 5, 0, 0),
              child: Text(
                "Condition here",
                style: TextStyle(fontSize: myfont, fontWeight: FontWeight.w100),
              ),
            )
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              width: screen_w * 0.9,
              margin: EdgeInsets.fromLTRB(screen_w * 0.1, 8, 0, 0),
              child: Text(
                "shfsbfj,sbfkbsdklvhjasbglfadlfahlfhahfsajhdsjhfakshdsjfhakfjhkasjfhksjhfakfhaskfhajkskfbjsbvksfvjbsdfkbsaefadjbfkfsejfhaefhjaekhfkajfkjanfkbakjfkhajwdwakhdajwdhkawhdjabfkafdhjabkefbaefbakwdkwahbdjabdkbajdkbdfjsko",
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                    fontSize: myfont * 0.75, fontWeight: FontWeight.w100),
              ),
            ),
          ]),
          Row(
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(screen_w * 0.1, 8, 0, 0),
                  child: Text(
                    "Contact Details:\n",
                    style: TextStyle(
                        fontSize: myfont, fontWeight: FontWeight.w600),
                  )),
              Container(
                  margin: EdgeInsets.fromLTRB(screen_w * 0.3, 8, 0, 0),
                  child: Column(
                    children: [
                      Text(
                        "Negotiable",
                        style: TextStyle(
                            fontSize: myfont, fontWeight: FontWeight.w500),
                      ),Text(
                        "Price",
                        style: TextStyle(
                            fontSize: myfont*1.5, fontWeight: FontWeight.w800),
                      )
                    ],
                  ))
            ],
          )

          // Add more widgets below the image card
        ]),
      ),
    );
  }
}
