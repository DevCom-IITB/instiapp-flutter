import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/calendar_bloc.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart' as el;
import 'dart:math';

class CalendarPage extends StatefulWidget {
  final String title = "Calendar";

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  DateTime _currentDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  static Widget? _eventIcon;
  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    var calBloc = bloc.calendarBloc;

    // print("Width: ${MediaQuery.of(context).size.width}");

    _eventIcon = Material(
      type: MaterialType.transparency,
      shape: CircleBorder(
        side: BorderSide(
          color: theme.colorScheme.secondary,
        ),
      ),
    );
    if (firstBuild) {
      calBloc.fetchEvents(DateTime.now(), _eventIcon!);
      firstBuild = false;
    }

    return Scaffold(
      key: _scaffoldKey,
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
      drawer: NavDrawer(),
      body: SafeArea(
        child: StreamBuilder<Map<DateTime, List<Event>>>(
          stream: calBloc.events,
          builder: (BuildContext context,
              AsyncSnapshot<Map<DateTime, List<Event>>> snapshot) {
            return ListView(
              children: <Widget>[
                TitleWithBackButton(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: theme.textTheme.headline3,
                      ),
                      SizedBox(
                          height: 18,
                          width: 18,
                          child: StreamBuilder<bool>(
                            stream: calBloc.loading,
                            initialData: true,
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              return snapshot.data != null
                                  ? CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              theme.colorScheme.secondary),
                                      strokeWidth: 2,
                                    )
                                  : Container();
                            },
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: CalendarCarousel<Event>(
                          customGridViewPhysics: NeverScrollableScrollPhysics(),
                          onDayPressed: (DateTime date, List<Event> evs) {
                            this.setState(() => _currentDate = date);
                          },
                          onCalendarChanged: (date) {
                            // print(
                            //     "Fetching events around ${date.month}/${date.year}");
                            calBloc.fetchEvents(
                                DateTime(date.year, date.month, 1),
                                _eventIcon!);
                          },

                          headerTextStyle: theme.textTheme.headline6,

                          weekendTextStyle: theme.textTheme.headline6
                              ?.copyWith(fontSize: 18)
                              .copyWith(color: Colors.red[800]),
                          daysTextStyle:
                              theme.textTheme.headline6?.copyWith(fontSize: 18),
                          inactiveDaysTextStyle:
                              theme.textTheme.headline6?.copyWith(fontSize: 18),
                          nextDaysTextStyle: theme.textTheme.headline6
                              ?.copyWith(fontSize: 18)
                              .copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(150)),
                          prevDaysTextStyle: theme.textTheme.headline6
                              ?.copyWith(fontSize: 18)
                              .copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(150)),

                          weekFormat: false,
                          markedDatesMap:
                              el.EventList(events: snapshot.data ?? {}),
                          markedDateShowIcon: true,
                          markedDateIconMaxShown: 10,
                          markedDateIconOffset: 0,

                          markedDateIconBuilder: (e) => Container(
                              decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.all(Radius.circular(1000.0)),
                          )),

                          // markedDateMoreShowTotal: true,
                          // markedDateMoreCustomTextStyle:
                          //     theme.accentTextTheme.body1.copyWith(
                          //         fontSize: 9.0, fontWeight: FontWeight.normal),
                          // markedDateMoreCustomDecoration: BoxDecoration(
                          //   color: theme.accentColor.withOpacity(1.0),
                          //   shape: BoxShape.circle,
                          // ),

                          todayButtonColor: theme.primaryColor.withOpacity(0.3),
                          selectedDayButtonColor: theme.colorScheme.secondary,
                          selectedDayTextStyle: theme.textTheme.headline6?.copyWith(
                            color: theme.colorScheme.secondary
                          ),

                          // height: min(MediaQuery.of(context).size.shortestSide, 600) * 1.6,
                          height: 440.0,
                          width: min(MediaQuery.of(context).size.width, 400),

                          selectedDateTime: _currentDate,

                          // null for not rendering any border, true for circular border, false for rectangular border
                          daysHaveCircularBorder: null,
                          staticSixWeekFormat: true,

                          iconColor: theme.colorScheme.secondary,
                          weekdayTextStyle: TextStyle(
                              // color: theme.accentColor.withOpacity(0.9),
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: RawMaterialButton(
                          fillColor: theme.colorScheme.secondary,
                          shape: StadiumBorder(),
                          splashColor: theme.colorScheme.secondary.withOpacity(0.8),
                          onPressed: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                snapshot.data != null &&
                                        (snapshot.data
                                                ?.containsKey(_currentDate) ??
                                            false)
                                    ? "${snapshot.data?[_currentDate]?.length} Events"
                                    : "No events",
                                style: theme.textTheme.button?.copyWith(
                                  color: theme.colorScheme.secondary
                                )),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ]
                ..addAll(_buildEvents(calBloc, theme))
                ..add(SizedBox(
                  height: 48,
                )),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton:
          (bloc.currSession?.profile?.userRoles?.isNotEmpty ?? false)
              ? FloatingActionButton(
                  child: Icon(Icons.add_outlined),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/putentity/event");
                  },
                )
              : null,
    );
  }

  Iterable<Widget> _buildEvents(CalendarBloc calBloc, ThemeData theme) {
    return calBloc.eventsMap[_currentDate]
            ?.map((e) => _buildEventTile(calBloc.bloc, theme, e)) ??
        [];
  }

  Widget _buildEventTile(InstiAppBloc bloc, ThemeData theme, Event event) {
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
        EventPage.navigateWith(context, bloc, event);
      },
    );
  }
}
