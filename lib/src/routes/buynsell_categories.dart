import 'package:flutter/material.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';

import '../utils/title_with_backbutton.dart';

double screen_h = 0, screen_w = 0;

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
    );
  }
}
