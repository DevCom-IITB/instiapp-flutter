import 'dart:async';
import 'dart:ui';

import 'package:InstiApp/constants.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart' hide Responsive;
import 'package:InstiApp/src/routes/explore_club.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:InstiApp/src/utils/responsivenew.dart';

class ExploreClubPage extends StatefulWidget {
  final Future<Body>? bodyFuture;
  final String? heroTag;
  final VoidCallback onBack;

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
    {
      "bodyname": "UGAC",
      "title": "Acadmics",
    }
  ];

  ExploreClubPage({
    this.bodyFuture,
    this.heroTag,
    required this.onBack,
  });

  @override
  _ExploreClubPageState createState() => _ExploreClubPageState();
}

class _ExploreClubPageState extends State<ExploreClubPage> {
  bool searchMode = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Constants myConstants = Constants();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Body? body;
  FocusNode _focusNode = FocusNode();
  // TextEditingController? _searchFieldController;

  bool loadingFollow = false;
  List<Body> Childrens = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent bar
      statusBarIconBrightness: Brightness.light, // white icons
    ));

    widget.bodyFuture?.then((b) {
      Childrens = b.bodyChildren ?? [];
      Childrens.sort((a, b) =>
          (b.bodyFollowersCount ?? 0).compareTo(a.bodyFollowersCount ?? 0));
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
  return WillPopScope(
    onWillPop: () async {
      widget.onBack();
      return false;
    },
    child: Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      key: _scaffoldKey,
      drawer: NavDrawer(),
      body: body == null
          ? Center(
              child: CircularProgressIndicatorExtended(
                label: Text("Loading the body page"),
              ),
            )
          : Column(
              children: [
                // Fixed Header
                Stack(
                  children: [
                    Container(
                      height: Responsive.width(295, context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                                    Responsive.width(20, context)),
                          bottomRight: Radius.circular(
                                    Responsive.width(20, context)),
                        ),
                        child: Image.asset(
                          'assets/explore/culturals.png',
                          height: Responsive.width(295, context),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            height: MediaQuery.of(context).padding.top,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: Responsive.width(16, context),
                        top: MediaQuery.of(context).padding.top,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          widget.onBack();
                        },
                        child: Container(
                          height: Responsive.width(52, context),
                          width: Responsive.width(52, context),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.60),
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                            child: Container(
                              height: Responsive.width(24, context),
                              width: Responsive.width(24, context),
                              child: SvgPicture.asset(
                                  'assets/quicklinks/icons/arrow_left.svg'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 70 + MediaQuery.of(context).padding.top,
                      left: Responsive.width(16, context),
                      right: Responsive.width(16, context),
                      child: Container(
                        height: Responsive.height(50, context),
                        padding: EdgeInsets.only(
                            left: Responsive.width(14, context),
                            right: Responsive.width(14, context),
                            top: Responsive.height(13, context),
                            bottom: Responsive.height(13, context)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              Responsive.height(25, context)),
                        ),
                        child: Row(
                          children: [
                            Image(
                              image: AssetImage('assets/blogs/search.png'),
                              height: Responsive.height(24, context),
                              width: Responsive.width(24, context),
                            ),
                            SizedBox(width: Responsive.height(20, context)),
                            Expanded(
                              child: TextField(
                                focusNode: _focusNode,
                                controller: _searchController,
                                style: TextStyle(
                                  fontSize: Responsive.text(16, context),
                                  color: Color.fromRGBO(0, 0, 0, 0.8),
                                  fontFamily: 'DM Sans',
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search events...',
                                  hintStyle: TextStyle(
                                    fontSize: Responsive.text(16, context),
                                    color: Color.fromRGBO(0, 0, 0, 0.4),
                                    fontFamily: 'DM Sans',
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value.trim().toLowerCase();
                                  });
                                },
                                maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: Responsive.width(8, context)),
                                  if (_searchQuery.isNotEmpty)
                                    InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () {
                                        _searchController.clear();
                                        _focusNode.unfocus();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(1),
                                        child: SvgPicture.asset(
                                          'assets/explore/x.svg',
                                          width: Responsive.width(24, context),
                                          height:
                                              Responsive.height(24, context),
                                        ),
                                ),
                              ),
                            SizedBox(width: Responsive.width(8, context)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 140 + MediaQuery.of(context).padding.top,
                      left: 32,
                      right: 32,
                      child: Text(
                        (() {
                          final bodyName = body?.bodyName ?? "";
                          final match = widget.bodyTitles.firstWhere(
                            (item) => item["bodyname"] == bodyName,
                            orElse: () => {},
                          );
                          final title = match["title"] ?? "";
                          return title.isNotEmpty ? "$title" : "Explore";
                        })(),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: Responsive.width(36, context),
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
                    Positioned(
                      top: 185 + MediaQuery.of(context).padding.top,
                      left: 32,
                      right: 32,
                      child: Text(
                        body?.bodyShortDescription ?? "",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.width(16, context),
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                
                // Scrollable Body Section
                Expanded(
                  child: Container(
                    color: Color.fromRGBO(246, 246, 246, 1),
                    child: ListView(
                      padding: EdgeInsets.only(top: Responsive.height(20, context)),
                      children: [
                        ...(_searchQuery.isEmpty
                                  ? Childrens
                                  : Childrens.where((body) {
                                    final name =
                                          body.bodyName?.toLowerCase() ?? "";
                                    return name.contains(_searchQuery);
                                  }).toList())
                              .map((b) {
                          return _buildBodyTile(bloc, theme.textTheme, b);
                        }).toList(),
                        Divider(),
                        SizedBox(height: Responsive.height(80, context)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    ),
  );
}
  // @override
  // Widget build(BuildContext context) {
  //   var theme = Theme.of(context);
  //   var bloc = BlocProvider.of(context)!.bloc;
  //   var exploreBloc = bloc.exploreBloc;
  //   return WillPopScope(
  //     onWillPop: () async {
  //       widget.onBack();
  //       return false;
  //     },
  //     child: Scaffold(
  //         extendBodyBehindAppBar: true,
  //         backgroundColor: Color.fromRGBO(246, 246, 246, 1),
  //         key: _scaffoldKey,
  //         drawer: NavDrawer(),
  //         body: Container(
  //           child: body == null
  //               ? Center(
  //                   child: CircularProgressIndicatorExtended(
  //                     label: Text("Loading the body page"),
  //                   ),
  //                 )
  //               : ListView(
  //                   padding: EdgeInsets.zero,
  //                   children: <Widget>[
  //                     Stack(
  //                       children: [
  //                         Container(
  //                           // height: Responsive.height(250, context),
  //                           height: 250,
  //                           child: ClipRRect(
  //                             borderRadius: BorderRadius.only(
  //                               bottomLeft: Radius.circular(Responsive.width(20, context)),
  //                               bottomRight: Radius.circular(Responsive.width(20, context)),
  //                             ),
  //                             child: Image.asset(
  //                               'assets/explore/culturals.png',
  //                               // height: Responsive.height(250, context),
  //                               height: 250,
  //                               width: double.infinity,
  //                               fit: BoxFit.cover,
  //                             ),
  //                           ),
  //                         ),
  //                         Positioned(
  //                           top: 0,
  //                           left: 0,
  //                           right: 0,
  //                           child: ClipRect(
  //                             child: BackdropFilter(
  //                               filter: ImageFilter.blur(
  //                                   sigmaX: 10, sigmaY: 10), // adjust blur
  //                               child: Container(
  //                                 height: MediaQuery.of(context).padding.top,
  //                                 color: Colors.white
  //                                     .withOpacity(0.2), // translucent layer
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         Padding(
  //                           padding: EdgeInsets.only(
  //                             left: Responsive.width(16, context),
  //                             top: MediaQuery.of(context).padding.top,
  //                           ),
  //                           child: GestureDetector(
  //                             onTap: () {
  //                               widget.onBack();
  //                             },
  //                             child: Container(
  //                               height: Responsive.width(52, context),
  //                               width: Responsive.width(52, context),
  //                               decoration: BoxDecoration(
  //                                   color: Colors.white.withOpacity(0.60),
  //                                   borderRadius: BorderRadius.circular(25)),
  //                               child: Center(
  //                                 child: Container(
  //                                   height: Responsive.width(24, context),
  //                                   width: Responsive.width(24, context),                                    child: SvgPicture.asset(
  //                                       'assets/quicklinks/icons/arrow_left.svg'),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         Positioned(
  //                           top: 70 + MediaQuery.of(context).padding.top,
  //                           left: Responsive.width(16, context),
  //                           right: Responsive.width(16, context),
  //                           child: Container(
  //                             height: Responsive.height(50, context),
  //                             padding: EdgeInsets.only(
  //                                 left: Responsive.width(14, context),
  //                                 right: Responsive.width(14, context),
  //                                 top: Responsive.height(13, context),
  //                                 bottom: Responsive.height(13, context)),
  //                             decoration: BoxDecoration(
  //                               color: Colors.white,
  //                               borderRadius: BorderRadius.circular(
  //                                   Responsive.height(25, context)),
  //                             ),
  //                             child: Row(
  //                               children: [
  //                                 Image(
  //                                   image:
  //                                       AssetImage('assets/blogs/search.png'),
  //                                   height: Responsive.height(24, context),
  //                                   width: Responsive.width(24, context),
  //                                 ),
  //                                 SizedBox(
  //                                     width: Responsive.height(20, context)),
  //                                 Expanded(
  //                                   child: TextField(
  //                                     focusNode: _focusNode,
  //                                     controller: _searchController,
  //                                     style: TextStyle(
  //                                       fontSize: Responsive.text(16, context),
  //                                       color: Color.fromRGBO(0, 0, 0, 0.8),
  //                                       fontFamily: 'DM Sans',
  //                                     ),
  //                                     decoration: InputDecoration(
  //                                       hintText: 'Search events...',
  //                                       hintStyle: TextStyle(
  //                                         fontSize:
  //                                             Responsive.text(16, context),
  //                                         color: Color.fromRGBO(0, 0, 0, 0.4),
  //                                         fontFamily: 'DM Sans',
  //                                       ),
  //                                       border: InputBorder.none,
  //                                       isDense: true,
  //                                       contentPadding: EdgeInsets.zero,
  //                                     ),
  //                                     onChanged: (value) {
  //                                       setState(() {
  //                                         _searchQuery =
  //                                             value.trim().toLowerCase();
  //                                       });
  //                                     },
  //                                     // autofocus: true,
  //                                     maxLines: 1,
  //                                   ),
  //                                 ),
  //                                 SizedBox(
  //                                     width: Responsive.width(20, context)),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                         // Positioned(
  //                         //   top: 72,
  //                         //   left: 16,
  //                         //   right: 16,
  //                         //   child: Material(
  //                         //   elevation: 6,
  //                         //   borderRadius: BorderRadius.circular(32),
  //                         //   color: Colors.transparent,
  //                         //   child: Container(
  //                         //     height: 50, // Set height to 50px
  //                         //     width: 380,
  //                         //     decoration: BoxDecoration(
  //                         //     color: Colors.white.withOpacity(0.98),
  //                         //     borderRadius: BorderRadius.circular(32),
  //                         //     // boxShadow: [
  //                         //     //   BoxShadow(
  //                         //     //   color: Colors.black.withOpacity(0.08),
  //                         //     //   blurRadius: 12,
  //                         //     //   offset: Offset(0, 4),
  //                         //     //   ),
  //                         //     // ],
  //                         //     ),
  //                         //     child: TextField(
  //                         //     controller: _searchFieldController,
  //                         //     focusNode: _focusNode,
  //                         //     cursorColor: theme.colorScheme.primary,
  //                         //     style: theme.textTheme.bodyMedium?.copyWith(
  //                         //       fontSize: 18,
  //                         //       color: Colors.black87,
  //                         //       fontFamily: 'DM Sans',
  //                         //     ),
  //                         //     decoration: InputDecoration(
  //                         //       isDense: true,
  //                         //       contentPadding: const EdgeInsets.symmetric(
  //                         //       vertical: 14, // Adjust for 50px height
  //                         //       horizontal: 20,
  //                         //       ),
  //                         //       prefixIcon: Icon(
  //                         //       Icons.search_outlined,
  //                         //       color: Colors.grey[600],
  //                         //       size: 22, // Adjust icon size for 50px height
  //                         //       ),
  //                         //       hintText: "Search clubs...",
  //                         //       hintStyle: TextStyle(
  //                         //       color: Colors.grey[500],
  //                         //       fontSize: 17,
  //                         //       fontWeight: FontWeight.w400,
  //                         //       fontFamily: 'DM Sans',
  //                         //       ),
  //                         //       border: InputBorder.none,
  //                         //       suffixIcon: IconButton(
  //                         //       tooltip: "Clear search",
  //                         //       icon: const Icon(Icons.close_outlined, size: 22), // Adjust icon size
  //                         //       color: Colors.grey[500],
  //                         //       onPressed: () {
  //                         //         setState(() {
  //                         //         _searchFieldController?.clear();
  //                         //         });
  //                         //       },
  //                         //       ),
  //                         //     ),
  //                         //     ),
  //                         //   ),
  //                         //   ),
  //                         // ),
  //                         Positioned(
  //                           top: 140 + MediaQuery.of(context).padding.top,
  //                           left: 32,
  //                           right: 32,
  //                           child: Text(
  //                             (() {
  //                               final bodyName = body?.bodyName ?? "";
  //                               final match = widget.bodyTitles.firstWhere(
  //                                 (item) => item["bodyname"] == bodyName,
  //                                 orElse: () => {},
  //                               );
  //                               final title = match["title"] ?? "";
  //                               return title.isNotEmpty ? "$title" : "Explore";
  //                             })(),
  //                             style: theme.textTheme.displaySmall?.copyWith(
  //                               fontWeight: FontWeight.w900,
  //                               color: Colors.white,
  //                               //letterSpacing: 1.2,
  //                               fontSize: Responsive.width(36, context),
  //                               fontFamily: 'DM Sans',
  //                               shadows: [
  //                                 Shadow(
  //                                   color: Colors.black.withOpacity(0.25),
  //                                   blurRadius: 8,
  //                                   offset: Offset(0, 2),
  //                                 ),
  //                               ],
  //                             ),
  //                             textAlign: TextAlign.start,
  //                           ),
  //                         ),
  //                         Positioned(
  //                           top: 185 + MediaQuery.of(context).padding.top,
  //                           left: 32,
  //                           right: 32,
  //                           child: Text(
  //                             body?.bodyShortDescription ?? "",
  //                             style: TextStyle(
  //                               color: Colors.white,
  //                               fontSize: Responsive.width(16, context),
  //                               fontFamily: 'DM Sans',
  //                               fontWeight: FontWeight.w500,
  //                             ),
  //                             textAlign: TextAlign.start,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: Responsive.height(20, context)),
  //                     ...(_searchQuery.isEmpty ? Childrens : Childrens.where((body) {
  //                           final name = body.bodyName?.toLowerCase() ?? "";
  //                           return name.contains(_searchQuery);
  //                         }).toList()).map((b) {
  //                           return _buildBodyTile(bloc, theme.textTheme, b);
  //                         }).toList() ??
  //                         [],
  //                     Divider(),
  //                     SizedBox(height: Responsive.height(64, context)),
  //                   ],
  //                 ),
  //         )
  //         // floatingActionButton: body == null
  //         //     ? null
  //         //     : editAccess
  //         //         ? FloatingActionButton.extended(
  //         //             icon: Icon(Icons.edit_outlined),
  //         //             label: Text("Edit"),
  //         //             tooltip: "Edit this Body",
  //         //             onPressed: () {
  //         //               Navigator.of(context)
  //         //                   .pushNamed("/putentity/body/${body!.bodyID}");
  //         //             },
  //         //           )
  //         //         : FloatingActionButton(
  //         //             child: Icon(Icons.share_outlined),
  //         //             tooltip: "Share this body",
  //         //             onPressed: () async {
  //         //               await Share.share(
  //         //                   "Check this Institute Body: ${ShareURLMaker.getBodyURL(body!)}");
  //         //             },
  //         //           ),
  //         // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  //         // persistentFooterButtons: [
  //         //   FooterButtons(
  //         //     footerButtons: footerButtons,
  //         //   )
  //         // ],
  //         ),
  //   );
  // }

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
    return Material(
      child: InkWell(
        onTap: () {
          BodyPage.navigateWith(context, bloc, body: body);
        },
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(246, 246, 246, 1)),
          padding: EdgeInsets.symmetric(vertical: Responsive.height(10, context), horizontal: Responsive.width(16, context)),
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
                width: Responsive.width(73, context),
                height: Responsive.width(73, context),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Responsive.width(20, context)),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(0.1),
                  //     blurRadius: 6,
                  //     offset: Offset(0, 2),
                  //   ),
                  // ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child:
                      body.bodyImageURL != null && body.bodyImageURL!.isNotEmpty
                          ? Image.network(
                              body.bodyImageURL!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: Responsive.width(56, context),
                                height: Responsive.height(56, context),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.people_outline,
                                  size: Responsive.width(28, context),
                                  color: Colors.grey[500],
                                ),
                              ),
                            )
                          : Container(
                              width: Responsive.width(56, context),
                              height: Responsive.height(56, context),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(Responsive.width(12, context)),
                              ),
                              child: Icon(
                                Icons.people_outline,
                                size: Responsive.width(28, context),
                                color: Colors.grey[500],
                              ),
                            ),
                ),
              ),
              SizedBox(width: Responsive.width(16, context)),

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
                          fontSize: Responsive.width(18, context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      body.bodyShortDescription ?? "",
                      style: theme.bodyMedium?.copyWith(
                        color: Colors.black,
                        fontSize: Responsive.width(14, context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.height(8, context)),
                    Container(
                      // height: 23,
                      // padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/explore_new/Isolation_Mode.svg',
                            height: Responsive.height(13.78, context),
                            width: Responsive.width(17, context),
                          ),
                          SizedBox(width: Responsive.width(4, context)),
                          Text(
                            '${body.bodyFollowersCount?.toString() ?? '422'}',
                            style: TextStyle(
                              color: const Color(0xFF306FDC),
                              fontSize: Responsive.width(12, context),
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: Responsive.width(4, context)),
                          Text(
                            'senti',
                            style: TextStyle(
                              color: const Color(0xFF306FDC),
                              fontSize: Responsive.width(12, context),
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          )
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
                size: Responsive.width(24, context),
              ),
            ],
          ),
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
