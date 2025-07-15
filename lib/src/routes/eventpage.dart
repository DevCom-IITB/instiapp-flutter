import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:share/share.dart';
import 'package:InstiApp/src/routes/feedpage.dart';
import 'package:url_launcher/url_launcher.dart';

class EventPage extends StatefulWidget {
  final Event? initialEvent;
  final Future<Event?> eventFuture;

  EventPage({required this.eventFuture, this.initialEvent});

  static void navigateWith(
      BuildContext context, InstiAppBloc bloc, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/event/${event.eventID ?? ""}",
        ),
        builder: (context) => EventPage(
          initialEvent: event,
          eventFuture: bloc.getEvent(event.eventID ?? ""),
        ),
      ),
    );
  }

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late Future<Body> body;
  Body? fullbody;
  Event? event;
  bool isfirstbuild = true;
  late UES currentUes;

  @override
  void initState() {
    super.initState();
    event = widget.initialEvent;
    currentUes = event?.eventUserUes ?? UES.NotGoing;
    widget.eventFuture.then((ev) {
      if (this.mounted) {
        setState(() {
          event = ev;
        });
      } else {
        event = ev;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context)!.bloc;
    if (isfirstbuild) {
      body = bloc.getBody(event!.eventBodies?[0].bodyID ?? "");
      body.then((value) {
        setState(() {
          fullbody = value;
        });
      });
      isfirstbuild = false;
    }
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(246, 246, 246, 1),
    ));
    Color colour = currentUes == UES.Going
        ? Color.fromRGBO(255, 255, 255, 1)
        : Color.fromRGBO(48, 111, 220, 1);
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
                        imageUrl: event!.eventBodies?[0].bodyImageURL ?? "",
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) =>
                            Icon(Icons.groups_2_outlined, size: 24),
                      )),
                  SizedBox(width: 10),
                  Text(
                    event!.eventBodies?[0].bodyName ?? "",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Text(''),
                  ),
                  Text(
                    '${event!.eventGoingCount + event!.eventInterestedCount}',
                    style: TextStyle(
                      color: const Color(0xFFEFEFEF),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Enthu',
                    style: TextStyle(
                      color: const Color(0xFFEFEFEF),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 20),
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
                        imageUrl: event!.eventImageURL ??
                            event!.eventBodies?[0].bodyImageURL ??
                            "",
                        heroTag: event!.eventID,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: event!.eventID ?? "",
                  child: CachedNetworkImage(
                    imageUrl: event!.eventImageURL ??
                        event!.eventBodies?[0].bodyImageURL ??
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
                maxChildSize: 0.85,
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
                                    event!.eventName ?? "",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'DM Sans',
                                    ),
                                  ),
                                ),
                                if (fullbody != null &&
                                    fullbody!.bodyParents != null &&
                                    fullbody!.bodyParents!.isNotEmpty)
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(15, 22, 32, 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: CachedNetworkImage(
                                              width: 20,
                                              height: 20,
                                              fit: BoxFit.cover,
                                              imageUrl: fullbody!
                                                      .bodyParents![0]
                                                      .bodyImageURL ??
                                                  "",
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            fullbody!
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
                                                  event!.eventStartTime != null
                                                      ? formatDate(event!
                                                                  .eventStartTime ??
                                                              "") +
                                                          (formatDate(event!
                                                                          .eventEndTime ??
                                                                      "") !=
                                                                  formatDate(
                                                                      event!.eventStartTime ??
                                                                          "")
                                                              ? ' - ' +
                                                                  formatDate(
                                                                      event!.eventEndTime ??
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
                                                  formatTime(
                                                      event!.eventStartTime ??
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
                                  InkWell(
                                    onTap: () async {
                                      if ((event!.eventVenues?.isNotEmpty ??
                                              false) &&
                                          event!.eventVenues![0]
                                                  .venueLatitude !=
                                              null) {
                                        String uri = defaultTargetPlatform ==
                                                TargetPlatform.iOS
                                            ? "http://maps.apple.com/?ll=${event!.eventVenues![0].venueLatitude},${event!.eventVenues![0].venueLongitude}&z=20"
                                            : "google.navigation:q=${event!.eventVenues![0].venueLatitude},${event!.eventVenues![0].venueLongitude}";
                                        if (await canLaunchUrl(
                                            Uri.parse(uri))) {
                                          await launchUrl(
                                            Uri.parse(uri),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                      } else {}
                                    },
                                    child: Row(
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
                                                event!.eventVenues
                                                            ?.isNotEmpty ??
                                                        false
                                                    ? event!.eventVenues![0]
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
                                  ),
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
                                event!.eventDescription ??
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
                                      "Check this event: ${ShareURLMaker.getEventURL(event!)}");
                                }),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                              child: InkWell(
                            onTap: () async {
                              if (bloc.currSession == null) {
                                return;
                              }
                              setState(() {
                                if (currentUes == UES.Going) {
                                  currentUes = UES.NotGoing;
                                } else {
                                  currentUes = UES.Going;
                                }
                              });
                              await bloc.updateUesEvent(event!, currentUes);
                              setState(() {});
                            },
                            child: Container(
                                padding: EdgeInsets.only(
                                    left: 16, right: 24, top: 13, bottom: 13),
                                decoration: BoxDecoration(
                                  color: currentUes == UES.Going
                                      ? Color.fromRGBO(48, 111, 220, 1)
                                      : Color.fromRGBO(15, 22, 32, 1),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Color.fromRGBO(48, 111, 220, 1),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/feed/enthu.png',
                                        color: colour,
                                        height: 18.3,
                                        width: 15,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 11),
                                      Text(
                                        'show enthu',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'DM Sans',
                                          color: colour,
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
