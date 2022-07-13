import 'dart:async';

import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/blocs/community_post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/utils/customappbar.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';

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

  CommunityPost? communityPost;

  int aboutIndex = 0;

  @override
  void initState() {
    super.initState();
    communityPost = widget.initialCommunityPost;
    widget.communityPostFuture.then((communityPost) {
      if (this.mounted) {
        setState(() {
          this.communityPost = communityPost;
        });
      }
    });
    //print(communityPost?.comments);
  }

  // void initComment(CommunityPost? comment) {
  //   var bloc = BlocProvider.of(context)!.bloc;
  //   var communityPostBloc = bloc.communityPostBloc;
  //   final Future<CommunityPost?> commentFuture =
  //       communityPostBloc.getCommunityPost(comment?.id ?? "");
  //   CommunityPost? finalComment;
  //   commentFuture.then((comment) {
  //     if (this.mounted) {
  //       setState(() {
  //         finalComment = comment;
  //       });
  //     }
  //   });
  //   print("object");
  //   print(comment?.comments);
  // }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // initState();
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
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
      body: SingleChildScrollView(
          child: Column(
        children: [
          _buildPost(theme, communityPost),
        ],
      )),
    );
  }

  ButtonStyle _getButtonStyle(bool selected, ThemeData theme) {
    return ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 15, vertical: 0)),
      foregroundColor: MaterialStateProperty.all<Color>(
        selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
          side: BorderSide(
            width: selected ? 2 : 1,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildPost(ThemeData theme, CommunityPost? communityPost) {
    List<String> imgList = [
      "https://media.pitchfork.com/photos/620e81cad8bc62857b465cc3/2:1/w_2560%2Cc_limit/Stranger-Things-Season-4.jpg",
      "https://www.denofgeek.com/wp-content/uploads/2019/04/infinity-war-montage-main.jpg?resize=768%2C432",
      "https://www.pluggedin.com/wp-content/uploads/2020/01/family-guy-scaled.jpg",
      "https://www.thenexthint.com/wp-content/uploads/2021/09/Is-BoJack-Horseman-Season-7-Cancelled-by-Netflix-1.jpeg.webp",
      "https://cdn.searchenginejournal.com/wp-content/uploads/2021/04/journalism-tactics-60812472af9db-1520x800.png",
    ];

    return (Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 30,
                  spreadRadius: -18,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 1,
                              color: theme.colorScheme.surfaceVariant))),
                  child: ListTile(
                    leading: NullableCircleAvatar(
                      communityPost?.postedBy?.userProfilePictureUrl ??
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg/1200px-Elon_Musk_Royal_Society_%28crop2%29.jpg",
                      Icons.person,
                      radius: 18,
                    ),
                    title: Text(
                      communityPost?.postedBy?.userName ?? "user",
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      "30 March",
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Icon(Icons.more_vert,
                        color: theme.colorScheme.onSurface),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    minVerticalPadding: 0,
                    dense: true,
                    horizontalTitleGap: 4,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Text(
                    communityPost?.content ?? '''post''',
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child:
                      ImageGallery(images: communityPost?.imageUrl ?? imgList),
                ),
                _buildFooter(theme, communityPost),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(children: _buildCommentList(theme, communityPost)))
        ],
      ),
    ));
  }

  List<Widget> _buildCommentList(
      ThemeData theme, CommunityPost? communityPost) {
    if (communityPost?.comments?.isEmpty == true) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
          child:
              Text.rich(TextSpan(style: theme.textTheme.headline6, children: [
            TextSpan(text: "Nothing found for the query "),
            TextSpan(text: "."),
          ])),
        )
      ];
    }
    // initComment(communityPost);
    return (communityPost?.comments
                ?.map((c) => _buildListTile(c, theme, communityPost)) ??
            [])
        .toList();
  }

  Widget _buildListTile(
      CommunityPost comment, ThemeData theme, CommunityPost post) {
    List<String> imgList = [
      "https://media.pitchfork.com/photos/620e81cad8bc62857b465cc3/2:1/w_2560%2Cc_limit/Stranger-Things-Season-4.jpg",
      "https://www.denofgeek.com/wp-content/uploads/2019/04/infinity-war-montage-main.jpg?resize=768%2C432",
      "https://www.pluggedin.com/wp-content/uploads/2020/01/family-guy-scaled.jpg",
      "https://www.thenexthint.com/wp-content/uploads/2021/09/Is-BoJack-Horseman-Season-7-Cancelled-by-Netflix-1.jpeg.webp",
      "https://cdn.searchenginejournal.com/wp-content/uploads/2021/04/journalism-tactics-60812472af9db-1520x800.png",
    ];
    var borderRadius = const BorderRadius.all(Radius.circular(10));

    return (comment.parent == post.id)
        ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Container(
                child: NullableCircleAvatar(
              communityPost?.postedBy?.userProfilePictureUrl ??
                  "https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg/1200px-Elon_Musk_Royal_Society_%28crop2%29.jpg",
              Icons.person,
              radius: 18,
            )),
            Container(
            margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 30,
                  spreadRadius: -18,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
            child: Column(
              children: [
                  
                  Container(
                  
                    
                    width: 300,
                  child: ListTile(
                    title: Text(
                      comment.postedBy?.userName ?? "user",
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      "30 March",
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Icon(Icons.more_vert,
                        color: theme.colorScheme.onSurface),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    minVerticalPadding: 0,
                    dense: true,
                    horizontalTitleGap: 4,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Text(
                    comment.content ?? '''post''',
                  ),
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 10),
                //   child: ImageGallery(images: comment.imageUrl ?? imgList),
                // ),
                _buildFooter(theme, comment),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(children: _buildCommentList(theme, comment)))
              ],
            ),
            )
          ])
        : Column();
  }

  Widget _buildFooter(ThemeData theme, CommunityPost? communityPost) {
    return Container(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 20,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/communities/emojis/laugh.png",
                        width: 20,
                      ),
                      Image.asset(
                        "assets/communities/emojis/cry.png",
                        width: 20,
                      ),
                      Image.asset(
                        "assets/communities/emojis/angry.png",
                        width: 20,
                      ),
                      Image.asset(
                        "assets/communities/emojis/surprise.png",
                        width: 20,
                      ),
                    ],
                  ),
                ),
                Text(communityPost?.userReaction.toString() ?? "filler",
                    style: theme.textTheme.bodySmall),
                Container(
                  margin: EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mode_comment_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 3),
                      Text((communityPost?.commentsCount).toString(),
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                )
              ],
            ),
            Icon(
              Icons.share_outlined,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}
