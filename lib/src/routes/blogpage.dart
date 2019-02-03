import 'dart:core';
import 'dart:collection';

import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:InstiApp/src/api/model/post.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final LocalKey _containerKey = ValueKey("container");
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  FocusNode _focusNode = FocusNode();
  ScrollController _hideButtonController;
  double isFabVisible = 0;

  bool searchMode = false;
  IconData actionIcon = OMIcons.search;

  bool firstBuild = true;

  @override
  void initState() {
    super.initState();

    _hideButtonController = ScrollController();
    _hideButtonController.addListener(() {
      if ((_hideButtonController.position.userScrollDirection ==
                  ScrollDirection.reverse &&
              isFabVisible == 1) ||
          (_hideButtonController.offset < 100)) {
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

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      key: _scaffoldKey,
      drawer: NavDrawer(),
      bottomNavigationBar: MyBottomAppBar(
        shape: RoundedNotchedRectangle(),
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
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: bloc.session,
          builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
            if ((snapshot.hasData && snapshot.data != null) ||
                !widget.loginNeeded) {
              return GestureDetector(
                onTap: () {
                  _focusNode.unfocus();
                },
                child: NestedScrollView(
                  controller: _hideButtonController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: theme.textTheme.display2,
                                ),
                              ),
                            ]..addAll(searchMode
                                ? []
                                : [
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 500),
                                      decoration: ShapeDecoration(
                                          shape: CircleBorder(
                                              side: BorderSide(
                                                  color: theme.primaryColor))),
                                      child: IconButton(
                                        tooltip: !searchMode
                                            ? "Search ${widget.title}"
                                            : "Clear search results",
                                        padding: EdgeInsets.all(16.0),
                                        icon: Icon(
                                          actionIcon,
                                          color: theme.primaryColor,
                                        ),
                                        color: theme.cardColor,
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
                                      ),
                                    )
                                  ]),
                          ),
                        ),
                      ),
                    ]..addAll(!searchMode
                        ? []
                        : [
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 16.0,
                              ),
                            ),
                            SliverPersistentHeader(
                              floating: true,
                              pinned: true,
                              delegate: SliverHeaderDelegate(
                                child: PreferredSize(
                                  preferredSize: Size.fromHeight(72),
                                  child: AnimatedContainer(
                                    key: _containerKey,
                                    color: theme.canvasColor,
                                    padding: EdgeInsets.all(8.0),
                                    duration: Duration(milliseconds: 500),
                                    child: TextField(
                                      cursorColor: theme.textTheme.body1.color,
                                      style: theme.textTheme.body1,
                                      autofocus: true,
                                      focusNode: _focusNode,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        labelStyle: theme.textTheme.body1,
                                        hintStyle: theme.textTheme.body1,
                                        prefixIcon: Icon(
                                          OMIcons.search,
                                        ),
                                        suffixIcon: IconButton(
                                          tooltip: !searchMode
                                              ? "Search ${widget.title}"
                                              : "Clear search results",
                                          icon: Icon(
                                            actionIcon,
                                          ),
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
                                        ),
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
                                ),
                              ),
                            )
                          ]);
                  },
                  body: StreamBuilder<UnmodifiableListView<Post>>(
                    stream: blogBloc.blog,
                    builder: (BuildContext context,
                        AsyncSnapshot<UnmodifiableListView<Post>> snapshot) {
                      return RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _handleRefresh,
                        child: Builder(builder: (context) {
                          return CustomScrollView(
                            // The "controller" and "primary" members should be left
                            // unset, so that the NestedScrollView can control this
                            // inner scroll view.
                            // If the "controller" property is set, then this scroll
                            // view will not be associated with the NestedScrollView.
                            // The PageStorageKey should be unique to this ScrollView;
                            // it allows the list to remember its scroll position when
                            // the tab view is not on the screen.
                            slivers: <Widget>[
                              // SliverOverlapInjector(
                              //   // This is the flip side of the SliverOverlapAbsorber above.
                              //   handle: NestedScrollView
                              //       .sliverOverlapAbsorberHandleFor(context),
                              // ),
                              SliverPadding(
                                  padding: const EdgeInsets.all(8.0),
                                  // In this example, the inner scroll view has
                                  // fixed-height list items, hence the use of
                                  // SliverFixedExtentList. However, one could use any
                                  // sliver widget here, e.g. SliverList or SliverGrid.
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        return _buildPost(blogBloc, index,
                                            snapshot.data, theme);
                                      },
                                      childCount: (snapshot.data == null
                                              ? 0
                                              : ((snapshot.data.isNotEmpty &&
                                                      snapshot.data.last
                                                              .content ==
                                                          null)
                                                  ? snapshot.data.length - 1
                                                  : snapshot.data.length)) +
                                          1,
                                    ),
                                  )),
                            ],
                          );
                        }),
                      );
                    },
                  ),
                ),
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
                          style: theme.textTheme.display2,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: isFabVisible == 0
          ? null
          : FloatingActionButton(
              tooltip: "Go to the Top",
              onPressed: () {
                _hideButtonController.animateTo(0.0,
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(milliseconds: 600));
              },
              child: Icon(OMIcons.keyboardArrowUp),
            ),
    );
  }

  Future<void> _handleRefresh() {
    var blogbloc = BlocProvider.of(context).bloc.getPostsBloc(widget.postType);
    return blogbloc.refresh(force: blogbloc.query.isEmpty);
  }

  Widget _buildPost(
      PostBloc bloc, int index, List<Post> posts, ThemeData theme) {
    bloc.inPostIndex.add(index);

    final Post post =
        (posts != null && posts.length > index) ? posts[index] : null;

    if (post == null) {
      return Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
            child: CircularProgressIndicatorExtended(
          label: Text("Getting ${widget.title} Posts"),
        )),
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

    return _post(post, bloc);
  }

  Widget _post(Post post, PostBloc bloc) {
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
                widget.postType == PostType.NewsArticle
                    ? InkWell(
                        onTap: () async {
                          var p = (post as NewsArticle);
                          BodyPage.navigateWith(context, bloc.bloc, p.body);
                        },
                        child: Text(
                          "${((post as NewsArticle).body.bodyName)} | ${post.published}",
                          style: theme.textTheme.subhead
                              .copyWith(color: Colors.lightBlue),
                        ),
                      )
                    : Text(
                        post.published,
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
