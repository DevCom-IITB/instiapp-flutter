import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:instiapp/src/api/model/placementblogpost.dart';
import 'package:instiapp/src/api/model/user.dart';
import 'package:instiapp/src/bloc_provider.dart';
import 'package:instiapp/src/drawer.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class PlacementBlogPage extends StatefulWidget {
  @override
  _PlacementBlogPageState createState() => _PlacementBlogPageState();
}

class _PlacementBlogPageState extends State<PlacementBlogPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;

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
              Text("Placement Blog",
                  style: theme.textTheme.headline
                      .copyWith(fontFamily: "Bitter", color: Colors.white)),
            ],
          ),
        ),
        drawer: DrawerOnly(key: bloc.drawerKey),
        body: StreamBuilder(
          stream: bloc.session,
          builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              bloc.updatePlacementBlogPosts();
              return StreamBuilder(
                stream: bloc.placementBlog,
                builder: (BuildContext context,
                    AsyncSnapshot<UnmodifiableListView<PlacementBlogPost>>
                        snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      children: snapshot.data.map(buildPlacementPost).toList(),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: theme.accentColor,
                      ),
                    );
                  }
                },
              );
            } else {
              return Center(
                child: Text(
                  "You must be logged in to view Placement Blog",
                  style: theme.textTheme.title,
                  textAlign: TextAlign.center,
                ),
              );
            }
          },
        ));
  }

  Widget buildPlacementPost(PlacementBlogPost post) {
    var theme = Theme.of(context);
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: <Widget>[
          Text(
            post.title,
            style: theme.textTheme.subhead,
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            post.content,
            style: theme.textTheme.subtitle,
          ),
        ],
      ),
    ));
  }
}
