import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
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
  bool firstBuild = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;

    if (firstBuild) {
      bloc.updateHostels();
      firstBuild = false;
    }

    var footerButtons = <Widget>[
      buildDropdownButton(theme),
    ];

    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: MyBottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              tooltip: "Show navigation drawer",
              icon: Icon(
                OMIcons.menu,
                semanticLabel: "Show navigation drawer",
              ),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
          ],
        ),
      ),
      drawer: NavDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => bloc.updateHostels(),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Mess Menu",
                      style: theme.textTheme.display2,
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
                        child: CircularProgressIndicatorExtended(
                          label: Text("Loading mess menu"),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: footerButtons,
    );
  }

  Widget buildDropdownButton(ThemeData theme) {
    var bloc = BlocProvider.of(context).bloc;
    return StreamBuilder<UnmodifiableListView<Hostel>>(
      stream: bloc.hostels,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var val = snapshot.data.indexWhere((h) => h.shortName == currHostel);
          return DropdownButton<int>(
            value: val != -1 ? val : null,
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
          return SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(theme.accentColor),
              strokeWidth: 2,
            ),
          );
        }
      },
    );
  }

  Widget _buildSingleDayMess(HostelMess mess) {
    var theme = Theme.of(context);
    var localTheme = theme.textTheme;
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            mess.getDayName(),
            style: localTheme.headline.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Breakfast",
            style: localTheme.title.copyWith(color: theme.accentColor),
          ),
          ContentText(mess.breakfast, context),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Lunch",
            style: localTheme.title.copyWith(color: theme.accentColor),
          ),
          ContentText(mess.lunch, context),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Snacks",
            style: localTheme.title.copyWith(color: theme.accentColor),
          ),
          ContentText(mess.snacks, context),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Dinner",
            style: localTheme.title.copyWith(color: theme.accentColor),
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
