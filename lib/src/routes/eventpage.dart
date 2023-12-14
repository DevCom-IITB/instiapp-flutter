import 'dart:async';
import 'dart:io';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/footer_buttons.dart';
import 'package:InstiApp/src/utils/notif_settings.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:device_calendar/device_calendar.dart' as cal;
import 'package:timezone/timezone.dart' as tz;
import 'package:InstiApp/src/blocs/ia_bloc.dart';

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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Event? event;

  UES loadingUes = UES.NotGoing;

  bool _bottomSheetActive = false;

  bool firstBuild = true;

  @override
  void initState() {
    super.initState();
    event = widget.initialEvent;
    widget.eventFuture.then((ev) {
      var tableParse = markdown.TableSyntax();
      ev?.eventDescription = markdown.markdownToHtml(
          ev.eventDescription
                  ?.split('\n')
                  .map((s) => s.trimRight())
                  .toList()
                  .join('\n') ??
              "",
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
    var bloc = BlocProvider.of(context)!.bloc;
    final NotificationRouteArguments? args = ModalRoute.of(context)!
        .settings
        .arguments as NotificationRouteArguments?;
    List<Widget> footerButtons = [];
    var editAccess = false;
    if (event != null) {
      footerButtons = <Widget>[];
      editAccess = bloc.editEventAccess(event!);
      if (bloc.currSession != null) {
        footerButtons.addAll([
          buildUserStatusButton("Going", UES.Going, theme, bloc),
          buildUserStatusButton("Interested", UES.Interested, theme, bloc),
        ]);

        if (args?.key == ActionKeys.ADD_TO_CALENDAR && firstBuild) {
          UESButtonOnClicked(UES.Going, theme, bloc, forceInterested: true);
          firstBuild = false;
        }
      }

      if ((event!.eventWebsiteURL ?? "") != "") {
        footerButtons.add(IconButton(
          tooltip: "Open website",
          icon: Icon(Icons.language_outlined),
          onPressed: () async {
            if (await canLaunchUrl(Uri.parse(event!.eventWebsiteURL!))) {
              await launchUrl(
                Uri.parse(event!.eventWebsiteURL!),
                mode: LaunchMode.externalApplication,
              );
            }
          },
        ));
      }
      if ((event!.eventVenues?.isNotEmpty ?? false) &&
          event!.eventVenues![0].venueLatitude != null) {
        footerButtons.add(IconButton(
          tooltip: "Navigate to event",
          icon: Icon(Icons.navigation_outlined),
          onPressed: () async {
            String uri = defaultTargetPlatform == TargetPlatform.iOS
                ? "http://maps.apple.com/?ll=${event!.eventVenues![0].venueLatitude},${event!.eventVenues![0].venueLongitude}&z=20"
                : "google.navigation:q=${event!.eventVenues![0].venueLatitude},${event!.eventVenues![0].venueLongitude}";
            if (await canLaunchUrl(Uri.parse(uri))) {
              await launchUrl(
                Uri.parse(uri),
                mode: LaunchMode.externalApplication,
              );
            }
          },
        ));
      }

      footerButtons.add(
        IconButton(
          icon: Icon(Icons.share_outlined),
          tooltip: "Share this event",
          padding: EdgeInsets.all(0),
          onPressed: () async {
            await Share.share(
                "Check this event: ${ShareURLMaker.getEventURL(event!)}");
          },
        ),
      );
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
                  _scaffoldKey.currentState?.openDrawer();
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
                            event!.eventName ?? "",
                            style: theme.textTheme.headline3,
                          ),
                          SizedBox(height: 8.0),
                          Text(event!.getSubTitle(),
                              style: theme.textTheme.headline6),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PhotoViewableImage(
                        url: event!.eventImageURL ??
                            event!.eventBodies?[0].bodyImageURL ??
                            defUrl,
                        heroTag: event!.eventID ?? "",
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
                        data: event!.eventDescription ?? "",
                        defaultTextStyle:
                            theme.textTheme.subtitle1 ?? TextStyle(),
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Divider(),
                  ]
                    ..addAll(event!.eventBodies?.map(
                            (b) => _buildBodyTile(bloc, theme.textTheme, b)) ??
                        [])
                    ..addAll([
                      Divider(),
                      SizedBox(
                        height: 64.0,
                      ),
                      Container(
                        child: bloc.currSession?.profile?.userRoles?.any(
                                    (role) => role.rolePermissions!
                                        .contains("VerE")) ??
                                false
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28.0, vertical: 16.0),
                                child: Text(
                                  event!.eventLongDescription ?? "",
                                  style:
                                      theme.textTheme.subtitle1 ?? TextStyle(),
                                ),
                              )
                            : null,
                      ),
                      Container(
                        child: bloc.currSession?.profile?.userRoles?.any(
                                    (role) => role.rolePermissions!
                                        .contains("VerE")) ??
                                false
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                  child: Text('Push Mail'),
                                  onPressed: () {
                                    bloc.client.pushMail(
                                        bloc.getSessionIdHeader(),
                                        event!.eventID ?? "",
                                        "approval");
                                  },
                                  style: TextButton.styleFrom(
                                    primary: Colors.black,
                                    backgroundColor: Colors.amber,
                                    onSurface: Colors.grey,
                                    elevation: 5.0,
                                  ),
                                ),
                              )
                            : null,
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
                          .pushNamed("/putentity/event/${event!.eventID}");
                    },
                  )
                : FloatingActionButton(
                    child: Icon(Icons.share_outlined),
                    tooltip: "Share this event",
                    onPressed: () async {
                      await Share.share(
                          "Check this event: ${ShareURLMaker.getEventURL(event!)}");
                    },
                  ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        persistentFooterButtons: [
          FooterButtons(
            footerButtons: footerButtons,
          )
        ]);
  }

  Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
    return ListTile(
      title: Text(body.bodyName ?? "", style: theme.headline6),
      subtitle: Text(body.bodyShortDescription ?? "", style: theme.subtitle2),
      leading: NullableCircleAvatar(
        body.bodyImageURL ?? defUrl,
        Icons.work_outline_outlined,
        heroTag: body.bodyID ?? "",
      ),
      onTap: () {
        BodyPage.navigateWith(context, bloc, body: body);
      },
    );
  }

  ElevatedButton buildUserStatusButton(
      String name, UES uesButton, ThemeData theme, InstiAppBloc bloc) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: event?.eventUserUes == uesButton
            ? theme.colorScheme.secondary
            : theme.scaffoldBackgroundColor,
        onPrimary: event?.eventUserUes == uesButton
            ? theme.floatingActionButtonTheme.foregroundColor
            : theme.textTheme.bodyText1?.color,
        shape: RoundedRectangleBorder(
            side: BorderSide(
              color: theme.colorScheme.secondary,
            ),
            borderRadius: BorderRadius.all(Radius.circular(4))),
      ),
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
                  valueColor: new AlwaysStoppedAnimation<Color?>(
                      event?.eventUserUes == uesButton
                          ? theme.floatingActionButtonTheme.foregroundColor
                          : theme.colorScheme.secondary),
                  strokeWidth: 2,
                )),
            SizedBox(
              width: 8.0,
            )
          ]);
        }
        return rowChildren;
      }()),
      onPressed: () {
        UESButtonOnClicked(uesButton, theme, bloc);
      },
    );
  }

  void UESButtonOnClicked(UES uesButton, ThemeData theme, InstiAppBloc bloc,
      {bool forceInterested = false}) async {
    if (bloc.currSession == null) {
      return;
    }
    setState(() {
      loadingUes = uesButton;
    });
    await bloc.updateUesEvent(
        event!,
        forceInterested
            ? UES.Going
            : (event!.eventUserUes == uesButton ? UES.NotGoing : uesButton));
    setState(() {
      loadingUes = UES.NotGoing;
      // event has changes
    });

    if (event?.eventUserUes != UES.NotGoing) {
      if (forceInterested) {
        _actualAddEventToDeviceCalendar(bloc);
      } else {
        // Add to calendar (or not)
        _addEventToCalendar(theme, bloc);
      }
    }
  }

  bool lastCheck = false;

  void _addEventToCalendar(ThemeData theme, InstiAppBloc bloc) async {
    lastCheck = false;
    if (bloc.addToCalendarSetting == AddToCalendar.AlwaysAsk) {
      bool? addToCal = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Add to Calendar?"),
                content: DialogContent(
                  parent: this,
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      if (lastCheck) {
                        bloc.addToCalendarSetting = AddToCalendar.No;
                      }
                    },
                  ),
                  TextButton(
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

  List<bool>? selector;
  void _actualAddEventToDeviceCalendar(InstiAppBloc bloc) async {
    // Init Device Calendar plugin
    cal.DeviceCalendarPlugin calendarPlugin = cal.DeviceCalendarPlugin();

    // Get Calendar Permissions
    var permissionsGranted = await calendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !(permissionsGranted.data ?? false)) {
      permissionsGranted = await calendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess ||
          !(permissionsGranted.data ?? false)) {
        return;
      }
    }

    // Get All Calendars
    final calendarsResult = await calendarPlugin.retrieveCalendars();
    if (calendarsResult.data != null) {
      lastCheck = false;
      // Get Calendar Permissions
      if (bloc.defaultCalendarsSetting.isEmpty) {
        bool? toContinue = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Select which calendars to add to?"),
                content: CalendarList(calendarsResult.data ?? [], parent: this),
                actions: <Widget>[
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  TextButton(
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
              calendarsResult.data?.asMap().entries.expand((entry) {
                    if (selector?[entry.key] == true) {
                      return <String>[entry.value.id ?? ""];
                    }
                    return <String>[];
                  }).toList() ??
                  [];
        }
      }

      if (!lastCheck && bloc.defaultCalendarsSetting.isNotEmpty) {
        selector = calendarsResult.data
            ?.map((calen) => bloc.defaultCalendarsSetting.contains(calen.id))
            .toList();
      }

      List<Future<cal.Result<String>?>> futures =
          calendarsResult.data?.asMap().entries.expand((entry) {
                if (selector?[entry.key] == true) {
                  DateTime? startTime;
                  if (event?.eventStartTime != null)
                    startTime = DateTime.parse(event!.eventStartTime!);
                  DateTime? endTime;
                  if (event?.eventEndTime != null)
                    endTime = DateTime.parse(event!.eventEndTime!);

                  cal.Event ev = cal.Event(
                    entry.value.id,
                    description: event?.eventDescription,
                    eventId: event?.eventID,
                    title: event?.eventName,
                    start: startTime == null
                        ? null
                        : Platform.isAndroid
                            ? tz.TZDateTime.utc(
                                startTime.year,
                                startTime.month,
                                startTime.day,
                                startTime.hour,
                                startTime.minute,
                                startTime.second)
                            : tz.TZDateTime.from(startTime, tz.local),
                    end: endTime == null
                        ? null
                        : Platform.isAndroid
                            ? tz.TZDateTime.utc(
                                endTime.year,
                                endTime.month,
                                endTime.day,
                                endTime.hour,
                                endTime.minute,
                                endTime.second)
                            : tz.TZDateTime.from(endTime, tz.local),
                  );
                  return <Future<cal.Result<String>?>>[
                    calendarPlugin.createOrUpdateEvent(ev)
                  ];
                }
                return <Future<cal.Result<String>?>>[];
              }).toList() ??
              [];

      if ((await Future.wait(futures)).every((res) {
        return res?.isSuccess ?? false;
      })) {
        showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Success",
                  style: TextStyle(color: Colors.green),
                ),
                content: Text(
                    'Event has been successfully added to ${futures.length} calendar${futures.length > 1 ? "s" : ""}.\n \nIt may take a few minutes to appear in your calendar.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
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

  // tz.TZDateTime? dateTimeToTZ(DateTime? dateTime){
  //   final timeZone = TimeZone()
  // }
}

class CalendarList extends StatefulWidget {
  final List<cal.Calendar> calendarsResult;
  final _EventPageState? parent;
  final List<bool>? defaultSelector;

  CalendarList(this.calendarsResult, {this.parent, this.defaultSelector});

  @override
  _CalendarListState createState() => _CalendarListState();
}

class _CalendarListState extends State<CalendarList> {
  List<bool>? selector;

  @override
  void initState() {
    super.initState();
    widget.parent?.selector = widget.defaultSelector ??
        List.filled(widget.calendarsResult.length, false);
    selector = widget.parent?.selector;
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
            .where((entry) => !(entry.value.isReadOnly ?? false))
            .map((calEntry) => CheckboxListTile(
                  title: Text(calEntry.value.name ?? ""),
                  dense: true,
                  value: selector?[calEntry.key],
                  onChanged: (val) {
                    setState(() {
                      selector?[calEntry.key] = val ?? false;
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
  final _EventPageState? parent;
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
              lastCheck = val ?? false;
              widget.parent?.lastCheck = val ?? false;
            });
          },
        ),
        Text("Do not ask again?"),
      ],
    );
  }
}
