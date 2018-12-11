import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:instiapp/src/api/model/placementblogpost.dart';
import 'package:instiapp/src/api/model/user.dart';
import 'package:instiapp/src/bloc_provider.dart';
import 'package:instiapp/src/blocs/placement_bloc.dart';
import 'package:instiapp/src/drawer.dart';
import 'package:instiapp/src/blocs/ia_bloc.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';

class PlacementBlogPage extends StatefulWidget {
  @override
  _PlacementBlogPageState createState() => _PlacementBlogPageState();
}

class _PlacementBlogPageState extends State<PlacementBlogPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  ScrollController _hideButtonController;

  double isFabVisible = 0;
  @override
  void initState() {
    super.initState();

    _hideButtonController = ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection == ScrollDirection.reverse && isFabVisible == 1) {
        setState(() {
          isFabVisible = 0;
        });
      } else if(_hideButtonController.position.userScrollDirection == ScrollDirection.forward && isFabVisible == 0) {
        setState(() {
          isFabVisible = 1;
        });
      }
    });
  }

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
            return StreamBuilder(
              stream: bloc.placementBloc.placementBlog,
              builder: (BuildContext context,
                  AsyncSnapshot<UnmodifiableListView<PlacementBlogPost>>
                      snapshot) {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    return buildPlacementPost(
                        bloc.placementBloc, index, snapshot.data);
                  },
                  itemCount:
                      (snapshot.data == null ? 0 : snapshot.data.length) + 20,
                  controller: _hideButtonController,
                );
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
      ),
      floatingActionButton: Opacity(
        opacity: isFabVisible,
        child: FloatingActionButton(
          onPressed: () {
            _hideButtonController.animateTo(0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300));
            setState(() {
                          isFabVisible = 0.0;
                        });
          },
          child: Icon(OMIcons.arrowUpward),
        ),
      ),
    );
  }

  Widget buildPlacementPost(
      PlacementBlogBloc bloc, int index, List<PlacementBlogPost> posts) {
    bloc.inPostIndex.add(index);

    final PlacementBlogPost post =
        (posts != null && posts.length > index) ? posts[index] : null;

    if (post == null) {
      return Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ));
    }

    return placementPost(post);
  }

  Widget placementPost(PlacementBlogPost post) {
    var theme = Theme.of(context);
    return Card(
        key: ValueKey(post.postID),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                post.title,
                textAlign: TextAlign.start,
                style: theme.textTheme.headline,
              ),
              Text(
                post.published,
                textAlign: TextAlign.start,
                style: theme.textTheme.body1,
              ),
              SizedBox(
                height: 8.0,
              ),
              Html(
                data: post.content,
                defaultTextStyle: theme.textTheme.subhead,
                onLinkTap: (link) async {
                  print(link);
                  if (await canLaunch(link)) {
                    await launch(link);
                  } else {
                    throw "Couldn't launch $link";
                  }
                },
              ),
            ],
          ),
        ));
  }
}
