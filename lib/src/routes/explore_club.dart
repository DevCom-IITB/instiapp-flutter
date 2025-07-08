import 'dart:async';

import 'package:InstiApp/constants.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/routes/explore_club.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:markdown/markdown.dart' as markdown;

class ExploreClubPage extends StatefulWidget {
  final Future<Body>? bodyFuture;
  final String? heroTag;

  final List<Map<String, String>> bodyTitles = [
    {
      "bodyname": "Culturals@IITB",
      "title": "Cult",
    },
    {
      "bodyname": "Tech@IITB",
      "title": "Tech",
    },
    {
      "bodyname": "IITB Sports",
      "title": "Sports",
    },
    {
      "bodyname": "Departments",
      "title": "Departments",
    },
    {
      "bodyname": "Hostel Affairs",
      "title": "Hostels",
    },
    {
      "bodyname": "IIT Bombay",
      "title": "Institute",
    },
    {
      "bodyname": "DevCom",
      "title": "DevCom",
    },
    {
      "bodyname": "Placement Cell",
      "title": "Placement",
    },
  ];

  ExploreClubPage({this.bodyFuture, this.heroTag});

  static void navigateWith(BuildContext context, InstiAppBloc bloc,
      {required String bodyID, Role? role,}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/body/${bodyID}",
        ),
        builder: (context) => ExploreClubPage(
          bodyFuture:
              bloc.getBody(bodyID),
          heroTag: bodyID,
        ),
      ),
    );
  }

  @override
  _ExploreClubPageState createState() => _ExploreClubPageState();
}

class _ExploreClubPageState extends State<ExploreClubPage> {
  Constants myConstants = Constants();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Body? body;
  FocusNode _focusNode = FocusNode();
  TextEditingController? _searchFieldController;

  bool loadingFollow = false;

  @override
  void initState() {
    super.initState();

    widget.bodyFuture?.then((b) {
      var tableParse = markdown.TableSyntax();
      b.bodyDescription = markdown.markdownToHtml(
          b.bodyDescription
                  ?.split('\n')
                  .map((s) => s.trimRight())
                  .toList()
                  .join('\n') ??
              "",
          blockSyntaxes: [tableParse]);
      if (this.mounted) {
        setState(() {
          body = b;
        });
      } else {
        body = b;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    var exploreBloc = bloc.exploreBloc;
    // var footerButtons = <Widget>[];
    // var editAccess = false;
    // if (body != null) {
    //   editAccess = bloc.editBodyAccess(body!);
    //   if (bloc.currSession != null) {
    //     footerButtons.addAll([
    //       _buildFollowBody(theme, bloc),
    //     ]);
    //   }

    //   if ((body?.bodyWebsiteURL ?? "") != "") {
    //     footerButtons.add(IconButton(
    //       tooltip: "Open website",
    //       icon: Icon(Icons.language_outlined),
    //       onPressed: () async {
    //         if (body?.bodyWebsiteURL != null) {
    //           if (await canLaunchUrl(Uri.parse(body?.bodyWebsiteURL ?? ""))) {
    //             await launchUrl(
    //               Uri.parse(body?.bodyWebsiteURL ?? ""),
    //               mode: LaunchMode.externalApplication,
    //             );
    //           }
    //         }
    //       },
    //     ));
    //   }

    //   if (editAccess) {
    //     footerButtons.add(IconButton(
    //       icon: Icon(Icons.share_outlined),
    //       tooltip: "Share this body",
    //       onPressed: () async {
    //         await Share.share(
    //             "Check this Institute Body: ${ShareURLMaker.getBodyURL(body ?? Body())}");
    //       },
    //     ));
    //   }
    // }
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
        key: _scaffoldKey,
        drawer: NavDrawer(),
        // bottomNavigationBar: MyBottomAppBar(
        //   child: new Row(
        //     mainAxisSize: MainAxisSize.max,
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: <Widget>[
        //       IconButton(
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
          child: body == null
              ? Center(
                  child: CircularProgressIndicatorExtended(
                    label: Text("Loading the body page"),
                  ),
                )
              : ListView(
                  children: <Widget>[
                    Stack(
                        children: [
                        
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          ),
                          child: Image.asset(
                          'assets/explore/culturals.png',
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                                  padding: const EdgeInsets.only(left: 16,),
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      height: 52,
                                      width: 52,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.60),
                                        borderRadius: BorderRadius.circular(25)
                                      ),
                                      child: Center(
                                        child: Container(
                                          height: 24,
                                          width: 24,
                                          child: SvgPicture.asset('assets/quicklinks/icons/arrow_left.svg'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        Positioned(
                          top: 72,
                          left: 16,
                          right: 16,
                          child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(32),
                          color: Colors.transparent,
                          child: Container(
                            height: 50, // Set height to 50px
                            width: 380,
                            decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.98),
                            borderRadius: BorderRadius.circular(32),
                            // boxShadow: [
                            //   BoxShadow(
                            //   color: Colors.black.withOpacity(0.08),
                            //   blurRadius: 12,
                            //   offset: Offset(0, 4),
                            //   ),
                            // ],
                            ),
                            child: TextField(
                            controller: _searchFieldController,
                            focusNode: _focusNode,
                            cursorColor: theme.colorScheme.primary,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 18,
                              color: Colors.black87,
                              fontFamily: 'DM Sans',
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, // Adjust for 50px height
                              horizontal: 20,
                              ),
                              prefixIcon: Icon(
                              Icons.search_outlined,
                              color: Colors.grey[600],
                              size: 22, // Adjust icon size for 50px height
                              ),
                              hintText: "Search clubs...",
                              hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'DM Sans',
                              ),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                              tooltip: "Clear search",
                              icon: const Icon(Icons.close_outlined, size: 22), // Adjust icon size
                              color: Colors.grey[500],
                              onPressed: () {
                                setState(() {
                                _searchFieldController?.clear();
                                });
                              },
                              ),
                            ),
                            ),
                          ),
                          ),
                        ),
                        Positioned(
                          top: 150,
                          left: 24,
                          right: 24,
                          child: Text(
                          (() {
                            final bodyName = body?.bodyName ?? "";
                            final match = widget.bodyTitles.firstWhere(
                            (item) => item["bodyname"] == bodyName,
                            orElse: () => {},
                            );
                            final title = match["title"] ?? "";
                            return title.isNotEmpty
                              ? "$title"
                              : "Explore";
                          })(),
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            //letterSpacing: 1.2,
                            fontSize: 36,
                            fontFamily: 'DM Sans',
                            shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                            ],
                          ),
                          textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...(body!.bodyChildren?.map((b) {
                      return _buildBodyTile(bloc, theme.textTheme, b);
                    }).toList() ?? []),
                    Divider(),
                    const SizedBox(height: 64.0),
                  ],
                ),
        )
// floatingActionButton: body == null
        //     ? null
        //     : editAccess
        //         ? FloatingActionButton.extended(
        //             icon: Icon(Icons.edit_outlined),
        //             label: Text("Edit"),
        //             tooltip: "Edit this Body",
        //             onPressed: () {
        //               Navigator.of(context)
        //                   .pushNamed("/putentity/body/${body!.bodyID}");
        //             },
        //           )
        //         : FloatingActionButton(
        //             child: Icon(Icons.share_outlined),
        //             tooltip: "Share this body",
        //             onPressed: () async {
        //               await Share.share(
        //                   "Check this Institute Body: ${ShareURLMaker.getBodyURL(body!)}");
        //             },
        //           ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // persistentFooterButtons: [
        //   FooterButtons(
        //     footerButtons: footerButtons,
        //   )
        // ],
        );
  }

  List<Widget> _nonEmptyListWithHeaderOrEmpty(
      List<Widget>? list, Widget header) {
    return list != null
        ? (list.isNotEmpty ? (list..insert(0, header)) : <Widget>[])
        : [
            CircularProgressIndicatorExtended(
              label: header,
            )
          ];
  }

  // ElevatedButton _buildFollowBody(ThemeData theme, InstiAppBloc bloc) {
  //   return ElevatedButton(
  //     style: ElevatedButton.styleFrom(
  //       foregroundColor: body?.bodyUserFollows ?? false
  //           ? theme.floatingActionButtonTheme.foregroundColor
  //           : theme.textTheme.bodyLarge?.color, backgroundColor: body?.bodyUserFollows ?? false
  //           ? theme.colorScheme.secondary
  //           : theme.scaffoldBackgroundColor,
  //       shape: RoundedRectangleBorder(
  //         side: BorderSide(
  //           color: theme.colorScheme.secondary,
  //         ),
  //         borderRadius: BorderRadius.all(Radius.circular(4)),
  //       ),
  //     ),
  //     // color: body.bodyUserFollows ?? false
  //     //     ? theme.accentColor
  //     //     : theme.scaffoldBackgroundColor,
  //     // textColor:
  //     //     body.bodyUserFollows ?? false ? theme.accentIconTheme.color : null,
  //     // shape: RoundedRectangleBorder(
  //     //     side: BorderSide(
  //     //       color: theme.accentColor,
  //     //     ),
  //     //     borderRadius: BorderRadius.all(Radius.circular(4))),
  //     child: Row(children: () {
  //       var rowChildren = <Widget>[
  //         Text(
  //           body?.bodyUserFollows ?? false ? "Following" : "Follow",
  //           // style: TextStyle(color: Colors.black),
  //         ),
  //         SizedBox(
  //           width: 8.0,
  //         ),
  //         body?.bodyFollowersCount != null
  //             ? Text("${body?.bodyFollowersCount}")
  //             : SizedBox(
  //                 height: 18,
  //                 width: 18,
  //                 child: CircularProgressIndicator(
  //                   valueColor: new AlwaysStoppedAnimation<Color>(
  //                     body?.bodyUserFollows ?? false
  //                         ? theme.floatingActionButtonTheme.foregroundColor!
  //                         : theme.colorScheme.secondary,
  //                   ),
  //                   strokeWidth: 2,
  //                 )),
  //       ];
  //       if (loadingFollow) {
  //         rowChildren.insertAll(0, [
  //           SizedBox(
  //               height: 18,
  //               width: 18,
  //               child: CircularProgressIndicator(
  //                 valueColor: new AlwaysStoppedAnimation<Color>(
  //                     body?.bodyUserFollows ?? false
  //                         ? theme.floatingActionButtonTheme.foregroundColor!
  //                         : theme.colorScheme.secondary),
  //                 strokeWidth: 2,
  //               )),
  //           SizedBox(
  //             width: 8.0,
  //           )
  //         ]);
  //       }
  //       return rowChildren;
  //     }()),
  //     onPressed: () async {
  //       if (bloc.currSession == null) {
  //         return;
  //       }
  //       setState(() {
  //         loadingFollow = true;
  //       });
  //       if (body != null) await bloc.updateFollowBody(body!);
  //       setState(() {
  //         loadingFollow = false;
  //         // event has changes
  //       });
  //     },
  //   );
  // }

  // Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
  //   return GestureDetector(
  //     onTap: () {
  //       BodyPage.navigateWith(context, bloc, body: body);
  //     },
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.05),
  //             blurRadius: 6,
  //             offset: Offset(0, 3),
  //           ),
  //         ],
  //         border: Border.all(color: Colors.black12),
  //       ),
  //       child: Row(
  //         children: [
  // NullableCircleAvatar(
  //   body.bodyImageURL ?? "",
  //   Icons.people_outline_outlined,
  //   heroTag: body.bodyID ?? "",
  //   radius: 25,
  // ),
  //           const SizedBox(width: 14),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   body.bodyName ?? "",
  //                   style:
  //                       theme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 const SizedBox(height: 6),
  //                 Text(
  //                   body.bodyShortDescription ?? "",
  //                   style: theme.bodyMedium?.copyWith(color: Colors.grey[600]),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const Icon(Icons.chevron_right, color: Colors.black45),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
    // debugPrint(body.bodyFollowersCount?.toString());
    return GestureDetector(
      onTap: () {
        BodyPage.navigateWith(context, bloc, body: body);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        //padding: const EdgeInsets.all(16),
        // color: Colors.grey[400],
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(16),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withOpacity(0.06),
        //       blurRadius: 10,
        //       offset: Offset(0, 4),
        //     ),
        //   ],
        // ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Club Image/Logo
            Container(
              width: 73,
              height: 73,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.1),
                //     blurRadius: 6,
                //     offset: Offset(0, 2),
                //   ),
                // ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: body.bodyImageURL != null &&
                        body.bodyImageURL!.isNotEmpty
                    ? Image.network(
                        body.bodyImageURL!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.people_outline,
                            size: 28,
                            color: Colors.grey[500],
                          ),
                        ),
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.people_outline,
                          size: 28,
                          color: Colors.grey[500],
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // Club Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    body.bodyName ?? "",
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 18
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  Text(
                    body.bodyShortDescription ?? "",
                    style: theme.bodyMedium?.copyWith(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  Container(
                    height: 23,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFFD2D5DA),
                      ),
                    borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/explore_new/users.svg',
                          height: 12,
                          width: 12,
                          ),
                        // Icon(
                        // Icons.people_outline,
                        // size: 16,
                        // color: Colors.blue[600],
                        // ),
                        const SizedBox(width: 8),
                        Text(
                        "${body.bodyFollowersCount?.toString() ?? '422'} senti",
                        // body.bodyFollowersCount != null
                        // ? "${body.bodyFollowersCount} senti"
                        // : "Loading...",
                        style: theme.bodySmall?.copyWith(
                          color: myConstants.instiappBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 12
                        ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

//   Widget _buildEventTile(InstiAppBloc bloc, ThemeData theme, Event event) {
//     return ListTile(
//       title: Text(
//         event.eventName ?? "",
//         style: theme.textTheme.titleLarge,
//       ),
//       enabled: true,
//       leading: NullableCircleAvatar(
//         event.eventImageURL ?? event.eventBodies?[0].bodyImageURL ?? "",
//         Icons.event_outlined,
//         heroTag: event.eventID ?? "",
//       ),
//       subtitle: Text(event.getSubTitle()),
//       onTap: () {
//         EventPage.navigateWith(context, bloc, event);
//       },
//     );
//   }

//   Widget _buildUserTile(InstiAppBloc bloc, ThemeData theme, User u) {
//     return ListTile(
//       leading: NullableCircleAvatar(
//         u.userProfilePictureUrl ?? "",
//         Icons.person_outline_outlined,
//         heroTag: u.userID ?? "",
//       ),
//       title: Text(
//         u.userName ?? "",
//         style: theme.textTheme.titleLarge,
//       ),
//       subtitle: Text(u.getSubTitle() ?? ""),
//       onTap: () {
//         UserPage.navigateWith(context, bloc, u);
//       },
//     );
  // }
}
