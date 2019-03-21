import 'dart:async';
import 'dart:core';
import 'dart:collection';

import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
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
  TextEditingController _searchFieldController;
  ScrollController _hideButtonController;
  double isFabVisible = 0;

  bool searchMode = false;
  IconData actionIcon = OMIcons.search;

  bool firstBuild = true;

  @override
  void initState() {
    super.initState();
    _searchFieldController = TextEditingController();
    _hideButtonController = ScrollController();
    _hideButtonController.addListener(() {
      if (isFabVisible == 1 && _hideButtonController.offset < 100) {
        setState(() {
          isFabVisible = 0;
        });
      } else if (isFabVisible == 0 && _hideButtonController.offset > 100) {
        setState(() {
          isFabVisible = 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    _hideButtonController.dispose();
    super.dispose();
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
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _handleRefresh,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<UnmodifiableListView<Post>>(
                        stream: blogBloc.blog,
                        builder: (BuildContext context,
                            AsyncSnapshot<UnmodifiableListView<Post>>
                                snapshot) {
                          return ListView.builder(
                            controller: _hideButtonController,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return _blogHeader(context, blogBloc);
                              }
                              return _buildPost(
                                  blogBloc, index - 1, snapshot.data, theme);
                            },
                            itemCount: (snapshot.data == null
                                    ? 0
                                    : ((snapshot.data.isNotEmpty &&
                                            snapshot.data.last.content == null)
                                        ? snapshot.data.length - 1
                                        : snapshot.data.length)) +
                                2,
                          );
                        }),
                  ),
                ),
              );
            } else {
              return ListView(
                children: <Widget>[
                  TitleWithBackButton(
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
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Text(
                        "You must be logged in to view ${widget.title}",
                        style: theme.textTheme.title,
                        textAlign: TextAlign.center,
                      ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () async {
                if (await canLaunch(post.link)) {
                  await launch(post.link);
                }
              },
              child: Tooltip(
                message: "Open post in browser",
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12.0,
                        top: 12.0,
                        right: 12.0,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
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
                                      BodyPage.navigateWith(context, bloc.bloc,
                                          body: p.body);
                                    },
                                    child: Tooltip(
                                      message: "Open body page",
                                      child: Text(
                                        "${((post as NewsArticle).body.bodyName)} | ${post.published}",
                                        style: theme.textTheme.subhead
                                            .copyWith(color: Colors.lightBlue),
                                      ),
                                    ),
                                  )
                                : Text(
                                    post.published,
                                    textAlign: TextAlign.start,
                                    style: theme.textTheme.subhead,
                                  ),
                            SizedBox(
                              height: 4.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Icon(
                        OMIcons.launch,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 4.0,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                right: 12.0,
              ),
              child: CommonHtml(
                data: post.content,
                defaultTextStyle: theme.textTheme.subhead,
              ),
            ),
            widget.postType == PostType.NewsArticle
                ? Builder(builder: (BuildContext context) {
                    const Map<String, String> reactionToEmoji = {
                      "0": "👍",
                      "1": "❤️",
                      "2": "😂",
                      "3": "😯",
                      "4": "😢",
                      "5": "😡",
                    };

                    const Map<String, String> reactionToName = {
                      "0": "Like",
                      "1": "Love",
                      "2": "Haha",
                      "3": "Wow",
                      "4": "Sad",
                      "5": "Angry",
                    };

                    var article = (post as NewsArticle);
                    var totalNumberOfReactions = article?.reactionCount?.values
                        ?.reduce((i1, i2) => i1 + i2);

                    var nonZeroReactions = article?.reactionCount?.keys
                        ?.where((s) => (article?.reactionCount[s] > 0))
                        ?.toList();
                    nonZeroReactions?.sort((s1, s2) =>
                        ((article?.reactionCount[s1])
                            .compareTo(article?.reactionCount[s2])));
                    var numberOfPeopleOtherThanYou =
                        (totalNumberOfReactions ?? 0) -
                            ((article?.userReaction ?? -1) >= 0 ? 1 : 0);

                    if (nonZeroReactions != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Divider(
                            height: 0.0,
                          ),
                          InkWell(
                            onTap: () async {
                              var sel = await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: reactionToEmoji.keys.map((s) {
                                        return RawMaterialButton(
                                          shape: CircleBorder(),
                                          constraints: const BoxConstraints(
                                              minWidth: 36.0, minHeight: 12.0),
                                          fillColor:
                                              "${article.userReaction}" == s
                                                  ? theme.accentColor
                                                  : theme.cardColor,
                                          child: Text(
                                            reactionToEmoji[s],
                                            style: theme.textTheme.headline,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop(s);
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              );

                              if (sel == null) {
                                return;
                              }

                              final reaction = int.parse(sel);
                              if (article.userReaction == -1) {
                                setState(() {
                                  article.userReaction = reaction;
                                  article.reactionCount[sel] += 1;
                                });
                              } else if (article.userReaction != reaction) {
                                setState(() {
                                  article.reactionCount[
                                      "${article.userReaction}"] -= 1;
                                  article.userReaction = reaction;
                                  article.reactionCount[sel] += 1;
                                });
                              } else {
                                setState(() {
                                  article.userReaction = -1;
                                  article.reactionCount[sel] -= 1;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: totalNumberOfReactions > 0
                                  ? Text.rich(
                                      TextSpan(children: [
                                        TextSpan(
                                            text:
                                                "${nonZeroReactions?.map((s) => reactionToEmoji[s])?.join()} ",
                                            style: theme.textTheme.headline),
                                        TextSpan(
                                            text:
                                                " ${((article?.userReaction ?? -1) < 0) ? "" : "You "}${((article?.userReaction ?? -1) >= 0 && totalNumberOfReactions > 1) ? "and " : ""}${numberOfPeopleOtherThanYou > 0 ? (numberOfPeopleOtherThanYou.toString() + " other " + (numberOfPeopleOtherThanYou > 1 ? "people " : "person ")) : ""}reacted"),
                                      ]),
                                      textAlign: TextAlign.center,
                                    )
                                  : Center(
                                      child: Text.rich(
                                      TextSpan(children: [
                                        TextSpan(
                                            text: "👍 ",
                                            style: theme.textTheme.headline),
                                        TextSpan(text: " Like"),
                                      ]),
                                    )),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return SizedBox();
                    }
                  })
                : SizedBox(),
          ],
        ));
  }

  Widget _blogHeader(BuildContext context, PostBloc blogBloc) {
    var theme = Theme.of(context);
    return Column(
      children: <Widget>[
        TitleWithBackButton(
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
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: searchMode ? 0.0 : null,
                height: searchMode ? 0.0 : null,
                decoration: ShapeDecoration(
                    shape: CircleBorder(
                        side: BorderSide(color: theme.primaryColor))),
                child: searchMode
                    ? SizedBox()
                    : IconButton(
                        tooltip: "Search ${widget.title}",
                        padding: EdgeInsets.all(16.0),
                        icon: Icon(
                          actionIcon,
                          color: theme.primaryColor,
                        ),
                        color: theme.cardColor,
                        onPressed: () {
                          setState(() {
                            actionIcon = OMIcons.close;
                            searchMode = !searchMode;
                          });
                        },
                      ),
              )
            ],
          ),
        ),
        !searchMode
            ? SizedBox()
            : PreferredSize(
                preferredSize: Size.fromHeight(72),
                child: AnimatedContainer(
                  key: _containerKey,
                  color: theme.canvasColor,
                  padding: EdgeInsets.all(8.0),
                  duration: Duration(milliseconds: 500),
                  child: TextField(
                    controller: _searchFieldController,
                    cursorColor: theme.textTheme.body1.color,
                    style: theme.textTheme.body1,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                      labelStyle: theme.textTheme.body1,
                      hintStyle: theme.textTheme.body1,
                      prefixIcon: Icon(
                        OMIcons.search,
                      ),
                      suffixIcon: IconButton(
                        tooltip: "Clear search results",
                        icon: Icon(
                          actionIcon,
                        ),
                        onPressed: () {
                          setState(() {
                            actionIcon = OMIcons.search;
                            blogBloc.query = "";
                            blogBloc.refresh();
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
      ],
    );
  }
}
