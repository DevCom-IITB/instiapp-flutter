import 'dart:collection';

import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/routes/explorepage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    if (firstBuild) {
      bloc.updateEvents();
      firstBuild = false;
    }
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => bloc.updateEvents(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column( 
            children: [
              Center(
              child: Container(
                padding: EdgeInsets.only(top: 10.5, bottom: 10.5),
                child: Text(
                  'Feed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ),
          SizedBox(height: 8),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(239, 239, 239, 1),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Color.fromRGBO(210, 213, 218, 1),
                          )),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/blogs/setting-4.svg',
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
                            'assets/blogs/chevron-down.svg',
                          ),
                        ],
                      )),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              SizedBox(height: 23),]
              ),),
              StreamBuilder(
                stream: bloc.events,
                builder: (context,
                    AsyncSnapshot<UnmodifiableListView<Event>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                Feedpost(bloc, snapshot.data![index]),
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
                  height: 32,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }}

//   Widget _buildEvent(ThemeData theme, InstiAppBloc bloc, Event event) {
//     if (event.eventBigImage) {
//       return InkWell(
//         onTap: () {
//           _openEventPage(bloc, event);
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             Hero(
//               tag: event.eventID ?? "",
//               child: Material(
//                 type: MaterialType.transparency,
//                 child: Ink.image(
//                   child: Container(),
//                   image: CachedNetworkImageProvider(
//                     event.eventImageURL ??
//                         event.eventBodies?[0].bodyImageURL ??
//                         "",
//                   ),
//                   height: MediaQuery.of(context).size.width * 0.6,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             ListTile(
//               contentPadding:
//                   EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               title: Text(
//                 event.eventName ?? "",
//                 style: theme.textTheme.titleLarge,
//               ),
//               enabled: true,
//               subtitle: Text(event.getSubTitle()),
//             )
//           ],
//         ),
//       );
//     } else {
//       return ListTile(
//         title: Text(
//           event.eventName ?? "",
//           style: theme.textTheme.titleLarge,
//         ),
//         enabled: true,
//         leading: NullableCircleAvatar(
//           event.eventImageURL ?? event.eventBodies?[0].bodyImageURL ?? "",
//           Icons.event_outlined,
//           heroTag: event.eventID ?? "",
//         ),
//         subtitle: Text(event.getSubTitle()),
//         onTap: () {
//           _openEventPage(bloc, event);
//         },
//       );
//     }
//   }

//   _openEventPage(InstiAppBloc bloc, Event event) {
//     EventPage.navigateWith(context, bloc, event);
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'homepage.dart';

// class FeedPage extends StatefulWidget {
//   @override
//   _FeedPageState createState() => _FeedPageState();
// }

// class _FeedPageState extends State<FeedPage> {
//   bool firstBuild = true;
//   @override
//   Widget build(BuildContext context) {
//     var bloc = BlocProvider.of(context)!.bloc;
//     if (firstBuild) {
//       bloc.updateEvents();
//       firstBuild = false;
//     }
//     return Scaffold(
//         body: SafeArea(
//       child: RefreshIndicator(
//         onRefresh: () => bloc.updateEvents(),
//           child: CustomScrollView(
//             slivers: [
//         Column(children: [
//           Center(
//             child: Container(
//               padding: EdgeInsets.only(top: 10.5, bottom: 10.5),
//               child: Text(
//                 'Feed',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: 'DM Sans',
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//               margin: EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Container(
//                       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                           color: Color.fromRGBO(239, 239, 239, 1),
//                           borderRadius: BorderRadius.circular(50),
//                           border: Border.all(
//                             color: Color.fromRGBO(210, 213, 218, 1),
//                           )),
//                       child: Row(
//                         children: [
//                           SvgPicture.asset(
//                             'assets/blogs/setting-4.svg',
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             'Sort',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               fontFamily: 'DM Sans',
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           SvgPicture.asset(
//                             'assets/blogs/chevron-down.svg',
//                           ),
//                         ],
//                       )),
//                   SizedBox(width: 8),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                         color: Color.fromRGBO(239, 239, 239, 1),
//                         borderRadius: BorderRadius.circular(50),
//                         border: Border.all(
//                           color: Color.fromRGBO(210, 213, 218, 1),
//                         )),
//                     child: Text(
//                       'Events',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         fontFamily: 'DM Sans',
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                         color: Color.fromRGBO(239, 239, 239, 1),
//                         borderRadius: BorderRadius.circular(50),
//                         border: Border.all(
//                           color: Color.fromRGBO(210, 213, 218, 1),
//                         )),
//                     child: Text(
//                       'Announcements',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         fontFamily: 'DM Sans',
//                       ),
//                     ),
//                   ),
//                 ],
//               )),
//           SizedBox(height: 23),
//           StreamBuilder(
//             stream: bloc.events,
//             builder:
//                 (context, AsyncSnapshot<UnmodifiableListView<Event>> snapshot) {
//               if (snapshot.hasData) {
//                 if (snapshot.data!.length > 0) {
//                   return SliverList(
//                     delegate: SliverChildBuilderDelegate(
//                         (context, index) => Feedpost(bloc, snapshot.data![index]),
//                         childCount: snapshot.data!.length),
//                   );
//                 } else {
//                   return SliverToBoxAdapter(
//                     child: Center(
//                       child: Text("No upcoming events"),
//                     ),
//                   );
//                 }
//               } else {
//                 return SliverToBoxAdapter(
//                   child: Center(
//                     child: CircularProgressIndicatorExtended(
//                       label: Text("Getting the latest events"),
//                     ),
//                   ),
//                 );
//               }
//             },
//           ),
//         ]),])
//       ),
//     ));
//   }
// }

Widget Feedpost(InstiAppBloc bloc, Event event) {
  return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color.fromRGBO(210, 213, 218, 1),
        ),
      ),
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          // child: Image.asset(
          //   'assets/blogs/Techfest.png',
          //   width: double.infinity,
          //   fit: BoxFit.cover,
          // ),
          child: Ink.image(
                  child: Container(),
                  image: CachedNetworkImageProvider(
                    event.eventImageURL ??
                        event.eventBodies?[0].bodyImageURL ??
                        "",
                  ),
                  fit: BoxFit.cover,
                ),
        ),        
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 16, top: 12, right: 16),
          child: Text(
            event.eventStartDate != null
                ? '${event.eventStartDate!.day} ${event.eventStartDate!.month}'
                : 'Unknown Date',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
            top: 8,
          ),
          child: Text(
            event.eventVenues?.isNotEmpty ?? false
                ? event.eventVenues![0].venueName ?? ""
                : "Venue not specified",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
        Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 16, right: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/blogs/e-cell.jpg',
                    width: 24,
                    height: 24,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Techfest',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            )),
        SizedBox(height: 13),
      ]));
}
