import 'dart:async';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/routes/explore_club.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as markdown;

class ExploreClubPage extends StatefulWidget {
  final Body? initialBody;
  final Future<Body>? bodyFuture;
  final String? heroTag;

  ExploreClubPage({this.bodyFuture, this.initialBody, this.heroTag});

  static void navigateWith(BuildContext context, InstiAppBloc bloc,
      {Body? body, Role? role}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/body/${(role?.roleBodyDetails ?? body)?.bodyID}",
        ),
        builder: (context) => ExploreClubPage(
          initialBody: role?.roleBodyDetails ?? body,
          bodyFuture:
              bloc.getBody((role?.roleBodyDetails ?? body)?.bodyID ?? ""),
          heroTag: role?.roleID ?? body?.bodyID,
        ),
      ),
    );
  }

  @override
  _ExploreClubPageState createState() => _ExploreClubPageState();
}

class _ExploreClubPageState extends State<ExploreClubPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Body? body;

  bool loadingFollow = false;

  @override
  void initState() {
    super.initState();
    body = widget.initialBody;
    
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
              ))
            : ListView(
                children: <Widget>[
                  // TitleWithBackButton(
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: <Widget>[
                  //       Text(
                  //         body?.bodyName ?? "",
                  //         style: theme.textTheme.displaySmall,
                  //       ),
                  //       SizedBox(height: 8.0),
                  //       Text(body?.bodyShortDescription ?? "",
                  //           style: theme.textTheme.titleLarge),
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: body?.bodyImageURL != null
                  //       ? PhotoViewableImage(
                  //           url: body?.bodyImageURL ?? defUrl,
                  //           heroTag: widget.heroTag ?? body?.bodyID ?? "",
                  //           fit: BoxFit.fitWidth,
                  //         )
                  //       : SizedBox(
                  //           height: 0.0,
                  //         ),
                  // ),
                  // body?.bodyImageURL != null
                  //     ? SizedBox(
                  //         height: 16.0,
                  //       )
                  //     : SizedBox(
                  //         height: 0.0,
                  //       ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 28.0, vertical: 16.0),
                  //   child: CommonHtml(
                  //       data: body?.bodyDescription ?? "",
                  //       defaultTextStyle:
                  //           theme.textTheme.titleMedium ?? TextStyle()),
                  // ),
                  // body?.bodyDescription != null
                  //     ? SizedBox(
                  //         height: 16.0,
                  //       )
                  //     : SizedBox(
                  //         height: 0.0,
                  //       ),
                  Divider(),
                ] // Events
                  // ..addAll(_nonEmptyListWithHeaderOrEmpty(
                  //     body?.bodyEvents
                  //         ?.map((e) => _buildEventTile(bloc, theme, e))
                  //         .toList(),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(
                  //           horizontal: 28.0, vertical: 16.0),
                  //       child: Text(
                  //         "Events",
                  //         style: theme.textTheme.headlineSmall,
                  //       ),
                  //     )))
                  // Children
                  ..addAll(_nonEmptyListWithHeaderOrEmpty(
                      body?.bodyChildren
                          ?.map((b) {
                          return _buildBodyTile(bloc, theme.textTheme, b);
                          })
                          .toList(),
                        Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28.0, vertical: 16.0),
                        child: Text(
                          (body?.bodyName == "Culturals@IITB")
                            ? "Explore Cult"
                            : "Organizations",
                          style: theme.textTheme.headlineSmall,
                        ),
                      )))
                  // People
                  // ..addAll(_nonEmptyListWithHeaderOrEmpty(
                  //     body?.bodyRoles
                  //         ?.expand((r) {
                  //           if (r.roleUsersDetail != null) {
                  //             return r.roleUsersDetail!
                  //                 .map((u) => u..currentRole = r.roleName)
                  //                 .toList();
                  //           }
                  //           return [];
                  //         })
                  //         .map((u) => _buildUserTile(bloc, theme, u))
                  //         .toList(),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(
                  //           horizontal: 28.0, vertical: 16.0),
                  //       child: Text(
                  //         "People",
                  //         style: theme.textTheme.headlineSmall,
                  //       ),
                  //     )))
                  // // Parents
                  // ..addAll(_nonEmptyListWithHeaderOrEmpty(
                  //       body?.bodyParents
                  //         ?.map((b) {
                  //         debugPrint(b.toString());
                  //         return _buildBodyTile(bloc, theme.textTheme, b);
                  //         })
                  //         .toList(),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(
                  //           horizontal: 28.0, vertical: 16.0),
                  //       child: Text(
                  //         "Part of",
                  //         style: theme.textTheme.headlineSmall,
                  //       ),
                  //     )
                  //     ))
                  ..addAll([
                    Divider(),
                    SizedBox(
                      height: 64.0,
                    )
                  ]),
              ),
      ),
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

  Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
  return GestureDetector(
    onTap: () {
      BodyPage.navigateWith(context, bloc, body: body);
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          NullableCircleAvatar(
            body.bodyImageURL ?? "",
            Icons.people_outline_outlined,
            heroTag: body.bodyID ?? "",
            radius: 25,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  body.bodyName ?? "",
                  style: theme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  body.bodyShortDescription ?? "",
                  style: theme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black45),
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
