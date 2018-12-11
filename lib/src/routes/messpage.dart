import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instiapp/src/bloc_provider.dart';
import 'package:instiapp/src/blocs/ia_bloc.dart';
import 'package:instiapp/src/drawer.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:instiapp/src/api/model/mess.dart';

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

  @override
  void initState() {
    super.initState();     
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;
    
    bloc.updateHostels();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            OMIcons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        title: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ImageIcon(
                AssetImage('assets/lotus.png'),
                color: Colors.white,
              ),
            ),
            Text("Mess",
                style: theme.textTheme.headline
                    .copyWith(fontFamily: "Bitter", color: Colors.white)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.white,
            height: 48.0,
            padding: EdgeInsets.only(left: 16.0),
            alignment: Alignment.centerLeft,
            child: buildDropdownButton(),
          ),
        ),
      ),
      drawer: DrawerOnly(key: InstiAppBloc.drawerKey),
      body: StreamBuilder<UnmodifiableListView<Hostel>>(
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
            return ListView(
              children: currMess.map(_buildSingleDayMess).toList(),
              // children: <Widget>[],
              physics: BouncingScrollPhysics(),
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
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(12.0),
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
            ],
          )),
    );
  }

  _launchURL() async {
    const url = 'https://flutter.io';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class ContentText extends Text {
  ContentText(String data, BuildContext context)
      : super(data, style: Theme.of(context).textTheme.subhead);
}
