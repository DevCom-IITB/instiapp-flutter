import 'dart:async';

import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/blocs/community_bloc.dart';
import 'package:InstiApp/src/routes/communitydetails.dart';
import 'package:InstiApp/src/utils/customappbar.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class CommunityPostPage extends StatefulWidget {
  // final CommunityPost? communityPost;
  final String? test;
  // final Future<CommunityPost?> communityFuture;

  CommunityPostPage({this.test});

  static void navigateWith(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/post/",
        ),
        builder: (context) => CommunityPostPage(
            // communityPost: communitypost,
            test: "hello"
            // //communityFuture: bloc.getCommunityDetails(community.id ?? ""),
            ),
      ),
    );
  }

  @override
  _CommunityPostPageState createState() => _CommunityPostPageState();
}

class _CommunityPostPageState extends State<CommunityPostPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  CommunityPost? community;

  int aboutIndex = 0;

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    double _avatarRadius = 50;

    return Scaffold(
      body: CommunityPostWidget(),
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
    );
  }
}
