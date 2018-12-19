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
            leading: Container(
              decoration: ShapeDecoration(
                  shape: BeveledRectangleBorder(
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(15))),
                  color: theme.accentColor),
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
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  child: Text(
                    widget.event?.eventName,
                  )),
              background: Image.network(
                  widget.event?.eventImageURL ??
                      widget.event?.eventBodies[0].imageUrl,
                  fit: BoxFit.fitWidth),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ButtonBar(
                  mainAxisSize: MainAxisSize.max,
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    buildUserStatusButton("Going", 2, theme, bloc),
                    buildUserStatusButton("Interested", 1, theme, bloc),
                  ],
                ),
                SizedBox(height: 16.0,),
                
              ],
            ),
          )
        ],
      ),
    );
  }

  RaisedButton buildUserStatusButton(String name, int id, ThemeData theme, InstiAppBloc bloc) {
    return RaisedButton(
      color: widget.event?.eventUserUes == id ? theme.accentColor : Colors.white,
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
          Text("${id == 1 ? widget.event?.eventInterestedCount : widget.event?.eventGoingCount}"),
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
