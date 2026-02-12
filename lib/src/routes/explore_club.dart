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
import 'package:InstiApp/src/shimmers/shimmer_body_tile.dart';
import 'package:InstiApp/src/shimmers/header_description.dart';
import 'package:InstiApp/src/shimmers/header_title.dart';

class ExploreClubPage extends StatefulWidget {
  final Future<Body> Function()? loadBody;
  final String? heroTag;
  final VoidCallback onBack;

  final String? headerTitle;
  final String? headerDescription;

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
      "bodyname": "UGAC",
      "title": "Academics",
    },
    {
      "bodyname": "Hostel Affairs",
      "title": "Hostels",
    },
    {
      "bodyname": "Departments",
      "title": "Departments",
    },
    {
      "bodyname": "IIT Bombay",
      "title": "I.B.s",
    },
    {
      "bodyname": "DevCom",
      "title": "DevCom",
    },
    {
      "bodyname": "Placement Cell",
      "title": "Placement",
    }
  ];

  ExploreClubPage({
    this.loadBody,
    this.heroTag,
    required this.onBack,
    this.headerTitle,
    this.headerDescription,
  });

  @override
  _ExploreClubPageState createState() => _ExploreClubPageState();
}

class _ExploreClubPageState extends State<ExploreClubPage> {
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

  List<Body> Childrens = [];

  bool _isLoading = true;
  bool _hasError = false;
  Map<String, String> bodyIdToImage = {
    "91199c20-7488-41c5-9f6b-6f6c7c5b897d": "assets/explore/cultBG.png",
    "81e05a1a-7fd1-45b5-84f6-074e52c0f085": "assets/explore/techBG.png",
    "a9f81e69-fcc9-4fe3-b261-9e5e7a13f898": "assets/explore/sportsBG.png",
    "44fe710a-8ede-4d59-a25b-a86434373209": "assets/explore/acadsBG.png",
    "f3ae5230-4441-4586-81a8-bf75a2e47318": "assets/explore/hostelsBG.png",
    "252ddc80-910b-4f63-b68a-de30a62a947e": "assets/explore/deptsBG.png",
    "de55aa06-7f0a-46d4-bad4-d0150671e56c": "assets/explore/ibBG.png",
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent bar
      statusBarIconBrightness: Brightness.light, // white icons
    ));

    _loadBody();
  }

  Future<void> _loadBody() async {
    if (widget.loadBody == null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final b = await widget.loadBody!();
      if (!mounted) return;

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

      setState(() {
        body = b;
        _isLoading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;

    return WillPopScope(
      onWillPop: () async {
        widget.onBack();
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          if (widget.loadBody != null) {
            setState(() {
              _isLoading = true;
            });
            try {
              Body b = await widget.loadBody!();
              Childrens = b.bodyChildren ?? [];
              Childrens.sort((a, b) => (b.bodyFollowersCount ?? 0)
                  .compareTo(a.bodyFollowersCount ?? 0));
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
                  _isLoading = false;
                });
              } else {
                body = b;
                _isLoading = false;
              }
            } catch (error) {
              if (this.mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            }
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Color.fromRGBO(246, 246, 246, 1),
          key: _scaffoldKey,
          // drawer: NavDrawer(),
          body: Column(
            children: [
              // Fixed Header
              Stack(
                children: [
                  Container(
                    height: Responsive.width(270, context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft:
                            Radius.circular(Responsive.width(20, context)),
                        bottomRight:
                            Radius.circular(Responsive.width(20, context)),
                      ),
                      child: Stack(
                        children: [
                          Image.asset(
                            bodyIdToImage[widget.heroTag] ??
                                'assets/explore/cultBG.png',
                            // 'assets/explore/culturals.png',
                            height: Responsive.width(275, context),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          // Black gradient at bottom
                          // Positioned(
                          //   bottom: 0,
                          //   left: 0,
                          //   right: 0,
                          //   child: Container(
                          //     height: Responsive.width(150, context),
                          //     decoration: BoxDecoration(
                          //       gradient: LinearGradient(
                          //         begin: Alignment(1, 0), // Middle left
                          //         end: Alignment(0, 0), // Middle bottom
                          //         colors: [
                          //           Colors.transparent,
                          //           Colors.black.withOpacity(0.6),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: MediaQuery.of(context).padding.top,
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
                    top: Responsive.height(70, context) +
                        MediaQuery.of(context).padding.top,
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
                                hintText: 'Search bodies...',
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
                                  height: Responsive.height(24, context),
                                ),
                              ),
                            ),
                          SizedBox(width: Responsive.width(8, context)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: Responsive.height(140, context) +
                        MediaQuery.of(context).padding.top,
                    left: Responsive.width(32, context),
                    right: Responsive.width(32, context),
                    child: _buildHeaderTitle(context, theme),
                  ),
                  Positioned(
                    top: Responsive.height(185, context) +
                        MediaQuery.of(context).padding.top,
                    left: Responsive.width(32, context),
                    right: Responsive.width(32, context),
                    child: _isLoading
                        ? HeaderDescriptionShimmer()
                        : Text(
                            body?.bodyShortDescription ?? "",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.width(16, context),
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ],
              ),

              // Scrollable Body Section
              Expanded(
                child: Container(
                  color: Color.fromRGBO(246, 246, 246, 1),
                  child: _isLoading
                      ? ListView.builder(
                          padding: EdgeInsets.only(
                              top: Responsive.height(20, context)),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return BodyTileShimmer();
                          },
                        )
                      : ListView(
                          padding: EdgeInsets.only(
                              top: Responsive.height(10, context)),
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
                            SizedBox(height: Responsive.height(70, context)),
                          ],
                        ),
                ),
              ),
              SizedBox(height: Responsive.height(5, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTitle(BuildContext context, ThemeData theme) {
    // BODY LOADED → behave EXACTLY like current code
    if (!_isLoading && body != null) {
      final bodyName = body?.bodyName ?? "";
      final match = widget.bodyTitles.firstWhere(
        (item) => item["bodyname"] == bodyName,
        orElse: () => {},
      );
      final title = match["title"] ?? "";

      return Text(
        title.isNotEmpty ? title : "Explore",
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
      );
    }

    // BODY NOT LOADED, headerTitle PROVIDED → show it
    if (widget.headerTitle != null && widget.headerTitle!.trim().isNotEmpty) {
      return Text(
        widget.headerTitle!,
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
      );
    }

    // BODY NOT LOADED, NO headerTitle → shimmer
    return HeaderTitleShimmer();
  }

  Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
    // debugPrint(body.bodyFollowersCount?.toString());
    return Material(
      child: InkWell(
        onTap: () {
          BodyPage.navigateWith(context, bloc, body: body);
        },
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(246, 246, 246, 1)),
          padding: EdgeInsets.symmetric(
              vertical: Responsive.height(10, context),
              horizontal: Responsive.width(16, context)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Club Image/Logo
              Container(
                width: Responsive.width(73, context),
                height: Responsive.width(73, context),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(Responsive.width(20, context)),
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
                                borderRadius: BorderRadius.circular(
                                    Responsive.width(12, context)),
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
}
