import 'dart:collection';
import 'dart:developer';

import 'package:InstiApp/src/api/apiclient.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/blocs/achievementform_bloc.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:InstiApp/src/api/model/event.dart';

import '../bloc_provider.dart';
import '../drawer.dart';

class Home extends StatefulWidget {
  // initiate widgetstate Form
  _CreateAchievementPage createState() => _CreateAchievementPage();
}

class _CreateAchievementPage extends State<Home> {
  int number = 0;
  bool selectedE = false;
  bool selectedB =false;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Event _selectedEvent = Event();
  Body  _selectedBody =Body();
  AchievementCreateRequest currRequest = AchievementCreateRequest();



  TextEditingController titlecontroller =TextEditingController();
  TextEditingController desccontroller =TextEditingController();
  TextEditingController adminnotecontroller =TextEditingController();

  // builds dropdown menu for event choice
  List<DropdownMenuItem<Event>> buildDropdownMenuItems(
      UnmodifiableListView<Event> data) {
    List<DropdownMenuItem<Event>> items = [];
    for (Event event in data) {
      items.add(
        DropdownMenuItem(
          value: event,
          child: Text(event.eventName),
        ),
      );
    }
    return items;
  }

  // builds dropdown menu for event choice
  List<DropdownMenuItem<Body>> buildDropdownMenuItemsBody(
      UnmodifiableListView<Body> data) {
    List<DropdownMenuItem<Body>> items = [];
    for (Body event in data) {
      items.add(
        DropdownMenuItem(
          value: event,
          child: Text(event.bodyName),
        ),
      );
    }
    return items;
  }
  @override
  void initstate(){
    titlecontroller.addListener(() {currRequest.title=titlecontroller.text;});
    desccontroller.addListener(() {currRequest.description=desccontroller.text;});
    adminnotecontroller.addListener(() {currRequest.admin_note=adminnotecontroller.text;});
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    titlecontroller.dispose();
    desccontroller.dispose();
    adminnotecontroller.dispose();
    super.dispose();
  }

  bool firstBuild = true;



  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);
    final achievementsBloc = bloc.achievementBloc;
    currRequest.title="aa";
    currRequest.description="aa";
    currRequest.admin_note="aa";


    if (firstBuild) {
      bloc.updateEvents();
      firstBuild = false;
    }







    return Scaffold(
        key: _scaffoldKey,
        drawer: NavDrawer(),
        appBar: AppBar(
          leading: IconButton(
            tooltip: "Show top sheet",
            icon: Icon(
              Icons.menu_outlined,
              semanticLabel: "Show top sheet",
            ),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
          ),
          title: Text(
            'Achievements',
            //style: theme.textTheme.display2,
          ),
          //centerTitle: true,
          backgroundColor: Colors.blue,
          actions: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(Icons.qr_code),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(Icons.notifications),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => bloc.updateEvents(),
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.fromLTRB(15.0, 15.0, 10.0, 5.0),
                      child: Text(
                        'Verification Request',
                        style: TextStyle(fontSize: 20),
                      )),
                  Container(
                      margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                      child: TextFormField(
                        controller: titlecontroller,
                        maxLength: 50,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Title",
                        ),
                        autocorrect: true,
                        validator: (value) {
                          log("aa");
                          currRequest.title = value;
                        },
                      )),
                  Container(
                      margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                      child: TextFormField(
                        controller: desccontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Description",
                        ),
                        autocorrect: true,
                        onChanged: (String selectedEvent) {
                                 setState(() {

                            currRequest.description = selectedEvent;

                            });
                                 },
                        validator: (value) {
                          log("bb");
                          currRequest.description = value;
                        },
                      )),
                  Container(
                      margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                      child: TextFormField(
                        controller: adminnotecontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Admin Note",
                        ),
                        autocorrect: true,
                        validator: (value) {
                          log("bb");
                          currRequest.admin_note = value;
                        },
                      )),
                  Container(
                      margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 20.0,
                            ),
                            StreamBuilder(
                              stream: bloc.events,
                              builder: (context,
                                  AsyncSnapshot<UnmodifiableListView<Event>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data.length > 0) {
                                    return DropdownButtonFormField(
                                        hint: Text("Event(Optional)"),
                                        items: buildDropdownMenuItems(
                                            snapshot.data),
                                        onChanged: (Event selectedEvent) {
                                          setState(() {
                                            selectedE = true;
                                            currRequest.event = selectedEvent;
                                            _selectedEvent = selectedEvent;
                                          });
                                        });
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
                                        label:
                                            Text("Getting the latest events"),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            verify_card(
                                thing: this._selectedEvent,
                                selected: this.selectedE),
                          ])),
                  Container(
                      margin: EdgeInsets.fromLTRB(15.0, 1.0, 15.0, 5.0),
                      child: Text(
                        "Search for an InstiApp event",
                        style: TextStyle(fontSize: 12),
                      )),
                  Container(
                     // width: double.infinity,
                        margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 20.0,
                              ),
                              StreamBuilder(
                                stream: bloc.exploreBloc.bodies,
                                builder: (context,
                                    AsyncSnapshot<UnmodifiableListView<Body>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data.length > 0) {
                                      return DropdownButtonFormField(
                                          hint: Text("Verifying Authority"),
                                          items: buildDropdownMenuItemsBody(
                                              snapshot.data),
                                          onChanged: (Body selectedEvent) {
                                            setState(() {
                                              selectedB = true;
                                              currRequest.verauth =
                                                  selectedEvent;
                                              _selectedBody = selectedEvent;
                                            });
                                          });
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
                                          label:
                                              Text("Getting the latest events"),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              body_card(
                                  thing: this._selectedBody,
                                  selected: this.selectedB),
                              //_buildEvent(theme, bloc, snapshot.data[0]);//verify_card(thing: this._selectedCompany, selected: this.selected);
                            ])),

                  Container(
                      margin: EdgeInsets.fromLTRB(15.0, 1.0, 15.0, 5.0),
                      child: Text(
                        'Enter an Organisations name',
                        style: TextStyle(fontSize: 12),
                      )),
                  Container(
                    width: double.infinity,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: TextButton(
                      onPressed: () async {
                        log(currRequest.description);
                        //var resp = await achievementsBloc.postForm(currRequest);
                        bloc.getVerifiableBodies();


                        //print(resp?.result);
                      },
                      child: Text('Request Verification'),
                      style: TextButton.styleFrom(
                          primary: Colors.black,
                          backgroundColor: Colors.amber,
                          onSurface: Colors.grey,
                          elevation: 5.0),
                    ),
                  ),
                ]),
          ),
        ));
  }
}

class verify_card extends StatefulWidget {
  final Event thing;
  final bool selected;

  verify_card({this.thing, this.selected});

  card createState() => card();
}

class card extends State<verify_card> {
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);
    if (widget.selected) {
      return ListTile(
        title: Text(
          widget.thing.eventName,
          style: theme.textTheme.title,
        ),
        enabled: true,
        leading: NullableCircleAvatar(
          widget.thing.eventImageURL ??
              widget.thing.eventBodies[0].bodyImageURL,
          Icons.event_outlined,
          heroTag: widget.thing.eventID,
        ),
        subtitle: Text(widget.thing.getSubTitle()),
      );
    } else {
      return SizedBox(height: 10);
    }
  }
}


class body_card extends StatefulWidget {
  final Body thing;
  final bool selected;

  body_card({this.thing, this.selected});

  bodycard createState() => bodycard();
}

class bodycard extends State<body_card> {
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);
    if (widget.selected) {
      return ListTile(
        title: Text(
          widget.thing.bodyName,
          style: theme.textTheme.title,
        ),
        enabled: true,
        leading: NullableCircleAvatar(
          widget.thing.bodyImageURL ??
              widget.thing.bodyImageURL,
          Icons.event_outlined,
          heroTag: widget.thing.bodyID,
        ),
        subtitle: Text(widget.thing.bodyShortDescription),
      );
    } else {
      return SizedBox(height: 10);
    }
  }
}

