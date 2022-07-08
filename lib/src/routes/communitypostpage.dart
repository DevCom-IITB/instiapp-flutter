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
  final String? test;

  CommunityPostPage({required this.test});

  static void navigateWith(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/post/",
        ),
        builder: (context) => CommunityPostPage(
          test: "community",
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
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        transparentBackground: true,
        searchIcon: true,
        appBarSearchStyle: AppBarSearchStyle(hintText: "Search "),
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
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommunityPostSection(),
              ],
            ),
            Positioned(
              top: 200 - _avatarRadius,
              left: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/posts/add");
        },
        child: Icon(Icons.create_outlined),
      ),
    );
  }

  Widget _buildInfo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [],
      ),
    );
  }
}

class CommunityAboutSection extends StatefulWidget {
  final CommunityPost? community;

  const CommunityAboutSection({Key? key, required this.community})
      : super(key: key);

  @override
  State<CommunityAboutSection> createState() => CommunityAboutSectionState();
}

class CommunityAboutSectionState extends State<CommunityAboutSection> {
  int _selectedIndex = 0;

  bool aboutExpanded = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}

class CommunityPostSection extends StatefulWidget {
  const CommunityPostSection({Key? key}) : super(key: key);

  @override
  State<CommunityPostSection> createState() => _CommunityPostSectionState();
}

class _CommunityPostSectionState extends State<CommunityPostSection> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4)),
          ),
          Divider(
            color: theme.colorScheme.onSurfaceVariant,
            height: 0,
          ),
          Container(
            decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant),
            child: Column(
              children: _buildPostList(),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildPostList() {
    return [CommunityPostWidget()];
  }

  List<Widget> _buildCommentList() {
    return [CommunityCommentWidget(), CommunityCommentWidget()];
  }
}
