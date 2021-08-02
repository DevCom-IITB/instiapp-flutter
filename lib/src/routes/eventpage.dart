import 'dart:async';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:device_calendar/device_calendar.dart' as cal;

class EventPage extends StatefulWidget {
  final Event initialEvent;
  final Future<Event> eventFuture;

  EventPage({this.eventFuture, this.initialEvent});

  static void navigateWith(
      BuildContext context, InstiAppBloc bloc, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/event/${event?.eventID ?? ""}",
        ),
        builder: (context) => EventPage(
          initialEvent: event,
          eventFuture: bloc.getEvent(event.eventID),
        ),
      ),
    );
  }

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Event event;

  UES loadingUes = UES.NotGoing;

  bool _bottomSheetActive = false;

  @override
  void initState() {
    super.initState();
    event = widget.initialEvent;
    widget?.eventFuture?.then((ev) {
      var tableParse = markdown.TableSyntax();
      ev.eventDescription = markdown.markdownToHtml(
          ev.eventDescription
              .split('\n')
              .map((s) => s.trimRight())
              .toList()
              .join('\n'),
          blockSyntaxes: [tableParse]);
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
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;
    var footerButtons;
    var editAccess = false;
    if (event != null) {
      footerButtons = <Widget>[];
      editAccess = bloc.editEventAccess(event);
      footerButtons.addAll([
        buildUserStatusButton("Going", UES.Going, theme, bloc),
        buildUserStatusButton("Interested", UES.Interested, theme, bloc),
      ]);

      if ((event.eventWebsiteURL ?? "") != "") {
        footerButtons.add(IconButton(
          tooltip: "Open website",
          icon: Icon(Icons.language_outlined),
          onPressed: () async {
            if (await canLaunch(event.eventWebsiteURL)) {
              await launch(event.eventWebsiteURL);
            }
          },
        ));
      }
      if (event.eventVenues.isNotEmpty &&
          event.eventVenues[0].venueLatitude != null) {
        footerButtons.add(IconButton(
          tooltip: "Navigate to event",
          icon: Icon(Icons.navigation_outlined),
          onPressed: () async {
            String uri = defaultTargetPlatform == TargetPlatform.iOS
                ? "http://maps.apple.com/?ll=${event.eventVenues[0].venueLatitude},${event.eventVenues[0].venueLongitude}&z=20"
                : "google.navigation:q=${event.eventVenues[0].venueLatitude},${event.eventVenues[0].venueLongitude}";
            if (await canLaunch(uri)) {
              await launch(uri);
            }
          },
        ));
      }

      if (editAccess) {
        footerButtons.add(IconButton(
          icon: Icon(Icons.share_outlined),
          tooltip: "Share this event",
          onPressed: () async {
            await Share.share(
                "Check this event: ${ShareURLMaker.getEventURL(event)}");
          },
        ));
      }
    }
    return Scaffold(
        key: _scaffoldKey,
        drawer: NavDrawer(),
        bottomNavigationBar: MyBottomAppBar(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.menu_outlined,
                  semanticLabel: "Show navigation drawer",
                ),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: event == null
              ? Center(
                  child: CircularProgressIndicatorExtended(
                  label: Text("Loading the event page"),
                ))
              : ListView(
                  children: <Widget>[
                    TitleWithBackButton(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            event.eventName,
                            style: theme.textTheme.display2,
                          ),
                          SizedBox(height: 8.0),
                          Text(event.getSubTitle(),
                              style: theme.textTheme.title),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PhotoViewableImage(
                        url: event?.eventImageURL ??
                            event?.eventBodies[0].bodyImageURL,
                        heroTag: event.eventID,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28.0, vertical: 16.0),
                      child: CommonHtml(
                        data: event?.eventDescription,
                        defaultTextStyle: theme.textTheme.subhead,
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Divider(),
                  ]
                    ..addAll(event.eventBodies
                        .map((b) => _buildBodyTile(bloc, theme.textTheme, b)))
                    ..addAll([
                      Divider(),
                      SizedBox(
                        height: 64.0,
                      )
                    ]),
                ),
        ),
        floatingActionButton: _bottomSheetActive || event == null
            ? null
            : editAccess
                ? FloatingActionButton.extended(
                    icon: Icon(Icons.edit_outlined),
                    label: Text("Edit"),
                    tooltip: "Edit this event",
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed("/putentity/event/${event.eventID}");
                    },
                  )
                : FloatingActionButton(
                    child: Icon(Icons.share_outlined),
                    tooltip: "Share this event",
                    onPressed: () async {
                      await Share.share(
                          "Check this event: ${ShareURLMaker.getEventURL(event)}");
                    },
                  ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        persistentFooterButtons: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: footerButtons,
            ),
          ),
        ]);
  }

  Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
    return ListTile(
      title: Text(body.bodyName, style: theme.title),
      subtitle: Text(body.bodyShortDescription, style: theme.subtitle),
      leading: NullableCircleAvatar(
        body.bodyImageURL,
        Icons.work_outline_outlined,
        heroTag: body.bodyID,
      ),
      onTap: () {
        BodyPage.navigateWith(context, bloc, body: body);
      },
    );
  }

  RaisedButton buildUserStatusButton(
      String name, UES uesButton, ThemeData theme, InstiAppBloc bloc) {
    return RaisedButton(
      color: event?.eventUserUes == uesButton
          ? theme.accentColor
          : theme.scaffoldBackgroundColor,
      textColor:
          event?.eventUserUes == uesButton ? theme.accentIconTheme.color : null,
      shape: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.accentColor,
          ),
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Row(children: () {
        var rowChildren = <Widget>[
          Text(name),
          SizedBox(
            width: 8.0,
          ),
          Text(
              "${uesButton == UES.Interested ? event?.eventInterestedCount : event?.eventGoingCount}"),
        ];
        if (loadingUes == uesButton) {
          rowChildren.insertAll(0, [
            SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      event?.eventUserUes == uesButton
                          ? theme.accentIconTheme.color
                          : theme.accentColor),
                  strokeWidth: 2,
                )),
            SizedBox(
              width: 8.0,
            )
          ]);
        }
        return rowChildren;
      }()),
      onPressed: () async {
        if (bloc.currSession == null) {
          return;
        }
        setState(() {
          loadingUes = uesButton;
        });
        await bloc.updateUesEvent(
            event, event.eventUserUes == uesButton ? UES.NotGoing : uesButton);
        setState(() {
          loadingUes = UES.NotGoing;
          // event has changes
        });

        if (event.eventUserUes != UES.NotGoing) {
          // Add to calendar (or not)
          _addEventToCalendar(theme, bloc);
        }
      },
    );
  }

  bool lastCheck = false;

  void _addEventToCalendar(ThemeData theme, InstiAppBloc bloc) async {
    lastCheck = false;
    if (bloc.addToCalendarSetting == AddToCalendar.AlwaysAsk) {
      bool addToCal = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Add to Calendar?"),
                content: DialogContent(
                  parent: this,
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      if (lastCheck ?? false) {
                        bloc.addToCalendarSetting = AddToCalendar.No;
                      }
                    },
                  ),
                  FlatButton(
                    child: Text("Yes"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ));
      if (addToCal == null) {
        return;
      }

      if (lastCheck) {
        bloc.addToCalendarSetting =
            addToCal ? AddToCalendar.Yes : AddToCalendar.No;
      }

      if (addToCal) {
        _actualAddEventToDeviceCalendar(bloc);
      }
    } else if (bloc.addToCalendarSetting == AddToCalendar.Yes) {
      _actualAddEventToDeviceCalendar(bloc);
    }
  }

  List<bool> selector;
  void _actualAddEventToDeviceCalendar(InstiAppBloc bloc) async {
    // Init Device Calendar plugin
    cal.DeviceCalendarPlugin calendarPlugin = cal.DeviceCalendarPlugin();

    // Get Calendar Permissions
    var permissionsGranted = await calendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !permissionsGranted.data) {
      permissionsGranted = await calendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
        return;
      }
    }

    // Get All Calendars
    final calendarsResult = await calendarPlugin.retrieveCalendars();
    if (calendarsResult?.data != null) {
      lastCheck = false;
      // Get Calendar Permissions
      if (bloc.defaultCalendarsSetting?.isEmpty ?? true) {
        bool toContinue = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Select which calendars to add to?"),
                content: CalendarList(calendarsResult.data, parent: this),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  FlatButton(
                    child: Text("Yes"),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              );
            });
        if (!(toContinue ?? false)) {
          return;
        }

        if (lastCheck) {
          bloc.defaultCalendarsSetting =
              calendarsResult.data.asMap().entries.expand((entry) {
            if (selector[entry.key]) {
              return <String>[entry.value.id];
            }
            return <String>[];
          }).toList();
        }
      }

      if (!lastCheck && bloc.defaultCalendarsSetting.isNotEmpty) {
        selector = calendarsResult.data
            .map((calen) => bloc.defaultCalendarsSetting.contains(calen.id))
            .toList();
      }

      List<Future<cal.Result<String>>> futures =
          calendarsResult.data.asMap().entries.expand((entry) {
        if (selector[entry.key]) {
          cal.Event ev = cal.Event(
            entry.value.id,
            description: event.eventDescription,
            eventId: event.eventID,
            title: event.eventName,
            start: DateTime.parse(event.eventStartTime),
            end: DateTime.parse(event.eventEndTime),
          );
          return <Future<cal.Result<String>>>[
            calendarPlugin.createOrUpdateEvent(ev)
          ];
        }
        return <Future<cal.Result<String>>>[];
      }).toList();

      if ((await Future.wait(futures)).every((res) {
        print(res.data);
        return res.isSuccess;
      })) {
        showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Success"),
                content: Text(
                    'Successfully added to ${futures.length} calendar${futures.length > 1 ? "s" : ""}'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }
    }
  }
}

class CalendarList extends StatefulWidget {
  final List<cal.Calendar> calendarsResult;
  final _EventPageState parent;
  final List<bool> defaultSelector;

  CalendarList(this.calendarsResult, {this.parent, this.defaultSelector});

  @override
  _CalendarListState createState() => _CalendarListState();
}

class _CalendarListState extends State<CalendarList> {
  List<bool> selector;

  @override
  void initState() {
    super.initState();
    widget.parent.selector = widget.defaultSelector ??
        List.filled(widget.calendarsResult.length, false);
    selector = widget.parent.selector;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[]
        ..addAll(widget.calendarsResult
            .asMap()
            .entries
            .where((entry) => !entry.value.isReadOnly)
            .map((calEntry) => CheckboxListTile(
                  title: Text(calEntry.value.name),
                  dense: true,
                  value: selector[calEntry.key],
                  onChanged: (val) {
                    setState(() {
                      selector[calEntry.key] = val;
                    });
                  },
                )))
        ..add(DialogContent(
          parent: widget.parent,
        )),
    );
  }
}

class DialogContent extends StatefulWidget {
  final _EventPageState parent;
  DialogContent({this.parent});

  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {
  bool lastCheck = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Checkbox(
          value: lastCheck,
          onChanged: (val) {
            setState(() {
              lastCheck = val;
              widget.parent?.lastCheck = val;
            });
          },
        ),
        Text("Do not ask again?"),
      ],
    );
  }
}
