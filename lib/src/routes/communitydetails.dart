import 'dart:async';

import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/blocs/community_bloc.dart';
import 'package:InstiApp/src/utils/customappbar.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class CommunityDetails extends StatefulWidget {
  final Community? initialCommunity;
  final Future<Community?> communityFuture;

  CommunityDetails({required this.communityFuture, this.initialCommunity});

  static void navigateWith(
      BuildContext context, CommunityBloc bloc, Community community) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/group/${community.id ?? ""}",
        ),
        builder: (context) => CommunityDetails(
          initialCommunity: community,
          communityFuture: bloc.getCommunity(community.id ?? ""),
        ),
      ),
    );
  }

  @override
  _CommunityDetailsState createState() => _CommunityDetailsState();
}

class _CommunityDetailsState extends State<CommunityDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Community? community;

  int aboutIndex = 0;

  @override
  void initState() {
    super.initState();
    community = widget.initialCommunity;
    widget.communityFuture.then((community) {
      if (this.mounted) {
        setState(() {
          this.community = community;
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
        appBarSearchStyle:
            AppBarSearchStyle(hintText: "Search " + (community?.name ?? "")),
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
                community?.coverImg != null
                    ? Material(
                        type: MaterialType.transparency,
                        child: Ink.image(
                          child: Container(),
                          image: CachedNetworkImageProvider(
                            community?.coverImg ?? "",
                          ),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      )
                    : SizedBox(height: 200),
                SizedBox(
                  height: _avatarRadius + 5,
                ),
                _buildInfo(theme),
                CommunityAboutSection(community: community),
                CommunityPostSection(),
              ],
            ),
            Positioned(
              top: 200 - _avatarRadius,
              left: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.25),
                        ),
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.25),
                          spreadRadius: -2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: NullableCircleAvatar(
                      community?.logoImg ?? "",
                      Icons.person,
                      radius: _avatarRadius,
                    ),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    child: Text(
                      "Join",
                      style: theme.textTheme.subtitle1?.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.25,
                      ),
                    ),
                    onPressed: () {},
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 24, vertical: 1)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            theme.colorScheme.primary),
                        shape: MaterialStateProperty
                            .all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                side: BorderSide(color: Colors.transparent)))),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton( 
        child: Icon(
          Icons.mode_edit,
          ),
        backgroundColor: Color.fromARGB(255, 28, 122, 230),
        onPressed: () {
        Navigator.of(context).pushNamed("/posts/add");
      }),
    );
  }

  Widget _buildInfo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            community?.name ?? "",
            style: theme.textTheme.headline5,
          ),
          Text((community?.followersCount ?? 0).toString() + " followers"),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}

class CommunityAboutSection extends StatefulWidget {
  final Community? community;

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
    ThemeData theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    "About",
                    style: theme.textTheme.bodyText1,
                  ),
                ),
                Tab(
                  child: Text(
                    "Members",
                    style: theme.textTheme.bodyText1,
                  ),
                )
              ],
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
          IndexedStack(
            children: [
              _buildAbout(theme),
              _buildMembers(theme),
            ],
            index: _selectedIndex,
          )
        ],
      ),
    );
  }

  Widget _buildAbout(ThemeData theme) {
    String about = widget.community?.description ?? "";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text.rich(
        new TextSpan(
          text: about.length > 210 && !aboutExpanded
              ? about.substring(0, 200) + (aboutExpanded ? "" : "...")
              : about,
          children: !aboutExpanded && about.length > 210
              ? [
                  new TextSpan(
                    text: 'Read More.',
                    style: theme.textTheme.subtitle2
                        ?.copyWith(color: theme.colorScheme.primary),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () => setState(() {
                            aboutExpanded = true;
                          }),
                  )
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildMembers(ThemeData theme) {
    return Text("");
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
            child: Row(
              children: [
                SizedBox(width: 20),
                TextButton(
                  child: Text(
                    "Newest",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {},
                  style: _getButtonStyle(true, theme),
                ),
                SizedBox(width: 10),
                TextButton(
                  child: Text(
                    "Unanswered",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {},
                  style: _getButtonStyle(false, theme),
                )
              ],
            ),
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

  List<Widget> _buildPostList() {
    return [
      CommunityPostWidget(),
      
    ];
  }
}
