import 'dart:async';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/footer_buttons.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:markdown/markdown.dart' as markdown;

class BodyPage extends StatefulWidget {
  final Body? initialBody;
  final Future<Body>? bodyFuture;
  final String? heroTag;

  BodyPage({this.bodyFuture, this.initialBody, this.heroTag});

  static void navigateWith(BuildContext context, InstiAppBloc bloc,
      {Body? body, Role? role}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/body/${(role?.roleBodyDetails ?? body)?.bodyID}",
        ),
        builder: (context) => BodyPage(
          initialBody: role?.roleBodyDetails ?? body,
          bodyFuture:
              bloc.getBody((role?.roleBodyDetails ?? body)?.bodyID ?? ""),
          heroTag: role?.roleID ?? body?.bodyID,
        ),
      ),
    );
  }

  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
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
    var footerButtons = <Widget>[];
    var editAccess = false;
    if (body != null) {
      editAccess = bloc.editBodyAccess(body!);
      if (bloc.currSession != null) {
        footerButtons.addAll([
          _buildFollowBody(theme, bloc),
        ]);
      }

      if ((body?.bodyWebsiteURL ?? "") != "") {
        footerButtons.add(IconButton(
          tooltip: "Open website",
          icon: Icon(Icons.language_outlined),
          onPressed: () async {
            if (body?.bodyWebsiteURL != null) {
              if (await canLaunchUrl(Uri.parse(body?.bodyWebsiteURL ?? ""))) {
                await launchUrl(
                  Uri.parse(body?.bodyWebsiteURL ?? ""),
                  mode: LaunchMode.externalApplication,
                );
              }
            }
          },
        ));
      }

      if (editAccess) {
        footerButtons.add(IconButton(
          icon: Icon(Icons.share_outlined),
          tooltip: "Share this body",
          onPressed: () async {
            await Share.share(
                "Check this Institute Body: ${ShareURLMaker.getBodyURL(body ?? Body())}");
          },
        ));
      }
    }
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
            : Stack(
                children: [
                  ListView(
                      padding: EdgeInsets.only(
                          bottom: 90), // Add padding for the button
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Cover Image
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                image: body?.bodyImageURL != null
                                    ? DecorationImage(
                                        image:
                                            // NetworkImage(body!.bodyImageURL!),
                                            AssetImage(
                                                'assets/explore/symphony.png'),
                                        fit: BoxFit.cover,
                                      )
                                    : const DecorationImage(
                                        image: AssetImage('assets/photo.png'),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),

                            // Profile Card Section
                            Container(
                              width: double.infinity,
                              height: 140,
                              // padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F1620),
                              ),
                              child: Stack(
                                children: [
                                  // Rotated background image
                                  Positioned(
                                    left: 0,
                                    child: SizedBox(
                                      width: 105,
                                      height: 199,
                                      child: Transform.rotate(
                                        angle:
                                            3.1416, // -180 degrees in radians
                                        child: Image.asset(
                                          'assets/explore/background.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                        child: CircleAvatar(
                                          radius: 35,
                                          backgroundColor: Colors.black,
                                          backgroundImage:
                                              body?.bodyImageURL != null
                                                  ? NetworkImage(
                                                      body!.bodyImageURL!)
                                                  : const AssetImage(
                                                          'assets/symphony.png')
                                                      as ImageProvider,
                                        ),
                                      ),
                                      const SizedBox(width: 20),

                                      // Profile Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              body?.bodyName ?? 'Symphony',
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              body?.bodyShortDescription ??
                                                  'Music Club of IITB',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: (body
                                                            ?.bodyFollowersCount
                                                            ?.toString() ??
                                                        '422'),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: ' Senti',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const SizedBox(height: 30),
                              // Row(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     Expanded(
                              //       child: Column(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           Text(
                              //             body?.bodyName ?? "",
                              //             style: const TextStyle(
                              //               fontSize: 24,
                              //               fontWeight: FontWeight.bold,
                              //               fontFamily: 'DM Sans',
                              //             ),
                              //           ),
                              //           const SizedBox(height: 6),
                              //           Text(
                              //             body?.bodyShortDescription ?? "",
                              //             style: const TextStyle(
                              //               fontSize: 18,
                              //               color: Colors.black54,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              const SizedBox(height: 24),
                              DefaultTabController(
                                length: 3,
                                child: Column(
                                  children: [
                                    const TabBar(
                                      indicatorColor: Colors.blueAccent,
                                      labelColor: Colors.blueAccent,
                                      unselectedLabelColor: Colors.black54,
                                      labelStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'DM Sans',
                                      ),
                                      tabs: [
                                        Tab(text: 'About'),
                                        Tab(text: 'Events'),
                                        Tab(text: 'People'),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 300,
                                      child: Builder(
                                        builder: (context) {
                                          final people = body?.bodyRoles
                                                  ?.expand((r) =>
                                                      (r.roleUsersDetail ?? [])
                                                          .map((u) => u
                                                            ..currentRole =
                                                                r.roleName))
                                                  .toList() ??
                                              [];
                                          return TabBarView(
                                            children: [
                                              // About Tab
                                              SingleChildScrollView(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CommonHtml(
                                                      data:
                                                          body?.bodyDescription ??
                                                              "",
                                                      defaultTextStyle: (theme
                                                                  .textTheme
                                                                  .titleMedium ??
                                                              const TextStyle())
                                                          .copyWith(
                                                              fontSize: 24),
                                                    ),
                                                    body?.bodyDescription !=
                                                            null
                                                        ? SizedBox(
                                                            height: 20.0,
                                                          )
                                                        : SizedBox(
                                                            height: 0.0,
                                                          ),
                                                    Divider(),
                                                    const SizedBox(height: 20),

                                                    // Photo Album Section
                                                    const Text(
                                                      'Photo Album',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily: 'DM Sans',
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    SizedBox(
                                                      height: 100,
                                                      child: ListView.separated(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount: 5,
                                                        separatorBuilder: (_,
                                                                __) =>
                                                            const SizedBox(
                                                                width: 8),
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Container(
                                                            width: 100,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),

                                                    const SizedBox(height: 24),

                                                    // Part Of Section
                                                    const Text(
                                                      'Part of',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily: 'DM Sans',
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    ...(body?.bodyParents
                                                            ?.map((b) =>
                                                                _buildBodyTile(
                                                                    bloc,
                                                                    theme
                                                                        .textTheme,
                                                                    b))
                                                            .toList() ??
                                                        [])
                                                  ],
                                                ),
                                              ),

                                              // Events Tab
                                              body?.bodyEvents == null ||
                                                      body!.bodyEvents!.isEmpty
                                                  ? const Center(
                                                      child: Text(
                                                          "No events yet."))
                                                  : ListView(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      28.0,
                                                                  vertical:
                                                                      8.0),
                                                          child: Text(
                                                            "Events",
                                                            style: theme
                                                                .textTheme
                                                                .headlineSmall,
                                                          ),
                                                        ),
                                                        ...body!.bodyEvents!
                                                            .map((e) =>
                                                                _buildEventTile(
                                                                    bloc,
                                                                    theme,
                                                                    e))
                                                      ],
                                                    ),

                                              // People Tab
                                              people.isEmpty
                                                  ? const Center(
                                                      child: Text(
                                                          "No people listed."))
                                                  : ListView(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      28.0,
                                                                  vertical:
                                                                      8.0),
                                                          child: Text(
                                                            "People",
                                                            style: theme
                                                                .textTheme
                                                                .headlineSmall,
                                                          ),
                                                        ),
                                                        ...people
                                                            .map((u) =>
                                                                _buildUserTile(
                                                                    bloc,
                                                                    theme,
                                                                    u))
                                                            .toList(),
                                                      ],
                                                    )
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 10),
                              // const Text(
                              //   'Photo Album',
                              //   style: TextStyle(
                              //     fontSize: 20,
                              //     fontWeight: FontWeight.w600,
                              //     fontFamily: 'DM Sans',
                              //   ),
                              // ),
                              // const SizedBox(height: 12),
                              // SizedBox(
                              //   height: 100,
                              //   child: ListView.separated(
                              //     scrollDirection: Axis.horizontal,
                              //     itemCount: 5,
                              //     separatorBuilder: (_, __) =>
                              //         const SizedBox(width: 8),
                              //     itemBuilder: (context, index) {
                              //       return Container(
                              //         width: 100,
                              //         decoration: BoxDecoration(
                              //           color: Colors.grey.shade300,
                              //           borderRadius: BorderRadius.circular(8),
                              //         ),
                              //       );
                              //     },
                              //   ),
                              // ),
                            ],
                          ),
                        )
                      ]
                      // Events
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
                      // ..addAll(_nonEmptyListWithHeaderOrEmpty(
                      //     body?.bodyChildren
                      //         ?.map((b) =>
                      //             _buildBodyTile(bloc, theme.textTheme, b))
                      //         .toList(),
                      //     Padding(
                      //       padding: const EdgeInsets.symmetric(
                      //           horizontal: 28.0, vertical: 16.0),
                      //       child: Text(
                      //         "Organizations",
                      //         style: theme.textTheme.headlineSmall,
                      //       ),
                      //     )))
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
                      // Parents
                      // ..addAll(_nonEmptyListWithHeaderOrEmpty(
                      //     body?.bodyParents
                      //         ?.map((b) =>
                      //             _buildBodyTile(bloc, theme.textTheme, b))
                      //         .toList(),
                      //     Padding(
                      //       padding: const EdgeInsets.symmetric(
                      //           horizontal: 28.0, vertical: 16.0),
                      //       child: Text(
                      //         "Part of",
                      //         style: theme.textTheme.headlineSmall,
                      //       ),
                      //     )))
                      // ..addAll([
                      //   Divider(),
                      //   SizedBox(
                      //     height: 64.0,
                      //   )

                      // ]),
                      ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Handle Join Action
                          },
                          child: const Text(
                            'Join',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'DM Sans',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // TitleWithBackButton(
                  // child: Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: <Widget>[
                  //     Text(
                  //       body?.bodyName ?? "",
                  //       style: theme.textTheme.displaySmall,
                  //     ),
                  //     SizedBox(height: 8.0),
                  //     Text(body?.bodyShortDescription ?? "",
                  //         style: theme.textTheme.titleLarge),
                  //   ],
                  // ),
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
                  // Divider(),
                ],
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

  ElevatedButton _buildFollowBody(ThemeData theme, InstiAppBloc bloc) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: body?.bodyUserFollows ?? false
            ? theme.floatingActionButtonTheme.foregroundColor
            : theme.textTheme.bodyLarge?.color,
        backgroundColor: body?.bodyUserFollows ?? false
            ? theme.colorScheme.secondary
            : theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.colorScheme.secondary,
          ),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      // color: body.bodyUserFollows ?? false
      //     ? theme.accentColor
      //     : theme.scaffoldBackgroundColor,
      // textColor:
      //     body.bodyUserFollows ?? false ? theme.accentIconTheme.color : null,
      // shape: RoundedRectangleBorder(
      //     side: BorderSide(
      //       color: theme.accentColor,
      //     ),
      //     borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Row(children: () {
        var rowChildren = <Widget>[
          Text(
            body?.bodyUserFollows ?? false ? "Following" : "Follow",
            // style: TextStyle(color: Colors.black),
          ),
          SizedBox(
            width: 8.0,
          ),
          body?.bodyFollowersCount != null
              ? Text("${body?.bodyFollowersCount}")
              : SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                      body?.bodyUserFollows ?? false
                          ? theme.floatingActionButtonTheme.foregroundColor!
                          : theme.colorScheme.secondary,
                    ),
                    strokeWidth: 2,
                  )),
        ];
        if (loadingFollow) {
          rowChildren.insertAll(0, [
            SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      body?.bodyUserFollows ?? false
                          ? theme.floatingActionButtonTheme.foregroundColor!
                          : theme.colorScheme.secondary),
                  strokeWidth: 2,
                )),
            SizedBox(
              width: 8.0,
            )
          ]);
        }
        return rowChildren;
      }()),
      onPressed: () async {
        if (bloc.currSession == null) {
          return;
        }
        setState(() {
          loadingFollow = true;
        });
        if (body != null) await bloc.updateFollowBody(body!);
        setState(() {
          loadingFollow = false;
          // event has changes
        });
      },
    );
  }

  Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
    return ListTile(
      title: Text(body.bodyName ?? "", style: theme.titleLarge),
      subtitle: Text(body.bodyShortDescription ?? "", style: theme.titleSmall),
      leading: NullableCircleAvatar(
        body.bodyImageURL ?? "",
        Icons.people_outline_outlined,
        heroTag: body.bodyID ?? "",
      ),
      onTap: () {
        BodyPage.navigateWith(context, bloc, body: body);
      },
    );
  }

  Widget _buildEventTile(InstiAppBloc bloc, ThemeData theme, Event event) {
    return ListTile(
      title: Text(
        event.eventName ?? "",
        style: theme.textTheme.titleLarge,
      ),
      enabled: true,
      leading: NullableCircleAvatar(
        event.eventImageURL ?? event.eventBodies?[0].bodyImageURL ?? "",
        Icons.event_outlined,
        heroTag: event.eventID ?? "",
      ),
      subtitle: Text(event.getSubTitle()),
      onTap: () {
        EventPage.navigateWith(context, bloc, event);
      },
    );
  }

  Widget _buildUserTile(InstiAppBloc bloc, ThemeData theme, User u) {
    return ListTile(
      leading: NullableCircleAvatar(
        u.userProfilePictureUrl ?? "",
        Icons.person_outline_outlined,
        heroTag: u.userID ?? "",
      ),
      title: Text(
        u.userName ?? "",
        style: theme.textTheme.titleLarge,
      ),
      subtitle: Text(u.getSubTitle() ?? ""),
      onTap: () {
        UserPage.navigateWith(context, bloc, u);
      },
    );
  }
}
