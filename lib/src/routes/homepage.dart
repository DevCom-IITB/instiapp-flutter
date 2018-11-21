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

  @override
  void initState() {
    super.initState();
    globalClient = IOClient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Hostel>>(
        builder: (BuildContext context, AsyncSnapshot<List<Hostel>> hostels) {
          if (hostels.hasData) {
            return GridView(
              children: hostels.data.map(_buildItem).toList(),
              physics: BouncingScrollPhysics(),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              scrollDirection: Axis.horizontal,
              controller: TrackingScrollController(),
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

  Widget _buildItem(Hostel hostel) {
    return Center(
      child: GridTile(
        footer: GridTileBar(
            title: Text(
              hostel.longName,
              style: Theme.of(context).textTheme.title,
            ),
            subtitle: Text(
              hostel.name,
              style: Theme.of(context).textTheme.subtitle,
            )),
        child: Center(child: Text(hostel.id)),
        // onTap: _launchURL,
      ),
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
