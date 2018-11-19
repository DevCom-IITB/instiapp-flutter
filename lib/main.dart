import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instiapp/src/json_parsing.dart';
import 'package:instiapp/src/mess.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Hostel> hostels = parseMess(hostelsJsonString);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: hostels.map(_buildItem).toList(),
        // physics: BouncingScrollPhysics(),
      ),
    );
  }

  Widget _buildItem(Hostel hostel) {
    return Center(
      child: ListTile(
        hostel.id,
        title: Text(
          hostel.long_name,
          style: Theme.of(context).textTheme.title,
        ),
        subtitle: Text(
          hostel.name,
          style: Theme.of(context).textTheme.subtitle,
        ),
        onTap: _launchURL,
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
