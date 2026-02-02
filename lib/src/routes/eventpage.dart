import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:date_format/date_format.dart';r
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dash/flutter_dash.dart';
// import 'package:share/share.dart';
import 'package:share_plus/share_plus.dart';
import 'package:InstiApp/src/routes/feedpage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

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

  String _buildVenueText(Event? ev) {
  if (ev == null) return 'Venue not specified';
  final room = ev.venueRoom?.trim();
  final hasRoom = room != null && room.isNotEmpty;
  final venueName = (ev.eventVenues?.isNotEmpty == true)
      ? (ev.eventVenues![0].venueName?.trim() ?? "")
      : "";
  if (hasRoom && venueName.isNotEmpty) return '$room, $venueName';
  if (hasRoom) return room!;
  if (venueName.isNotEmpty) return venueName;
  return 'Venue not specified';
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
    String? parentBodyName = "";
    if (fullbody != null &&
        fullbody!.bodyParents != null &&
        fullbody!.bodyParents!.isNotEmpty) {
      parentBodyName = parentBody[fullbody!.bodyParents![0].bodyName] ??
          fullbody!.bodyParents![0].bodyName;
    }
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(246, 246, 246, 1),
    ));
    Color colour = currentUes == UES.NotGoing
        ? Color.fromRGBO(255, 255, 255, 1)
        : Color.fromRGBO(48, 111, 220, 1);
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      body: SafeArea(
        child: Column(children: [
          Container(
              margin: EdgeInsets.only(
                  left: Responsive.width(16, context),
                  right: Responsive.width(16, context),
                  top: Responsive.height(4, context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      height: Responsive.height(52, context),
                      width: Responsive.width(52, context),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(235, 235, 235, 0.8),
                        borderRadius: BorderRadius.circular(
                            Responsive.height(26, context)),
                      ),
                      child: IconButton(
                          icon: SvgPicture.asset(
                            'assets/blogs/arrow-left.svg',
                            height: Responsive.height(24, context),
                            width: Responsive.width(24, context),
                            fit: BoxFit.none,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          })),
                ],
              )),
          SizedBox(height: Responsive.height(12, context)),
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
                        imageUrl: event!.eventBodies?[0].bodyImageURL ?? "",
                        width: Responsive.width(28, context),
                        height: Responsive.height(28, context),
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) => Icon(
                            Icons.groups_2_outlined,
                            size: Responsive.height(24, context)),
                      )),
                  SizedBox(width: Responsive.width(10, context)),
                  Text(
                    event!.eventBodies?[0].bodyName ?? "",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.text(16, context),
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
                    height: Responsive.height(412, context),
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
                          top: Responsive.height(10, context),
                          left: Responsive.width(16, context),
                          right: Responsive.width(16, context),
                          bottom: Responsive.height(20, context)),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(246, 246, 246, 1),
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                                Responsive.height(24, context))),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                height: Responsive.height(5, context),
                                width: Responsive.width(50, context),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(210, 213, 218, 1),
                                  borderRadius: BorderRadius.circular(
                                      Responsive.height(100, context)),
                                ),
                              ),
                            ),
                            SizedBox(height: Responsive.height(24, context)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    event!.eventName ?? "",
                                    style: TextStyle(
                                      fontSize: Responsive.text(24, context),
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
                                          horizontal:
                                              Responsive.width(8, context),
                                          vertical:
                                              Responsive.height(6, context)),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(15, 22, 32, 1),
                                        borderRadius: BorderRadius.circular(
                                            Responsive.height(8, context)),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                Responsive.height(15, context)),
                                            child: CachedNetworkImage(
                                              width:
                                                  Responsive.width(20, context),
                                              height: Responsive.height(
                                                  20, context),
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
                                          SizedBox(  
                                              width:
                                                  Responsive.width(8, context)),

                                          Text(
                                            fullbody!.bodyParents![0].bodyShortName ?? "",
                                            style: TextStyle(
                                              fontSize:
                                                  Responsive.text(14, context),
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
                            SizedBox(height: Responsive.height(4, context)),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/feed/light.svg',
                                  color: Color.fromRGBO(48, 111, 220, 1),
                                  height: Responsive.height(16.5, context),
                                  width: Responsive.width(9.17, context),
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: Responsive.width(6, context)),
                                Text(
                                  '${event!.eventGoingCount + event!.eventInterestedCount}',
                                  style: TextStyle(
                                    color: const Color(0xFF306FDC),
                                    fontSize: Responsive.text(14, context),
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: Responsive.width(4, context)),
                                Text(
                                  'Enthu',
                                  style: TextStyle(
                                    color: const Color(0xFF306FDC),
                                    fontSize: Responsive.text(14, context),
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Responsive.height(12, context)),
                            Dash(
                              direction: Axis.horizontal,
                              length: Responsive.width(368, context),
                              dashLength: Responsive.width(6, context),
                              dashGap: Responsive.width(7, context),
                              dashColor: Color(0xFFDADADA),
                            ),
                            SizedBox(height: Responsive.height(24, context)),
                            Container(
                                padding: EdgeInsets.only(
                                    right: Responsive.width(16, context)),
                                child: Column(children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height:
                                              Responsive.height(46, context),
                                          width: Responsive.width(46, context),
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                                196, 212, 239, 1),
                                            borderRadius: BorderRadius.circular(
                                                Responsive.height(50, context)),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/feed/Clock.svg',
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                Responsive.width(20, context)),
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
                                                fontSize: Responsive.text(
                                                    12, context),
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'DM Sans',
                                                color: Color.fromRGBO(
                                                    126, 130, 135, 1),
                                              ),
                                            ),
                                            SizedBox(
                                                height: Responsive.height(
                                                    2, context)),
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
                                                    fontSize: Responsive.text(
                                                        16, context),
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
                                                    fontSize: Responsive.text(
                                                        16, context),
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
                                  SizedBox(
                                      height: Responsive.height(16, context)),
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
                                            height:
                                                Responsive.height(46, context),
                                            width:
                                                Responsive.width(46, context),
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  196, 212, 239, 1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Responsive.height(
                                                          50, context)),
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                'assets/feed/Location.svg',
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: Responsive.width(
                                                  20, context)),
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
                                                  fontSize: Responsive.text(
                                                      12, context),
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'DM Sans',
                                                  color: Color.fromRGBO(
                                                      126, 130, 135, 1),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: Responsive.height(
                                                      2, context)),
                                              Text(
                                                _buildVenueText(event),
                                                style: TextStyle(
                                                  fontSize: Responsive.text(
                                                      16, context),
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
                            SizedBox(height: Responsive.height(24, context)),
                            Dash(
                              direction: Axis.horizontal,
                              length: Responsive.width(368, context),
                              dashLength: Responsive.width(6, context),
                              dashGap: Responsive.width(7, context),
                              dashColor: Color(0xFFDADADA),
                            ),
                            SizedBox(height: Responsive.height(24, context)),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: Responsive.text(16, context),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'DM Sans',
                                color: Color.fromRGBO(21, 32, 45, 1),
                              ),
                            ),
                            
                            SizedBox(height: Responsive.height(8, context)),
                            Container(
                              child: SelectableLinkify(
                                text : event!.eventDescription ??
                                    "No description available",
                                style: TextStyle(
                                  fontSize: Responsive.text(16, context),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'DM Sans',
                                  color: Color.fromRGBO(15, 22, 32, 1),
                                ),
                                linkStyle: TextStyle(
                                  color: Color.fromRGBO(48, 111, 220, 1),
                                  decoration: TextDecoration.underline,
                                ),
                                onOpen: (link) async {
                                  final uri = Uri.tryParse(link.url);
                                  if (uri == null) return;
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: Responsive.height(70, context)),
                          ],
                        ),
                      ));
                },
              ),
              Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.width(6, context),
                          vertical: Responsive.height(6, context)),
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/blogs/background.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(
                            Responsive.height(50, context)),
                        border: Border.all(
                          color: Color.fromRGBO(246, 246, 246, 1),
                          width: Responsive.height(8, context),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: Responsive.height(52, context),
                            width: Responsive.width(52, context),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(45, 70, 108, 1),
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: IconButton(
                                icon: SvgPicture.asset(
                                  'assets/feed/share.svg',
                                  height: Responsive.height(24, context),
                                  width: Responsive.width(24, context),
                                  fit: BoxFit.none,
                                ),
                                // onPressed: () async {
                                //   await Share.share(
                                //       "Check this event: ${ShareURLMaker.getEventURL(event!)}");
                                // }),
                                onPressed: () async {
                                String message = Uri.encodeComponent(
                                    "Check this event: ${ShareURLMaker.getEventURL(event!)}");
                                String whatsappUrl =
                                    "https://wa.me/?text=$message";
                                if (await canLaunchUrl(
                                    Uri.parse(whatsappUrl))) {
                                  await launchUrl(Uri.parse(whatsappUrl),
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("Could not open WhatsApp")));
                                }
                              },),
                          ),
                          SizedBox(width: Responsive.width(8, context)),
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
                                    left: Responsive.width(16, context),
                                    right: Responsive.width(16, context),
                                    top: Responsive.height(13, context),
                                    bottom: Responsive.height(13, context)),
                                decoration: BoxDecoration(
                                  color: currentUes == UES.NotGoing
                                      ? Color.fromRGBO(48, 111, 220, 1)
                                      : Color.fromRGBO(15, 22, 32, 1),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Color.fromRGBO(48, 111, 220, 1),
                                    width: Responsive.width(2, context),
                                  ),
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/feed/light.svg',
                                        color: colour,
                                        height:
                                            Responsive.height(18.3, context),
                                        width: Responsive.width(15, context),
                                        fit: BoxFit.cover,
                                      ),
                                      if (UES.NotGoing == currentUes)
                                        SizedBox(
                                            width:
                                                Responsive.width(11, context)),
                                      if (UES.NotGoing == currentUes)
                                        Text(
                                          'Show enthu',
                                          style: TextStyle(
                                            fontSize:
                                                Responsive.text(14, context),
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'DM Sans',
                                            color: colour,
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                Responsive.width(11, context)),
                                      // if (UES.Going == currentUes)
                                      //   SvgPicture.asset(
                                      //     'assets/feed/light.svg',
                                      //     color: colour,
                                      //     height:
                                      //         Responsive.height(18.3, context),
                                      //     width: Responsive.width(15, context),
                                      //     fit: BoxFit.cover,
                                      //   ),
                                      if (UES.Going == currentUes)
                                        Text(
                                          'Showing Enthu',
                                          style: TextStyle(
                                            fontSize:
                                                Responsive.text(14, context),
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'DM Sans',
                                            color: colour,
                                          ),
                                        ),
                                    ])),
                          )),
                          SizedBox(width: Responsive.width(8, context)),
                          // Container(
                          //   height: Responsive.height(52, context),
                          //   width: Responsive.width(52, context),
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(26),
                          //     color: Color.fromRGBO(37, 211, 102, 1),
                          //   ),
                          //   child: IconButton(
                          //     icon: SvgPicture.asset(
                          //       'assets/feed/whatsapp.svg',
                          //       fit: BoxFit.none,
                          //     ),
                          //     onPressed: () async {
                          //       String message = Uri.encodeComponent(
                          //           "Check this event: ${ShareURLMaker.getEventURL(event!)}");
                          //       String whatsappUrl =
                          //           "https://wa.me/?text=$message";
                          //       if (await canLaunchUrl(
                          //           Uri.parse(whatsappUrl))) {
                          //         await launchUrl(Uri.parse(whatsappUrl),
                          //             mode: LaunchMode.externalApplication);
                          //       } else {
                          //         ScaffoldMessenger.of(context).showSnackBar(
                          //             SnackBar(
                          //                 content:
                          //                     Text("Could not open WhatsApp")));
                          //       }
                          //     },
                          //   ),
                          // ),
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
