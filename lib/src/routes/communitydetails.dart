import 'dart:async';

import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/blocs/community_bloc.dart';
import 'package:InstiApp/src/blocs/community_post_bloc.dart';
import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/routes/createpost_form.dart';
import 'package:InstiApp/src/utils/customappbar.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
    bool isLoggedIn = bloc.currSession != null;
    // print(community?.isUserFollowing);
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        transparentBackground: true,
        searchIcon: true,
        appBarSearchStyle:
            AppBarSearchStyle(hintText: "Search " + (community?.name ?? "")),
        //TODO: Uncomment leading style
        // leadingStyle: LeadingStyle(
        //     icon: Icons.arrow_back,
        //     onPressed: () async {
        //       Navigator.of(context).pop();
        //     }),
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
      body: !isLoggedIn
          ? Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(50),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud,
                    size: 200,
                    color: Colors.grey[600],
                  ),
                  Text(
                    "Login To Continue",
                    style: theme.textTheme.headline5,
                    textAlign: TextAlign.center,
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                bloc.communityBloc
                    .getCommunity(community!.id!)
                    .then((community) {
                  setState(() {
                    this.community = community;
                  });
                });
              },
              child: StreamBuilder<Object>(builder: (context, snapshot) {
                return SingleChildScrollView(
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
                                (community?.isUserFollowing ?? false)
                                    ? "Joined"
                                    : "Join",
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
                                      EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 1)),
                                  foregroundColor: MaterialStateProperty.all<Color>(
                                      Colors.white),
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                      (community?.isUserFollowing ?? false)
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.secondary),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          side: BorderSide(color: Colors.transparent)))),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.mode_edit,
          ),
          backgroundColor: Color.fromARGB(255, 33, 89, 243),
          onPressed: () {
            Navigator.of(context).pushNamed("/posts/add",
                arguments: NavigateArguments(community: community!));
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
  bool memberExpanded = false;

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
          ),
          _buildFeaturedPosts(theme, widget.community?.featuredPosts),
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
    return Container(
      padding: const EdgeInsets.all(5.0),

      child: ConstrainedBox(
        constraints: new BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height / 6,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ElevatedButton(
              //   child: Text(
              //     'SEE ALL',
              //     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              //   ),
              //   style: ElevatedButton.styleFrom(
              //     primary: Colors.white,
              //     onPrimary: Colors.blue,
              //     minimumSize: Size(400, 20),
              //   ),
              //   onPressed: () {},
              // ),
            ]..addAll(
                widget.community?.roles?.expand((r) {
                      if (r.roleUsersDetail != null) {
                        return r.roleUsersDetail!
                            .map((u) => u..currentRole = r.roleName)
                            .toList();
                      }
                      return [];
                    }).map((u) => _buildUserTile(theme, u)) ??
                    [],
              ),
          ),
        ),
      ),
      // ),
    );
  }

  Widget _buildUserTile(ThemeData theme, User u) {
    return ListTile(
      leading: NullableCircleAvatar(
        u.userProfilePictureUrl ?? "",
        Icons.person_outline_outlined,
        // heroTag: u.userID ?? "",
      ),
      title: Text(
        u.userName ?? "",
        style: theme.textTheme.headline6,
      ),
      subtitle: Text(
        u.getSubTitle() ?? "",
        style: theme.textTheme.bodySmall,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      minVerticalPadding: 0,
      dense: true,
      horizontalTitleGap: 4,
    );
  }

  Widget _buildFeaturedPosts(ThemeData theme, List<CommunityPost>? posts) {
    if (posts == null || posts.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        Container(
          child: Text(
            'Featured',
            style: theme.textTheme.headline5,
          ),
        ),
        Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // child: Container(
            //   child: CommunityPostWidget(
            //     communityPost: posts[0],
            //     communityId: posts[0].id,
            //     postType: CPType.Featured,
            //   ),
            // ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: posts
                  .map(
                    (e) => CommunityPostWidget(
                      communityPost: e,
                      postType: CPType.Featured,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class CommunityPostSection extends StatefulWidget {
  final Community? community;

  const CommunityPostSection({Key? key, required this.community})
      : super(key: key);

  @override
  State<CommunityPostSection> createState() => _CommunityPostSectionState();
}

class _CommunityPostSectionState extends State<CommunityPostSection> {
  bool firstBuild = true;
  // final Community? community;

  CPType cpType = CPType.All;

  _CommunityPostSectionState();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    firstBuild = true;
  }

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

    Community? community = widget.community;

    return community == null
        ? CircularProgressIndicatorExtended()
        : Container(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.4)),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        TextButton(
                          child: Text(
                            "All",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            setState(() {
                              loading = true;
                              cpType = CPType.All;
                            });
                            await communityPostBloc.refresh(type: CPType.All);
                            setState(() {
                              loading = false;
                            });
                          },
                          style: _getButtonStyle(cpType == CPType.All, theme),
                        ),
                        SizedBox(width: 10),
                        TextButton(
                          child: Text(
                            "Your Posts",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            setState(() {
                              loading = true;
                              cpType = CPType.YourPosts;
                            });
                            await communityPostBloc.refresh(
                                type: CPType.YourPosts);
                            setState(() {
                              loading = false;
                            });
                          },
                          style: _getButtonStyle(
                              cpType == CPType.YourPosts, theme),
                        ),
                        SizedBox(width: 10),
                        bloc.hasPermission(community.body!, "AppP")
                            ? TextButton(
                                child: Text(
                                  "Pending posts",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    loading = true;
                                    cpType = CPType.PendingPosts;
                                  });
                                  await communityPostBloc.refresh(
                                      type: CPType.PendingPosts);
                                  setState(() {
                                    loading = false;
                                  });
                                },
                                style: _getButtonStyle(
                                    cpType == CPType.PendingPosts, theme),
                              )
                            : Container(),
                        SizedBox(width: 10),
                        bloc.hasPermission(community.body!, "ModC")
                            ? TextButton(
                                child: Text(
                                  "Reported Content",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    loading = true;
                                    cpType = CPType.ReportedContent;
                                  });
                                  await communityPostBloc.refresh(
                                    type: CPType.ReportedContent,
                                  );
                                  setState(() {
                                    loading = false;
                                  });
                                },
                                style: _getButtonStyle(
                                    cpType == CPType.ReportedContent, theme),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 0,
                ),
                loading
                    ? CircularProgressIndicator()
                    : Container(
                        decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant),
                        child: StreamBuilder<List<CommunityPost>>(
                          stream: communityPostBloc.communityposts,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<CommunityPost>> snapshot) {
                            return Column(
                              children: _buildPostList(snapshot, theme,
                                  communityPostBloc, community.id),
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
              TextSpan(text: "Nothing here yet!"),
              // TextSpan(
              //     text: "\"${communityPostBloc.query}\"",
              //     style: TextStyle(fontWeight: FontWeight.bold)),
              // TextSpan(text: "."),
            ])),
          )
        ];
      }
      //print("a");
      return (communityPosts
          .map(
            (c) => CommunityPostWidget(
              communityPost: c,
              postType: cpType,
            ),
          )
          .toList());
    } else {
      return [
        Center(
            child: CircularProgressIndicatorExtended(
          label: Text("Loading..."),
        ))
      ];
    }
  }
}
