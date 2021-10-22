import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({Key key}) : super(key: key);

  @override
  _QueryPageState createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      bottomNavigationBar: MyBottomAppBar(
        shape: RoundedNotchedRectangle(),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              tooltip: "Show bottom sheet",
              icon: Icon(
                Icons.menu_outlined,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }
}
