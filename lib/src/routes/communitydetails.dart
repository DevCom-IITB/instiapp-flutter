import 'dart:async';
import 'dart:convert';

import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/blocs/community_bloc.dart';
import 'package:InstiApp/src/blocs/community_post_bloc.dart';
import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/routes/communitypage.dart';
import 'package:InstiApp/src/utils/customappbar.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:json_annotation/json_annotation.dart';
import '../bloc_provider.dart';

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
  bool loadingFollow = false;

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

    var bloc = BlocProvider.of(context)!.bloc;
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
            onPressed: () async {
              bloc.communityBloc.refresh();
              await Navigator.of(context).pushNamed("/groups");
            }),
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
                CommunityPostSection(community: community),
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
                      (community?.isUserFollowing ?? false) ? "Joined" : "Join",
                      style: theme.textTheme.subtitle1?.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.25,
                      ),
                    ),
                    onPressed: () async {
                      if (bloc.currSession == null) {
                        return;
                      }
                      setState(() {
                        loadingFollow = true;
                      });
                      if (community != null)
                        await bloc.updateFollowCommunity(community!);
                      setState(() {
                        loadingFollow = false;
                        // event has changes
                      });
                    },
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 24, vertical: 1)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            (community?.isUserFollowing ?? false)
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary),
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
          backgroundColor: Color.fromARGB(255, 33, 89, 243),
          onPressed: () {
            Navigator.of(context)
                .pushNamed("/posts/add", arguments: community?.id);
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
  final Community? community;

  const CommunityPostSection({Key? key, required this.community})
      : super(key: key);

  @override
  State<CommunityPostSection> createState() =>
      _CommunityPostSectionState(community: community);
}

class _CommunityPostSectionState extends State<CommunityPostSection> {
  bool firstBuild = true;
  final Community? community;

  _CommunityPostSectionState({required this.community});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    var communityPostBloc = bloc.communityPostBloc;

    if (firstBuild) {
      communityPostBloc.query = "";
      communityPostBloc.refresh();
      firstBuild = false;
    }
    var communityPost;
    return Container(
      child: Column(
        children: [
          Container(
            height: 37,
            child: Text('Featured',
                style: TextStyle(
                  fontSize: 23.0,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Container(
              height: 239,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.8, color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(15))
                         ),
                      height: 223,
                      width: 285,
                      margin: EdgeInsets.all(8),
                      child: 
                      Column(
                        children: [
                          ListTile(
                            leading: NullableCircleAvatar(
                              //communityPost.postedBy?.userProfilePictureUrl ??
                              "https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg/1200px-Elon_Musk_Royal_Society_%28crop2%29.jpg",
                              Icons.person,
                              radius: 18,
                            ),
                            title: Text(
                              //communityPost.postedBy?.userName ??
                              "Prime Minister",
                              style: theme.textTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              "30 March",
                              style: theme.textTheme.bodySmall,
                            ),
                            // trailing: Icon(Icons.more_vert,
                            //     color: theme.colorScheme.onSurface),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            minVerticalPadding: 0,
                            dense: true,
                            horizontalTitleGap: 4,
                          ),
                          Container(
                            height: 14,
                            child: Text('anmol is boinn to clai uesss'),
                          ),
                          SizedBox(height: 2),
                          Container(
                            height: 130,
                            margin: EdgeInsets.fromLTRB(14, 2, 14, 7),
                            decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjGHyud7_PeGNa1uWQVfgOT4Zzidr8UlesDA&usqp=CAU",
                              ),
                              fit: BoxFit.cover,
                              ) ,
                            ),
                           // padding:  EdgeInsets.symmetric(horizontal: 10),
                           
                          ),
                        ],
                      ),
                      
                      
                    ),
                    SizedBox(width: 1),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.8, color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(15))
                         ),
                      height: 223,
                      width: 285,
                      margin: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          ListTile(
                            leading: NullableCircleAvatar(
                              //communityPost.postedBy?.userProfilePictureUrl ??
                              "https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg/1200px-Elon_Musk_Royal_Society_%28crop2%29.jpg",
                              Icons.person,
                              radius: 18,
                            ),
                            title: Text(
                              //communityPost.postedBy?.userName ??
                              "Chai wala",
                              style: theme.textTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              "32 March",
                              style: theme.textTheme.bodySmall,
                            ),
                            // trailing: Icon(Icons.more_vert,
                            //     color: theme.colorScheme.onSurface),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            minVerticalPadding: 0,
                            dense: true,
                            horizontalTitleGap: 4,
                          ),
                          Container(
                            height: 14,
                            child: Text('uio uioioi o uone !!!'),
                          ),
                          SizedBox(height: 2),
                          Container(
                            height: 130,
                            margin: EdgeInsets.fromLTRB(14, 2, 14, 7),
                            decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSL2VQ8U5Ab0juZsdw8AIhX1qLjvo6OScVTTQ&usqp=CAU",
                              ),
                              fit: BoxFit.cover,
                              ) ,
                            ),
                           // padding:  EdgeInsets.symmetric(horizontal: 10),
                           
                          ),
                        ],
                      ),
                      
                    ),
                  ],
                )
              ])
              //   ],
              // ),

              ),
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
            child: StreamBuilder<List<CommunityPost>>(
              stream: communityPostBloc.communityposts,
              builder: (BuildContext context,
                  AsyncSnapshot<List<CommunityPost>> snapshot) {
                // print("object");
                return Column(
                  children: _buildPostList(
                      snapshot, theme, communityPostBloc, community?.id),
                );
              },
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

  List<Widget> _buildPostList(
      AsyncSnapshot<List<CommunityPost>> snapshot,
      ThemeData theme,
      CommunityPostBloc communityPostBloc,
      String? communityId) {
    if (snapshot.hasData) {
      // print(snapshot.data ?? "hii");

      var communityPosts = snapshot.data!;

      if (communityPosts.isEmpty == true) {
        return [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child:
                Text.rich(TextSpan(style: theme.textTheme.headline6, children: [
              TextSpan(text: "Nothing found for the query "),
              TextSpan(
                  text: "\"${communityPostBloc.query}\"",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: "."),
            ])),
          )
        ];
      }
      return (communityPosts
          .map(
            (c) =>
                CommunityPostWidget(communityPost: c, communityId: communityId),
          )
          .toList());
    } else {
      return [
        Center(
            child: CircularProgressIndicatorExtended(
          label: Text("Loading the some default bodies"),
        ))
      ];
    }
  }
}
