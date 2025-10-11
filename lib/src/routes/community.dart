import 'package:InstiApp/constants.dart';
import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/community_bloc.dart';
import 'package:InstiApp/src/blocs/community_post_bloc.dart';
import 'package:InstiApp/src/routes/createpost_form.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/communitypostwidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/api/model/user.dart';

class Responsive {
  final BuildContext context;
  final double baseWidth;
  final double baseHeight;

  Responsive(this.context, {this.baseWidth = 411, this.baseHeight = 914});

  double w(double px) => MediaQuery.of(context).size.width * (px / baseWidth);
  double h(double px) => MediaQuery.of(context).size.height * (px / baseHeight);
  double sp(double px) => w(px); // scale text with width
}

class Communities extends StatefulWidget {
  final Community? initialCommunity;
  final Future<Community?> communityFuture;
  const Communities({required this.communityFuture, this.initialCommunity});

  static void navigateWith(
      BuildContext context, CommunityBloc bloc, Community community) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/group/${community.id ?? ""}",
        ),
        builder: (context) => Communities(
          initialCommunity: community,
          communityFuture: bloc.getCommunity(community.id ?? ""),
        ),
      ),
    );
  }

  @override
  State<Communities> createState() => _CommunitiesState();
}

class _CommunitiesState extends State<Communities> {
  Community? community;
  bool loadingFollow = false;
  Constants myConstants = Constants();
  bool aboutExpanded = false;
  final List<String> _filterTabs = ['Sort', 'Filter'];
  List<String> subContLabels = ["Hostel Affairs", "Interns", "Tech"];
  // Widget _buildUserTile(User u) {
  // return ListTile(
  //   title: Text(u.userName ?? ""),
  //   subtitle: Text(u.currentRole ?? ""),
  //   dense: true,
  //   contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
  //   );
  // }
  // Widget _membersTab() {
  // // Flatten roles -> users and annotate each user with their role
  // final members = widget.community?.roles
  //         ?.expand((r) =>
  //             (r.roleUsersDetail
  //                     ?.map((u) {
  //                       u.currentRole = r.roleName;   // annotate the user object
  //                       return u;
  //                     })
  //                     .toList()) ??
  //                 [])
  //         .toList() ??
  //     [];

  // if (members.isEmpty) {
  //   return Center(child: Text("No members yet."));
  // }

  // return ListView.separated(
  //   padding: EdgeInsets.symmetric(vertical: 8),
  //   itemCount: members.length,
  //   separatorBuilder: (_, __) => Divider(height: 0),
  //   itemBuilder: (context, index) {
  //     final u = members[index];
  //     return _buildUserTile(u);
  //   },
  // );
// }

  Widget members(Map<String, Map<String, String>> membersList) {
    List<Map<String, String>> member = membersList.values.toList();
    return Column(
      children: [
        for (int i = 0; i < member.length; i++) ...[
          Row(
            children: [
              Container(
                height: 63,
                width: 63,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey),
              ),
              SizedBox(
                width: 16,
              ),
              Container(
                width: 213,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member[i]["name"] ?? "",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      member[i]["year"] ?? "",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 16,
              ),
              member[i]["role"] == "Admin"
                  ? Container(
                      height: 24,
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: myConstants.instiappBlue,
                      ),
                      child: Center(
                        child: Text(
                          "Admin",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(), // shows nothing if not Admin
            ],
          ),
          SizedBox(
            height: 16,
          )
        ]
      ],
    );
  }

  Widget subCont(String label) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          border: Border.all(
            color: myConstants.instiappBlue,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: myConstants.instiappBlue),
        ),
      ),
    );
  }

  Widget LinkContainer(String label, String link, bool isTop, bool isBottom) {
    final responsive = Responsive(context);
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(link);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          throw "Could not launch ${url}";
        }
      },
      child: Container(
        height: responsive.h(63),
        width: responsive.w(380),
        decoration: BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.vertical(
                top: isTop ? Radius.circular(16) : Radius.zero,
                bottom: isBottom ? Radius.circular(16) : Radius.zero),
            border: isBottom
                ? null
                : Border(
                    bottom: BorderSide(
                        width: responsive.h(1), color: Color(0x80D2D5DA)))),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: responsive.w(16), vertical: responsive.h(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  color: const Color(0xFF0F1620),
                  fontSize: responsive.sp(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                height: responsive.h(24),
                width: responsive.w(24),
                child: SvgPicture.asset(
                    'assets/quicklinks/icons/external_link.svg'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget LinkSection(String title, Map<String, String> links) {
    final responsive = Responsive(context);
    List<String> keys = links.keys.toList();
    List<String> values = links.values.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xFF1B3252),
              fontSize: responsive.sp(16),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (int i = 0; i < keys.length; i++) ...[
          LinkContainer(keys[i], values[i], i == 0, i == keys.length - 1),
        ],
      ],
    );
  }

  Widget sort() {
    return Container(
      height: 36,
      //width: 108,
      decoration: BoxDecoration(
        color: Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Color(0XFFD2D5DA), // your border color here
          width: 1, // thickness of the border
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SvgPicture.asset('assets/feed/setting-4.svg'),
            SizedBox(width: 8),
            Text(
              "Sort",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(width: 8),
            SvgPicture.asset(
              'assets/homepage/icons/arrow_down.svg',
              height: 14,
              width: 16,
            )
          ],
        ),
      ),
    );
  }
// Widget postTypeContainer(CPType cp, CommunityPostBloc communityPostBloc, String label){
//   final bool isSelected = cpType == cp;
//   return GestureDetector(
//     onTap: () async{
//       setState(() {
//         loading = true;
//         cpType = cp;
//       });
//       await communityPostBloc.refresh(
//         type: cp, id: widget.community?.id);
//         setState(() {
//           loading = false;
//         });
//     },
//     child: Container(
//       height: 36,
//       decoration: BoxDecoration(
//         color: Color(0xFFEFEFEF),
//         borderRadius: BorderRadius.circular(50),
//         border: Border.all(
//           color: isSelected?myConstants.instiappBlue:Color(0XFFD2D5DA), // your border color here
//           width: 1,           // thickness of the border
//         ),
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
//         child: Row(
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: isSelected?myConstants.instiappBlue:Colors.black
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

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
    bool isLoggedIn = bloc.currSession != null;
    final responsive = Responsive(context);
    Map<String, Map<String, String>> quickLinks = {
      "Quick external links": {
        "WhatsApp": "https://google.com",
        "Discord": "https://google.com",
        "Google Drive": "https://google.com"
      },
    };
    // Map<String,String> cPost={
    //   "name":"Tanvi Sharma",
    //   "date":"13 Jan, 2024",
    //   "content":"Just wanted to get your thoughts on when we should kick off the party! We want to make sure it works for most of you. Please vote for your preferred timing below and feel free to drop any suggestions.",
    //   "reactionCount":"2",
    //   "commentCount":"14",
    // };
    Map<String, Map<String, String>> memberList = {
      "member1": {
        "name": "Tanvi Sharma",
        "role": "Admin",
        "year": "3rd year",
      },
      "member2": {
        "name": "Tanvi Sharma",
        "role": "Admin",
        "year": "3rd year",
      },
      "member3": {
        "name": "Tanvi Sharma",
        "role": "Member",
        "year": "3rd year",
      }
    };
    List<String> linkLabel = quickLinks.keys.toList();
    List<Map<String, String>> links = quickLinks.values.toList();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            child: SvgPicture.asset(
              "assets/communities/system-uicons_write.svg",
              height: 24,
              width: 24,
              color: Colors.white,
            ),
            backgroundColor: Color.fromRGBO(48, 111, 220, 1),
            onPressed: () {
              Navigator.of(context).pushNamed("/posts/add",
                  arguments: NavigateArguments(community: community!));
            }),
        body: !isLoggedIn
            ? Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(50),
                child: Text("Login to Continue"),
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
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    children: [
                      // --- Banner with buttons ---
                      Stack(
                        children: [
                          SizedBox(
                            height: 32,
                          ),
                          Container(
                            height: 153,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              image: community?.coverImg != null &&
                                      community!.coverImg!.isNotEmpty
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          community!.coverImg!),
                                      fit: BoxFit.cover,
                                      //alignment: Alignment.topCenter,
                                    )
                                  : const DecorationImage(
                                      image: AssetImage(
                                          'assets/explore/symphony.png'),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(left: responsive.w(16)),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                        color: const Color(0x99FFFFFF),
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    child: Center(
                                      child: Container(
                                        height: responsive.h(24),
                                        width: responsive.w(24),
                                        child: SvgPicture.asset(
                                            'assets/quicklinks/icons/arrow_left.svg'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(right: responsive.w(16)),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                        color: const Color(0x99FFFFFF),
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    child: Center(
                                      child: Container(
                                        height: responsive.h(24),
                                        width: responsive.w(24),
                                        child: SvgPicture.asset(
                                            'assets/homepage/icons/bell.svg'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // --- Club Info ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 63,
                                  width: 63,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(31.5),
                                    child: NullableCircleAvatar(
                                      community?.logoImg ?? "",
                                      Icons.person,
                                      radius: 31.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        community?.name ?? "",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F1620),
                                        ),
                                      ),
                                      // Text(
                                      //   "Music Club of IITB",
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     fontWeight: FontWeight.w400,
                                      //     color: Color(0xFF0F1620),
                                      //   ),
                                      // ),
                                      Row(
                                        children: [
                                          Text(
                                            (community?.followersCount ?? 0)
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF306FDC),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Members",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF306FDC),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 25),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        if (bloc.currSession == null) {
                                          return;
                                        }
                                        setState(() {
                                          loadingFollow = true;
                                        });
                                        if (community != null)
                                          await bloc.updateFollowCommunity(
                                              community!);
                                        setState(() {
                                          loadingFollow = false;
                                        });
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 61,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF306FDC),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: Center(
                                          child: Text(
                                            (community?.isUserFollowing ??
                                                    false)
                                                ? "Joined"
                                                : "Join",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Container(
                                    //   height: 30,
                                    //   width: 30,
                                    //   decoration: BoxDecoration(
                                    //     color: Color(0xFFF6F6F6),
                                    //     borderRadius: BorderRadius.circular(25),
                                    //   ),
                                    //   child:
                                    //       Center(child: Icon(Icons.more_vert)),
                                    // ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              //height: aboutExpanded?192:72,
                              child: _buildAbout(theme)
                            ),
                            // const Text(
                            //     "Use this forum to Lorem ipsum dolorajhds Read More"),
                            // const SizedBox(height: 10),
                            Row(
                              children: [
                                // for (int i = 0;
                                //     i < subContLabels.length;
                                //     i++) ...[
                                //   subCont(subContLabels[i]),
                                //   const SizedBox(width: 8),
                                // ]
                              ],
                            ),
                            // const SizedBox(height: 16),
                            // Dash(
                            //   direction: Axis.horizontal,
                            //   length: responsive.w(379),
                            //   dashLength: 6,
                            //   dashGap: 5,
                            //   dashColor: const Color(0xFFDADADA),
                            // ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // --- Tabs ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Stack(
                          children: [
                            Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                    height: 1.5, color: Color(0xFFD0D5DD))),
                            TabBar(
                              indicatorColor: myConstants.instiappBlue,
                              labelColor: myConstants.instiappBlue,
                              unselectedLabelColor: Colors.black54,
                              labelStyle: TextStyle(
                                fontSize: responsive.sp(16),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'DM Sans',
                              ),
                              tabs: const [
                                Tab(text: 'Posts'),
                                Tab(text: 'Links'),
                                Tab(text: 'Members'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // --- Tab Content (fills remaining space) ---
                      Expanded(
                        child: TabBarView(
                          children: [
                            //posts
                            SingleChildScrollView(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                child: Column(
                                  children: [
                                    // Communitypostwidget(c: cPost),
                                    // Communitypostwidget(c: cPost),
                                    // Communitypostwidget(c: cPost),
                                    CommunityPostSection(community: community),
                                    //SizedBox(height: 100,)
                                  ],
                                ),
                              ),
                            ),
                            //links
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 24),
                                  for (int i = 0;
                                      i < linkLabel.length;
                                      i++) ...[
                                    LinkSection(linkLabel[i], links[i]),
                                  ],
                                  SizedBox(height: 12)
                                ],
                              ),
                            ),
                            //members
                            //_membersTab(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  SizedBox(height: 24),
                                  Row(
                                    children: [
                                      // sort(),
                                    ],
                                  ),
                                  // SizedBox(
                                  //   height: 26,
                                  // ),
                                  //members(memberList),
                                  _buildMembers(theme)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
  Widget _buildAbout(ThemeData theme) {
    String about = community?.description ?? "";
    return SizedBox(
      height: aboutExpanded ? 200 : 72,
      child: SingleChildScrollView(
        physics: aboutExpanded
        ? ClampingScrollPhysics()
        :NeverScrollableScrollPhysics(),
        child: Text.rich(
          new TextSpan(
            text: about.length > 160 && !aboutExpanded
                ? about.substring(0, 160) + (aboutExpanded ? "" : "...")
                : about,
            children: !aboutExpanded && about.length > 160
                ? [
                    new TextSpan(
                      text: 'Read More',
                      style: TextStyle(
                        color: myConstants.instiappBlue,
                        fontWeight: FontWeight.w600
                      ),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () => setState(() {
                              aboutExpanded = true;
                            }),
                    )
                  ]
                : [
                  new TextSpan(
                      text: ' Read Less',
                      style: TextStyle(
                        color: myConstants.instiappBlue,
                        fontWeight: FontWeight.w600
                      ),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () => setState(() {
                              aboutExpanded = false;
                            }),
                    )
                ],
          ),
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
                community?.roles?.expand((r) {
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

  // Widget _buildUserTile(ThemeData theme, User u) {
  //   return ListTile(
  //     leading: NullableCircleAvatar(
  //       u.userProfilePictureUrl ?? "",
  //       Icons.person_outline_outlined,
  //       // heroTag: u.userID ?? "",
  //     ),
  //     title: Text(
  //       u.userName ?? "",
  //       style: theme.textTheme.titleLarge,
  //     ),
  //     subtitle: Text(
  //       u.getSubTitle() ?? "",
  //       style: theme.textTheme.bodySmall,
  //     ),
  //     contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
  //     minVerticalPadding: 0,
  //     dense: true,
  //     horizontalTitleGap: 4,
  //   );
  // }
  Widget _buildUserTile(ThemeData theme, User u) {
    final isAdmin = (u.currentRole?.toLowerCase() == "admin");

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Profile picture container
          Container(
            height: 63,
            width: 63,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade300,
              image: u.userProfilePictureUrl != null &&
                      u.userProfilePictureUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(u.userProfilePictureUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (u.userProfilePictureUrl == null ||
                    u.userProfilePictureUrl!.isEmpty)
                ? const Icon(Icons.person, size: 32, color: Colors.white)
                : null,
          ),

          const SizedBox(width: 16),

        // Name and subtitle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 213,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.userName ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    //u.getSubTitle() ?? "",
                    "3rd year",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            if (isAdmin)
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: myConstants.instiappBlue,
                ),
              child: const Center(
                child: Text(
                  "Admin",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),

        
        // Admin tag (if applicable)
        // if (isAdmin)
        //   Container(
        //     height: 24,
        //     padding: const EdgeInsets.symmetric(horizontal: 6),
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(8),
        //       color: myConstants.instiappBlue,
        //     ),
        //     child: const Center(
        //       child: Text(
        //         "Admin",
        //         style: TextStyle(
        //           color: Colors.white,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    ),
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
  //  final Community? community;
  //String id=community.id;
  CPType cpType = CPType.All;
  Constants myConstants = Constants();
  _CommunityPostSectionState();
  final List<String> _filterTabs = ['Sort', 'Filter'];
  int _selectedFilterTabIndex = 0;

  bool loading = false;
  Widget sort() {
    return GestureDetector(
      onTap: () {
        _openSortBottomSheet();
      },
      child: Container(
        height: 36,
        //width: 108,
        decoration: BoxDecoration(
          color: Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Color(0XFFD2D5DA),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SvgPicture.asset('assets/feed/setting-4.svg'),
              SizedBox(width: 8),
              Text(
                "Sort",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(width: 8),
              SvgPicture.asset(
                'assets/homepage/icons/arrow_down.svg',
                height: 14,
                width: 16,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openSortBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.99,
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xFFF6F6F6),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16))),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(246, 246, 246, 1),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sort By',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 20),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    //Main Content
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Navigation Rail
                          Container(
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(246, 246, 246, 1),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(24)),
                            ),
                            child: Column(
                              children: [
                                ..._filterTabs.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final label = entry.value;
                                  final isSelected =
                                      index == _selectedFilterTabIndex;

                                  return GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        _selectedFilterTabIndex = index;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 0),
                                      decoration: BoxDecoration(
                                        // 1. base color: white if not selected, grey if selected
                                        color: isSelected
                                            ? Color.fromRGBO(239, 239, 239, 1)
                                            : Color.fromRGBO(246, 246, 246, 1),
                                        // 2. gradient only on selected: blue line → grey
                                        gradient: isSelected
                                            ? const LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                stops: [
                                                  0.0,
                                                  0.05,
                                                  0.06,
                                                  0.7,
                                                  0.99
                                                ],
                                                colors: [
                                                  Color.fromRGBO(
                                                      48, 111, 220, 1),
                                                  Color.fromRGBO(
                                                      48, 111, 220, 1),
                                                  Color.fromRGBO(
                                                      48, 111, 220, 0.2),
                                                  Color.fromRGBO(
                                                      239, 239, 239, 0.4),
                                                  Color.fromRGBO(
                                                      239, 239, 239, 0.8)
                                                ],
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          label,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),

                          // Content area
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(239, 239, 239, 1),
                                borderRadius: BorderRadius.only(
                                  topLeft: _selectedFilterTabIndex == 0
                                      ? Radius.circular(0)
                                      : Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                ),
                              ),
                              child: _buildFilterTabPanel(setModalState),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(246, 246, 246, 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Clear Filters Button
                          SizedBox(
                            width: 165,
                            height: 60,
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  // _sortBy = 'Recently Added';
                                  // _selectedCategories = null;
                                  // _isNegotiable = null;
                                });
                                setState(() {});
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.zero, // ensure height fits
                              ),
                              child: const Text(
                                "Clear All",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),

                          // Apply Filters Button
                          SizedBox(
                            width: 165,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {});
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        "assets/buynsell/filterbutton.png"),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: const Text(
                                    "Apply",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget _buildFilterTabPanel(StateSetter setModalState) {
    switch (_filterTabs[_selectedFilterTabIndex]) {
      case 'Sort':
        //return _buildSortPanel(setModalState);
        return const SizedBox();
      case 'Filter':
        //return _buildFilterPanel(setModalState);
        return const SizedBox();
      default:
        return const SizedBox();
    }
  }

  Widget postTypeContainer(
      CPType cp, CommunityPostBloc communityPostBloc, String label) {
    final bool isSelected = cpType == cp;
    return GestureDetector(
      onTap: () async {
        setState(() {
          loading = true;
          cpType = cp;
        });
        await communityPostBloc.refresh(type: cp, id: widget.community?.id);
        setState(() {
          loading = false;
        });
      },
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected
                ? myConstants.instiappBlue
                : Color(0XFFD2D5DA), // your border color here
            width: 1, // thickness of the border
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? myConstants.instiappBlue : Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

    loading = false;
    if (firstBuild) {
      communityPostBloc.query = "";
      communityPostBloc.refresh(id: widget.community?.id);
      firstBuild = false;
    }

    Community? community = widget.community;

    return community == null
        ? CircularProgressIndicatorExtended()
        : Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Row(
                          children: [
                            //sort(),
                            //SizedBox(width: 8),
                            postTypeContainer(CPType.All, communityPostBloc,"All"),
                            SizedBox(width: 8),
                            postTypeContainer(CPType.YourPosts,
                                communityPostBloc, "Your Posts"),
                            // TextButton(
                            //   child: Text(
                            //     "All",
                            //     style: TextStyle(fontWeight: FontWeight.w500),
                            //   ),
                            //   onPressed: () async {
                            //     setState(() {
                            //       loading = true;
                            //       cpType = CPType.All;
                            //     });
                            //     await communityPostBloc.refresh(
                            //         type: CPType.All, id: widget.community?.id);
                            //     setState(() {
                            //       loading = false;
                            //     });
                            //   },
                            //   style: _getButtonStyle(cpType == CPType.All, theme),
                            // ),
                            // SizedBox(width: 10),
                            // TextButton(
                            //   child: Text(
                            //     "Your Posts",
                            //     style: TextStyle(fontWeight: FontWeight.bold),
                            //   ),
                            //   onPressed: () async {
                            //     setState(() {
                            //       loading = true;
                            //       cpType = CPType.YourPosts;
                            //     });
                            //     await communityPostBloc.refresh(
                            //         type: CPType.YourPosts,
                            //         id: widget.community?.id);
                            //     setState(() {
                            //       loading = false;
                            //     });
                            //   },
                            //   style: _getButtonStyle(
                            //       cpType == CPType.YourPosts, theme),
                            // ),
                            // SizedBox(width: 10),
                            bloc.hasPermission(community.body!, "AppP")
                                ? TextButton(
                                    child: Text(
                                      "Pending posts",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                        cpType = CPType.PendingPosts;
                                      });
                                      await communityPostBloc.refresh(
                                          type: CPType.PendingPosts,
                                          id: widget.community?.id);
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                        cpType = CPType.ReportedContent;
                                      });
                                      await communityPostBloc.refresh(
                                        type: CPType.ReportedContent,
                                        id: widget.community?.id,
                                      );
                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    style: _getButtonStyle(
                                        cpType == CPType.ReportedContent,
                                        theme),
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Divider(
                //   color: theme.colorScheme.onSurfaceVariant,
                //   height: 0,
                // ),
                loading
                    ? CircularProgressIndicator()
                    : Container(
                      padding: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(color: Colors.white),
                        child: StreamBuilder<List<CommunityPost>>(
                          stream: communityPostBloc.communityposts,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<CommunityPost>> snapshot) {
                            return Column(
                              spacing: 16,
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
      padding: WidgetStateProperty.all<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 15, vertical: 0)),
      foregroundColor: WidgetStateProperty.all<Color>(
        selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
            padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 200.0),
            child: Center(
                child: Text(
              "Nothing here yet!",
              style: TextStyle(fontSize: 18),
            )),
          )
        ];
      }
      //print("a");
      return (communityPosts
          .map(
            (c) => Communitypostwidget(
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
