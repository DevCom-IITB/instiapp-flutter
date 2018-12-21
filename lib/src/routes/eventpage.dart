import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:scrollable_bottom_sheet/scrollable_bottom_sheet.dart';

class EventPage extends StatefulWidget {
  final Event event;

  EventPage(this.event);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  int loadingUes = 0;

  bool _bottomSheetActive = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;
    var footerButtons = <Widget>[
      buildUserStatusButton("Going", 2, theme, bloc),
      buildUserStatusButton("Interested", 1, theme, bloc),
    ];

    if ((widget.event.eventWebsiteURL ?? "") != "") {
      footerButtons.add(IconButton(
        tooltip: "Open website",
        icon: Icon(OMIcons.language),
        onPressed: () async {
          if (await canLaunch(widget.event.eventWebsiteURL)) {
            await launch(widget.event.eventWebsiteURL);
          }
        },
      ));
    }
    if (widget.event.eventVenues.isNotEmpty &&
        widget.event.eventVenues[0].venueLatitude != null) {
      footerButtons.add(IconButton(
        tooltip: "Navigate to event",
        icon: Icon(OMIcons.navigation),
        onPressed: () async {
          String uri =
              "google.navigation:q=${widget.event.eventVenues[0].venueLatitude},${widget.event.eventVenues[0].venueLongitude}";
          if (await canLaunch(uri)) {
            await launch(uri);
          }
        },
      ));
    }
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                OMIcons.menu,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: _bottomSheetActive
                  ? null
                  : () {
                      setState(() {
                        //disable button
                        _bottomSheetActive = true;
                      });
                      _scaffoldKey.currentState
                          .showBottomSheet((context) {
                            return BottomDrawer();
                          })
                          .closed
                          .whenComplete(() {
                            setState(() {
                              _bottomSheetActive = false;
                            });
                          });
                    },
            ),
          ],
        ),
      ),
      // bottomSheet: ,
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.event.eventName,
                  style: theme.textTheme.display2
                      .copyWith(color: Colors.black, fontFamily: "Bitter"),
                ),
                SizedBox(height: 8.0),
                Text(widget.event.getSubTitle(),
                    style: theme.textTheme.title),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
                widget.event?.eventImageURL ??
                    widget.event?.eventBodies[0].imageUrl,
                fit: BoxFit.fitWidth),
          ),
          SizedBox(
            height: 16.0,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: Text(
              widget.event?.eventDescription,
              style: theme.textTheme.subhead,
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Divider(),
        ]
          ..addAll(widget.event.eventBodies
              .map((b) => _buildBodyTile(b, theme.textTheme)))
          ..addAll([
            Divider(),
            SizedBox(
              height: 64.0,
            )
          ]),
      ),

      floatingActionButton: _bottomSheetActive
          ? null
          : FloatingActionButton(
              child: Icon(OMIcons.share),
              tooltip: "Share this event",
              onPressed: () async {
                await Share.share(
                    "Check this event: ${ShareURLMaker.getEventURL(widget.event)}");
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      persistentFooterButtons: footerButtons,
    );
  }

  Widget _buildBodyTile(Body body, TextTheme theme) {
    return ListTile(
      title: Text(body.name, style: theme.title),
      subtitle: Text(body.shortDescription, style: theme.subtitle),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(body.imageUrl),
      ),
      onTap: () {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Body page is still in progress"),
        ));
        // TODO: BodyPage
        // Navigator.of(context).pushNamed("/body/${body.id}");
      },
    );
  }

  RaisedButton buildUserStatusButton(
      String name, int id, ThemeData theme, InstiAppBloc bloc) {
    return RaisedButton(
      color:
          widget.event?.eventUserUes == id ? theme.accentColor : Colors.white,
      textColor: widget.event?.eventUserUes == id ? Colors.white : null,
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
              "${id == 1 ? widget.event?.eventInterestedCount : widget.event?.eventGoingCount}"),
        ];
        if (loadingUes == id) {
          rowChildren.insertAll(0, [
            SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      widget.event?.eventUserUes == id
                          ? Colors.white
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
        setState(() {
          loadingUes = id;
        });
        await bloc.updateUesEvent(
            widget.event, widget.event.eventUserUes == id ? 0 : id);
        setState(() {
          loadingUes = 0;
          // event has changes
        });
      },
    );
  }
}
