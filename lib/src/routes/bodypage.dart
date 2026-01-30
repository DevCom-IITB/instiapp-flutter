import 'dart:async';
import 'dart:ui';

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
import 'package:flutter/services.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:share/share.dart';
import 'package:share_plus/share_plus.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:shimmer/shimmer.dart';

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
  bool isProfileClicked = false;
  bool isAlbumClicked = false;
  bool showLinks = false;
  bool loadingFollow = false;
  List<String> imageUrls = [
    'assets/explore_new/images/image1.png',
    'assets/explore_new/images/image2.png',
    'assets/explore_new/images/image2.png',
    'assets/explore_new/images/image2.png',
    'assets/explore_new/images/image2.png',
    'assets/explore_new/images/image3.png',
    'assets/explore_new/images/image3.png',
  ];
  List<String> linkIcon = ["globe", "whatsapp", "instagram"];
  List<String> linkLabel = ["Website", "Whatsapp Group", "Instagram"];
  List<String> link = [
    "bodyWebsiteURL",
    "bodyWhatsappGroupURL",
  ];
  Widget clubQuickLinkContainer(String icon, String label) {
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
            if (label == "Instagram") {
              url = body?.bodyInstagramURL;
            } else if (label == "Whatsapp Group") {
              url = body?.bodyWhatsappGroupURL;
            } else {
              url = body?.bodyWebsiteURL;
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
            child:
                SvgPicture.asset('assets/quicklinks/icons/external_link.svg'),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent bar
      statusBarIconBrightness: Brightness.light, // white icons
    ));
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
    final title = parent?.bodyName;
    Constants myConstants = Constants();
    Map<String, String> parentBody = {
      "Culturals@IITB": "ICC",
      "IITB Sports": "ISC",
      "Tech@IITB": "ITC",
      "IIT Bombay": "I.B.",
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
      extendBodyBehindAppBar: true,
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
                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (!mounted) return;
                      setState(() {
                        showLinks = false;
                      });
                    });
                  },
                  child: Container(
                    child: ListView(
                        padding: EdgeInsets.zero, // Add padding for the button
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cover Image
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ExploreImagePreview(
                                                      imageUrls: [
                                                        body!.bodyImageURL!
                                                      ])));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: responsive.h(200),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        //borderRadius: BorderRadius.circular(40),
                                        image: body?.bodyImageURL != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    body!.bodyImageURL!),
                                                // AssetImage(
                                                //     'assets/explore/symphony.png'),
                                                fit: BoxFit.cover,
                                              )
                                            : const DecorationImage(
                                                image: AssetImage(
                                                    'assets/photo.png'),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: ClipRect(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 7,
                                            sigmaY: 7), // adjust blur
                                        child: Container(
                                          height: MediaQuery.of(context)
                                              .padding
                                              .top,
                                          color: Colors.white.withOpacity(
                                              0.2), // translucent layer
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: responsive.w(12),
                                        top: responsive.h(MediaQuery.of(context)
                                            .padding
                                            .top)),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        height: responsive.h(52),
                                        width: responsive.h(52),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: Center(
                                          child: Container(
                                            height: responsive.h(24),
                                            width: responsive.h(24),
                                            child: SvgPicture.asset(
                                                'assets/quicklinks/icons/arrow_left.svg'),
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
                                        bottom: Radius.circular(24))),
                                child: Stack(
                                  children: [
                                    // Rotated background image
                                    Positioned(
                                      left: responsive.w(-16),
                                      child: SizedBox(
                                        width: responsive.w(105),
                                        height: responsive.h(199),
                                        child: Transform.rotate(
                                          angle: 0, // -180 degrees in radians
                                          child: Image.asset(
                                            'assets/explore/background.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          responsive.w(16),
                                          responsive.h(22),
                                          responsive.w(16),
                                          responsive.h(22)),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              child: CircleAvatar(
                                                radius: 40,
                                                backgroundColor: Colors.black,
                                                backgroundImage: body
                                                            ?.bodyImageURL !=
                                                        null
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
                                                SizedBox(
                                                    height: responsive.h(6)),
                                                Text(
                                                  body?.bodyShortDescription ??
                                                      'Music Club of IITB',
                                                  style: TextStyle(
                                                    fontSize: responsive.sp(16),
                                                    color: myConstants
                                                        .instiappGrey,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: responsive.h(6)),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: (body
                                                                ?.bodyFollowersCount
                                                                ?.toString() ??
                                                            '422'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              responsive.sp(16),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: ' Senti',
                                                        style: TextStyle(
                                                          fontSize:
                                                              responsive.sp(16),
                                                          color: myConstants
                                                              .instiappGrey,
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: responsive.w(8),
                                                vertical: responsive.h(6)),
                                            decoration: BoxDecoration(
                                                color: Color(0xFF15263C),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  height: responsive.h(20),
                                                  width: responsive.w(20),
                                                  decoration: BoxDecoration(
                                                      // color: Colors.amber[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      image: DecorationImage(
                                                          image: imageUrl !=
                                                                      null &&
                                                                  imageUrl
                                                                      .isNotEmpty
                                                              ? NetworkImage(
                                                                  imageUrl)
                                                              : const AssetImage(
                                                                      'assets/explore_new/images/org.png')
                                                                  as ImageProvider,
                                                          // image: AssetImage(
                                                          //   'assets/explore_new/images/org.png',
                                                          // ),
                                                          fit: BoxFit.cover)),
                                                ),
                                                SizedBox(
                                                    width: responsive.w(8)),
                                                Text(
                                                  parent?.bodyShortName ??
                                                      parentBody[title ?? ""] ??
                                                      "",
                                                  style: TextStyle(
                                                      fontSize:
                                                          responsive.sp(14),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: const Color(
                                                          0xFFF6F6F6)),
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
                            padding: EdgeInsets.symmetric(
                                vertical: responsive.h(10),
                                horizontal: responsive.w(16)),
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
                                              color: Color(
                                                  0xFFD0D5DD), // light grey line
                                            ),
                                          ),
                                          TabBar(
                                            indicatorColor:
                                                myConstants.instiappBlue,
                                            labelColor:
                                                myConstants.instiappBlue,
                                            unselectedLabelColor:
                                                Colors.black54,
                                            labelStyle: TextStyle(
                                              fontSize: responsive.sp(16),
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'DM Sans',
                                            ),
                                            tabs: const [
                                              Tab(text: 'About'),
                                              Tab(text: 'Events'),
                                              Tab(text: 'People'),
                                            ],
                                            onTap: (index) {
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 150), () {
                                                if (!mounted) return;
                                                setState(() {
                                                  showLinks = false;
                                                });
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: responsive.h(410),
                                        child: Builder(
                                          builder: (context) {
                                            final people = body?.bodyRoles
                                                    ?.expand((r) =>
                                                        (r.roleUsersDetail ??
                                                                [])
                                                            .map((u) => u
                                                              ..currentRole =
                                                                  r.roleName))
                                                    .toList() ??
                                                [];
                                            return TabBarView(
                                              children: [
                                                // About Tab
                                                SingleChildScrollView(
                                                  padding: EdgeInsets.only(
                                                      top: responsive.h(20)),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                                fontSize:
                                                                    responsive
                                                                        .sp(24)),
                                                      ),
                                                      body?.bodyDescription != null && body?.bodyDescription != ""
                                                        ? CommonHtml(
                                                            data: body?.bodyDescription ?? "",
                                                            defaultTextStyle: (theme.textTheme.titleMedium ?? TextStyle())
                                                                .copyWith(fontSize: responsive.sp(24)),
                                                          )
                                                        : Shimmer.fromColors(
                                                            baseColor: Colors.grey[300]!,
                                                            highlightColor: Colors.grey[100]!,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: List.generate(4, (index) {
                                                                return Padding(
                                                                  padding: EdgeInsets.only(bottom: responsive.h(8)),
                                                                  child: Container(
                                                                    width: index == 3 
                                                                        ? responsive.w(200) 
                                                                        : double.infinity,
                                                                    height: responsive.h(16),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.circular(4),
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                            ),
                                                          ),
                                                    SizedBox(height: responsive.h(20.0)),

                                                      // Photo Album Section
                                                        Text(
                                                          'Photo Album',
                                                          style: TextStyle(
                                                            fontSize: responsive
                                                                .sp(16),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontFamily:
                                                                'DM Sans',
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (photoAlbumUrls !=
                                                                    null &&
                                                                photoAlbumUrls
                                                                    .isNotEmpty) {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ExploreImagePreview(
                                                                    imageUrls:
                                                                        photoAlbumUrls,
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: (photoAlbumUrls !=
                                                                      null &&
                                                                  photoAlbumUrls
                                                                      .isNotEmpty)
                                                              ? _buildImages(
                                                                  photoAlbumUrls)
                                                              : Center(
                                                                child: SvgPicture.asset(
                                                                  'assets/explore/Social.svg',
                                                                  width: responsive.w(380),
                                                                  height: responsive.h(190),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                        ),
                                                      // Container(
                                                      //   height: 190,
                                                      //   width: 380,
                                                      // child: ListView.separated(
                                                      //   scrollDirection:
                                                      //       Axis.horizontal,
                                                      //   itemCount: 5,
                                                      //   separatorBuilder: (_, __) =>
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
                                                        body!
                                                            .bodyEvents!.isEmpty
                                                    ? const Center(
                                                        child: Text(
                                                            "No events yet."))
                                                    : ListView(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical:
                                                                    responsive
                                                                        .h(16)),
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
                                                                      e)),
                                                          SizedBox(
                                                              height: responsive
                                                                  .h(50))
                                                        ],
                                                      ),

                                                // People Tab
                                                GestureDetector(
                                                  onTap: () {
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 150),
                                                        () {
                                                      if (!mounted) return;
                                                      setState(() {
                                                        showLinks = false;
                                                      });
                                                    });
                                                  },
                                                  child: people.isEmpty
                                                      ? const Center(
                                                          child: Text(
                                                              "No people listed."))
                                                      : ListView(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      responsive
                                                                          .h(16)),
                                                          children: [
                                                            ...people
                                                                .map((u) =>
                                                                    _buildUserTile(
                                                                        bloc,
                                                                        theme,
                                                                        u))
                                                                .toList(),
                                                            SizedBox(
                                                                height:
                                                                    responsive
                                                                        .h(50))
                                                          ],
                                                        ),
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.only(
                        bottom: responsive.h(16), // Adjust as needed
                        top: responsive.h(16),
                        left: responsive.w(16),
                        right: responsive.w(16)),
                    child: Stack(
                      children: [
                          Align(
                          alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: showLinks ? responsive.h(244) : 0,
                              child: Container(
                                margin: EdgeInsets.only(
                                    bottom: responsive.h(32)), // To avoid FAB
                                padding: EdgeInsets.fromLTRB(
                                    responsive.w(20),
                                    responsive.h(16),
                                    responsive.w(20),
                                    responsive.h(0)),
                                // height: responsive.h(256),
                                width: responsive.w(380),
                                decoration: BoxDecoration(
                                    color: myConstants.instiappDark,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20))),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Quick Links",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: responsive.sp(18),
                                              fontWeight: FontWeight.w700),
                                        ),
                                        // GestureDetector(
                                        //   onTap: () {
                                        //     Future.delayed(
                                        //         const Duration(milliseconds: 150), () {
                                        //       if (!mounted) return;
                                        //       setState(() {
                                        //         showLinks = false;
                                        //       });
                                        //     });
                                        //   },
                                        //   child: Container(
                                        //     height: responsive.h(21),
                                        //     width: responsive.w(21),
                                        //     child: SvgPicture.asset(
                                        //         'assets/explore_new/x.svg'),
                                        //   ),
                                        // )
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
                                    for (int i = 0; i <= 2; i++) ...[
                                      clubQuickLinkContainer(
                                          linkIcon[i], linkLabel[i]),
                                      if (i != 3)
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
                            padding:
                                EdgeInsets.symmetric(horizontal: responsive.w(6)),
                            height: responsive.h(64),
                            width: responsive.w(380),
                            decoration: BoxDecoration(
                                color: myConstants.instiappDark,
                                borderRadius: BorderRadius.circular(50),
                                ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Future.delayed(
                                        const Duration(milliseconds: 150), () {
                                      if (!mounted) return;
                                      setState(() {
                                        showLinks = !showLinks;
                                      });
                                    });
                                  },
                                  child: Container(
                                    height: responsive.h(52),
                                    width: responsive.w(52),
                                    decoration: BoxDecoration(
                                        color: Color(0xFF2B4E83),
                                        borderRadius: BorderRadius.circular(50)),
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
                                        backgroundColor:
                                            (body!.bodyUserFollows ?? false)
                                                ? Color.fromRGBO(43, 78, 131, 1)
                                                : Color(0xFF306FDC),
                                        padding: EdgeInsets.symmetric(
                                            vertical: responsive.h(14)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (body != null) {
                                          await bloc.updateFollowBody(body!);
                                          setState(() {});
                                        }
                                      },
                                      child: Text(
                                        (body!.bodyUserFollows ?? false)
                                            ? 'Joined'
                                            : 'Join',
                                        style: TextStyle(
                                          fontSize: responsive.h(16),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'DM Sans',
                                          color: Colors.white,
                                        ),
                                      )),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                if (isAlbumClicked)
                  Positioned.fill(
                      child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isAlbumClicked = false;
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
                                itemBuilder: (context, index) {
                                  return InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    child: Image.asset(
                                      imageUrls[index],
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                }),
                          ),
                        ),
                      )
                    ],
                  )),
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
    final responsive = Responsive(context);
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
                          borderRadius:
                              BorderRadius.only(topRight: Radius.circular(12)),
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
                              bottomRight: Radius.circular(12)),
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
                                            fontSize: responsive.w(15.29)),
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
      onTap: () {
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
                        // color: Colors.pink[100],
                        borderRadius:
                            BorderRadius.circular(responsive.w(35.5))),
                    child: NullableCircleAvatar(
                      event.eventImageURL ??
                          event.eventBodies?[0].bodyImageURL ??
                          "",
                      Icons.event_outlined,
                      radius: responsive.w(35.5),
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
                              fontSize: responsive.w(20)),
                        ),
                        SizedBox(height: responsive.h(4)),
                        Text(
                          event.getSubTitle(),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: responsive.w(14)),
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
      onTap: () {
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
                        // color: Colors.pink[100],
                        borderRadius: BorderRadius.circular(35.5)),
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
                              fontSize: responsive.sp(20)),
                        ),
                        SizedBox(height: responsive.h(4)),
                        Text(
                          u.getSubTitle() ?? "",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: responsive.w(14)),
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
  const PhotoAlbumGrid({required this.imageUrls, super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    int col, row;
    // final displayImages=imageUrls.take(5).toList();
    final extraCount = imageUrls.length - 5;
    final displayImages = [
      "data:image/jpeg;base64,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",
      "data:image/jpeg;base64,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",
      "data:image/jpeg;base64,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",
      "data:image/jpeg;base64,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"
    ];
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
                )),
            SizedBox(width: responsive.w(2)),
            Expanded(
                flex: 2,
                child: Row(
                  children: [
                    for (row = 0; row < 2; row++) ...[
                      Expanded(
                          child: Column(
                        children: [
                          for (col = 0; col < 2; col++) ...[
                            Expanded(
                              flex: 2,
                              child: Stack(
                                children: [
                                  Image.asset(
                                    displayImages[row * 2 + col * 1 + 1],
                                    fit: BoxFit.cover,
                                    height: responsive.h(94.25),
                                  ),
                                  if (col == 1 && row == 1)
                                    Positioned.fill(
                                        child: Container(
                                      color: Color(0xB3000000),
                                      child: Center(
                                        child: Text(
                                          "+${extraCount}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: responsive.sp(16),
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ))
                                ],
                              ),
                            ),
                            if (col == 0) SizedBox(height: responsive.h(1.5))
                          ]
                        ],
                      )),
                      if (row == 0)
                        SizedBox(
                          width: responsive.h(1.5),
                        )
                    ]
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
