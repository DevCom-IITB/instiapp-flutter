import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instiapp/src/api/model/user.dart';
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
  final Session _session;
  MyHomePage(this._session, {Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState(_session);
}

class _MyHomePageState extends State<MyHomePage> {
  String currHostel = '1';
  InstiAppBloc _bloc;
  Session session;

  _MyHomePageState(this.session);

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _bloc = InstiAppBloc(currSession: session);
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
        drawer: buildDrawer(context),
        body: StreamBuilder<UnmodifiableListView<Hostel>>(
          stream: _bloc.hostels,
          builder: (BuildContext context,
              AsyncSnapshot<UnmodifiableListView<Hostel>> hostels) {
            currHostel = _bloc.currSession.sessionid == null
                ? "1"
                : _bloc.currSession.profile.hostel;
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
      ),
    );
  }

  StreamBuilder<Session> buildDrawer(BuildContext context) {
    return StreamBuilder<Session>(
      stream: _bloc.session,
      initialData: Session(),
      builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
        var theme = Theme.of(context);
        var textTheme =
            theme.textTheme.subhead.copyWith(fontWeight: FontWeight.bold);
        var navList = <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              child: Icon(OMIcons.person),
            ),
            accountName: Text(
              snapshot.data.sessionid != null
                  ? snapshot.data.profile.name
                  : 'Not Logged in',
              style: theme.textTheme.body1
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            accountEmail: snapshot.data.sessionid != null
                ? Text(snapshot.data.profile.rollNo,
                    style: theme.textTheme.body1.copyWith(color: Colors.white))
                : RaisedButton(
                    child: Text("Log in"),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                  ),
            decoration: BoxDecoration(
              color: theme.accentColor,
            ),
          ),
          ListTile(
            leading: Icon(OMIcons.dashboard),
            title: Text(
              "Feed",
              style: textTheme,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.rssFeed),
            title: Text(
              "News",
              style: textTheme,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.search),
            title: Text(
              "Explore",
              style: textTheme,
            ),
            onTap: () {},
          ),
          ListTile(
            selected: true,
            leading: Icon(OMIcons.restaurant),
            title: Text(
              "Mess Menu",
              style: textTheme,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.workOutline),
            title: Text(
              "Placement Blog",
              style: textTheme,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.workOutline),
            title: Text(
              "Internship Blog",
              style: textTheme,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.dateRange),
            title: Text(
              "Calender",
              style: textTheme,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.map),
            title: Text(
              "Map",
              style: textTheme,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.feedback),
            title: Text(
              "Complaints/Suggestions",
              style: textTheme,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.link),
            title: Text(
              "Quick Links",
              style: textTheme,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(OMIcons.settings),
            title: Text(
              "Settings",
              style: textTheme,
            ),
            onTap: () {},
          ),
        ];
        if (snapshot.data.sessionid != null) {
          navList.add(ListTile(
            leading: Icon(OMIcons.exitToApp),
            title: Text(
              "Logout",
              style: textTheme,
            ),
            onTap: () {},
          ));
        }
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: navList,
          ),
        );
      },
    );
  }

  Widget buildDropdownButton() {
    return StreamBuilder<UnmodifiableListView<Hostel>>(
      stream: _bloc.hostels,
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
