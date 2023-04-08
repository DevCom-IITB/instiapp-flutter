// import 'dart:async';
import 'dart:core';
import 'dart:collection';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/notif_settings.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:InstiApp/src/api/model/post.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
// import 'package:flutter_html/shims/dart_ui_real.dart';
// import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:flutter/foundation.dart';
TextSpan highlight(String result, String query, BuildContext context) {
  // var bloc = BlocProvider.of(context)!.bloc;
  var theme = Theme.of(context);
  TextStyle posRes =
      TextStyle(color: Colors.white, backgroundColor: Colors.red);
  TextStyle? negRes = theme.textTheme
      .subtitle1; // TextStyle(backgroundColor: bloc.bloc.brightness.toColor().withOpacity(1.0),);
  if (result == "" || query == "") return TextSpan(text: result, style: negRes);
  result.replaceAll('\n', " ").replaceAll("  ", "");

  var refinedMatch = result.toLowerCase();
  var refinedsearch = query.toLowerCase();

  if (refinedMatch.contains(refinedsearch)) {
    if (refinedMatch.substring(0, refinedsearch.length) == refinedsearch) {
      return TextSpan(
          style: posRes,
          text: result.substring(0, refinedsearch.length),
          children: [
            highlight(result.substring(refinedsearch.length), query, context),
          ]);
    } else if (refinedsearch.length == refinedMatch.length) {
      return TextSpan(text: result, style: posRes);
    } else {
      return TextSpan(
          style: negRes,
          text: result.substring(0, refinedMatch.indexOf(refinedsearch)),
          children: [
            highlight(result.substring(refinedMatch.indexOf(refinedsearch)),
                query, context)
          ]);
    }
  } else if (!refinedMatch.contains(refinedsearch)) {
    return TextSpan(text: result, style: negRes);
  }

  return TextSpan(
    text: result.substring(0, refinedMatch.indexOf(refinedsearch)),
    style: negRes,
    children: [
      highlight(
          result.substring(refinedMatch.indexOf(refinedsearch)), query, context)
    ],
  );
}

class BlogPage extends StatefulWidget {
  final String title;
  final PostType postType;
  final bool loginNeeded;

  BlogPage(
      {required this.postType, required this.title, this.loginNeeded = true});

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final LocalKey _containerKey = ValueKey("container");
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  FocusNode _focusNode = FocusNode();
  TextEditingController? _searchFieldController;
  ScrollController? _hideButtonController;
  double isFabVisible = 0;

  bool searchMode = false;
  IconData actionIcon = Icons.search_outlined;

  bool firstBuild = true;
  bool firstNotifAct = true;
  String? loadingReaction;

  List<String>? currCat;

  late NotificationRouteArguments? args;

  @override
  void initState() {
    super.initState();
    _searchFieldController = TextEditingController();
    _hideButtonController = ScrollController();
    _hideButtonController!.addListener(() {
      if (isFabVisible == 1 && _hideButtonController!.offset < 100) {
        setState(() {
          isFabVisible = 0;
        });
      } else if (isFabVisible == 0 && _hideButtonController!.offset > 100) {
        setState(() {
          isFabVisible = 1;
        });
      }
    });
    if (widget.postType == PostType.ChatBot) {
      searchMode = true;
      actionIcon = Icons.close_outlined;
    }
  }

  @override
  void dispose() {
    _searchFieldController?.dispose();
    _hideButtonController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    var blogBloc = bloc.getPostsBloc(widget.postType);
    args = ModalRoute.of(context)!.settings.arguments
        as NotificationRouteArguments?;

    if (firstBuild) {
      blogBloc?.query = "";
      blogBloc?.refresh();
      firstBuild = false;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                Icons.menu_outlined,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamB,   v  uilder(
          stream: bloc.session,
          builder: (BuildContext context, AsyncSnapshot<Session?> snapshot) {
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
                        stream: blogBloc!.blog,
                        builder: (BuildContext context,
                            AsyncSnapshot<UnmodifiableListView<Post>>
                                snapshot) {
                          return ListView.builder(
                            controller: _hideButtonController,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return _blogHeader(context, blogBloc, bloc);
                              }
                              return _buildPost(blogBloc, index - 1,
                                  snapshot.data, theme, context);
                            },
                            itemCount: (snapshot.data == null
                                    ? 0
                                    : ((snapshot.data!.isNotEmpty &&
                                            snapshot.data!.last.content == null)
                                        ? snapshot.data!.length - 1
                                        : snapshot.data!.length)) +
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
                          style: theme.textTheme.headline3,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Text(
                        "You must be logged in to view ${widget.title}",
                        style: theme.textTheme.headline6,
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
          ? widget.postType == PostType.Query
              ? FloatingActionButton.extended(
                  tooltip: "Ask a Question",
                  onPressed: () {
                    Navigator.of(context).pushNamed("/query/add");
                  },
                  icon: Icon(Icons.add),
                  label: Text("Ask a Question"),
                )
              : null
          : FloatingActionButton(
              tooltip: "Go to the Top",
              onPressed: () {
                _hideButtonController!.animateTo(0.0,
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(milliseconds: 600));
              },
              child: Icon(Icons.keyboard_arrow_up_outlined),
            ),
    );
  }

  Future<void> _handleRefresh() {
    var blogbloc = BlocProvider.of(context)!.bloc.getPostsBloc(widget.postType);
    return blogbloc!.refresh(force: blogbloc.query.isEmpty);
  }

  Widget _buildPost(PostBloc bloc, int index, List<Post>? posts,
      ThemeData theme, BuildContext context) {
    bloc.inPostIndex.add(index);

    final Post? post =
        (posts != null && posts.length > index) ? posts[index] : null;

    if (post == null &&
        (widget.postType != PostType.ChatBot ||
            (widget.postType == PostType.ChatBot && bloc.query.isNotEmpty))) {
      return Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
            child: CircularProgressIndicatorExtended(
          label: Column(
            children: [
              Text("Getting ${widget.title} Posts"),
              widget.postType == PostType.ChatBot
                  ? Text("This might take a while")
                  : SizedBox()
            ],
          ),
        )),
      ));
    }

    if (bloc.query.isEmpty && bloc.postType == PostType.ChatBot) {
      if (post == null || post.content == null) return SizedBox();
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(50),
        child: Column(
          children: [
            Icon(
              Icons.bolt,
              size: 200,
              color: Colors.grey[600],
            ),
            Text(
              "Ask your queries!",
              style: theme.textTheme.headline5,
              textAlign: TextAlign.center,
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      );
    }

    if (post?.content == null) {
      if (bloc.postType == PostType.ChatBot) {
        if (bloc.bloc.currSession != null)
          return GestureDetector(
              onTap: () async {
                await bloc.updateUserReactionChatBot(
                    ChatBot("", "", "", "", "", "", body: bloc.query), 2);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Reaction Noted ❤️"),
                  duration: Duration(seconds: 1),
                ));
              },
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: "👎 ", style: theme.textTheme.headline5),
                    TextSpan(text: " No Suitable Results"),
                  ]),
                )),
              )));
        return SizedBox();
      }
      return Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text("End of results"),
        ),
      ));
    }
    return _post(post, bloc, context);
  }

  Widget _post(dynamic post, PostBloc bloc, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var theme = Theme.of(context);

    if (post.id == args?.notif.notificationObjectID &&
        args?.key == ActionKeys.LIKE_REACT &&
        firstNotifAct) {
      firstNotifAct = false;
      WidgetsBinding.instance?.addPostFrameCallback(
          (_) => _pressedReact(post, theme, bloc, context));
    }

    //print(post.title);
    return Card(
        key: ValueKey(post.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () async {
                if (await canLaunchUrl(Uri.parse(post.link))) {
                  await launchUrl(
                    Uri.parse(post.link),
                    mode: LaunchMode.externalApplication,
                  );
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
                            widget.postType == PostType.ChatBot
                                ? RichText(
                                    textScaleFactor: 0.8,
                                    // textHeightBehavior: ,
                                    text: TextSpan(
                                        text: "Click here to know more",
                                        style:
                                            theme.textTheme.subtitle1!.copyWith(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        )),
                                    textAlign: TextAlign.start,
                                    strutStyle: StrutStyle.fromTextStyle(
                                        theme.textTheme.headline5!.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.blue),
                                        height: 0.7,
                                        fontWeight: FontWeight.w900))
                                : RichText(
                                    textScaleFactor: 1.55,
                                    // textHeightBehavior: ,
                                    text: highlight(
                                        post.title, bloc.query, context),
                                    textAlign: TextAlign.start,
                                    strutStyle: StrutStyle.fromTextStyle(
                                        theme.textTheme.headline5!.copyWith(
                                            fontWeight: FontWeight.w900),
                                        height: 0.7,
                                        fontWeight: FontWeight.w900)),
                            // Text(
                            //   post.title,
                            //   textAlign: TextAlign.start,
                            //   style: theme.textTheme.headline5
                            //       ?.copyWith(fontWeight: FontWeight.bold),
                            // ),
                            widget.postType == PostType.NewsArticle
                                ? InkWell(
                                    onTap: () async {
                                      var p = (post as NewsArticle);
                                      BodyPage.navigateWith(context, bloc.bloc,
                                          body: p.body ?? Body());
                                    },
                                    child: Tooltip(
                                      message: "Open body page",
                                      child: Text(
                                        "${((post as NewsArticle).body?.bodyName)} | ${post.published}",
                                        style: theme.textTheme.subtitle1
                                            ?.copyWith(color: Colors.lightBlue),
                                      ),
                                    ),
                                  )
                                : widget.postType == PostType.ChatBot
                                    ? SizedBox()
                                    : Text(
                                        post.published,
                                        textAlign: TextAlign.start,
                                        style: theme.textTheme.subtitle1,
                                      ),
                            SizedBox(
                              height: 4.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    (post.link != null && post.link != "")
                        ? Positioned(
                            top: 6,
                            right: 6,
                            child: Icon(
                              Icons.launch_outlined,
                              size: 16,
                            ),
                          )
                        : SizedBox(),

                    //             Positioned(
                    //               top: 6,
                    //               right: 6,
                    //               child: Icon(
                    //
                    //               Icons.launch_outlined,
                    //
                    //                 size: 16,
                    //               ),
                    //             ),
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
                  bottom: 12.0,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                      constraints: BoxConstraints(maxWidth: width * 0.8),
                      child: CommonHtml(
                          data: post.content,
                          defaultTextStyle:
                              theme.textTheme.subtitle1 ?? TextStyle())),
                )),
            widget.postType == PostType.External
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 12.0,
                    ),
                    child: Text(
                      "By " + post.body,
                      style: theme.textTheme.bodyText1,
                    ),
                  )
                : SizedBox(),
            widget.postType == PostType.External
                ? SizedBox(height: 10)
                : SizedBox(),
            widget.postType == PostType.NewsArticle
                ? Builder(builder: (BuildContext context) {
                    const Map<String, String> reactionToEmoji = {
                      "0": "👍",
                      "1": "❤️", //heart
                      "2": "😂",
                      "3": "😯",
                      "4": "😢",
                      "5": "😡",
                    };

                    // const Map<String, String> reactionToName = {
                    //   "0": "Like",
                    //   "1": "Love",
                    //   "2": "Haha",
                    //   "3": "Wow",
                    //   "4": "Sad",
                    //   "5": "Angry",
                    // };

                    var article = (post as NewsArticle);
                    var totalNumberOfReactions = article.reactionCount?.values
                        .reduce((i1, i2) => i1 + i2);

                    var nonZeroReactions = article.reactionCount?.keys
                        .where((s) => ((article.reactionCount?[s] ?? 0) > 0))
                        .toList();
                    nonZeroReactions?.sort((s1, s2) =>
                        ((article.reactionCount?[s1] ?? 0)
                            .compareTo(article.reactionCount?[s2] ?? 0)));
                    var numberOfPeopleOtherThanYou =
                        (totalNumberOfReactions ?? 0) -
                            ((article.userReaction ?? -1) >= 0 ? 1 : 0);

                    if (nonZeroReactions != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Divider(
                            height: 0.0,
                          ),
                          InkWell(
                            onTap: (loadingReaction != null &&
                                    loadingReaction == article.id)
                                ? null
                                : () => _pressedReact(
                                    article, theme, bloc, context),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  (totalNumberOfReactions ?? 0) > 0
                                      ? Text.rich(
                                          TextSpan(children: [
                                            TextSpan(
                                                text:
                                                    "${nonZeroReactions.map((s) => reactionToEmoji[s]).join()} ",
                                                style:
                                                    theme.textTheme.headline5),
                                            TextSpan(
                                                text:
                                                    " ${((article.userReaction ?? -1) < 0) ? "" : "You "}${((article.userReaction ?? -1) >= 0 && (totalNumberOfReactions ?? 0) > 1) ? "and " : ""}${numberOfPeopleOtherThanYou > 0 ? (numberOfPeopleOtherThanYou.toString() + " other " + (numberOfPeopleOtherThanYou > 1 ? "people " : "person ")) : ""}reacted"),
                                          ]),
                                          textAlign: TextAlign.center,
                                        )
                                      : Center(
                                          child: Text.rich(
                                          TextSpan(children: [
                                            TextSpan(
                                                text: "👍 ",
                                                style:
                                                    theme.textTheme.headline5),
                                            TextSpan(text: " Like"),
                                          ]),
                                        )),
                                ]..addAll(loadingReaction != null &&
                                        loadingReaction == article.id
                                    ? [
                                        SizedBox(width: 8),
                                        CircularProgressIndicatorExtended()
                                      ]
                                    : []),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return SizedBox();
                    }
                  })
                : widget.postType == PostType.ChatBot &&
                        bloc.query.isNotEmpty &&
                        bloc.bloc.currSession != null
                    ? Builder(builder: (BuildContext context) {
                        const Map<String, String> reactionToEmoji = {
                          "0": "👍",
                          "1": "👎",
                        };

                        var article = (post as ChatBot);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Divider(
                              height: 0.0,
                            ),
                            InkWell(
                              onTap: (loadingReaction != null &&
                                      loadingReaction == article.id)
                                  ? null
                                  : () async {
                                      setState(() {
                                        loadingReaction = article.id;
                                      });

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
                                              children:
                                                  reactionToEmoji.keys.map((s) {
                                                return RawMaterialButton(
                                                  shape: CircleBorder(),
                                                  constraints:
                                                      const BoxConstraints(
                                                          minWidth: 36.0,
                                                          minHeight: 12.0),
                                                  child: Text(
                                                    reactionToEmoji[s] ?? "",
                                                    style: theme
                                                        .textTheme.headline5,
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

                                      if (sel != null) {
                                        final reaction = int.parse(sel);
                                        await bloc.updateUserReactionChatBot(
                                            article, reaction);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Reaction Noted ❤️"),
                                          duration: Duration(seconds: 1),
                                        ));
                                      }

                                      setState(() {
                                        loadingReaction = null;
                                      });
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Center(
                                        child: Text.rich(
                                      TextSpan(children: [
                                        TextSpan(
                                            text: "👍 ",
                                            style: theme.textTheme.headline5),
                                        TextSpan(text: " Like"),
                                      ]),
                                    )),
                                  ]..addAll(loadingReaction != null &&
                                          loadingReaction == article.id
                                      ? [
                                          SizedBox(width: 8),
                                          CircularProgressIndicatorExtended()
                                        ]
                                      : []),
                                ),
                              ),
                            ),
                          ],
                        );
                      })
                    : SizedBox(),
          ],
        ));
  }

  final Map<String, String> reactionToEmoji = {
    "0": "👍",
    "1": "❤️",
    "2": "😂",
    "3": "😯",
    "4": "😢",
    "5": "😡",
  };
  void _pressedReact(NewsArticle article, ThemeData theme, PostBloc bloc,
      BuildContext context) async {
    setState(() {
      loadingReaction = article.id;
    });

    var sel = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: reactionToEmoji.keys.map((s) {
              return RawMaterialButton(
                shape: CircleBorder(),
                constraints:
                    const BoxConstraints(minWidth: 36.0, minHeight: 12.0),
                fillColor: "${article.userReaction}" == s
                    ? theme.colorScheme.secondary
                    : theme.cardColor,
                child: Text(
                  reactionToEmoji[s] ?? "",
                  style: theme.textTheme.headline5,
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(s);
                },
              );
            }).toList(),
          ),
        );
      },
    );

    if (sel != null) {
      final reaction = int.parse(sel);
      await bloc.updateUserReaction(article, reaction);
    }

    setState(() {
      loadingReaction = null;
    });
  }

  Widget _blogHeader(BuildContext context, PostBloc blogBloc, var bloc) {
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
                  style: theme.textTheme.headline3,
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                // width: searchMode ? 0.0 : null,
                // height: searchMode ? 0.0 : null,
                decoration: ShapeDecoration(
                    shape: CircleBorder(
                        side: BorderSide(color: theme.primaryColor))),
                child: searchMode
                    ? widget.postType == PostType.Query
                        ? buildDropdownButton(theme, blogBloc, bloc)
                        : SizedBox()
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
                            actionIcon = Icons.close_outlined;
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
                    cursorColor: theme.textTheme.bodyText2?.color,
                    style: theme.textTheme.bodyText2,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                      labelStyle: theme.textTheme.bodyText2,
                      hintStyle: theme.textTheme.bodyText2,
                      prefixIcon: Icon(
                        Icons.search_outlined,
                      ),
                      suffixIcon: IconButton(
                        tooltip: "Clear search results",
                        icon: Icon(
                          actionIcon,
                        ),
                        onPressed: () {
                          setState(() {
                            actionIcon = Icons.search_outlined;
                            _searchFieldController?.text = "";
                            blogBloc.query = "";
                            blogBloc.refresh();
                            searchMode = !searchMode;
                          });
                        },
                      ),
                      hintText: "Search...",
                    ),
                    onChanged: (query) async {
                      if (widget.postType != PostType.ChatBot &&
                          query.length > 4) {
                        blogBloc.query = query;
                        blogBloc.refresh();
                      }
                    },
                    onSubmitted: (query) async {
                      blogBloc.query = query;
                      await blogBloc.refresh();
                    },
                    autofocus: true,
                  ),
                ),
              ),
      ],
    );
  }

  Widget buildDropdownButton(ThemeData theme, PostBloc blogBloc, var bloc) {
    blogBloc.setCategories();
    return Container(
        padding: EdgeInsets.all(6.0),
        child: StreamBuilder<UnmodifiableListView<Map<String, String>>>(
            stream: blogBloc.categories,
            builder: (BuildContext context,
                AsyncSnapshot<UnmodifiableListView<Map<String, String>>>
                    snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Text("No Filters");
              }
              var categories_1 = snapshot.data;
              return MultiSelectDialogField<String?>(
                title: Text(
                  "Filters",
                  style: theme.textTheme.subtitle1,
                ),
                searchable: true,
                decoration: BoxDecoration(),
                chipDisplay: MultiSelectChipDisplay.none(),
                listType: MultiSelectListType.CHIP,
                items: categories_1
                        ?.map((cat) => MultiSelectItem<String>(
                              cat['value'] ?? "",
                              cat['name'] ?? "",
                            ))
                        .toList() ??
                    [],
                selectedItemsTextStyle: TextStyle(color: Colors.white),
                selectedColor: theme.primaryColor,
                barrierColor: Colors.black.withOpacity(0.7),
                onConfirm: (c) {
                  setState(() {
                    currCat = c.map((element) => element ?? "").toList();
                    String category = "";
                    currCat?.forEach((element) {
                      category += element + ",";
                    });
                    if (category != "")
                      category = category.substring(0, category.length - 1);
                    blogBloc.category = category;
                    blogBloc.refresh();
                  });
                },
                buttonText: Text(
                  "",
                ),
                buttonIcon: Icon(
                  Icons.filter_alt_outlined,
                  color: theme.primaryColor,
                ),
              );
            }));
  }
}
