import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:InstiApp/src/api/model/trainingblogpost.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/training_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;

class TrainingBlogPage extends StatefulWidget {
  @override
  _TrainingBlogPageState createState() => _TrainingBlogPageState();
}

class _TrainingBlogPageState extends State<TrainingBlogPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  ScrollController _hideButtonController;
  double isFabVisible = 0;

  bool searchMode = false;

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
            icon: Icon(searchMode ? OMIcons.close : OMIcons.search),
            onPressed: () {
              setState(() {
                if (searchMode) {
                  bloc.trainingBloc.query = "";
                  bloc.trainingBloc.refresh();
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
            Text("Internship Blog",
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
                    if (query.length >= 4) {
                      bloc.trainingBloc.query = query;
                      await bloc.trainingBloc.refresh();
                    }
                  },
                  onSubmitted: (query) async {
                    bloc.trainingBloc.query = query;
                    await bloc.trainingBloc.refresh();
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
              stream: bloc.trainingBloc.trainingBlog,
              builder: (BuildContext context,
                  AsyncSnapshot<UnmodifiableListView<TrainingBlogPost>>
                      snapshot) {
                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return buildTrainingPost(
                          bloc.trainingBloc, index, snapshot.data);
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
                "You must be logged in to view Training Blog",
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
    return bloc.trainingBloc.refresh();
  }

  Widget buildTrainingPost(
      TrainingBlogBloc bloc, int index, List<TrainingBlogPost> posts) {
    bloc.inPostIndex.add(index);

    final TrainingBlogPost post =
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

    return trainingPost(post);
  }

  Widget trainingPost(TrainingBlogPost post) {
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
