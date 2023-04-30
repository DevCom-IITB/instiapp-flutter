import 'package:flutter/material.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/blocs/buynsell_post_block.dart';

import '../api/model/buynsellPost.dart';
import '../bloc_provider.dart';

class BuyAndSellInfoPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    BuynSellPostBloc buynSellPostBloc =
        BlocProvider.of(context)!.bloc.buynSellPostBloc;

    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;
    double myfont = ((18 / 274.4) * screen_h);

    return Container(
      child: Center(
        child: StreamBuilder<BuynSellPost>(
            stream: buynSellPostBloc.buynsellpost,
            builder:
                (BuildContext context, AsyncSnapshot<BuynSellPost> snapshot) {
              return ListView.builder(
                itemBuilder: (_, index) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicatorExtended(
                      label: Text("Loading..."),
                    ));
                  }
                  return _buildContent(
                      screen_h, screen_w, index, myfont, context, snapshot);
                },
              );
            }),
      ),
    );
  }

  Center _buildContent(double screen_h, double screen_w, int index,
      double myfont, BuildContext context, AsyncSnapshot snapshot) {
    return Center(
        child: Scaffold(
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
            body: SafeArea(
              child: Column(children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Padding(padding: EdgeInsets.fromLTRB(10, 80, 20, 20)),
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("/buyandsell");
                        },
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.black,
                        ),
                        backgroundColor: Colors.white,
                      )
                    ],
                  ),
                ), //Row
                Expanded(
                    flex: 6,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(25, 30, 25, 10),
                        child: Image.network(""))),
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
