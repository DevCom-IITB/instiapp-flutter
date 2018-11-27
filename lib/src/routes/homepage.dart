import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:instiapp/src/api/apiclient.dart';
import 'package:jaguar_retrofit/jaguar_retrofit.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:instiapp/src/api/model/mess.dart';
import 'package:instiapp/src/json_parsing.dart';

class MyHomePage extends StatefulWidget {
  final String title = "InstiApp";
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final client = InstiAppApi();

  int hostelIndex;

  @override
  void initState() {
    super.initState();
    globalClient = IOClient();
    hostelIndex = 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ImageIcon(AssetImage('assets/lotus.png'), color: Colors.white,),
        ),
        title: Text("Mess",
            style: Theme.of(context).textTheme.headline.copyWith(
                fontFamily: "Bitter", color: Colors.white)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.white,
            height: 48.0,
            padding: EdgeInsets.only(left: 16.0),
            alignment: Alignment.centerLeft,
            child: DropdownButton(
              hint: Text("Hostel"),
              items: [
                DropdownMenuItem(
                  child: Text("H1"),
                ),
              ],
              onChanged: (a) {},
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Hostel>>(
        builder: (BuildContext context, AsyncSnapshot<List<Hostel>> hostels) {
          if (hostels.hasData) {
            return ListView(
              children: (hostels.data[hostelIndex].mess
                        ..sort((h1, h2) => h1.compareTo(h2)))
                        .map(_buildSingleDayMess).toList(),
              physics: BouncingScrollPhysics(),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).accentColor,
              ),
            );
          }
        },
        future: client.getSortedHostelMess(),
      ),
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
