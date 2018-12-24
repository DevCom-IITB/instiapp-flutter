import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

class BodyPage extends StatefulWidget {
  final Future<Body> _bodyFuture;

  BodyPage(this._bodyFuture);

  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Body body;

  int loadingUes = 0;

  bool _bottomSheetActive = false;

  @override
  void initState() {
    super.initState();
    body = null;
    widget._bodyFuture.then((b) {
      setState(() {
        body = b;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;
    var footerButtons = <Widget>[];
    if (body != null) {
      // footerButtons.addAll([
      // buildUserStatusButton("Going", 2, theme, bloc),
      // buildUserStatusButton("Interested", 1, theme, bloc),
      // ]);

      if ((body.bodyWebsiteURL ?? "") != "") {
        footerButtons.add(IconButton(
          tooltip: "Open website",
          icon: Icon(OMIcons.language),
          onPressed: () async {
            if (await canLaunch(body.bodyWebsiteURL)) {
              await launch(body.bodyWebsiteURL);
            }
          },
        ));
      }
    }
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
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
      body: body == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        body.bodyName,
                        style: theme.textTheme.display2.copyWith(
                            color: Colors.black, fontFamily: "Bitter"),
                      ),
                      SizedBox(height: 8.0),
                      Text(body.bodyShortDescription,
                          style: theme.textTheme.title),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(body.bodyImageURL, fit: BoxFit.fitWidth),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 16.0),
                  child: Text(
                    body.bodyDescription,
                    style: theme.textTheme.subhead,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Divider(),
              ]
                ..addAll(body.bodyParents
                    .map((b) => _buildBodyTile(b, theme.textTheme))
                    .toList()
                      ..insert(
                          0, Text("Part of", style: theme.textTheme.subhead)))
                ..addAll([
                  Divider(),
                  SizedBox(
                    height: 64.0,
                  )
                ]),
            ),

      floatingActionButton: _bottomSheetActive || body == null
          ? null
          : FloatingActionButton(
              child: Icon(OMIcons.share),
              tooltip: "Share this body",
              onPressed: () async {
                await Share.share(
                    "Check this Institute Body: ${ShareURLMaker.getBodyURL(body)}");
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      persistentFooterButtons: footerButtons,
    );
  }

  Widget _buildBodyTile(Body body, TextTheme theme) {
    return ListTile(
      title: Text(body.bodyName, style: theme.title),
      subtitle: Text(body.bodyShortDescription, style: theme.subtitle),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(body.bodyImageURL),
      ),
      onTap: () {
        Navigator.of(context).pushNamed("/body/${body.bodyID}");
      },
    );
  }
}
