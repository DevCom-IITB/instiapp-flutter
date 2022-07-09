import 'dart:async';

import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/blocs/community_post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/utils/customappbar.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';

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
  _CommunityDetailsState createState() => _CommunityDetailsState();
}

class _CommunityDetailsState extends State<CommunityPostPage> {
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
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    double _avatarRadius = 50;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        transparentBackground: true,
        searchIcon: true,
        
        leadingStyle: LeadingStyle(
          icon: Icons.arrow_back,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
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
                print("lol");
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }
}
