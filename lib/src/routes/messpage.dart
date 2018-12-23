import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:scrollable_bottom_sheet/scrollable_bottom_sheet.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:InstiApp/src/api/model/mess.dart';

import 'dart:collection';

class MessPage extends StatefulWidget {
  MessPage({Key key}) : super(key: key);

  @override
  _MessPageState createState() => _MessPageState();
}

class _MessPageState extends State<MessPage> {
  String currHostel = "0";

  _MessPageState();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _bottomSheetActive = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;

    bloc.updateHostels();

    var footerButtons = [
      buildDropdownButton(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              tooltip: "Show bottom sheet",
              icon: Icon(
                OMIcons.menu,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: _bottomSheetActive
                  ? null
                  : () {
                      setState(() {
                        //disable button
                        _bottomSheetActive = true;
                      });
                      _scaffoldKey.currentState
                          .showBottomSheet((context) {
                            // BottomDrawer.setPageIndex(bloc, 3);
                            return BottomDrawer();
                          })
                          .closed
                          .whenComplete(() {
                            setState(() {
                              _bottomSheetActive = false;
                            });
                          });
                    },
            ),
          ],
        ),
      ),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        foregroundDecoration: _bottomSheetActive
            ? BoxDecoration(
                color: Color.fromRGBO(100, 100, 100, 12),
              )
            : null,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Mess Menu",
                    style: theme.textTheme.display2
                        .copyWith(color: Colors.black, fontFamily: "Bitter"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: StreamBuilder<UnmodifiableListView<Hostel>>(
                stream: bloc.hostels,
                builder: (BuildContext context,
                    AsyncSnapshot<UnmodifiableListView<Hostel>> hostels) {
                  if (currHostel == "0")
                    currHostel = bloc.currSession?.profile?.hostel ?? "1";
                  if (hostels.hasData) {
                    var currMess = hostels.data
                        .firstWhere((h) => h.shortName == currHostel)
                        .mess
                      ..sort((h1, h2) => h1.compareTo(h2));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: currMess.map(_buildSingleDayMess).toList(),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: theme.accentColor,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      persistentFooterButtons: footerButtons,
    );
  }

  Widget buildDropdownButton() {
    var bloc = BlocProvider.of(context).bloc;
    return StreamBuilder<UnmodifiableListView<Hostel>>(
      stream: bloc.hostels,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DropdownButton<int>(
            value: snapshot.data.indexWhere((h) => h.shortName == currHostel),
            items: snapshot.data
                .asMap()
                .entries
                .map((entry) => DropdownMenuItem<int>(
                      child: Text(entry.value.name),
                      value: entry.key,
                    ))
                .toList(),
            onChanged: (h) {
              setState(() {
                currHostel = snapshot.data[h].shortName;
              });
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildSingleDayMess(HostelMess mess) {
    var localTheme = Theme.of(context).textTheme;
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            mess.getDayName(),
            style: localTheme.display1,
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Breakfast",
            style: localTheme.headline,
          ),
          ContentText(mess.breakfast, context),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Lunch",
            style: localTheme.headline,
          ),
          ContentText(mess.lunch, context),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Snacks",
            style: localTheme.headline,
          ),
          ContentText(mess.snacks, context),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Dinner",
            style: localTheme.headline,
          ),
          ContentText(mess.dinner, context),
          SizedBox(
            height: 8.0,
          ),
          Divider(
            height: 16.0,
          ),
        ],
      ),
    );
  }
}

class ContentText extends Text {
  ContentText(String data, BuildContext context)
      : super(data, style: Theme.of(context).textTheme.subhead);
}
