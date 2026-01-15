import 'dart:collection';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:InstiApp/src/routes/explore_club.dart';
// import 'package:InstiApp/src/routes/bodypage.dart';
// import 'package:share/share.dart';
import 'package:share_plus/share_plus.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool firstBuild = true;

  ScrollController? _hideButtonController;
  bool headervisible = true;
  double isFabVisible = 0;
  bool _headerCollapsed = false;
  double _lastScrollOffset = 0;

  IconData actionIcon = Icons.search_outlined;

  bool searchMode = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    _hideButtonController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _hideButtonController = ScrollController()
      ..addListener(() {
        if (!mounted || !_hideButtonController!.hasClients) return;

        final currentOffset = _hideButtonController!.offset;
        final isScrollingDown = currentOffset > _lastScrollOffset;

        // FAB visibility
        final visible = _hideButtonController!.position.userScrollDirection ==
                ScrollDirection.forward &&
            currentOffset > 100;

        // Header collapse logic
        bool shouldCollapse = _headerCollapsed;
        if (isScrollingDown && currentOffset > 100) {
          shouldCollapse = true;
        } else if (!isScrollingDown && currentOffset < 80) {
          shouldCollapse = false;
        }

        if ((visible ? 1.0 : 0.0) != isFabVisible ||
            shouldCollapse != _headerCollapsed) {
          setState(() {
            isFabVisible = visible ? 1 : 0;
            _headerCollapsed = shouldCollapse;
          });
        }

        _lastScrollOffset = currentOffset;
      });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(246, 246, 246, 1),
    ));
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    if (firstBuild) {
      bloc.updateEvents();
      firstBuild = false;
    }
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      key: _scaffoldKey,
      floatingActionButton: AnimatedOpacity(
        opacity: isFabVisible, // 1 = visible, 0 = hidden
        duration: Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: isFabVisible == 0,
          child: Container(
            padding: EdgeInsets.only(bottom: Responsive.height(70.0, context)),
            child: FloatingActionButton(
              backgroundColor: Color.fromRGBO(48, 111, 220, 1),
              onPressed: () {
                _hideButtonController?.animateTo(
                  0.0,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              },
              child: Icon(Icons.arrow_upward),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _focusNode.unfocus();
          },
          child: RefreshIndicator(
            onRefresh: () => bloc.updateEvents(),
            child: Column(
              children: [
                Container(
                  child: Column(children: [
                    ClipRect(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: _headerCollapsed
                            ? 0
                            : Responsive.height(67.5, context),
                        child: ListView(
                          children: [
                            Center(
                              child: Container(
                                  padding: EdgeInsets.only(
                                      top: Responsive.height(10.5, context),
                                      bottom: Responsive.height(10.5, context)),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Insti ',
                                          style: TextStyle(
                                            color: const Color(0xFF0F1620),
                                            fontSize:
                                                Responsive.text(24, context),
                                            fontFamily: 'DM Sans',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Feed',
                                          style: TextStyle(
                                            color: const Color(0xFF306FDC),
                                            fontSize:
                                                Responsive.text(24, context),
                                            fontFamily: 'DM Sans',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                            SizedBox(height: Responsive.height(2, context)),
                            Dash(
                              direction: Axis.horizontal,
                              length: Responsive.width(368, context),
                              dashLength: Responsive.width(6, context),
                              dashGap: Responsive.width(7, context),
                              dashColor: Color(0xFFDADADA),
                            ),
                            SizedBox(height: Responsive.height(10, context)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.height(10, context)),
                    Container(
                      margin: EdgeInsets.only(
                          left: Responsive.width(16, context),
                          right: Responsive.width(16, context)),
                      height: Responsive.height(53, context),
                      padding: EdgeInsets.only(
                          left: Responsive.width(14, context),
                          right: Responsive.width(14, context),
                          top: Responsive.height(13, context),
                          bottom: Responsive.height(13, context)),
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/blogs/searchbar.png'),
                          fit: BoxFit.fill,
                        ),
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
                              // autofocus: true,
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
                                padding: EdgeInsets.all(
                                    Responsive.width(3, context)),
                                child: SvgPicture.asset(
                                  'assets/explore/x.svg',
                                  width: Responsive.width(24, context),
                                  height: Responsive.height(24, context),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // SizedBox(height: Responsive.height(20, context)),
                    // Container(
                    //     margin: EdgeInsets.symmetric(horizontal: 16),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       children: [
                    //         Container(
                    //             padding: EdgeInsets.symmetric(
                    //                 horizontal: 16, vertical: 8),
                    //             decoration: BoxDecoration(
                    //                 color: Color.fromRGBO(239, 239, 239, 1),
                    //                 borderRadius: BorderRadius.circular(50),
                    //                 border: Border.all(
                    //                   color: Color.fromRGBO(210, 213, 218, 1),
                    //                 )),
                    //             child: Row(
                    //               children: [
                    //                 SvgPicture.asset(
                    //                   'assets/feed/setting-4.svg',
                    //                 ),
                    //                 SizedBox(width: 8),
                    //                 Text(
                    //                   'Sort',
                    //                   style: TextStyle(
                    //                     fontSize: 14,
                    //                     fontWeight: FontWeight.w500,
                    //                     fontFamily: 'DM Sans',
                    //                   ),
                    //                 ),
                    //                 SizedBox(width: 8),
                    //                 SvgPicture.asset(
                    //                   'assets/feed/chevron-down.svg',
                    //                 ),
                    //               ],
                    //             )),
                    //         SizedBox(width: 8),
                    //         Container(
                    //           padding: EdgeInsets.symmetric(
                    //               horizontal: 16, vertical: 8),
                    //           decoration: BoxDecoration(
                    //               color: Color.fromRGBO(239, 239, 239, 1),
                    //               borderRadius: BorderRadius.circular(50),
                    //               border: Border.all(
                    //                 color: Color.fromRGBO(210, 213, 218, 1),
                    //               )),
                    //           child: Text(
                    //             'Events',
                    //             style: TextStyle(
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w500,
                    //               fontFamily: 'DM Sans',
                    //             ),
                    //           ),
                    //         ),
                    //         SizedBox(width: 8),
                    //         Container(
                    //           padding: EdgeInsets.symmetric(
                    //               horizontal: 16, vertical: 8),
                    //           decoration: BoxDecoration(
                    //               color: Color.fromRGBO(239, 239, 239, 1),
                    //               borderRadius: BorderRadius.circular(50),
                    //               border: Border.all(
                    //                 color: Color.fromRGBO(210, 213, 218, 1),
                    //               )),
                    //           child: Text(
                    //             'Announcements',
                    //             style: TextStyle(
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w500,
                    //               fontFamily: 'DM Sans',
                    //             ),
                    //           ),
                    //         ),
                    //   ],
                    // )),
                    SizedBox(height: 15),
                  ]),
                ),
                Expanded(
                  child: CustomScrollView(
                    controller: _hideButtonController,
                    slivers: [
                      StreamBuilder(
                        stream: bloc.events,
                        builder: (context,
                            AsyncSnapshot<UnmodifiableListView<Event>>
                                snapshot) {
                          if (snapshot.hasData) {
                            final filteredEvents = _searchQuery.isEmpty
                                ? snapshot.data!
                                : UnmodifiableListView(
                                    snapshot.data!.where((event) {
                                    final name =
                                        event.eventName?.toLowerCase() ?? "";
                                    return name.contains(_searchQuery) ||
                                        (event.eventBodies != null &&
                                            event.eventBodies!.any((body) =>
                                                body.bodyName
                                                    ?.toLowerCase()
                                                    .contains(_searchQuery) ??
                                                false));
                                  }).toList());
                            if (filteredEvents.length > 0) {
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                    (context, index) => Feedpost(
                                        context, bloc, filteredEvents[index]),
                                    childCount: filteredEvents.length),
                              );
                            } else {
                              return SliverToBoxAdapter(
                                child: Center(
                                  child: Text("No events"),
                                ),
                              );
                            }
                          } else {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: CircularProgressIndicatorExtended(
                                  label: Text("Getting the latest events"),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: Responsive.height(100, context),
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
}

String formatDate(String dateStr) {
  DateTime date = DateTime.parse(dateStr);
  return DateFormat('d MMM').format(date); // e.g., "23 June"
}

String formatTime(String timeStr) {
  DateTime time = DateTime.parse(timeStr).toLocal();
  return DateFormat('h:mm a').format(time); // e.g., "2:30 PM"
}

Widget Feedpost(BuildContext context, InstiAppBloc bloc, Event event) {
  DateTime now = DateTime.now();
  return InkWell(
    onTap: () {
      EventPage.navigateWith(
        context,
        bloc,
        event,
      );
    },
    child: Container(
        margin: EdgeInsets.only(
            left: Responsive.width(16, context),
            right: Responsive.width(16, context),
            bottom: Responsive.height(12, context)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Responsive.height(16, context)),
            color: Color.fromRGBO(239, 239, 239, 1)),
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Responsive.height(16, context)),
              topRight: Radius.circular(Responsive.height(16, context)),
            ),
            child: Hero(
              tag: event.eventID ?? "",
              child: CachedNetworkImage(
                imageUrl: event.eventImageURL ??
                    event.eventBodies?[0].bodyImageURL ??
                    "",
                width: double.infinity,
                height: Responsive.height(440, context),
                fit: BoxFit.fill,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          Container(
              height: Responsive.height(36, context),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/feed/Text Area.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: Responsive.width(16, context)),
                  ClipRRect(
                      borderRadius:
                          BorderRadius.circular(Responsive.height(50, context)),
                      child: CachedNetworkImage(
                        imageUrl: event.eventBodies?[0].bodyImageURL ?? "",
                        width: Responsive.width(28, context),
                        height: Responsive.height(28, context),
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) => Icon(
                            Icons.groups_2_outlined,
                            size: Responsive.height(24, context)),
                      )),
                  SizedBox(width: Responsive.width(16, context)),
                  Text(
                    maxLines: 1,
                    event.eventBodies?[0].bodyName ?? "",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.text(16, context),
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(
                left: Responsive.width(16, context),
                top: Responsive.height(16, context),
                right: Responsive.width(16, context)),
            child: Text(
              (event.eventStartTime != null
                      ? formatDate(event.eventStartTime ?? "") +
                          (formatDate(event.eventEndTime ?? "") !=
                                  formatDate(event.eventStartTime ?? "")
                              ? ' - ' + formatDate(event.eventEndTime ?? "")
                              : '')
                      : 'Unknown Date') +
                  ', ' +
                  formatTime(event.eventStartTime ?? '') +
                  (event.eventStartTime != null
                      ? (now.isBefore(DateTime.parse(event.eventStartTime!))
                          ? ' | Upcoming'
                          : (event.eventEndTime != null
                              ? (now.isAfter(
                                      DateTime.parse(event.eventEndTime!))
                                  ? ' | Ended'
                                  : ' | Ongoing')
                              : ' | Ended'))
                      : ''),
              style: TextStyle(
                fontSize: Responsive.text(12, context),
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
                color: Color.fromRGBO(48, 111, 220, 1),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(
                left: Responsive.width(16, context),
                top: Responsive.height(8, context),
                right: Responsive.width(16, context)),
            child: Text(
              event.eventName ?? "",
              style: TextStyle(
                fontSize: Responsive.text(18, context),
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              left: Responsive.width(16, context),
              right: Responsive.width(16, context),
            ),
            child: Text(
              event.eventDescription ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xCC0F1620),
                fontSize: Responsive.text(14, context),
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: Responsive.height(20, context)),
        ])),
  );
}
