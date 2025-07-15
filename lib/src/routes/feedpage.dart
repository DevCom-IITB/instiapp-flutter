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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:InstiApp/src/routes/explore_club.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:share/share.dart';
import 'package:InstiApp/src/routes/eventpage.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool firstBuild = true;

  IconData actionIcon = Icons.search_outlined;

  bool searchMode = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

@override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => bloc.updateEvents(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search events...",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim().toLowerCase();
                          });
                        },
                      ),
                    ),
                  Center(
                    child: Container(
                        padding: EdgeInsets.only(top: 10.5, bottom: 10.5),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Insti ',
                                style: TextStyle(
                                  color: const Color(0xFF0F1620),
                                  fontSize: 24,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: 'Feed',
                                style: TextStyle(
                                  color: const Color(0xFF306FDC),
                                  fontSize: 24,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  SizedBox(height: 2),
                  Dash(
                    direction: Axis.horizontal,
                    length: 368,
                    dashLength: 6,
                    dashGap: 7,
                    dashColor: Color(0xFFDADADA),
                  ),
                  SizedBox(height: 20),
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
                  // SizedBox(height: 23),
                ]),
              ),
              StreamBuilder(
                stream: bloc.events,
                builder: (context,
                    AsyncSnapshot<UnmodifiableListView<Event>> snapshot) {
                  if (snapshot.hasData) {
                    final filteredEvents = _searchQuery.isEmpty ? snapshot.data! : UnmodifiableListView(snapshot.data!.where((event) {
                            final name = event.eventName?.toLowerCase() ?? "";
                            return name.contains(_searchQuery);
                          }).toList()); 
                    if (filteredEvents.length > 0) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                Feedpost(context, bloc, filteredEvents[index]),
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
                  height: 100,
                ),
              )
            ],
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
  DateTime time = DateTime.parse(timeStr);
  return DateFormat('h:mm a').format(time); // e.g., "2:30 PM"
}

Widget Feedpost(BuildContext context, InstiAppBloc bloc, Event event) {
  return InkWell(
    onTap: () {
      EventPage.navigateWith(
        context,
        bloc,
        event,
      );
    },
    child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Color.fromRGBO(239, 239, 239, 1)),
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Hero(
              tag: event.eventID ?? "",
              child: CachedNetworkImage(
                imageUrl: event.eventImageURL ??
                    event.eventBodies?[0].bodyImageURL ??
                    "",
                width: double.infinity,
                height: 475,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          Container(
              height: 36,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/feed/Text Area.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 16),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl: event.eventBodies?[0].bodyImageURL ?? "",
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) =>
                            Icon(Icons.groups_2_outlined, size: 24),
                      )),
                  SizedBox(width: 16),
                  Text(
                    event.eventBodies?[0].bodyName ?? "",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              (event.eventStartTime != null
                      ? formatDate(event.eventStartTime ?? "") +
                          (formatDate(event.eventEndTime ?? "") !=
                                  formatDate(event.eventStartTime ?? "")
                              ? ' - ' + formatDate(event.eventEndTime ?? "")
                              : '')
                      : 'Unknown Date') +
                  ', ' +
                  formatTime(event.eventStartTime ?? ''),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
                color: Color.fromRGBO(48, 111, 220, 1),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 16, top: 8, right: 16),
            child: Text(
              event.eventName ?? "",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            child: Text(
              event.eventVenues?.isNotEmpty ?? false
                  ? event.eventVenues![0].venueName ?? ""
                  : "Venue not specified",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Sans',
                color: const Color(0xCC0F1620),
              ),
            ),
          ),
          SizedBox(height: 20),
        ])),
  );
}
