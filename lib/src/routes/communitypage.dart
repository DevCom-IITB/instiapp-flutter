import 'package:InstiApp/constants.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/community_bloc.dart';
import 'package:InstiApp/src/routes/community.dart';
import 'package:InstiApp/src/utils/customappbar.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/routes/communitydetails.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:share/share.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';

import '../utils/share_url_maker.dart';

// import 'package:flutter/rendering.dart';

class Responsive {
  final BuildContext context;
  final double baseWidth;
  final double baseHeight;

  Responsive(this.context, {this.baseWidth = 411, this.baseHeight = 914});

  double w(double px) => MediaQuery.of(context).size.width * (px / baseWidth);
  double h(double px) => MediaQuery.of(context).size.height * (px / baseHeight);
  double sp(double px) => w(px); // scale text with width
}

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Body? body;
  FocusNode _focusNode = FocusNode();
  Constants myConstants = Constants();
  ScrollController? _hideButtonController;
  TextEditingController? _searchFieldController;
  double isFabVisible = 0;
  bool loadingFollow = false;

  bool searchMode = false;
  IconData actionIcon = Icons.search_outlined;

  bool firstBuild = true;
  bool firstCallBack = true;

  @override
  void initState() {
    super.initState();

    _searchFieldController = TextEditingController();
    _hideButtonController = ScrollController();
    _hideButtonController!.addListener(() {
      if (isFabVisible == 1 && _hideButtonController!.offset < 100) {
        setState(() {
          isFabVisible = 0;
        });
      } else if (isFabVisible == 0 && _hideButtonController!.offset > 100) {
        setState(() {
          isFabVisible = 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchFieldController?.dispose();
    _hideButtonController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(246, 246, 246, 1),
    ));
    final responsive = Responsive(context);
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    var communityBloc = bloc.communityBloc;
    bool isLoggedIn = bloc.currSession != null;

    if (firstBuild) {
      communityBloc.query = "";
      communityBloc.refresh();
      firstBuild = false;
    }

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsive.h(52)),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFF6F6F6),
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.w(16),
                vertical: responsive.h(0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: responsive.w(52),
                    height: responsive.h(52),
                  ),
                  Text(
                    "Community",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: responsive.sp(24),
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    width: responsive.w(52),
                    height: responsive.h(52),
                    child: Stack(
                      children: [
                        Positioned(
                          left: responsive.w(4),
                          right: responsive.w(4),
                          top: responsive.h(4),
                          bottom: responsive.h(4),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: myConstants.instiappGrey,
                            ),
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed('/feed');
                                  },
                                  child: Center(
                                    child: Container(
                                      width: responsive.w(24),
                                      height: responsive.h(24),
                                      child: SvgPicture.asset(
                                        'assets/homepage/icons/bell.svg',
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // drawer: NavDrawer(),
      // bottomNavigationBar: MyBottomAppBar(
      //   shape: RoundedNotchedRectangle(),
      //   child: Row(
      //     mainAxisSize: MainAxisSize.max,
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: <Widget>[
      //       IconButton(
      //         tooltip: "Show bottom sheet",
      //         icon: Icon(
      //           Icons.menu_outlined,
      //           semanticLabel: "Show bottom sheet",
      //         ),
      //         onPressed: () {
      //           _scaffoldKey.currentState?.openDrawer();
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: SafeArea(
        child: !isLoggedIn
            ? Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud,
                      size: 200,
                      color: Colors.grey[600],
                    ),
                    Text(
                      "Login To View Communities",
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : GestureDetector(
                onTap: () {
                  _focusNode.unfocus();
                },
                child: RefreshIndicator(
                  onRefresh: () {
                    return communityBloc.refresh();
                  },
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      // controller: _hideButtonController,
                      // physics: const BouncingScrollPhysics(
                      //   parent: AlwaysScrollableScrollPhysics(),
                      // ),
                      // physics: const ClampingScrollPhysics(),
                      children: <Widget>[
                        SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.only(left: 16, right: 16),
                          height: responsive.h(50),
                          padding: EdgeInsets.only(
                            left: responsive.w(14),
                            right: responsive.w(14),
                            top: responsive.h(13),
                            bottom: responsive.h(13),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(responsive.h(25)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage('assets/blogs/search.png'),
                                height: responsive.h(24),
                                width: responsive.h(24),
                              ),
                              SizedBox(width: responsive.w(20)),
                              Expanded(
                                child: TextField(
                                  controller: _searchFieldController,
                                  focusNode: _focusNode,
                                  // onChanged: (value) {
                                  //   communityBloc.query = value;
                                  //   communityBloc.refresh();
                                  // },
                                  // onSubmitted: (value) {
                                  //   communityBloc.query = value;
                                  //   communityBloc.refresh();
                                  // },
                                  onChanged: (value) {
                                          // Just update UI, don't call refresh
                                          setState(() {}); // Rebuild with filtered results
                                        },
                                  onSubmitted: (value) {
                                          setState(() {}); // Rebuild with filtered results
                                        }, 
                                  decoration: InputDecoration(         
                                    border: InputBorder.none,                                                             
                                    hintText: 'Search communities',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'DM Sans',
                                      color: Color.fromRGBO(0, 0, 0, 0.4),                                      
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'DM Sans',
                                    color: Color.fromRGBO(0, 0, 0, 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: StreamBuilder<List<Community>>(
                              stream: communityBloc.communities,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Community>> snapshot) {
                                // return Column(
                                //   children: _buildContent(
                                //     snapshot,
                                //     theme,
                                //     communityBloc,
                                //   ),
                                // );
                                // Tabs 
                                return Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 1.5,
                                            color: Color(0xFFD0D5DD),
                                          )
                                        ),
                                        TabBar(
                                          indicatorColor: myConstants.instiappBlue,
                                          labelColor: myConstants.instiappBlue,
                                          unselectedLabelColor: Colors.black54,
                                          labelStyle: TextStyle(
                                            fontSize: responsive.sp(16),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'DM Sans',
                                          ),
                                          tabs: [
                                            Tab(text: "All"),
                                            Tab(text: "Explore"),
                                            Tab(text: "My Groups"), 
                                          ]
                                        )
                                      ],
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        children: [
                                          // All
                                          Column(
                                            children: [
                                              SizedBox(height: 20),
                                              
                                             ... _buildContent(snapshot, theme, communityBloc)
                                            ],
                                          ),
                                          // Explore
                                          Padding(
                                            padding: const EdgeInsets.only(top: 70, left: 150),
                                            child: Text("coming soon"),
                                          ),
                                          // My Groups
                                          Padding(
                                            padding: const EdgeInsets.only(top: 70, left: 150),
                                            child: Text("coming soon"),
                                          ),
                                        ]
                                      )
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: isFabVisible == 0
          ? null
          : FloatingActionButton(
              tooltip: "Go to the Top",
              onPressed: () {
                _hideButtonController!.animateTo(
                  0.0,
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(milliseconds: 600),
                );
              },
              child: Icon(Icons.keyboard_arrow_up_outlined),
            ),
    );
  }

  List<Widget> _buildContent(
    AsyncSnapshot<List<Community>> snapshot,
    ThemeData theme,
    CommunityBloc communityBloc,
  ) {
    if (snapshot.hasData) {
      var communities = snapshot.data!;

      var filteredCommunities = communities.where((community) {
      return community.name!.toLowerCase().contains(_searchFieldController!.text.toLowerCase()) ||
             (community.about?.toLowerCase().contains(_searchFieldController!.text.toLowerCase()) ?? false);
    }).toList();
      communities = filteredCommunities;
      if (communities.isEmpty == true) {
        return [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.titleLarge,
                children: [
                  TextSpan(text: "Nothing here yet!"),
                ],
              ),
            ),
          )
        ];
      }

      if (firstCallBack) {
        firstCallBack = false;
      }

      return communities
          .map((c) => _buildListTile(c, theme, communityBloc))
          .toList();
    } else {
      return [
        Center(
          child: CircularProgressIndicatorExtended(
            label: Text("Loading..."),
          ),
        )
      ];
    }
  }
  Widget tagContainer(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.13,vertical: 4.17),
      height: 23,
      // width: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(69.54),
        color: myConstants.instiappDark
      ),
      child: Center(
        child: Text(
          "Public",
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700
          ),
          ),
      ),
    );
  }
  Widget _buildListTile(
    Community community,
    ThemeData theme,
    CommunityBloc bloc,
  ) {
    // var borderRadius = const BorderRadius.all(Radius.circular(10));
    // var instiBloc = BlocProvider.of(context)!.bloc;

    return Material(
      color:Color.fromRGBO(246, 246, 246, 1.0),
      child: InkWell(
        onTap:() {
          Communities.navigateWith(context, bloc, community);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Color(0xFFEDEDED),
            // border: Border.all(
            //   color: Color.fromARGB(0, 255, 255, 255),
            //   width: 0,
            // ),
            borderRadius: BorderRadius.circular(16),
            // image: DecorationImage(
            //   fit: BoxFit.cover,
            //   image: community.coverImg != null
            //       ? CachedNetworkImageProvider(community.coverImg!)
            //       : Image.asset('assets/buynsell/DevcomLogo.png').image,
            //   colorFilter: ColorFilter.mode(
            //     Colors.black.withOpacity(0.3),
            //     BlendMode.darken,
            //   ),
            // ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 47,
                      width: 49,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.5),
                        color: Colors.amber,
                      ),
                      child: community.logoImg != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.5),
                        child: Image.network(
                          community.logoImg!,     
                          fit: BoxFit.cover,      
                        ),
                      )
                      : Icon(Icons.group, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          community.name ?? "Some community",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.51),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.group_outlined,size: 18,color: myConstants.instiappBlue,),
                              SizedBox(width: 4.51),
                              Text(
                                "${community.followersCount ?? "0"} followers",
                                style: TextStyle(
                                  color: myConstants.instiappBlue,
                                  fontWeight: FontWeight.w700
                                ),
                                ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  community.about ?? "",
                  style: TextStyle(
                    color: Color(0xFF7E8287)
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    tagContainer()
                  ],
                )
              ],
            ),
            ),
          // child: ListTile(
          //   horizontalTitleGap: 0,
          //   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          //   shape: RoundedRectangleBorder(borderRadius: borderRadius),
          //   leading: community.logoImg != null
          //       ? Container(
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             shape: BoxShape.circle,
          //             border: Border.all(
          //               color: Colors.white,
          //               width: 2,
          //             ),
          //             boxShadow: [
          //               BoxShadow(
          //                 blurRadius: 3,
          //                 color: Colors.black.withOpacity(0.25),
          //               ),
          //               BoxShadow(
          //                 blurRadius: 10,
          //                 color: Colors.black.withOpacity(0.25),
          //                 spreadRadius: -2,
          //                 offset: Offset(0, 1),
          //               ),
          //             ],
          //           ),
          //           child: NullableCircleAvatar(
          //             community.logoImg!,
          //             Icons.group,
          //             heroTag: community.id,
          //             radius: 15,
          //             backgroundColor: Colors.white,
          //           ),
          //         )
          //       : null,
          //   title: Text(
          //     community.name ?? "Some community",
          //     style: theme.textTheme.titleMedium?.copyWith(
          //       color: Color.fromARGB(255, 255, 255, 255),
          //       fontSize: 15,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          //   textColor: Color.fromARGB(255, 221, 215, 255),
          //   // trailing: PopupMenuButton<int>(
          //   //   itemBuilder: (context) => [
          //   //     PopupMenuItem(
          //   //       value: 1,
          //   //       child: Row(
          //   //         children: [
          //   //           Icon(Icons.people_alt),
          //   //           SizedBox(width: 10),
          //   //           Text((community.isUserFollowing ?? false)
          //   //               ? "Leave"
          //   //               : "Join"),
          //   //         ],
          //   //       ),
          //   //       onTap: () async {
          //   //         if (instiBloc.currSession == null) return;
          //   //         setState(() {
          //   //           loadingFollow = true;
          //   //         });
          //   //         await instiBloc.updateFollowCommunity(community);
          //   //         setState(() {
          //   //           loadingFollow = false;
          //   //         });
          //   //       },
          //   //     ),
          //   //     PopupMenuItem(
          //   //       value: 2,
          //   //       onTap: () {
          //   //         Share.share(
          //   //           "Check this community: ${ShareURLMaker.getCommunityURL(community)}",
          //   //         );
          //   //       },
          //   //       child: Row(
          //   //         children: [
          //   //           Icon(Icons.share),
          //   //           SizedBox(width: 10),
          //   //           Text("Share"),
          //   //         ],
          //   //       ),
          //   //     ),
          //   //     PopupMenuItem(
          //   //       value: 3,
          //   //       child: Row(
          //   //         children: [
          //   //           Icon(Icons.push_pin_outlined),
          //   //           SizedBox(width: 10),
          //   //           Text("Pin"),
          //   //         ],
          //   //       ),
          //   //     ),
          //   //   ],
          //   //   elevation: 2,
          //   //   tooltip: "More",
          //   //   icon: Icon(
          //   //     Icons.more_vert,
          //   //     color: Color.fromARGB(255, 252, 250, 250),
          //   //   ),
          //   // ),
          //   subtitle: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text("${community.followersCount ?? "0"} followers"),
          //       SizedBox(height: 10),
          //       Text(
          //         community.about ?? "",
          //         style: TextStyle(
          //           color: Color.fromARGB(255, 243, 243, 243),
          //           fontSize: 15,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ],
          //   ),
          //   onTap: () {
          //     Communities.navigateWith(context, bloc, community);
          //   },
          // ),
        ),
      ),
    );
  }
}




// class SimplifiedGroupUI extends StatelessWidget {
//   const SimplifiedGroupUI({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Using Theme for consistent styling
//     final theme = Theme.of(context);

//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // 1. Simplified Tab Bar
//           Container(
//             decoration: const BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(color: Colors.grey, width: 1),
//               ),
//             ),
//             child: const Row(
//               children: [
//                 _TabButton(title: 'All', isSelected: true),
//                 _TabButton(title: 'Explore'),
//                 _TabButton(title: 'My Groups'),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),

//           // 2. Simplified Group Card using ListTile
//           Card(
//             color: const Color(0xFFEDEDED),
//             elevation: 0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: ListTile(
//               // The image on the left
//               leading: ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0),
//                 child: Image.network(
//                   "https://placehold.co/50x50",
//                   width: 50,
//                   height: 50,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               // The main title and the "Public" chip
//               title: Row(
//                 children: [
//                   const Text(
//                     'Academic Discussion',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(width: 8),
//                   Chip(
//                     label: const Text('Public'),
//                     visualDensity: VisualDensity.compact,
//                     padding: EdgeInsets.zero,
//                     backgroundColor: const Color(0xFF1B3252),
//                     labelStyle: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               // The description and member count below the title
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 4),
//                   const Text(
//                     'This forum is for discussions relevant to academics at IIT Bombay.',
//                     style: TextStyle(color: Color(0xFF7E8287), fontSize: 14),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(Icons.group, size: 16, color: theme.primaryColor),
//                       const SizedBox(width: 4),
//                       Text(
//                         '422 members',
//                         style: TextStyle(
//                           color: theme.primaryColor,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               contentPadding: const EdgeInsets.all(16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// A private helper widget to build the tab buttons, avoiding code repetition.
// class _TabButton extends StatelessWidget {
//   const _TabButton({required this.title, this.isSelected = false});

//   final String title;
//   final bool isSelected;

//   @override
//   Widget build(BuildContext context) {
//     // Expanded makes each button take up equal space in the Row
//     return Expanded(
//       child: TextButton(
//         onPressed: () {
//           // TODO: Add tab switching logic here
//         },
//         style: TextButton.styleFrom(
//           shape: const RoundedRectangleBorder(), // Remove default rounding
//           padding: const EdgeInsets.symmetric(vertical: 16),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: isSelected ? Colors.blue : Colors.transparent,
//                 width: 3,
//               ),
//             ),
//           ),
//           child: Text(
//             title,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               color: isSelected ? Colors.blue : Colors.black54,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }