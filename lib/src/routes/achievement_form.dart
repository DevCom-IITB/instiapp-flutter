import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
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
  bool selectedB = false;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();

  Event _selectedEvent;
  Body _selectedBody;
  AchievementCreateRequest currRequest = AchievementCreateRequest();

  // builds dropdown menu for event choice
  Widget buildDropdownMenuItemsEvent(
      BuildContext context, Event event, String itemDesignation) {
    print("Entered build dropdown menu items");
    if (event == null) {
      return Container(
        child: Text(
          "Search for an InstiApp Event",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
    }
    return Container(
      child: ListTile(
        title: Text(event.eventName),
      ),
    );
  }

  Widget _customPopupItemBuilderEvent(
      BuildContext context, Event event, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(event.eventName),
      ),
    );
  }

  Widget buildDropdownMenuItemsBody(
      BuildContext context, Body body, String itemDesignation) {
    print("Entered build dropdown menu items");
    if (body == null) {
      return Container(
        child: Text(
          "Search for an organisation",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
    }
    print(body);
    return Container(
      child: ListTile(
        title: Text(body.bodyName),
      ),
    );
  }

  Widget _customPopupItemBuilderBody(
      BuildContext context, Body body, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(body.bodyName),
      ),
    );
  }

  void onEventChange(Event event) {
    setState(() {
      selectedE = true;
      currRequest.event = event;
      _selectedEvent = event;
      onBodyChange(event.eventBodies[0]);
    });
  }

  void onBodyChange(Body body) {
    setState(() {
      selectedB = true;
      currRequest.body = body;
      currRequest.bodyID = body.bodyID;
      _selectedBody = body;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    print(_selectedBody);
    var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);
    final achievementsBloc = bloc.achievementBloc;
    if (firstBuild) {
      firstBuild = false;
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
                _scaffoldKey.currentState.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
          child: bloc.currSession == null
              ? Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(50),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud,
                        size: 200,
                        color: Colors.grey[600],
                      ),
                      Text(
                        "Login To View Achievements",
                        style: theme.textTheme.headline5,
                        textAlign: TextAlign.center,
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => bloc.updateEvents(),
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  margin: EdgeInsets.fromLTRB(
                                      15.0, 15.0, 10.0, 5.0),
                                  child: Text(
                                    'Verification Request',
                                    style: theme.textTheme.headline4,
                                  )),
                              SizedBox(
                                height: 40,
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(
                                      15.0, 5.0, 15.0, 10.0),
                                  child: TextFormField(
                                    maxLength: 50,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Title",
                                    ),
                                    autocorrect: true,
                                    onChanged: (value) {
                                      setState(() {
                                        currRequest.title = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Title should not be empty';
                                      }
                                      return null;
                                    },
                                  )),
                              Container(
                                  margin: EdgeInsets.fromLTRB(
                                      15.0, 5.0, 15.0, 10.0),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Description",
                                    ),
                                    autocorrect: true,
                                    onChanged: (value) {
                                      setState(() {
                                        currRequest.description = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Description should not be empty';
                                      }
                                      return null;
                                    },
                                  )),
                              Container(
                                  margin: EdgeInsets.fromLTRB(
                                      15.0, 5.0, 15.0, 10.0),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Admin Note",
                                    ),
                                    autocorrect: true,
                                    onChanged: (value) {
                                      setState(() {
                                        currRequest.adminNote = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Admin Note should not be empty';
                                      }
                                      return null;
                                    },
                                  )),
                              Container(
                                  margin:
                                      EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 0.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 20.0,
                                        ),
                                        DropdownSearch<Event>(
                                          mode: Mode.DIALOG,
                                          maxHeight: 700,
                                          isFilteredOnline: true,
                                          showSearchBox: true,
                                          label: "Event (Optional)",
                                          hint: "Event (Optional)",
                                          onChanged: onEventChange,
                                          onFind: bloc
                                              .achievementBloc.searchForEvent,
                                          dropdownBuilder:
                                              buildDropdownMenuItemsEvent,
                                          popupItemBuilder:
                                              _customPopupItemBuilderEvent,
                                          popupSafeArea: PopupSafeArea(
                                              top: true, bottom: true),
                                          scrollbarProps: ScrollbarProps(
                                            isAlwaysShown: true,
                                            thickness: 7,
                                          ),
                                          emptyBuilder:
                                              (BuildContext context, String _) {
                                            return Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(20),
                                              child: Text(
                                                "No events found. Refine your search!",
                                                style:
                                                    theme.textTheme.subtitle1,
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          height: this.selectedE ? 20.0 : 0,
                                        ),
                                        VerifyCard(
                                            thing: this._selectedEvent,
                                            selected: this.selectedE),
                                      ])),
                              Container(
                                  // width: double.infinity,
                                  margin: EdgeInsets.fromLTRB(
                                      15.0, 0.0, 15.0, 10.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 20.0,
                                        ),

                                        DropdownSearch<Body>(
                                          mode: Mode.DIALOG,
                                          maxHeight: 700,
                                          isFilteredOnline: true,
                                          showSearchBox: true,
                                          label: "Verifying Authority",
                                          hint: "Verifying Authority",
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Please select a organization';
                                            }
                                            return null;
                                          },
                                          onChanged: onBodyChange,
                                          onFind: bloc
                                              .achievementBloc.searchForBody,
                                          dropdownBuilder:
                                              buildDropdownMenuItemsBody,
                                          popupItemBuilder:
                                              _customPopupItemBuilderBody,
                                          popupSafeArea: PopupSafeArea(
                                              top: true, bottom: true),
                                          scrollbarProps: ScrollbarProps(
                                            isAlwaysShown: true,
                                            thickness: 7,
                                          ),
                                          selectedItem: _selectedBody,
                                          emptyBuilder:
                                              (BuildContext context, String _) {
                                            return Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(20),
                                              child: Text(
                                                "No verifying authorities found. Refine your search!",
                                                style:
                                                    theme.textTheme.subtitle1,
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          height: this.selectedB ? 20.0 : 0,
                                        ),
                                        BodyCard(
                                            thing: this._selectedBody,
                                            selected: this.selectedB),
                                        //_buildEvent(theme, bloc, snapshot.data[0]);//verify_card(thing: this._selectedCompany, selected: this.selected);
                                      ])),
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
                                child: TextButton(
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      var resp = await achievementsBloc
                                          .postForm(currRequest);
                                      if (resp.result == "success") {
                                        Navigator.of(context)
                                            .pushNamed("/achievements");
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: new Text('Error'),
                                          duration: new Duration(seconds: 10),
                                        ));
                                      }
                                    }

                                    //log(currRequest.description);
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
                    ),
                  ),
                )),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.qr_code),
        label: Text("Scan QR"),
        onPressed: () {
          Navigator.of(context).pushNamed("/achievements/add");
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class VerifyCard extends StatefulWidget {
  final Event thing;
  final bool selected;

  VerifyCard({this.thing, this.selected});

  Card createState() => Card();
}

class Card extends State<VerifyCard> {
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    if (widget.selected) {
      return ListTile(
        title: Text(
          widget.thing.eventName,
          style: theme.textTheme.headline6,
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

class BodyCard extends StatefulWidget {
  final Body thing;
  final bool selected;

  BodyCard({this.thing, this.selected});

  BodyCardState createState() => BodyCardState();
}

class BodyCardState extends State<BodyCard> {
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    if (widget.selected) {
      return ListTile(
        title: Text(
          widget.thing.bodyName,
          style: theme.textTheme.headline6,
        ),
        enabled: true,
        leading: NullableCircleAvatar(
          widget.thing.bodyImageURL ?? widget.thing.bodyImageURL,
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
