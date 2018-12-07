import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instiapp/src/ia_bloc.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:instiapp/src/api/model/mess.dart';

import 'dart:collection';

class BlocProvider extends InheritedWidget {
  final InstiAppBloc bloc;

  BlocProvider(this.bloc, {child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

  static BlocProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(BlocProvider);
  }
}

class MyHomePage extends StatefulWidget {
  final String title = "InstiApp";
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int hostelIndex = 3;
  InstiAppBloc _bloc;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _bloc = InstiAppBloc();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return BlocProvider(
      _bloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(OMIcons.menu, color: Colors.white,),
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
        drawer: buildDrawer(context),
        body: StreamBuilder<UnmodifiableListView<Hostel>>(
          stream: _bloc.hostels,
          builder: (BuildContext context,
              AsyncSnapshot<UnmodifiableListView<Hostel>> hostels) {
            if (hostels.hasData) {
              hostels.data[hostelIndex].mess.sort((h1, h2) => h1.compareTo(h2));
              return ListView(
                children: hostels.data[hostelIndex].mess
                    .map(_buildSingleDayMess)
                    .toList(),
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
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    var theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              child: Icon(OMIcons.person),
            ),
            accountName: Text(
              _bloc.loggedIn ? 'Name Goes Here' : 'Not Logged in',
              style: theme.textTheme.body1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              _bloc.loggedIn ? 'ID goes here' : "",
              style: theme.textTheme.body1.copyWith(color: Colors.white),
            ),
            decoration: BoxDecoration(
              color: theme.accentColor,
            ),
          ),
          ListTile(
            leading: Icon(OMIcons.dashboard),
            title: Text(
              "Feed",
              style: theme.textTheme.title,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.rssFeed),
            title: Text(
              "News",
              style: theme.textTheme.title,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.search),
            title: Text(
              "Explore",
              style: theme.textTheme.title,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.restaurant),
            title: Text(
              "Mess Menu",
              style: theme.textTheme.title,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.workOutline),
            title: Text(
              "Placement Blog",
              style: theme.textTheme.title,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.workOutline),
            title: Text(
              "Internship Blog",
              style: theme.textTheme.title,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.dateRange),
            title: Text(
              "Calender",
              style: theme.textTheme.title,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.map),
            title: Text(
              "Map",
              style: theme.textTheme.title,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.feedback),
            title: Text(
              "Complaints/Suggestions",
              style: theme.textTheme.title,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.link),
            title: Text(
              "Quick Links",
              style: theme.textTheme.title,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.settings),
            title: Text(
              "Settings",
              style: theme.textTheme.title,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget buildDropdownButton() {
    return StreamBuilder<UnmodifiableListView<Hostel>>(
      stream: _bloc.hostels,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DropdownButton<int>(
            value: hostelIndex,
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
                hostelIndex = h;
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
