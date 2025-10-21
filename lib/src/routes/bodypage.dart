import 'dart:async';

import 'package:InstiApp/constants.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/routes/exploreimagepreview.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/footer_buttons.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:markdown/markdown.dart' as markdown;

class Responsive {
  final BuildContext context;
  final double baseWidth;  
  final double baseHeight;

  Responsive(this.context, {this.baseWidth = 411, this.baseHeight = 914});

  double w(double px) => MediaQuery.of(context).size.width * (px / baseWidth);
  double h(double px) => MediaQuery.of(context).size.height * (px / baseHeight);
  double sp(double px) => w(px); // scale text with width
}

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
  Constants myConstants = Constants();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Body? body;
  bool isProfileClicked=false;
  bool isAlbumClicked=false;
  bool showLinks=false;
  bool loadingFollow = false;
  List<String> imageUrls=['assets/explore_new/images/image1.png',
                          'assets/explore_new/images/image2.png',
                          'assets/explore_new/images/image2.png',
                          'assets/explore_new/images/image2.png',
                          'assets/explore_new/images/image2.png',
                          'assets/explore_new/images/image3.png',
                          'assets/explore_new/images/image3.png',];
  List<String> linkIcon=["globe","whatsapp","instagram"];
  List<String> linkLabel=["Website","Whatsapp Group","Instagram"];
  List<String> link=["bodyWebsiteURL","bodyWhatsappGroupURL",];
  Widget clubQuickLinkContainer(String icon, String label){
    final responsive = Responsive(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: responsive.h(24),
              width: responsive.w(24),
              child: SvgPicture.asset('assets/explore_new/${icon}.svg'),
            ),
            SizedBox(width: responsive.w(9)),
            Text(
              label,
              style: TextStyle(
              color: Colors.white,
              fontSize: responsive.sp(16),
              fontWeight: FontWeight.w500,
            ),
          ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            final url;
            if(label=="Instagram"){
              url=body?.bodyInstagramURL;
            }
            else if(label=="Whatsapp Group"){
              url=body?.bodyWhatsappGroupURL;
            }
            else{
              url=body?.bodyWebsiteURL;
            }
            // final url = body?.bodyWebsiteURL;
            if (url != null && url.isNotEmpty) {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            }
          },
          child: Container(
            height: responsive.h(24),
            width: responsive.w(24),
            child: SvgPicture.asset('assets/quicklinks/icons/external_link.svg'),
          ),
        ),
      ],
    );
  }

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
    final responsive = Responsive(context);
    final photoAlbumUrls = body?.bodyPhotoalbumURLs;
    final parent = (body?.bodyParents != null && body!.bodyParents!.isNotEmpty)
        ? body!.bodyParents!.first
        : null;
    final imageUrl = parent?.bodyImageURL;
    final title=parent?.bodyName;
    Constants myConstants=Constants();
    Map<String,String> parentBody = {
      "Culturals@IITB": "ICC",
      "IITB Sports": "ISC",
      "Tech@IITB": "ITC",
      "IIT Bombay": "IITB",
      "Hostel Affairs": "HA",
      "Departments": "IITB",
      "DevCom": "DC",
      "Placement Cell": "IITB"
    };
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
      //backgroundColor: Colors.blue[300],
      backgroundColor: Color(0xFFF6F6F6),
      key: _scaffoldKey,
      // drawer: NavDrawer(),
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
      body: body == null
          ? Center(
              child: CircularProgressIndicatorExtended(
              label: Text("Loading the body page"),
            ))
          : Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showLinks=false;
                    });
                  },
                  child: SafeArea(
                    child: ListView(
                        //padding: EdgeInsets.only(bottom: 100), // Add padding for the button
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cover Image
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context, 
                                        MaterialPageRoute(
                                          builder: (context)=>ExploreImagePreview(imageUrls: ["assets/explore/symphony.png"])
                                          )
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: responsive.h(200),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        //borderRadius: BorderRadius.circular(40),
                                        image: body?.bodyImageURL != null
                                        ? DecorationImage(
                                            image:
                                                // NetworkImage(body!.bodyImageURL!),
                                                AssetImage(
                                                  'assets/explore/symphony.png'
                                                ),
                                            fit: BoxFit.cover,
                                          )
                                        : const DecorationImage(
                                            image: AssetImage('assets/photo.png'),
                                            fit: BoxFit.cover,
                                          ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: responsive.w(12)),
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        height: 52,
                                        width: 52,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(25)
                                        ),
                                        child: Center(
                                          child: Container(
                                            height: responsive.h(24),
                                            width: responsive.w(24),
                                            child: SvgPicture.asset('assets/quicklinks/icons/arrow_left.svg'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              
                              // Profile Card Section
                              Container(
                                width: double.infinity,
                                // height: 125,
                                //padding: EdgeInsets.fromLTRB(16, 22, 16, 20),
                                // padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F1620),
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(24)
                                  )
                                ),
                                child: Stack(
                                  children: [
                                    // Rotated background image
                                    Positioned(
                                      left: responsive.w(-16),
                                      child: SizedBox(
                                        width: responsive.w(105),
                                        height: responsive.h(199),
                                        child: Transform.rotate(
                                          angle:
                                              0, // -180 degrees in radians
                                          child: Image.asset(
                                            'assets/explore/background.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                          
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(responsive.w(16), responsive.h(22), responsive.w(16), responsive.h(22)),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            // onTap: (){
                                            //   setState(() {
                                            //     isProfileClicked=true;
                                            //     //showLinks=false;
                                            //   });
                                            // },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white, width: 2),
                                              ),
                                              child: CircleAvatar(
                                                radius: 40,
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
                                          ),
                                          SizedBox(width: responsive.w(20)),
                                                              
                                          // Profile Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  body?.bodyName ?? 'Symphony',
                                                  style: TextStyle(
                                                    fontSize: responsive.sp(24),
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: responsive.h(6)),
                                                Text(
                                                  body?.bodyShortDescription ??
                                                      'Music Club of IITB',
                                                  style:TextStyle(
                                                    fontSize: responsive.sp(16),
                                                    color: myConstants.instiappGrey,
                                                  ),
                                                ),
                                                SizedBox(height: responsive.h(6)),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: (body
                                                                ?.bodyFollowersCount
                                                                ?.toString() ??
                                                            '422'),
                                                        style: TextStyle(
                                                          fontSize: responsive.sp(16),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: ' Senti',
                                                        style: TextStyle(
                                                          fontSize: responsive.sp(16),
                                                          color: myConstants.instiappGrey,
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
                                          Container(
                                            height: responsive.h(35),
                                            padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(6)),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF15263C),
                                              borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  height: responsive.h(20),
                                                  width: responsive.w(20),
                                                  decoration: BoxDecoration(
                                                    // color: Colors.amber[100],
                                                    borderRadius: BorderRadius.circular(10),
                                                    image: DecorationImage(
                                                      image: imageUrl != null && imageUrl.isNotEmpty
                                                        ? NetworkImage(imageUrl)
                                                        : const AssetImage('assets/explore_new/images/org.png') as ImageProvider,
                                                      // image: AssetImage(
                                                      //   'assets/explore_new/images/org.png',
                                                      // ),
                                                      fit: BoxFit.cover
                                                      )
                                                  ),
                                                ),
                                                SizedBox(width: responsive.w(8)),
                                                Text(
                                                  parentBody[title ?? ""] ?? "",
                                                  style: TextStyle(
                                                    fontSize: responsive.sp(14),
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFFF6F6F6)
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: responsive.h(16),horizontal: responsive.w(16)),
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
                                SizedBox(height: responsive.h(7)),
                                DefaultTabController(
                                  length: 3,
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              height: responsive.h(1.5),
                                              color: Color(0xFFD0D5DD), // light grey line
                                            ),
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
                                            Tab(text: 'About'),
                                            Tab(text: 'Events'),
                                            Tab(text: 'People'),
                                          ],
                                          onTap: (index){
                                            setState(() {
                                              showLinks=false;
                                            });
                                          }
                                        ),
                                        ],
                                        
                                      ),
                                      SizedBox(
                                        height: responsive.h(410),
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
                                                  padding: EdgeInsets.only(top: responsive.h(24)),
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
                                                                TextStyle())
                                                            .copyWith(
                                                                fontSize: responsive.sp(24)),
                                                      ),
                                                      body?.bodyDescription !=
                                                              null
                                                          ? SizedBox(
                                                              height: responsive.h(20.0),
                                                            )
                                                          : SizedBox(
                                                              height: 0.0,
                                                            ),
                                                      //Divider(),
                                                      SizedBox(height: responsive.h(16)),
                          
                                                      // Photo Album Section
                                                      // Text(
                                                      //   'Photo Album',
                                                      //   style: TextStyle(
                                                      //     fontSize: responsive.sp(16),
                                                      //     fontWeight:FontWeight.w700,
                                                      //     fontFamily: 'DM Sans',
                                                      //   ),
                                                      // ),
                                                      // PhotoAlbumGrid(imageUrls: imageUrls),
                                                      // if (photoAlbumUrls != null && photoAlbumUrls.isNotEmpty)
                                                      // ...[
                                                      // Text(
                                                      //   'Photo Album',
                                                      //   style: TextStyle(
                                                      //     fontSize: responsive.sp(16),
                                                      //     fontWeight:FontWeight.w700,
                                                      //     fontFamily: 'DM Sans',
                                                      //   ),
                                                      // ),
                                                      // SizedBox(height: responsive.h(12)),
                                                      // GestureDetector(
                                                      //   onTap: () {
                                                      //     if (photoAlbumUrls != null && photoAlbumUrls.isNotEmpty) {
                                                      //       Navigator.push(
                                                      //         context,
                                                      //         MaterialPageRoute(
                                                      //           builder: (context) => ExploreImagePreview(
                                                      //             imageUrls: photoAlbumUrls,
                                                      //           ),
                                                      //         ),
                                                      //       );
                                                      //      }
                                                      //     },
                                                      //     child: (photoAlbumUrls != null && photoAlbumUrls.isNotEmpty)
                                                      //       ? _buildImages(photoAlbumUrls)
                                                      //       : PhotoAlbumGrid(imageUrls: imageUrls),
                                                      // ),

                                                      // ],
                                                      SizedBox(height: responsive.h(40)),
                                                      // Container(
                                                      //   height: 190,
                                                      //   width: 380,
                                                        // child: ListView.separated(
                                                        //   scrollDirection:
                                                        //       Axis.horizontal,
                                                        //   itemCount: 5,
                                                        //   separatorBuilder: (_,
                                                        //           __) =>
                                                        //       const SizedBox(
                                                        //           width: 8),
                                                        //   itemBuilder:
                                                        //       (context, index) {
                                                        //     return Container(
                                                        //       width: 100,
                                                        //       decoration:
                                                        //           BoxDecoration(
                                                        //         color: Colors.grey
                                                        //             .shade300,
                                                        //         borderRadius:
                                                        //             BorderRadius
                                                        //                 .circular(
                                                        //                     8),
                                                        //       ),
                                                        //     );
                                                        //   },
                                                        // ),
                                                      // ),
                          
                                                      SizedBox(height: responsive.h(24)),
                          
                                                      // Part Of Section
                                                      // const Text(
                                                      //   'Part of',
                                                      //   style: TextStyle(
                                                      //     fontSize: 20,
                                                      //     fontWeight:
                                                      //         FontWeight.w600,
                                                      //     fontFamily: 'DM Sans',
                                                      //   ),
                                                      // ),
                                                      // const SizedBox(height: 12),
                                                      // ...(body?.bodyParents
                                                      //         ?.map((b) =>
                                                      //             _buildBodyTile(
                                                      //                 bloc,
                                                      //                 theme
                                                      //                     .textTheme,
                                                      //                 b))
                                                      //         .toList() ??
                                                      //     [])
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
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                            vertical: responsive.h(16)),
                                                        children: [
                                                          // Padding(
                                                          //   padding:
                                                          //       const EdgeInsets
                                                          //           .symmetric(
                                                          //           horizontal:
                                                          //               28.0,
                                                          //           vertical:
                                                          //               8.0),
                                                          //   child: Text(
                                                          //     "Events",
                                                          //     style: theme
                                                          //         .textTheme
                                                          //         .headlineSmall,
                                                          //   ),
                                                          // ),
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
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                            vertical: responsive.h(16)),
                                                        children: [
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
                  ),
                ),
              if(showLinks)
                Padding(
                  //padding: const EdgeInsets.all(16.0),
                  padding: EdgeInsets.fromLTRB(responsive.w(16), responsive.h(0), responsive.w(16), responsive.h(16)),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(responsive.w(20), responsive.h(16), responsive.w(20), responsive.h(24)),
                      height: responsive.h(256),
                      width: responsive.w(380),
                      decoration: BoxDecoration(
                        color: myConstants.instiappDark,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(40),
                          top: Radius.circular(20)
                        )
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Quick Links",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.sp(18),
                                  fontWeight: FontWeight.w700
                                ),
                              ),
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    showLinks=false;
                                  });
                                },
                                child: Container(
                                  height: responsive.h(21),
                                  width: responsive.w(21),
                                  child: SvgPicture.asset('assets/explore_new/x.svg'),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: responsive.h(16)),
                          Dash(
                            direction: Axis.horizontal,
                            length: responsive.w(339),
                            dashLength: 6,
                            dashGap: 7,
                            dashColor: Colors.white.withOpacity(0.10),
                          ),
                          SizedBox(height: responsive.h(16)),
                          for(int i=0;i<=2;i++)...[
                            clubQuickLinkContainer(linkIcon[i],linkLabel[i]),
                            if(i!=3)
                              SizedBox(height: responsive.h(12))
                          ] 
                        ],
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  //color: Colors.amber,
                    padding: EdgeInsets.fromLTRB(responsive.w(10), responsive.h(10), responsive.w(10), responsive.h(16)),
                    // color: Colors.transparent,
                    // decoration: const BoxDecoration(
                    //   color: Colors.white,
                    //   borderRadius: BorderRadius.all(Radius.circular(50)),
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: Colors.black12,
                    //       blurRadius: 8,
                    //       offset: Offset(0, -2),
                    //     ),
                    //   ],
                    // ),
                    child: Container(
                      padding: showLinks?EdgeInsets.only(bottom: responsive.h(6)):EdgeInsets.symmetric(vertical: responsive.h(6),horizontal: responsive.w(6)),
                      decoration: BoxDecoration(
                        color: Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      
                      child: Stack(
                        children: [
                          Container(
                        padding: EdgeInsets.symmetric(horizontal: responsive.w(6)),
                        height: responsive.h(64),
                        width: responsive.w(380),
                        decoration: BoxDecoration(
                          color: myConstants.instiappDark,
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showLinks=true;
                                });
                              },
                              child: Container(
                                height: responsive.h(52),
                                width: responsive.w(52),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2B4E83),
                                  borderRadius: BorderRadius.circular(50)
                                ),
                                child: Container(
                                  height: responsive.h(24),
                                  width: responsive.w(24),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/explore_new/link.svg',
                                      height: responsive.h(24),
                                      width: responsive.w(24),
                                      ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: responsive.w(8)),
                            Expanded(
                              child: SizedBox(
                                height: responsive.h(52),
                                child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: myConstants.instiappBlue,
                                  padding: EdgeInsets.symmetric(vertical: responsive.h(14)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                onPressed: () async {
                                  if(body!=null){
                                    
                                      await bloc.updateFollowBody(body!);
                                      setState((){});
                                    
                                  }  
                                },
                                child: Text(
                                  (body!.bodyUserFollows ?? false) ? 'Joined' : 'Join',
                                  style: TextStyle(
                                    fontSize: responsive.h(16),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'DM Sans',
                                    color: Colors.white,
                                  ),
                                )
                                
                              ),
                              )
                            ),
                          ],
                        ),
                      ),
                        ],
                      )
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
                // if(isProfileClicked)
                //   Positioned.fill(
                //     child: Stack(
                //       children: [
                //         GestureDetector(
                //           onTap: (){
                //             setState(() {
                //               isProfileClicked=false;
                //             });
                //           },
                //           child: AnimatedOpacity(
                //             duration: Duration(milliseconds: 1000),
                //             opacity: isProfileClicked ? 1.0 : 0.0,
                //             child: Container(
                //               color: Color(0xB3000000),
                //             ),
                //           ),
                //         ),
                //         Center(
                //           child: AnimatedScale(
                //             scale: isProfileClicked ? 1.0 : 0.8,
                //             duration: Duration(milliseconds: 300),
                //             curve: Curves.easeOutBack,
                //             child: Container(
                //               height: 350,
                //               width: 350,
                //               // color: Colors.amber[300],
                //               child: body?.bodyImageURL != null
                //               ? Image.network(body!.bodyImageURL!, fit: BoxFit.contain)
                //               : Image.asset('assets/symphony.png', fit: BoxFit.cover),
                //             ),
                //           ),
                //         )
                //       ],
                //     )
                //   ),
                if(isAlbumClicked)
                  Positioned.fill(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              isAlbumClicked=false;
                            });
                          },
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 1000),
                            opacity: isAlbumClicked ? 1.0 : 0.0,
                            child: Container(
                              color: Color(0xB3000000),
                            ),
                          ),
                        ),
                        Center(
                          child: AnimatedScale(
                            scale: isAlbumClicked ? 1.0 : 0.8,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            child: Container(
                              height: responsive.h(350),
                              width: responsive.w(350),
                              // color: Colors.amber[300],
                              // child: Image.asset('assets/explore_new/images/image1.png')
                              child: PageView.builder(
                                itemCount: imageUrls.length,
                                itemBuilder: (context, index){
                                  return InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    child: Image.asset(
                                      imageUrls[index],
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                }
                                ),
                            ),
                          ),
                        )
                      ],
                    )
                  ),
              ],
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

  Widget _buildImages(List<String> images) {
    final imageCount = images.length;

    if (imageCount == 0) return Container();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12, bottom: 8),
      child: _buildImageGrid(images, imageCount),
    );
  }

  Widget _buildImageGrid(List<String> images, int imageCount) {
    switch (imageCount) {
      case 1:
        return FutureBuilder<ImageInfo>(
          future: _getImageInfo(images[0]),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Color(0xFFF0F0F0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final imageInfo = snapshot.data;
            final aspectRatio = imageInfo != null
                ? imageInfo.image.width / imageInfo.image.height
                : 16 / 9;

            return AspectRatio(
              aspectRatio: aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  images[0],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Color(0xFFF0F0F0),
                      child:
                          Icon(Icons.error_outline, color: Color(0xFF666666)),
                    );
                  },
                ),
              ),
            );
          },
        );

      case 2:
        return FutureBuilder<List<ImageInfo?>>(
          future: Future.wait([
            _getImageInfo(images[0]),
            _getImageInfo(images[1]),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container(
                height: 200,
                child: Row(
                  children: [
                    Expanded(child: _buildImagePlaceholder()),
                    SizedBox(width: 4),
                    Expanded(child: _buildImagePlaceholder()),
                  ],
                ),
              );
            }

            final imageInfos = snapshot.data!;
            final aspectRatio1 = imageInfos[0] != null
                ? imageInfos[0]!.image.width / imageInfos[0]!.image.height
                : 1.0;
            final aspectRatio2 = imageInfos[1] != null
                ? imageInfos[1]!.image.width / imageInfos[1]!.image.height
                : 1.0;

            // Calculate height that maintains both aspect ratios
            final availableWidth = MediaQuery.of(context).size.width -
                92; // 60px avatar + 32px padding
            final gapWidth = 4.0;
            final totalWidth = availableWidth - gapWidth;

            final width1 =
                totalWidth * (aspectRatio1 / (aspectRatio1 + aspectRatio2));
            final width2 = totalWidth - width1;
            final height1 = width1 / aspectRatio1;
            final height2 = width2 / aspectRatio2;

            final containerHeight = height1 > height2 ? height1 : height2;

            return Container(
              height: containerHeight,
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[0],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: gapWidth),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[1],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

      case 3:
        return Container(
          height: 200,
          child: Row(
            children: [
              // Big image on left (50% width)
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  child: Image.network(
                    images[0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  ),
                ),
              ),
              SizedBox(width: 4),
              // Two small images on right (50% width total)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                        ),
                        child: Image.network(
                          images[1],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                        ),
                        child: Image.network(
                          images[2],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 4:
        return LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final spacing = 4.0;
            final itemSize = (totalWidth - spacing) / 2; // each square

            return Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[0],
                        width: itemSize,
                        height: itemSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
                    ),
                    SizedBox(width: spacing),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[1],
                        width: itemSize,
                        height: itemSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[2],
                        width: itemSize,
                        height: itemSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
                    ),
                    SizedBox(width: spacing),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[3],
                        width: itemSize,
                        height: itemSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );

      default: // 5 or more
        return LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final spacing = 4.0;

            // Calculate widths
            final leftWidth = (totalWidth - spacing) / 2;
            final rightWidth = (totalWidth - spacing) / 2;
            final gridItemSize = (rightWidth - spacing) / 2;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Big left image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Image.network(
                    images[0],
                    width: leftWidth,
                    height: leftWidth, // square
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImagePlaceholder(),
                  ),
                ),
                SizedBox(width: spacing),
                // Right 2x2 grid
                Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          //borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            images[1],
                            width: gridItemSize,
                            height: gridItemSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                          ),
                        ),
                        SizedBox(width: spacing),
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12)
                          ),
                          child: Image.network(
                            images[2],
                            width: gridItemSize,
                            height: gridItemSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing),
                    Row(
                      children: [
                        ClipRRect(
                          //borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            images[3],
                            width: gridItemSize,
                            height: gridItemSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                          ),
                        ),
                        SizedBox(width: spacing),
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(12)
                          ),
                          child: Stack(
                            children: [
                              Image.network(
                                images[4],
                                width: gridItemSize,
                                height: gridItemSize,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildImagePlaceholder(),
                              ),
                              if (images.length > 5)
                                Positioned.fill(
                                  child: Container(
                                    color: Color(0xB3000000),
                                    child: Center(
                                      child: Text(
                                        "+${images.length - 5}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15.29
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            );
          },
        );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Color(0xFFF0F0F0),
      child: Icon(Icons.error_outline, color: Color(0xFF666666)),
    );
  }
  Future<ImageInfo> _getImageInfo(String imageUrl) async {
    final completer = Completer<ImageInfo>();
    final imageStream =
        NetworkImage(imageUrl).resolve(ImageConfiguration.empty);

    final listener =
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      completer.complete(info);
    });

    imageStream.addListener(listener);
    return completer.future;
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
    final responsive = Responsive(context);
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
            width: responsive.w(8),
          ),
          body?.bodyFollowersCount != null
              ? Text("${body?.bodyFollowersCount}")
              : SizedBox(
                  height: responsive.h(18),
                  width: responsive.w(18),
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
                height: responsive.h(18),
                width: responsive.w(18),
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      body?.bodyUserFollows ?? false
                          ? theme.floatingActionButtonTheme.foregroundColor!
                          : theme.colorScheme.secondary),
                  strokeWidth: 2,
                )),
            SizedBox(
              width: responsive.w(8),
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
    final responsive = Responsive(context);
    // return ListTile(
    //   title: Text(
    //     event.eventName ?? "",
    //     // style: theme.textTheme.titleLarge,
    //     style: TextStyle(
    //       color: Colors.black,
    //       fontSize: 20,
    //       fontWeight: FontWeight.w600,
    //     ),
    //   ),
    //   enabled: true,
    //   leading: NullableCircleAvatar(
    //     event.eventImageURL ?? event.eventBodies?[0].bodyImageURL ?? "",
    //     Icons.event_outlined,
    //     radius: 36,
    //     heroTag: event.eventID ?? "",
    //   ),
    //   subtitle: Text(
    //     event.getSubTitle(),
    //     style: TextStyle(
    //       color: Colors.black,
    //       fontWeight: FontWeight.w400
    //     ),
    //     ),
    //   onTap: () {
    //     EventPage.navigateWith(context, bloc, event);
    //   },
    // );
    return GestureDetector(
      onTap: (){
        EventPage.navigateWith(context, bloc, event);
      },
      child: Padding(
        padding: EdgeInsets.only(left: responsive.w(16)),
        child: Column(
          children: [
            Container(
              // height: 72,
              width: responsive.w(364),
              child: Row(
                children: [
                  Container(
                    height: responsive.h(71),
                    width: responsive.w(71),
                    decoration: BoxDecoration(
                      color: Colors.pink[100],
                      borderRadius: BorderRadius.circular(35.5)
                    ),
                    child: NullableCircleAvatar(
                      event.eventImageURL ?? event.eventBodies?[0].bodyImageURL ?? "",
                      Icons.event_outlined,
                      radius: 35.5,
                      heroTag: event.eventID ?? "",
                    ),
                  ),
                  SizedBox(width: responsive.w(16)),
                  Container(
                    width: responsive.w(242),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.eventName ?? "",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: responsive.sp(20)
                          ),
                        ),
                        SizedBox(height: responsive.h(4)),
                        Text(
                          event.getSubTitle(),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: responsive.h(16))
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(InstiAppBloc bloc, ThemeData theme, User u) {
    final responsive = Responsive(context);
    // return ListTile(
    //   leading: NullableCircleAvatar(
    //     u.userProfilePictureUrl ?? "",
    //     Icons.person_outline_outlined,
    //     heroTag: u.userID ?? "",
    //   ),
    //   title: Text(
    //     u.userName ?? "",
    //     style: theme.textTheme.titleLarge,
    //   ),
    //   subtitle: Text(u.getSubTitle() ?? ""),
    //   onTap: () {
    //     UserPage.navigateWith(context, bloc, u);
    //   },
    // );
    return GestureDetector(
      onTap: (){
        UserPage.navigateWith(context, bloc, u);
      },
      child: Padding(
        padding: EdgeInsets.only(left: responsive.w(16)),
        child: Column(
          children: [
            Container(
              // height: 72,
              width: responsive.w(364),
              child: Row(
                children: [
                  Container(
                    height: responsive.h(71),
                    width: responsive.w(71),
                    decoration: BoxDecoration(
                      color: Colors.pink[100],
                      borderRadius: BorderRadius.circular(35.5)
                    ),
                    child: NullableCircleAvatar(
                      u.userProfilePictureUrl ?? "",
                      Icons.person_outline_outlined,
                      radius: 35.5,
                      heroTag: u.userID ?? "",
                    ),
                  ),
                  SizedBox(width: responsive.w(16)),
                  Container(
                    width: responsive.w(242),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.userName ?? "",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: responsive.sp(20)
                          ),
                        ),
                        SizedBox(height: responsive.h(4)),
                        Text(
                          u.getSubTitle() ?? "",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: responsive.h(16))
          ],
        ),
      ),
    );
  }
}
class PhotoAlbumGrid extends StatelessWidget {
  final List<String> imageUrls;
  const PhotoAlbumGrid({required this.imageUrls,super.key});

  @override
  Widget build(BuildContext context){
    final responsive = Responsive(context);
    int col,row;
    final displayImages=imageUrls.take(5).toList();
    final extraCount=imageUrls.length-5;
    return Container(
      height: responsive.h(190),
      width: responsive.w(380),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        //color: Colors.amber[200]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Image.asset(
                displayImages[0],
                fit: BoxFit.cover,
              )
            ),
            SizedBox(width: responsive.w(2)),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  for(row=0;row<2;row++) ...[
                    Expanded(
                      child: Column(
                        children: [
                          for(col=0;col<2;col++) ...[
                            Expanded(
                              flex: 2,
                              child: Stack(
                                children: [
                                  Image.asset(
                                    displayImages[row*2 + col*1 +1],
                                    fit: BoxFit.cover,
                                    height: responsive.h(94.25),
                                  ),
                                  if(col==1 && row==1)
                                    Positioned.fill(
                                      child: Container(
                                        color: Color(0xB3000000),
                                        child: Center(
                                          child: Text(
                                            "+${extraCount}",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: responsive.sp(16),
                                              fontWeight: FontWeight.w600
                                            ),
                                            ),
                                        ),
                                      )

                                    )
                                ],
                              ),
                              
                            ),
                            if(col==0)
                              SizedBox(height: responsive.h(1.5))
                          ]
                        ],
                      )
                    ),
                    if(row==0)
                      SizedBox(
                        width: responsive.h(1.5),
                      )
                  ]
                ],
              )
            ),
          ],
        ),
      ),

    );
  }
}
