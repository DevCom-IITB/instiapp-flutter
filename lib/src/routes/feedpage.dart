import 'dart:async';
import 'dart:collection';
import 'package:InstiApp/src/utils/footer_buttons.dart';

import 'popupbox.dart';
import 'popupboxroute.dart';

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
import 'package:flutter_gif/flutter_gif.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool firstBuild = true;

  IconData actionIcon = Icons.search_outlined;

  bool searchMode = false;
  late FlutterGifController controller1;
  late AnimationController animControl;
  bool bday = false;

  Timer? timer;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      bdayAnimSequence();
    });
    controller1 =
        FlutterGifController(vsync: this, duration: Duration(seconds: 5));
    animControl = AnimationController(
        vsync: this, value: 0, duration: Duration(seconds: 1));
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      mascot();
      timer = Timer.periodic(Duration(seconds: 10), (timer) => mascot());
    });
    super.initState();
  }

  void mascot() {
    animControl.value = 1;
    setState(() {});
    controller1.value = 0;
    controller1.animateTo(71)
      ..then((value) {
        animControl.value = 0;
        setState(() {});
      });
  }

  void bdayAnimSequence({bool override = false}) {
    if (override || !bday)
      Navigator.of(context).push(PopUpDialogRoute(builder: (context) {
        return PopUpBox();
      }));
    if (!bday) {
      BlocProvider.of(context)!.bloc.setBday();
      bday = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    bday = bloc.bday;
    double screenWidth = MediaQuery.of(context).size.width;
    if (firstBuild) {
      bloc.updateEvents();
      firstBuild = false;
    }

    var fab;

    if (bloc.currSession?.profile?.userRoles?.isNotEmpty ?? false) {
      // fab = FloatingActionButton(child: Icon(Icons.add_outlined), onPressed: () {},);
      fab = FloatingActionButton.extended(
        icon: Icon(Icons.add_outlined),
        label: Text("Add Event"),
        onPressed: () {
          Navigator.of(context).pushNamed("/putentity/event");
        },
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      bottomNavigationBar: MyBottomAppBar(
        shape: RoundedNotchedRectangle(),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              tooltip: "Show bottom sheet",
              icon: Icon(
                Icons.menu_outlined,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => bloc.updateEvents(),
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: TitleWithBackButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Feed",
                              style: theme.textTheme.headline3,
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: searchMode ? 0.0 : null,
                            height: searchMode ? 0.0 : null,
                            decoration: ShapeDecoration(
                                shape: CircleBorder(
                                    side:
                                        BorderSide(color: theme.primaryColor))),
                            child: searchMode
                                ? SizedBox()
                                : IconButton(
                                    tooltip: "Search ${""}",
                                    padding: EdgeInsets.all(16.0),
                                    icon: Icon(
                                      actionIcon,
                                      color: theme.primaryColor,
                                    ),
                                    color: theme.cardColor,
                                    onPressed: () {
                                      setState(() {
                                        actionIcon = Icons.close_outlined;
                                        ExplorePage.navigateWith(context, true);
                                      });
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  StreamBuilder(
                    stream: bloc.events,
                    builder: (context,
                        AsyncSnapshot<UnmodifiableListView<Event>> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.length > 0) {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildEvent(
                                    theme, bloc, snapshot.data![index]),
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
              AnimatedPositioned(
                bottom: screenWidth * (animControl.value - 1),
                duration: Duration(seconds: 1),
                left: 0,
                child: GifImage(
                  controller: controller1,
                  image: AssetImage("assets/Anim.gif"),
                  width: screenWidth / 2,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      persistentFooterButtons: [
        FooterButtons(footerButtons: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: theme.scaffoldBackgroundColor,
              onPrimary: theme.textTheme.bodyText1?.color,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: theme.colorScheme.secondary,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
            child: Text("Wish Birthday!"),
            onPressed: () {
              bdayAnimSequence(override: true);
            },
          )
        ])
      ],
    );
  }

  Widget _buildEvent(ThemeData theme, InstiAppBloc bloc, Event event) {
    if (event.eventBigImage) {
      return InkWell(
        onTap: () {
          _openEventPage(bloc, event);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: event.eventID ?? "",
              child: Material(
                type: MaterialType.transparency,
                child: Ink.image(
                  child: Container(),
                  image: CachedNetworkImageProvider(
                    event.eventImageURL ??
                        event.eventBodies?[0].bodyImageURL ??
                        "",
                  ),
                  height: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              title: Text(
                event.eventName ?? "",
                style: theme.textTheme.headline6,
              ),
              enabled: true,
              subtitle: Text(event.getSubTitle()),
            )
          ],
        ),
      );
    } else {
      return ListTile(
        title: Text(
          event.eventName ?? "",
          style: theme.textTheme.headline6,
        ),
        enabled: true,
        leading: NullableCircleAvatar(
          event.eventImageURL ?? event.eventBodies?[0].bodyImageURL ?? "",
          Icons.event_outlined,
          heroTag: event.eventID ?? "",
        ),
        subtitle: Text(event.getSubTitle()),
        onTap: () {
          _openEventPage(bloc, event);
        },
      );
    }
  }

  _openEventPage(InstiAppBloc bloc, Event event) {
    EventPage.navigateWith(context, bloc, event);
  }

  @override
  void dispose() {
    controller1.dispose();
    animControl.dispose();
    timer?.cancel();
    super.dispose();
  }
}
