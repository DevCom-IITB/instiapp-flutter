import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:markdown/markdown.dart' as markdown;

class EventPage extends StatefulWidget {
  final Event initialEvent;
  final Future<Event> eventFuture;

  EventPage({this.eventFuture, this.initialEvent});

  static void navigateWith(
      BuildContext context, InstiAppBloc bloc, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
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

  int loadingUes = 0;

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
        buildUserStatusButton("Going", 2, theme, bloc),
        buildUserStatusButton("Interested", 1, theme, bloc),
      ]);

      if ((event.eventWebsiteURL ?? "") != "") {
        footerButtons.add(IconButton(
          tooltip: "Open website",
          icon: Icon(OMIcons.language),
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
          icon: Icon(OMIcons.navigation),
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
          icon: Icon(OMIcons.share),
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
                OMIcons.menu,
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
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          event.eventName,
                          style: theme.textTheme.display2,
                        ),
                        SizedBox(height: 8.0),
                        Text(event.getSubTitle(), style: theme.textTheme.title),
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
                  icon: Icon(OMIcons.edit),
                  label: Text("Edit"),
                  tooltip: "Edit this event",
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed("/putentity/event/${event.eventID}");
                  },
                )
              : FloatingActionButton(
                  child: Icon(OMIcons.share),
                  tooltip: "Share this event",
                  onPressed: () async {
                    await Share.share(
                        "Check this event: ${ShareURLMaker.getEventURL(event)}");
                  },
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      persistentFooterButtons: footerButtons,
    );
  }

  Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
    return ListTile(
      title: Text(body.bodyName, style: theme.title),
      subtitle: Text(body.bodyShortDescription, style: theme.subtitle),
      leading: NullableCircleAvatar(
        body.bodyImageURL,
        OMIcons.workOutline,
        heroTag: body.bodyID,
      ),
      onTap: () {
        BodyPage.navigateWith(context, bloc, body);
      },
    );
  }

  RaisedButton buildUserStatusButton(
      String name, int id, ThemeData theme, InstiAppBloc bloc) {
    return RaisedButton(
      color: event?.eventUserUes == id
          ? theme.accentColor
          : theme.scaffoldBackgroundColor,
      textColor: event?.eventUserUes == id ? theme.accentIconTheme.color : null,
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
              "${id == 1 ? event?.eventInterestedCount : event?.eventGoingCount}"),
        ];
        if (loadingUes == id) {
          rowChildren.insertAll(0, [
            SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      event?.eventUserUes == id
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
          loadingUes = id;
        });
        await bloc.updateUesEvent(event, event.eventUserUes == id ? 0 : id);
        setState(() {
          loadingUes = 0;
          // event has changes
        });
      },
    );
  }
}
