import 'dart:async';
import 'dart:convert';

import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/blocs/community_bloc.dart';
import 'package:InstiApp/src/blocs/community_post_bloc.dart';
import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/routes/communitypostpage.dart';
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
            child: StreamBuilder<List<CommunityPost>>(
              stream: communityPostBloc.communityposts,
              builder: (BuildContext context,
                  AsyncSnapshot<List<CommunityPost>> snapshot) {
                // print("object");
                return Column(
                  children: _buildPostList(snapshot, theme, communityPostBloc),
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

  List<Widget> _buildPostList(AsyncSnapshot<List<CommunityPost>> snapshot,
      ThemeData theme, CommunityPostBloc communityPostBloc) {
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
                // _buildListTile(c, theme, communityPostBloc),
                CommunityPostWidget(communityPost: c),
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

  Widget _buildListTile(
    CommunityPost communityPost,
    ThemeData theme,
    CommunityPostBloc bloc,
  ) {
    List<String> imgList = [
      "https://media.pitchfork.com/photos/620e81cad8bc62857b465cc3/2:1/w_2560%2Cc_limit/Stranger-Things-Season-4.jpg",
      "https://www.denofgeek.com/wp-content/uploads/2019/04/infinity-war-montage-main.jpg?resize=768%2C432",
      "https://www.pluggedin.com/wp-content/uploads/2020/01/family-guy-scaled.jpg",
      "https://www.thenexthint.com/wp-content/uploads/2021/09/Is-BoJack-Horseman-Season-7-Cancelled-by-Netflix-1.jpeg.webp",
      "https://cdn.searchenginejournal.com/wp-content/uploads/2021/04/journalism-tactics-60812472af9db-1520x800.png",
    ];
    var borderRadius = const BorderRadius.all(Radius.circular(10));
    // print(communityPost.threadRank);
    // print(communityPost.imageUrl);
    return (communityPost.threadRank == 1)
        ? GestureDetector(
            onTap: () =>
                {CommunityPostPage.navigateWith(context, bloc, communityPost)},
            child: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.colorScheme.surface,
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
                        communityPost.postedBy?.userProfilePictureUrl ??
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg/1200px-Elon_Musk_Royal_Society_%28crop2%29.jpg",
                        Icons.person,
                        radius: 18,
                      ),
                      title: Text(
                        communityPost.postedBy?.userName ?? "user",
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
                      communityPost.content ?? '''post''',
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ImageGallery(images: communityPost.imageUrl ?? []),
                  ),
                  _buildFooter(theme, communityPost),
                ],
              ),
            ))
        : Column();
  }

  Widget _buildFooter(ThemeData theme, CommunityPost communityPost) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.surface,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          // border:
          //     Border(top: BorderSide(color: theme.colorScheme.surfaceVariant)),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 3),
              blurRadius: 30,
              spreadRadius: -18,
              color: theme.colorScheme.onSurface,
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: theme.colorScheme.surfaceVariant,
                  ),
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
                Text(communityPost.userReaction.toString(),
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
                      Text((communityPost.commentsCount).toString(),
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
