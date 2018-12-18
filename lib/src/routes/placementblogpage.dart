import 'dart:core';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:InstiApp/src/api/model/placementblogpost.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/placement_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;

class PlacementBlogPage extends StatefulWidget {
  @override
  _PlacementBlogPageState createState() => _PlacementBlogPageState();
}

class _PlacementBlogPageState extends State<PlacementBlogPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  ScrollController _hideButtonController;
  double isFabVisible = 0;

  bool searchMode = false;
  IconData actionIcon = OMIcons.search;

  @override
  void initState() {
    super.initState();

    _hideButtonController = ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
              ScrollDirection.reverse &&
          isFabVisible == 1) {
        setState(() {
          isFabVisible = 0;
        });
      } else if (_hideButtonController.position.userScrollDirection ==
              ScrollDirection.forward &&
          isFabVisible == 0) {
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
        actions: <Widget>[
          IconButton(
            icon: Icon(actionIcon),
            onPressed: () {
              setState(() {
                if (searchMode) {
                  actionIcon = OMIcons.search;
                  bloc.placementBloc.query = "";
                  bloc.placementBloc.refresh();
                } else {
                  actionIcon = OMIcons.close;
                }

                searchMode = !searchMode;
              });
            },
          )
        ],
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
        bottom: searchMode
            ? PreferredSize(
                preferredSize: Size.fromHeight(48.0),
                child: TextField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                      prefixIcon: Icon(OMIcons.search, color: Colors.white),
                      hintText: "Search...",
                      hintStyle: TextStyle(color: Colors.white)),
                  onChanged: (query) async {
                    if (query.length > 4) {
                      bloc.placementBloc.query = query;
                      bloc.placementBloc.refresh();
                    }
                  },
                  onSubmitted: (query) async {
                    bloc.placementBloc.query = query;
                    await bloc.placementBloc.refresh();
                  },
                ),
              )
            : null,
      ),
      drawer: DrawerOnly(),
      body: StreamBuilder(
        stream: bloc.session,
        builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return StreamBuilder(
              stream: bloc.placementBloc.placementBlog,
              builder: (BuildContext context,
                  AsyncSnapshot<UnmodifiableListView<PlacementBlogPost>>
                      snapshot) {
                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return buildPlacementPost(
                          bloc.placementBloc, index, snapshot.data);
                    },
                    itemCount:
                        (snapshot.data == null ? 0 : snapshot.data.length) + 1,
                    controller: _hideButtonController,
                  ),
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
                curve: Curves.fastOutSlowIn,
                duration: const Duration(milliseconds: 600));
            setState(() {
              isFabVisible = 0.0;
            });
          },
          child: Icon(OMIcons.keyboardArrowUp),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() {
    var bloc = BlocProvider.of(context).bloc;
    return bloc.placementBloc.refresh();
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
                customRender: (node, children) {
                  if (node is dom.Element) {
                    switch (node.localName) {
                      case "img":
                        return Text(node.attributes['href'] ?? "<img>");
                    }
                  }
                },
              ),
            ],
          ),
        ));
  }
}
