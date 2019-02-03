import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/calendar_bloc.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    as cal;
import 'package:flutter_calendar_carousel/classes/event_list.dart' as el;

class CalendarPage extends StatefulWidget {
  final String title = "Calendar";

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  DateTime _currentDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  static Widget _eventIcon;
  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;
    var calBloc = bloc.calendarBloc;

    _eventIcon = Material(
      type: MaterialType.transparency,
      shape: CircleBorder(
        side: BorderSide(
          color: theme.accentColor,
        ),
      ),
    );
    if (firstBuild) {
      calBloc.fetchEvents(DateTime.now(), _eventIcon);
      firstBuild = false;
    }

    var footerButtons;
    footerButtons = null;

    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: MyBottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              tooltip: "Show bottom sheet",
              icon: Icon(
                OMIcons.menu,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
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
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: theme.textTheme.display2,
                      ),
                      SizedBox(
                          height: 18,
                          width: 18,
                          child: StreamBuilder<bool>(
                            stream: calBloc.loading,
                            initialData: true,
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              return snapshot.data
                                  ? CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              theme.accentColor),
                                      strokeWidth: 2,
                                    )
                                  : Container();
                            },
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      cal.CalendarCarousel<Event>(
                        customGridViewPhysics: NeverScrollableScrollPhysics(),
                        onDayPressed: (DateTime date, List<Event> evs) {
                          this.setState(() => _currentDate = date);
                        },
                        onCalendarChanged: (date) {
                          print(
                              "Fetching events around ${date.month}/${date.year}");
                          calBloc.fetchEvents(
                              DateTime(date.year, date.month, 1), _eventIcon);
                        },
                        weekendTextStyle: TextStyle(
                          color: Colors.red[800],
                        ),

                        headerTextStyle: theme.textTheme.title,

                        daysTextStyle: theme.textTheme.subhead,

                        weekFormat: false,
                        markedDatesMap:
                            el.EventList(events: snapshot.data ?? {}),
                        markedDateShowIcon: true,
                        markedDateIconMaxShown: 0,

                        markedDateMoreShowTotal: true,
                        markedDateMoreCustomTextStyle:
                            theme.accentTextTheme.body1.copyWith(
                                fontSize: 9.0, fontWeight: FontWeight.normal),
                        markedDateMoreCustomDecoration: BoxDecoration(
                          color: theme.accentColor.withOpacity(1.0),
                          shape: BoxShape.circle,
                        ),

                        todayButtonColor: theme.accentColor.withOpacity(0.6),
                        selectedDayButtonColor: theme.accentColor,
                        selectedDayTextStyle: theme.accentTextTheme.subhead,

                        // height: min(MediaQuery.of(context).size.shortestSide, 600) * 1.6,
                        // width: min(MediaQuery.of(context).size.shortestSide, 600),
                        height: 420.0,

                        selectedDateTime: _currentDate,

                        // null for not rendering any border, true for circular border, false for rectangular border
                        daysHaveCircularBorder: null,
                        staticSixWeekFormat: true,

                        iconColor: theme.accentColor,
                        weekdayTextStyle: TextStyle(
                            // color: theme.accentColor.withOpacity(0.9),
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                      Center(
                        child: RawMaterialButton(
                          fillColor: theme.accentColor,
                          shape: StadiumBorder(),
                          splashColor: theme.accentColor.withOpacity(0.8),
                          onPressed: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                snapshot.data != null &&
                                        snapshot.data.containsKey(_currentDate)
                                    ? "${snapshot.data[_currentDate].length} Events"
                                    : "No events",
                                style: theme.accentTextTheme.button),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ]..addAll(_buildEvents(calBloc, theme)),
            );
          },
        ),
      ),
      persistentFooterButtons: footerButtons,
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
        event.eventName,
        style: theme.textTheme.title,
      ),
      enabled: true,
      leading: NullableCircleAvatar(
        event.eventImageURL ?? event.eventBodies[0].bodyImageURL,
        OMIcons.event,
        heroTag: event.eventID,
      ),
      subtitle: Text(event.getSubTitle()),
      onTap: () {
        EventPage.navigateWith(context, bloc, event);
      },
    );
  }
}
