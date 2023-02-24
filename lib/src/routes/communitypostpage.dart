import 'dart:async';

import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/blocs/community_post_bloc.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
// import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/utils/customappbar.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:share/share.dart';

import '../bloc_provider.dart';

class CommunityPostPage extends StatefulWidget {
  final CommunityPost? initialCommunityPost;
  final Future<CommunityPost?> communityPostFuture;
  CommunityPostPage(
      {required this.communityPostFuture, this.initialCommunityPost});

  static void navigateWith(BuildContext context, CommunityPostBloc bloc,
      CommunityPost communityPost) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/post/${communityPost.id ?? ""}",
        ),
        builder: (context) => CommunityPostPage(
          initialCommunityPost: communityPost,
          communityPostFuture: bloc.getCommunityPost(communityPost.id ?? ""),
        ),
      ),
    );
  }

  @override
  _CommunityPostPageState createState() => _CommunityPostPageState();
}

class _CommunityPostPageState extends State<CommunityPostPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TextEditingController _commentController = TextEditingController();
  FocusNode _commentFocusNode = FocusNode();

  CommunityPost? communityPost;
  CommunityPost? currentlyCommentingPost;
  int? threadRank;
  int aboutIndex = 0;

  bool firstBuild = true;

  @override
  void initState() {
    super.initState();
    //print(communityPost?.comments);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    InstiAppBloc bloc = BlocProvider.of(context)!.bloc;

    if (firstBuild) {
      communityPost = widget.initialCommunityPost;
      currentlyCommentingPost = communityPost;
      widget.communityPostFuture.then((communityPost) {
        setState(() {
          this.communityPost = communityPost;
          currentlyCommentingPost = communityPost;
          this.threadRank = communityPost?.threadRank;
        });
      });
      firstBuild = false;
    }

    return communityPost != null
        ? SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                communityPost = await bloc.communityPostBloc
                    .getCommunityPost(communityPost!.id!);
                setState(() {});
              },
              child: Scaffold(
                key: _scaffoldKey,
                // extendBodyBehindAppBar: true,
                drawer: NavDrawer(),
                appBar: CustomAppBar(
                  leadingStyle: LeadingStyle(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
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
                body: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          // _buildPost(theme, communityPost),
                          CommunityPostWidget(
                            communityPost: communityPost!,
                            shouldTap: false,
                            onPressedComment: () {
                              changeCommentingPost(communityPost!);
                            },
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: _buildCommentList(
                                  theme, communityPost!, bloc),
                            ),
                          ),
                          SizedBox(height: 150)
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(child: SizedBox()),
                        Container(
                          color: theme.colorScheme.surfaceVariant,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  cursorColor:
                                      theme.textTheme.bodyMedium?.color,
                                  style: theme.textTheme.bodyLarge,
                                  focusNode: _commentFocusNode,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(5)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(5)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(5)),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                    hintText: communityPost!.id ==
                                            currentlyCommentingPost!.id
                                        ? "Add a comment"
                                        : "Reply to ${currentlyCommentingPost!.content!.length > 23 ? currentlyCommentingPost!.content!.substring(0, 20) + "..." : currentlyCommentingPost!.content!}",
                                    hintStyle: theme.textTheme.bodyLarge,
                                  ),
                                  // onChanged: widget.appBarSearchStyle.onChanged,
                                  // onSubmitted: widget.appBarSearchStyle.onSubmitted,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: theme.colorScheme.surface,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  color: theme.colorScheme.onSurfaceVariant,
                                  splashColor: Colors.transparent,
                                  tooltip: "Post",
                                  icon: Icon(
                                    Icons.keyboard_double_arrow_up,
                                    semanticLabel: "Post",
                                  ),
                                  onPressed: () async {
                                    if (_commentController.text.length > 0) {
                                      CommunityPost comment = CommunityPost(
                                        content: _commentController.text,
                                        parent: currentlyCommentingPost!.id,
                                        community: communityPost!.community,
                                        deleted: false,
                                        featured: false,
                                        bodies: [],
                                        users: [],
                                        interests: [],
                                        imageUrl: [],
                                        anonymous: false,
                                      );
                                      await bloc.communityPostBloc
                                          .createCommunityPost(comment);
                                      _commentController.clear();
                                      _commentFocusNode.unfocus();
                                      currentlyCommentingPost = await bloc
                                          .communityPostBloc
                                          .getCommunityPost(
                                              currentlyCommentingPost!.id!);
                                      if (communityPost!.id ==
                                          currentlyCommentingPost!.id) {
                                        communityPost = currentlyCommentingPost;
                                      } else {
                                        Navigator.of(context).pop();
                                        return;
                                      }
                                      setState(() {
                                        communityPost!.comments = communityPost!
                                            .comments?.reversed
                                            .toList();
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  List<Widget> _buildCommentList(
      ThemeData theme, CommunityPost communityPost, InstiAppBloc bloc) {
    if (communityPost.comments == null &&
        (communityPost.commentsCount ?? 0) > 0) {
      return [
        Container(
          child: CircularProgressIndicator(),
          padding: EdgeInsets.all(20),
        )
      ];
    }

    return (communityPost.comments?.map(
              (c) => Comment(
                comment: c,
                onReply: changeCommentingPost,
              ),
            ) ??
            [])
        .toList();
  }

  void changeCommentingPost(CommunityPost communityPost) {
    setState(() {
      currentlyCommentingPost = communityPost;
      _commentController.text = "";
    });
    _commentFocusNode.requestFocus();
  }
}

class Comment extends StatefulWidget {
  final CommunityPost comment;
  final void Function(CommunityPost) onReply;

  Comment({required this.comment, required this.onReply});
  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  CommunityPost? comment;

  bool showingComments = false;
  bool loading = true;

  bool firstBuild = true;
  bool isReported = false;

  @override
  void initState() {
    super.initState();
    comment = widget.comment;
    //print(communityPost?.comments);
  }

  Widget build(BuildContext context) {
    if (comment!.deleted == true) {
      return Container();
    }

    ThemeData theme = Theme.of(context);
    InstiAppBloc bloc = BlocProvider.of(context)!.bloc;

    String timeToShow = "";

    if (firstBuild && showingComments) {
      bloc.communityPostBloc.getCommunityPost(widget.comment.id ?? "").then(
        (value) {
          setState(() {
            comment = value;
            loading = false;
          });
        },
      );
      firstBuild = false;
    }

    if (comment != null) {
      if (comment!.postedMinutes != null) {
        if (comment!.postedMinutes! > 1440) {
          timeToShow = "${comment!.postedMinutes! ~/ 1440}d";
        } else if (comment!.postedMinutes! > 60) {
          timeToShow = "${comment!.postedMinutes! ~/ 60}h";
        } else {
          timeToShow = "${comment!.postedMinutes!}m";
        }
      }
    }

    return comment != null
        ? Container(
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                ListTile(
                  title: RichText(
                    text: TextSpan(
                      text: comment!.postedBy?.userName ?? "Anonymous",
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: "  ${timeToShow}",
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  leading: NullableCircleAvatar(
                    comment!.postedBy?.userProfilePictureUrl ?? "",
                    Icons.person,
                    radius: 16,
                  ),
                  trailing: PopupMenuButton<int>(
                    itemBuilder: (context) {
                      List<PopupMenuItem<int>> items = [];

                      bool isAuthor = comment!.postedBy?.userID ==
                          bloc.currSession!.profile!.userID;

                      bool isAdmin = bloc.hasPermission(
                          comment!.community?.body ?? "", "ModC");

                      if (isAuthor) {
                        // items.add(
                        //   PopupMenuItem(
                        //     value: 1,
                        //     // row has two child icon and text.
                        //     child: Row(
                        //       children: [
                        //         Icon(Icons.edit),
                        //         SizedBox(
                        //           // sized box with width 10
                        //           width: 10,
                        //         ),
                        //         Text("Edit")
                        //       ],
                        //     ),
                        //     onTap: () => Future(() async {
                        //       CommunityPost? post =
                        //           (await Navigator.of(context).pushNamed(
                        //         "/posts/add",
                        //         arguments: NavigateArguments(post: comment!),
                        //       )) as CommunityPost?;
                        //       if (post != null) {
                        //         setState(() {
                        //           comment = post;
                        //         });
                        //       }
                        //     }),
                        //   ),
                        // );
                      }

                      if ((isAuthor || isAdmin) &&
                          !(comment!.deleted == true)) {
                        items.add(
                          PopupMenuItem(
                            value: 2,
                            // row has two child icon and text
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(
                                  // sized box with width 10
                                  width: 10,
                                ),
                                Text("Delete")
                              ],
                            ),
                            onTap: () async {
                              await bloc.communityPostBloc
                                  .deleteCommunityPost(comment!.id ?? "");
                              setState(() {
                                comment!.deleted = true;
                              });
                            },
                          ),
                        );
                      }

                      items.add(
                        PopupMenuItem(
                          value: 3,
                          // row has two child icon and text
                          child: Row(
                            children: [
                              !(comment?.hasUserReported ?? false)
                                  ? Icon(Icons.report)
                                  : Icon(Icons.report_off),
                              SizedBox(
                                // sized box with width 10
                                width: 10,
                              ),
                              !(comment?.hasUserReported ?? false)
                                  ? Text("Report")
                                  : Text("Unreport")
                            ],
                          ),
                          onTap: () async {
                            await bloc.communityPostBloc
                                .reportCommunityPost(comment!.id ?? "");
                            setState(() {
                              comment!.hasUserReported =
                                  !(comment?.hasUserReported ?? false);
                            });
                          },
                        ),
                      );

                      return items;
                    },
                    // offset: Offset(0, 100),
                    elevation: 2,
                    tooltip: "More",
                    icon: Icon(
                      Icons.more_vert,
                    ),
                  ),
                  dense: true,
                  horizontalTitleGap: 5,
                  contentPadding: EdgeInsets.zero,
                ),
                Container(
                  margin: EdgeInsets.only(left: 16),
                  padding: EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.inverseSurface,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableLinkify(
                        text: comment!.content ?? "",
                        onOpen: (link) async {
                          if (await canLaunchUrl(Uri.parse(link.url))) {
                            await launchUrl(
                              Uri.parse(link.url),
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                      ),
                      _buildFooter(theme, bloc, comment!),
                      ..._buildCommentList(theme, comment!)
                    ],
                  ),
                )
              ],
            ),
          )
        : Container();
  }

  List<Widget> _buildCommentList(ThemeData theme, CommunityPost communityPost) {
    if (showingComments) {
      if (loading) {
        return [
          Container(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.all(5),
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          )
        ];
      }
      return (communityPost.comments?.map((c) => Comment(
                    comment: c,
                    onReply: widget.onReply,
                  )) ??
              [])
          .toList();
    } else if (communityPost.commentsCount != 0) {
      return [
        Container(
          alignment: Alignment.center,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              setState(() {
                showingComments = true;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.inverseSurface,
                    thickness: 1,
                  ),
                  flex: 1,
                ),
                SizedBox(width: 5),
                Expanded(
                  flex: 3,
                  child: Text(
                    "View ${communityPost.commentsCount} Replies",
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ];
    } else {
      return [];
    }
  }

  Widget _buildFooter(
      ThemeData theme, InstiAppBloc bloc, CommunityPost communityPost) {
    int numReactions = communityPost.reactionCount?.values
            .reduce((sum, element) => sum + element) ??
        0;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.inverseSurface,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                PopupMenuButton<int>(
                  onSelected: (val) async {
                    await bloc.communityPostBloc
                        .updateUserCommunityPostReaction(communityPost, val);
                    setState(() {
                      if ((communityPost.userReaction ?? -1) != -1) {
                        communityPost.reactionCount![communityPost.userReaction!
                            .toString()] = (communityPost.reactionCount![
                                    communityPost.userReaction!.toString()] ??
                                1) -
                            1;
                      }
                      communityPost.reactionCount![val.toString()] =
                          (communityPost.reactionCount![val.toString()] ?? 0) +
                                      (communityPost.userReaction ?? -1) ==
                                  val
                              ? 0
                              : 1;
                      communityPost.userReaction =
                          communityPost.userReaction == val ? -1 : val;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      new PopupMenuWidget(
                        height: 20,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: emojis
                                .asMap()
                                .entries
                                .map(
                                  (e) => Container(
                                    color: e.key == communityPost.userReaction
                                        ? Colors.blue
                                        : Colors.transparent,
                                    child: InkWell(
                                      onTap: () =>
                                          Navigator.of(context).pop(e.key),
                                      child: Image.asset(e.value, width: 30),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ];
                  },
                  child: Row(children: [
                    Icon(
                      Icons.add_reaction_outlined,
                      size: 20,
                    ),
                    numReactions > 0
                        ? Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: theme.colorScheme.surfaceVariant,
                            ),
                            child: Row(
                              children: emojis
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => (communityPost.reactionCount?[
                                                    e.key.toString()] ??
                                                0) >
                                            0
                                        ? Image.asset(e.value, width: 20)
                                        : Container(),
                                  )
                                  .toList(),
                            ),
                          )
                        : Container(),
                    numReactions > 0
                        ? Text(
                            numReactions.toString(),
                            style: theme.textTheme.bodySmall,
                          )
                        : Container(),
                  ]),
                ),
                Container(
                  margin: EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      IconButton(
                        enableFeedback: false,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        // iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: Icon(
                          Icons.reply,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () {
                          widget.onReply(communityPost);
                        },
                      ),
                      SizedBox(width: 3),
                      Text((communityPost.commentsCount ?? 0).toString(),
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                )
              ],
            ),
            // IconButton(
            //     onPressed: () async {
            //       await Share.share(
            //           "Check this post: ${ShareURLMaker.getCommunityPostURL(communityPost)}");
            //     },
            //     icon: Icon(
            //       Icons.share_outlined,
            //       color: theme.colorScheme.onSurfaceVariant,
            //       size: 20,
            //     ))
          ],
        ),
      ),
    );
  }
}
