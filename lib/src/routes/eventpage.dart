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
                              setState(() {                                
                              });
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
                                      Image.asset(
                                        'assets/feed/enthu.png',
                                        height: 18.3,
                                        width: 15,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 11),
                                      Text(
                                        currentUes == UES.Going
                                            ? 'Going'
                                            : 'Not Going',
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


// import 'dart:async';
// import 'dart:io';

// import 'package:InstiApp/src/api/model/body.dart';
// import 'package:InstiApp/src/api/model/event.dart';
// import 'package:InstiApp/src/bloc_provider.dart';
// import 'package:InstiApp/src/blocs/ia_bloc.dart';
// import 'package:InstiApp/src/drawer.dart';
// import 'package:InstiApp/src/routes/bodypage.dart';
// import 'package:InstiApp/src/utils/common_widgets.dart';
// import 'package:InstiApp/src/utils/footer_buttons.dart';
// import 'package:InstiApp/src/utils/notif_settings.dart';
// import 'package:InstiApp/src/utils/share_url_maker.dart';
// import 'package:InstiApp/src/utils/title_with_backbutton.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:share/share.dart';
// import 'package:markdown/markdown.dart' as markdown;
// import 'package:device_calendar/device_calendar.dart' as cal;
// import 'package:timezone/timezone.dart' as tz;

// class EventPage extends StatefulWidget {
//   final Event? initialEvent;
//   final Future<Event?> eventFuture;

//   EventPage({required this.eventFuture, this.initialEvent});

//   static void navigateWith(
//       BuildContext context, InstiAppBloc bloc, Event event) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         settings: RouteSettings(
//           name: "/event/${event.eventID ?? ""}",
//         ),
//         builder: (context) => EventPage(
//           initialEvent: event,
//           eventFuture: bloc.getEvent(event.eventID ?? ""),
//         ),
//       ),
//     );
//   }

//   @override
//   _EventPageState createState() => _EventPageState();
// }

// class _EventPageState extends State<EventPage> {
//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   Event? event;

//   UES loadingUes = UES.NotGoing;

//   bool _bottomSheetActive = false;

//   bool firstBuild = true;

//   @override
//   void initState() {
//     super.initState();
//     event = widget.initialEvent;
//     widget.eventFuture.then((ev) {
//       var tableParse = markdown.TableSyntax();
//       ev?.eventDescription = markdown.markdownToHtml(
//           ev.eventDescription
//                   ?.split('\n')
//                   .map((s) => s.trimRight())
//                   .toList()
//                   .join('\n') ??
//               "",
//           blockSyntaxes: [tableParse]);
//       if (this.mounted) {
//         setState(() {
//           event = ev;
//         });
//       } else {
//         event = ev;
//       }
//     });

//     // widget.eventFuture.then((ev) {
//     //   print("fwkfnlw");
//     //   setState(() {
//     //     this.event = ev;
//     //   });
//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     var bloc = BlocProvider.of(context)!.bloc;
//     final NotificationRouteArguments? args = ModalRoute.of(context)!
//         .settings
//         .arguments as NotificationRouteArguments?;
//     List<Widget> footerButtons = [];
//     var editAccess = false;
//     if (event != null) {
//       footerButtons = <Widget>[];
//       editAccess = bloc.editEventAccess(event!);
//       if (bloc.currSession != null) {
//         footerButtons.addAll([
//           buildUserStatusButton("Going", UES.Going, theme, bloc),
//           buildUserStatusButton("Interested", UES.Interested, theme, bloc),
//         ]);

//         if (args?.key == ActionKeys.ADD_TO_CALENDAR && firstBuild) {
//           UESButtonOnClicked(UES.Going, theme, bloc, forceInterested: true);
//           firstBuild = false;
//         }
//       }

//       if ((event!.eventWebsiteURL ?? "") != "") {
//         footerButtons.add(IconButton(
//           tooltip: "Open website",
//           icon: Icon(Icons.language_outlined),
//           onPressed: () async {
//             if (await canLaunchUrl(Uri.parse(event!.eventWebsiteURL!))) {
//               await launchUrl(
//                 Uri.parse(event!.eventWebsiteURL!),
//                 mode: LaunchMode.externalApplication,
//               );
//             }
//           },
//         ));
//       }
//       if ((event!.eventVenues?.isNotEmpty ?? false) &&
//           event!.eventVenues![0].venueLatitude != null) {
//         footerButtons.add(IconButton(
//           tooltip: "Navigate to event",
//           icon: Icon(Icons.navigation_outlined),
//           onPressed: () async {
//             String uri = defaultTargetPlatform == TargetPlatform.iOS
//                 ? "http://maps.apple.com/?ll=${event!.eventVenues![0].venueLatitude},${event!.eventVenues![0].venueLongitude}&z=20"
//                 : "google.navigation:q=${event!.eventVenues![0].venueLatitude},${event!.eventVenues![0].venueLongitude}";
//             if (await canLaunchUrl(Uri.parse(uri))) {
//               await launchUrl(
//                 Uri.parse(uri),
//                 mode: LaunchMode.externalApplication,
//               );
//             }
//           },
//         ));
//       }

//       footerButtons.add(
//         IconButton(
//           icon: Icon(Icons.share_outlined),
//           tooltip: "Share this event",
//           padding: EdgeInsets.all(0),
//           onPressed: () async {
//             await Share.share(
//                 "Check this event: ${ShareURLMaker.getEventURL(event!)}");
//           },
//         ),
//       );
//     }

//     return Scaffold(
//         key: _scaffoldKey,
//         drawer: NavDrawer(),
//         bottomNavigationBar: MyBottomAppBar(
//           child: new Row(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               IconButton(
//                 icon: Icon(
//                   Icons.menu_outlined,
//                   semanticLabel: "Show navigation drawer",
//                 ),
//                 onPressed: () {
//                   _scaffoldKey.currentState?.openDrawer();
//                 },
//               ),
//             ],
//           ),
//         ),
//         body: SafeArea(
//           child: event == null
//               ? Center(
//                   child: CircularProgressIndicatorExtended(
//                   label: Text("Loading the event page"),
//                 ))
//               : ListView(
//                   children: <Widget>[
//                     TitleWithBackButton(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Text(
//                             event!.eventName ?? "",
//                             style: theme.textTheme.displaySmall,
//                           ),
//                           SizedBox(height: 8.0),
//                           Text(event!.getSubTitle(),
//                               style: theme.textTheme.titleLarge),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: PhotoViewableImage(
//                         url: event!.eventImageURL ??
//                             event!.eventBodies?[0].bodyImageURL ??
//                             defUrl,
//                         heroTag: event!.eventID ?? "",
//                         fit: BoxFit.fitWidth,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 16.0,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 28.0, vertical: 16.0),
//                       child: CommonHtml(
//                         data: event!.eventDescription ?? "",
//                         defaultTextStyle:
//                             theme.textTheme.titleMedium ?? TextStyle(),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 16.0,
//                     ),
//                     Divider(),
//                   ]
//                     ..addAll(event!.eventBodies?.map(
//                             (b) => _buildBodyTile(bloc, theme.textTheme, b)) ??
//                         [])
//                     ..addAll([
//                       Divider(),
//                       SizedBox(
//                         height: 64.0,
//                       ),
//                       Container(
//                         child: !(event!.emailVerified ?? false) &&
//                                 ((bloc.currSession?.profile?.userRoles?.any(
//                                         (role) => role.rolePermissions!
//                                             .contains("VerE")) ??
//                                     false))
//                             ? Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 28.0, vertical: 16.0),
//                                 child: Text(
//                                   event!.eventLongDescription ?? "",
//                                   style:
//                                       theme.textTheme.titleMedium ?? TextStyle(),
//                                 ),
//                               )
//                             : null,
//                       ),
//                       Container(
//                         child: !(event!.emailVerified ?? false) &&
//                                 ((bloc.currSession?.profile?.userRoles?.any(
//                                         (role) => role.rolePermissions!
//                                             .contains("VerE")) ??
//                                     false))
//                             ? Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: TextButton(
//                                   child: Text('Accept and Push Mail'),
//                                   onPressed: () {
//                                     bloc.client.pushMail(
//                                       bloc.getSessionIdHeader(),
//                                       event!.eventID ?? "",
//                                     );
//                                     Navigator.of(context).pop();
//                                   },
//                                   style: TextButton.styleFrom(
//                                     foregroundColor: Colors.black, backgroundColor: Colors.amber, disabledForegroundColor: Colors.grey.withOpacity(0.38),
//                                     elevation: 5.0,
//                                   ),
//                                 ),
//                               )
//                             : null,
//                       ),
//                       Container(
//                         child: !(event!.emailVerified ?? false) &&
//                                 ((bloc.currSession?.profile?.userRoles?.any(
//                                         (role) => role.rolePermissions!
//                                             .contains("VerE")) ??
//                                     false))
//                             ? Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: TextButton(
//                                   child: Text('Reject Mail'),
//                                   onPressed: () {
//                                     bloc.client.rejectMail(
//                                       bloc.getSessionIdHeader(),
//                                       event!.eventID ?? "",
//                                     );
//                                     Navigator.of(context).pop();
//                                   },
//                                   style: TextButton.styleFrom(
//                                     foregroundColor: Colors.black, backgroundColor: Colors.amber, disabledForegroundColor: Colors.grey.withOpacity(0.38),
//                                     elevation: 5.0,
//                                   ),
//                                 ),
//                               )
//                             : null,
//                       )
//                     ]),
//                 ),
//         ),
//         floatingActionButton: _bottomSheetActive || event == null
//             ? null
//             : editAccess
//                 ? FloatingActionButton.extended(
//                     icon: Icon(Icons.edit_outlined),
//                     label: Text("Edit"),
//                     tooltip: "Edit this event",
//                     onPressed: () {
//                       Navigator.of(context)
//                           .pushNamed("/putentity/event/${event!.eventID}");
//                     },
//                   )
//                 : FloatingActionButton(
//                     child: Icon(Icons.share_outlined),
//                     tooltip: "Share this event",
//                     onPressed: () async {
//                       await Share.share(
//                           "Check this event: ${ShareURLMaker.getEventURL(event!)}");
//                     },
//                   ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//         persistentFooterButtons: [
//           FooterButtons(
//             footerButtons: footerButtons,
//           )
//         ]);
//   }

//   Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
//     return ListTile(
//       title: Text(body.bodyName ?? "", style: theme.titleLarge),
//       subtitle: Text(body.bodyShortDescription ?? "", style: theme.titleSmall),
//       leading: NullableCircleAvatar(
//         body.bodyImageURL ?? defUrl,
//         Icons.work_outline_outlined,
//         heroTag: body.bodyID ?? "",
//       ),
//       onTap: () {
//         BodyPage.navigateWith(context, bloc, body: body);
//       },
//     );
//   }

//   ElevatedButton buildUserStatusButton(
//       String name, UES uesButton, ThemeData theme, InstiAppBloc bloc) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         foregroundColor: event?.eventUserUes == uesButton
//             ? theme.floatingActionButtonTheme.foregroundColor
//             : theme.textTheme.bodyLarge?.color, backgroundColor: event?.eventUserUes == uesButton
//             ? theme.colorScheme.secondary
//             : theme.scaffoldBackgroundColor,
//         shape: RoundedRectangleBorder(
//             side: BorderSide(
//               color: theme.colorScheme.secondary,
//             ),
//             borderRadius: BorderRadius.all(Radius.circular(4))),
//       ),
//       child: Row(children: () {
//         var rowChildren = <Widget>[
//           Text(name),
//           SizedBox(
//             width: 8.0,
//           ),
//           Text(
//               "${uesButton == UES.Interested ? event?.eventInterestedCount : event?.eventGoingCount}"),
//         ];
//         if (loadingUes == uesButton) {
//           rowChildren.insertAll(0, [
//             SizedBox(
//                 height: 18,
//                 width: 18,
//                 child: CircularProgressIndicator(
//                   valueColor: new AlwaysStoppedAnimation<Color?>(
//                       event?.eventUserUes == uesButton
//                           ? theme.floatingActionButtonTheme.foregroundColor
//                           : theme.colorScheme.secondary),
//                   strokeWidth: 2,
//                 )),
//             SizedBox(
//               width: 8.0,
//             )
//           ]);
//         }
//         return rowChildren;
//       }()),
//       onPressed: () {
//         UESButtonOnClicked(uesButton, theme, bloc);
//       },
//     );
//   }

//   void UESButtonOnClicked(UES uesButton, ThemeData theme, InstiAppBloc bloc,
//       {bool forceInterested = false}) async {
//     if (bloc.currSession == null) {
//       return;
//     }
//     setState(() {
//       loadingUes = uesButton;
//     });
//     await bloc.updateUesEvent(
//         event!,
//         forceInterested
//             ? UES.Going
//             : (event!.eventUserUes == uesButton ? UES.NotGoing : uesButton));
//     setState(() {
//       loadingUes = UES.NotGoing;
//       // event has changes
//     });

//     if (event?.eventUserUes != UES.NotGoing) {
//       if (forceInterested) {
//         _actualAddEventToDeviceCalendar(bloc);
//       } else {
//         // Add to calendar (or not)
//         _addEventToCalendar(theme, bloc);
//       }
//     }
//   }

//   bool lastCheck = false;

//   void _addEventToCalendar(ThemeData theme, InstiAppBloc bloc) async {
//     lastCheck = false;
//     if (bloc.addToCalendarSetting == AddToCalendar.AlwaysAsk) {
//       bool? addToCal = await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//                 title: Text("Add to Calendar?"),
//                 content: DialogContent(
//                   parent: this,
//                 ),
//                 actions: <Widget>[
//                   TextButton(
//                     child: Text("No"),
//                     onPressed: () {
//                       Navigator.of(context).pop(false);
//                       if (lastCheck) {
//                         bloc.addToCalendarSetting = AddToCalendar.No;
//                       }
//                     },
//                   ),
//                   TextButton(
//                     child: Text("Yes"),
//                     onPressed: () {
//                       Navigator.of(context).pop(true);
//                     },
//                   ),
//                 ],
//               ));
//       if (addToCal == null) {
//         return;
//       }

//       if (lastCheck) {
//         bloc.addToCalendarSetting =
//             addToCal ? AddToCalendar.Yes : AddToCalendar.No;
//       }

//       if (addToCal) {
//         _actualAddEventToDeviceCalendar(bloc);
//       }
//     } else if (bloc.addToCalendarSetting == AddToCalendar.Yes) {
//       _actualAddEventToDeviceCalendar(bloc);
//     }
//   }

//   List<bool>? selector;
//   void _actualAddEventToDeviceCalendar(InstiAppBloc bloc) async {
//     // Init Device Calendar plugin
//     cal.DeviceCalendarPlugin calendarPlugin = cal.DeviceCalendarPlugin();

//     // Get Calendar Permissions
//     var permissionsGranted = await calendarPlugin.hasPermissions();
//     if (permissionsGranted.isSuccess && !(permissionsGranted.data ?? false)) {
//       permissionsGranted = await calendarPlugin.requestPermissions();
//       if (!permissionsGranted.isSuccess ||
//           !(permissionsGranted.data ?? false)) {
//         return;
//       }
//     }

//     // Get All Calendars
//     final calendarsResult = await calendarPlugin.retrieveCalendars();
//     if (calendarsResult.data != null) {
//       lastCheck = false;
//       // Get Calendar Permissions
//       if (bloc.defaultCalendarsSetting.isEmpty) {
//         bool? toContinue = await showDialog(
//             context: context,
//             builder: (context) {
//               return AlertDialog(
//                 title: Text("Select which calendars to add to?"),
//                 content: CalendarList(calendarsResult.data ?? [], parent: this),
//                 actions: <Widget>[
//                   TextButton(
//                     child: Text("Cancel"),
//                     onPressed: () {
//                       Navigator.pop(context, false);
//                     },
//                   ),
//                   TextButton(
//                     child: Text("Yes"),
//                     onPressed: () {
//                       Navigator.pop(context, true);
//                     },
//                   ),
//                 ],
//               );
//             });
//         if (!(toContinue ?? false)) {
//           return;
//         }

//         if (lastCheck) {
//           bloc.defaultCalendarsSetting =
//               calendarsResult.data?.asMap().entries.expand((entry) {
//                     if (selector?[entry.key] == true) {
//                       return <String>[entry.value.id ?? ""];
//                     }
//                     return <String>[];
//                   }).toList() ??
//                   [];
//         }
//       }

//       if (!lastCheck && bloc.defaultCalendarsSetting.isNotEmpty) {
//         selector = calendarsResult.data
//             ?.map((calen) => bloc.defaultCalendarsSetting.contains(calen.id))
//             .toList();
//       }

//       List<Future<cal.Result<String>?>> futures =
//           calendarsResult.data?.asMap().entries.expand((entry) {
//                 if (selector?[entry.key] == true) {
//                   DateTime? startTime;
//                   if (event?.eventStartTime != null)
//                     startTime = DateTime.parse(event!.eventStartTime!);
//                   DateTime? endTime;
//                   if (event?.eventEndTime != null)
//                     endTime = DateTime.parse(event!.eventEndTime!);

//                   cal.Event ev = cal.Event(
//                     entry.value.id,
//                     description: event?.eventDescription,
//                     eventId: event?.eventID,
//                     title: event?.eventName,
//                     start: startTime == null
//                         ? null
//                         : Platform.isAndroid
//                             ? tz.TZDateTime.utc(
//                                 startTime.year,
//                                 startTime.month,
//                                 startTime.day,
//                                 startTime.hour,
//                                 startTime.minute,
//                                 startTime.second)
//                             : tz.TZDateTime.from(startTime, tz.local),
//                     end: endTime == null
//                         ? null
//                         : Platform.isAndroid
//                             ? tz.TZDateTime.utc(
//                                 endTime.year,
//                                 endTime.month,
//                                 endTime.day,
//                                 endTime.hour,
//                                 endTime.minute,
//                                 endTime.second)
//                             : tz.TZDateTime.from(endTime, tz.local),
//                   );
//                   return <Future<cal.Result<String>?>>[
//                     calendarPlugin.createOrUpdateEvent(ev)
//                   ];
//                 }
//                 return <Future<cal.Result<String>?>>[];
//               }).toList() ??
//               [];

//       if ((await Future.wait(futures)).every((res) {
//         return res?.isSuccess ?? false;
//       })) {
//         showDialog<void>(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text(
//                   "Success",
//                   style: TextStyle(color: Colors.green),
//                 ),
//                 content: Text(
//                     'Event has been successfully added to ${futures.length} calendar${futures.length > 1 ? "s" : ""}.\n \nIt may take a few minutes to appear in your calendar.'),
//                 actions: <Widget>[
//                   TextButton(
//                     child: Text('OK'),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               );
//             });
//       }
//     }
//   }

//   // tz.TZDateTime? dateTimeToTZ(DateTime? dateTime){
//   //   final timeZone = TimeZone()
//   // }
// }

// class CalendarList extends StatefulWidget {
//   final List<cal.Calendar> calendarsResult;
//   final _EventPageState? parent;
//   final List<bool>? defaultSelector;

//   CalendarList(this.calendarsResult, {this.parent, this.defaultSelector});

//   @override
//   _CalendarListState createState() => _CalendarListState();
// }

// class _CalendarListState extends State<CalendarList> {
//   List<bool>? selector;

//   @override
//   void initState() {
//     super.initState();
//     widget.parent?.selector = widget.defaultSelector ??
//         List.filled(widget.calendarsResult.length, false);
//     selector = widget.parent?.selector;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[]
//         ..addAll(widget.calendarsResult
//             .asMap()
//             .entries
//             .where((entry) => !(entry.value.isReadOnly ?? false))
//             .map((calEntry) => CheckboxListTile(
//                   title: Text(calEntry.value.name ?? ""),
//                   dense: true,
//                   value: selector?[calEntry.key],
//                   onChanged: (val) {
//                     setState(() {
//                       selector?[calEntry.key] = val ?? false;
//                     });
//                   },
//                 )))
//         ..add(DialogContent(
//           parent: widget.parent,
//         )),
//     );
//   }
// }

// class DialogContent extends StatefulWidget {
//   final _EventPageState? parent;
//   DialogContent({this.parent});

//   @override
//   _DialogContentState createState() => _DialogContentState();
// }

// class _DialogContentState extends State<DialogContent> {
//   bool lastCheck = false;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       mainAxisSize: MainAxisSize.max,
//       children: <Widget>[
//         Checkbox(
//           value: lastCheck,
//           onChanged: (val) {
//             setState(() {
//               lastCheck = val ?? false;
//               widget.parent?.lastCheck = val ?? false;
//             });
//           },
//         ),
//         Text("Do not ask again?"),
//       ],
//     );
//   }
// }

