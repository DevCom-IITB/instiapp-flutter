import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class EventPage extends StatefulWidget {
  final Event event;

  EventPage(this.event);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  int loadingUes = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;

    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerOnly(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            leading: Material(
              shape: BeveledRectangleBorder(
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(15))),
              color: theme.accentColor,
              child: IconButton(
                icon: Icon(
                  OMIcons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
            ),
            actions: <Widget>[
              Material(
                shape: BeveledRectangleBorder(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(15))),
                color: theme.accentColor,
                child: IconButton(
                  tooltip: "Opens website",
                  icon: Icon(OMIcons.language),
                  onPressed: () {},
                ),
              ),
              Material(
                color: theme.accentColor,
                child: IconButton(
                  tooltip: "Navigate to event",
                  icon: Icon(OMIcons.navigation),
                  onPressed: () {},
                ),
              ),
              Material(
                color: theme.accentColor,
                child: IconButton(
                  tooltip: "Share",
                  icon: Icon(OMIcons.share),
                  onPressed: () {},
                ),
              ),
            ],
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(
                widget.event?.eventName,
              ),
              // title: Placeholder(),
              // title: Container(
              //     width: MediaQuery.of(context).size.width * 0.65,
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              //     color: Color.fromRGBO(0, 0, 0, 0.2),
              //     child: Text(
              //       widget.event?.eventName,
              //     )),
              // title: Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: <Widget>,
              // ),
              // background: Image.network(
              //     widget.event?.eventImageURL ??
              //         widget.event?.eventBodies[0].imageUrl,
              //     fit: BoxFit.fitWidth),
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(
                      widget.event?.eventImageURL ??
                          widget.event?.eventBodies[0].imageUrl,
                      fit: BoxFit.fitWidth),
                  // This gradient ensures that the toolbar icons are distinct
                  // against the background image.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.0, -1.0),
                        end: Alignment(0.0, -0.4),
                        colors: <Color>[Color(0x60000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      widget.event?.getSubTitle(),
                      style: theme.textTheme.title,
                    ),
                  ),
                  ButtonBar(
                    mainAxisSize: MainAxisSize.max,
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildUserStatusButton("Going", 2, theme, bloc),
                      buildUserStatusButton("Interested", 1, theme, bloc),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    widget.event?.eventDescription,
                    style: theme.textTheme.subhead,
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Divider(),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              widget.event.eventBodies
                  .map((b) => _buildBodyTile(b, theme.textTheme))
                  .toList(),
            ),
          ),
        ],
      ),
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
