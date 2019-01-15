import 'dart:core';
import 'dart:collection';

import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:InstiApp/src/api/model/post.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter/foundation.dart';

class BlogPage extends StatefulWidget {
  final String title;
  final PostType postType;
  final bool loginNeeded;

  BlogPage({@required this.postType, this.title, this.loginNeeded = true});

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  ScrollController _hideButtonController;
  bool _bottomSheetActive = false;
  double isFabVisible = 0;

  bool searchMode = false;
  IconData actionIcon = OMIcons.search;

  bool firstBuild = true;

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
    var blogBloc = bloc.getPostsBloc(widget.postType);

    if (firstBuild) {
      blogBloc.query = "";
      blogBloc.refresh();
      firstBuild = false;
    }

    var footerButtons = searchMode
        ? [
            Expanded(
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(OMIcons.search),
                  hintText: "Search...",
                ),
                onChanged: (query) async {
                  if (query.length > 4) {
                    blogBloc.query = query;
                    blogBloc.refresh();
                  }
                },
                onSubmitted: (query) async {
                  blogBloc.query = query;
                  await blogBloc.refresh();
                },
              ),
            ),
          ]
        : null;

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      key: _scaffoldKey,
      drawer: BottomDrawer(),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            searchMode
                ? Container(
                    decoration: BoxDecoration(
                      color: theme.bottomAppBarColor,
                      border: Border(
                        top: Divider.createBorderSide(context, width: 1.0),
                      ),
                    ),
                    child: SafeArea(
                      child: ButtonTheme.bar(
                        child: SafeArea(
                          top: false,
                          child: Row(children: footerButtons),
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 0,
                    height: 0,
                  ),
            BottomAppBar(
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    tooltip: "Show bottom sheet",
                    icon: Icon(
                      OMIcons.menu,
                      semanticLabel: "Show bottom sheet",
                    ),
                    onPressed: _bottomSheetActive
                        ? null
                        : () {
                            BottomDrawer.setPageIndex(
                                bloc,
                                {
                                  PostType.Placement: 4,
                                  PostType.Training: 5,
                                  PostType.NewsArticle: 1,
                                }[widget.postType]);
                            _scaffoldKey.currentState.openDrawer();
                            // setState(() {
                            //   //disable button
                            //   _bottomSheetActive = true;
                            // });
                            // _scaffoldKey.currentState
                            //     .showBottomSheet((context) {
                            //       BottomDrawer.setPageIndex(
                            //           bloc,
                            //           {
                            //             PostType.Placement: 4,
                            //             PostType.Training: 5,
                            //             PostType.NewsArticle: 1,
                            //           }[widget.postType]);
                            //       return BottomDrawer();
                            //     })
                            //     .closed
                            //     .whenComplete(() {
                            //       setState(() {
                            //         _bottomSheetActive = false;
                            //       });
                            //     });
                          },
                  ),
                  IconButton(
                    icon: Icon(actionIcon),
                    onPressed: () {
                      setState(() {
                        if (searchMode) {
                          actionIcon = OMIcons.search;
                          blogBloc.query = "";
                          blogBloc.refresh();
                        } else {
                          actionIcon = OMIcons.close;
                        }
                        searchMode = !searchMode;
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        foregroundDecoration: _bottomSheetActive
            ? BoxDecoration(
                color: Color.fromRGBO(100, 100, 100, 12),
              )
            : null,
        child: StreamBuilder(
          stream: bloc.session,
          builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
            if ((snapshot.hasData && snapshot.data != null) ||
                !widget.loginNeeded) {
              return StreamBuilder<UnmodifiableListView<Post>>(
                stream: blogBloc.blog,
                builder: (BuildContext context,
                    AsyncSnapshot<UnmodifiableListView<Post>> snapshot) {
                  return RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _handleRefresh,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.title,
                                  style: theme.textTheme.display2.copyWith(
                                      fontFamily: "Bitter"),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return _buildPost(blogBloc, index - 1, snapshot.data);
                        }
                      },
                      itemCount: (snapshot.data == null
                              ? 0
                              : ((snapshot.data.isNotEmpty &&
                                      snapshot.data.last.content == null)
                                  ? snapshot.data.length - 1
                                  : snapshot.data.length)) +
                          2,
                      controller: _hideButtonController,
                    ),
                  );
                },
              );
            } else {
              return ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: theme.textTheme.display2.copyWith( fontFamily: "Bitter"),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      "You must be logged in to view ${widget.title}",
                      style: theme.textTheme.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: isFabVisible == 0
          ? null
          : FloatingActionButton(
              tooltip: "Go to the Top",
              onPressed: () {
                _hideButtonController
                    .animateTo(0.0,
                        curve: Curves.fastOutSlowIn,
                        duration: const Duration(milliseconds: 600))
                    .then((_) {
                  setState(() {
                    isFabVisible = 0.0;
                  });
                });
                setState(() {
                  isFabVisible = 0.0;
                });
              },
              child: Icon(OMIcons.keyboardArrowUp),
            ),
    );
  }

  Future<void> _handleRefresh() {
    var bloc = BlocProvider.of(context).bloc;
    return bloc.getPostsBloc(widget.postType).refresh();
  }

  Widget _buildPost(PostBloc bloc, int index, List<Post> posts) {
    bloc.inPostIndex.add(index);

    final Post post =
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

    if (post.content == null) {
      return Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text("End of results"),
        ),
      ));
    }

    return _post(post);
  }

  Widget _post(Post post) {
    var theme = Theme.of(context);
    return Card(
        key: ValueKey(post.postID),
        child: InkWell(
          onTap: () async {
            if (await canLaunch(post.link)) {
              await launch(post.link);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  post.title,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.headline
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.postType == PostType.NewsArticle
                      ? "${((post as NewsArticle).body.bodyName)} | ${post.published}"
                      : post.published,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.subhead,
                ),
                SizedBox(
                  height: 8.0,
                ),
                CommonHtml(
                  data: post.content,
                  defaultTextStyle: theme.textTheme.subhead,
                ),
              ],
            ),
          ),
        ));
  }
}
