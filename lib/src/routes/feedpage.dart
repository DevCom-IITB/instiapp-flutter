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

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool firstBuild = true;

  IconData actionIcon = Icons.search_outlined;

  bool searchMode = false;

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
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(239, 239, 239, 1),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Color.fromRGBO(210, 213, 218, 1),
                                  )),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/feed/setting-4.svg',
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sort',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'DM Sans',
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  SvgPicture.asset(
                                    'assets/feed/chevron-down.svg',
                                  ),
                                ],
                              )),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(239, 239, 239, 1),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Color.fromRGBO(210, 213, 218, 1),
                                )),
                            child: Text(
                              'Events',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(239, 239, 239, 1),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Color.fromRGBO(210, 213, 218, 1),
                                )),
                            child: Text(
                              'Announcements',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: 23),
                ]),
              ),
              StreamBuilder(
                stream: bloc.events,
                builder: (context,
                    AsyncSnapshot<UnmodifiableListView<Event>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                Feedpost(context, bloc, snapshot.data![index]),
                            childCount: snapshot.data!.length),
                      );
                    } else {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text("No upcoming events"),
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
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Specificblogpage(event: event, bloc: bloc),
          ));
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

class Specificblogpage extends StatefulWidget {
  final Event event;
  final InstiAppBloc bloc;

  Specificblogpage({required this.event, required this.bloc});

  @override
  _specificblogpageState createState() => _specificblogpageState();
}

class _specificblogpageState extends State<Specificblogpage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(246, 246, 246, 1),
    ));
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      body: SafeArea(
        child: Column(children: [
          Container(
              margin: EdgeInsets.only(left: 16, right: 16, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(235, 235, 235, 0.8),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: IconButton(
                          icon: SvgPicture.asset(
                            'assets/blogs/arrow-left.svg',
                            height: 24,
                            width: 24,
                            fit: BoxFit.none,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          })),
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(235, 235, 235, 0.8),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          'assets/feed/bookmark.svg',
                          height: 24,
                          width: 24,
                          fit: BoxFit.none,
                        )),
                  ),
                ],
              )),
          SizedBox(height: 12),
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
                        imageUrl:
                            widget.event.eventBodies?[0].bodyImageURL ?? "",
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) =>
                            Icon(Icons.groups_2_outlined, size: 24),
                      )),
                  SizedBox(width: 10),
                  Text(
                    widget.event.eventBodies?[0].bodyName ?? "",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )),
          Expanded(
            child: Stack(children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullscreenImagePage(
                        imageUrl: widget.event.eventImageURL ??
                            widget.event.eventBodies?[0].bodyImageURL ??
                            "",
                        heroTag: widget.event.eventID,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: widget.event.eventID ?? "",
                  child: CachedNetworkImage(
                    imageUrl: widget.event.eventImageURL ??
                        widget.event.eventBodies?[0].bodyImageURL ??
                        "",
                    height: 412,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (context, scrollController) {
                  return Container(
                      padding: EdgeInsets.only(
                          top: 10, left: 16, right: 16, bottom: 20),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(246, 246, 246, 1),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                height: 5,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(210, 213, 218, 1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.event.eventName ?? "",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'DM Sans',
                                    ),
                                  ),
                                ),
                                if (widget.event.eventBodies?[0].bodyParents !=
                                    null)
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(15, 22, 32, 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: widget
                                                    .event
                                                    .eventBodies?[0]
                                                    .bodyParents![0]
                                                    .bodyImageURL ??
                                                "",
                                            placeholder: (context, url) =>
                                                CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            widget.event.eventBodies?[0]
                                                    .bodyParents![0].bodyName ??
                                                "",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'DM Sans',
                                              color: Color.fromRGBO(
                                                  246, 246, 246, 1),
                                            ),
                                          )
                                        ],
                                      ))
                              ],
                            ),
                            SizedBox(height: 24),
                            Dash(
                              direction: Axis.horizontal,
                              length: 368,
                              dashLength: 6,
                              dashGap: 7,
                              dashColor: Color(0xFFDADADA),
                            ),
                            SizedBox(height: 24),
                            Container(
                                padding: EdgeInsets.only(right: 16),
                                child: Column(children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 46,
                                          width: 46,
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                                196, 212, 239, 1),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/feed/Clock.svg',
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Date & Time',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'DM Sans',
                                                color: Color.fromRGBO(
                                                    126, 130, 135, 1),
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  widget.event.eventStartTime !=
                                                          null
                                                      ? formatDate(widget.event
                                                                  .eventStartTime ??
                                                              "") +
                                                          (formatDate(widget
                                                                          .event
                                                                          .eventEndTime ??
                                                                      "") !=
                                                                  formatDate(widget
                                                                          .event
                                                                          .eventStartTime ??
                                                                      "")
                                                              ? ' - ' +
                                                                  formatDate(widget
                                                                          .event
                                                                          .eventEndTime ??
                                                                      "")
                                                              : '')
                                                      : 'Unknown Date',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'DM Sans',
                                                    color: Color.fromRGBO(
                                                        15, 22, 32, 1),
                                                  ),
                                                ),
                                                Text(
                                                  formatTime(widget.event
                                                          .eventStartTime ??
                                                      ""),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'DM Sans',
                                                    color: Color.fromRGBO(
                                                        15, 22, 32, 1),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ))
                                      ]),
                                  SizedBox(height: 16),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 46,
                                          width: 46,
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                                196, 212, 239, 1),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/feed/Location.svg',
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Venue',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'DM Sans',
                                                color: Color.fromRGBO(
                                                    126, 130, 135, 1),
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              widget.event.eventVenues
                                                          ?.isNotEmpty ??
                                                      false
                                                  ? widget.event.eventVenues![0]
                                                          .venueName ??
                                                      ""
                                                  : "Venue not specified",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'DM Sans',
                                                color: Color.fromRGBO(
                                                    15, 22, 32, 1),
                                              ),
                                            )
                                          ],
                                        ))
                                      ]),
                                ])),
                            SizedBox(height: 24),
                            Dash(
                              direction: Axis.horizontal,
                              length: 368,
                              dashLength: 6,
                              dashGap: 7,
                              dashColor: Color(0xFFDADADA),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'DM Sans',
                                color: Color.fromRGBO(21, 32, 45, 1),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              child: Text(
                                widget.event.eventDescription ??
                                    "No description available",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'DM Sans',
                                  color: Color.fromRGBO(15, 22, 32, 1),
                                ),
                              ),
                            ),
                            SizedBox(height: 70),
                          ],
                        ),
                      ));
                },
              ),
              Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/blogs/background.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Color.fromRGBO(246, 246, 246, 1),
                          width: 8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(45, 70, 108, 1),
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: IconButton(
                                icon: SvgPicture.asset(
                                  'assets/feed/share.svg',
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.none,
                                ),
                                onPressed: () async {
                                  await Share.share(
                                      "Check this event: ${ShareURLMaker.getEventURL(widget.event)}");
                                }),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                              child: InkWell(
                            onTap: () {
                              BodyPage.navigateWith(
                                context,
                                widget.bloc,
                                body: widget.event.eventBodies?[0],
                              );
                            },
                            child: Container(
                                padding: EdgeInsets.only(
                                    left: 16, right: 24, top: 13, bottom: 13),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(48, 111, 220, 1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/feed/person.svg',
                                        height: 24,
                                        width: 24,
                                        fit: BoxFit.none,
                                      ),
                                      SizedBox(width: 16),
                                      Text(
                                        'Visit Club',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'DM Sans',
                                          color:
                                              Color.fromRGBO(255, 255, 255, 1),
                                        ),
                                      ),
                                    ])),
                          )),
                          SizedBox(width: 8),
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              color: Color.fromRGBO(37, 211, 102, 1),
                            ),
                            child: IconButton(
                              icon: SvgPicture.asset(
                                'assets/feed/whatsapp.svg',
                                fit: BoxFit.none,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      )))
            ]),
          )
        ]),
      ),
    );
  }
}

class FullscreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const FullscreenImagePage({Key? key, required this.imageUrl, this.heroTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: BackButton(
            color: Colors.white, // optional: set icon color
            onPressed: () => Navigator.pop(context),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: heroTag != null
                ? Hero(
                    tag: heroTag!,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ]),
    );
  }
}

// onTap: () {
//                       Share.share(
//                           "Check this community: ${ShareURLMaker.getCommunityURL(community)}");
//                     },
