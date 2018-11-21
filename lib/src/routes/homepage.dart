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
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ImageIcon(AssetImage('assets/lotus.png'), color: Colors.white,),
        ),
        title: Text("Mess",
            style: Theme.of(context).textTheme.headline.copyWith(
                fontFamily: "Bitter", color: Colors.white)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Theme(
            data: Theme.of(context).copyWith(
                textTheme: TextTheme(button: TextStyle(color: Colors.white))),
            child: Container(
              height: 48.0,
              alignment: Alignment.center,
              child: DropdownButton(
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
      ),
      body: FutureBuilder<List<Hostel>>(
        builder: (BuildContext context, AsyncSnapshot<List<Hostel>> hostels) {
          if (hostels.hasData) {
            return ListView(
              children: hostels.data[3].mess.map(_buildSingleDayMess).toList(),
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
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                mess.getDayName(),
                style: Theme.of(context).textTheme.display1,
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                "Breakfast",
                style: Theme.of(context).textTheme.headline,
              ),
              ContentText(mess.breakfast, context),
              SizedBox(
                height: 8.0,
              ),
              Text(
                "Lunch",
                style: Theme.of(context).textTheme.headline,
              ),
              ContentText(mess.lunch, context),
              SizedBox(
                height: 8.0,
              ),
              Text(
                "Snacks",
                style: Theme.of(context).textTheme.headline,
              ),
              ContentText(mess.snacks, context),
              SizedBox(
                height: 8.0,
              ),
              Text(
                "Dinner",
                style: Theme.of(context).textTheme.headline,
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
