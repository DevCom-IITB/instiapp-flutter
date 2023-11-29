import 'dart:developer';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/response/secret_response.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
  bool selectedS = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  Event? _selectedEvent;
  Body? _selectedBody;
  Skill? _selectedSkill;
  AchievementCreateRequest currRequest1 = AchievementCreateRequest();
  AchievementCreateRequest currRequest2 = AchievementCreateRequest();

  // builds dropdown menu for event choice
  Widget buildDropdownMenuItemsEvent(BuildContext context, Event? event) {
    // print("Entered build dropdown menu items");
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
        title: Text(event.eventName!),
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
        title: Text(event.eventName!),
      ),
    );
  }

  Widget buildDropdownMenuItemsBody(BuildContext context, Body? body) {
    // print("Entered build dropdown menu items");
    if (body == null) {
      return Container(
        child: Text(
          "Search for an organisation",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
    }
    // print(body);
    return Container(
      child: ListTile(
        title: Text(body.bodyName!),
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
        title: Text(body.bodyName!),
      ),
    );
  }

  Widget buildDropdownMenuItemsSkill(BuildContext context, Skill? body) {
    // print("Entered build dropdown menu items");
    if (body == null) {
      return Container(
        child: Text(
          "Search for a skill",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
    }
    // print(body);
    return Container(
      child: ListTile(
        title: Text(body.title!),
      ),
    );
  }

  Widget _customPopupItemBuilderSkill(
      BuildContext context, Skill body, bool isSelected) {
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
        title: Text(body.title!),
      ),
    );
  }

  void onEventChange(Event? event) {
    setState(() {
      selectedE = true;
      currRequest1.event = event;
      _selectedEvent = event!;
      onBodyChange(event.eventBodies![0]);
    });
  }

  void onBodyChange(Body? body) {
    setState(() {
      selectedB = true;
      currRequest1.body = body;
      currRequest1.bodyID = body?.bodyID!;
      _selectedBody = body!;
    });
  }

  void onSkillChange(Skill? body) {
    setState(() {
      selectedS = true;
      currRequest2.title = body?.title;
      // currRequest2.body = body?.body!;
      _selectedSkill = body!;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    // print(_selectedBody);
    var bloc = BlocProvider.of(context)!.bloc;
    var theme = Theme.of(context);
    final achievementsBloc = bloc.achievementBloc;
    if (firstBuild) {
      firstBuild = false;
    }
    var fab;
    fab = FloatingActionButton.extended(
      icon: Icon(Icons.qr_code),
      label: Text("Scan QR Code"),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => QRViewExample(),
        ));
      },
    );

    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
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
                    _scaffoldKey.currentState!.openDrawer();
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
                : NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[];
                    },
                    body: TabBarView(
                      // These are the contents of the tab views, below the tabs.
                      children: ["Associations", "Skills"].map((name) {
                        return SafeArea(
                          top: false,
                          bottom: false,
                          child: Builder(
                            // This Builder is needed to provide a BuildContext that is "inside"
                            // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
                            // find the NestedScrollView.
                            builder: (BuildContext context) {
                              var delegates = {
                                "Associations": RefreshIndicator(
                                  onRefresh: () => bloc.updateEvents(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(7.0),
                                    child: SingleChildScrollView(
                                      child: Form(
                                        key: _formKey1,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      15.0, 15.0, 10.0, 5.0),
                                                  child: Text(
                                                    'Verification Request',
                                                    style: theme
                                                        .textTheme.headline4,
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
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText: "Title",
                                                    ),
                                                    autocorrect: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        currRequest1.title =
                                                            value;
                                                      });
                                                    },
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
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
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText: "Description",
                                                    ),
                                                    autocorrect: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        currRequest1
                                                                .description =
                                                            value;
                                                      });
                                                    },
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
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
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText: "Admin Note",
                                                    ),
                                                    autocorrect: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        currRequest1.adminNote =
                                                            value;
                                                      });
                                                    },
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Admin Note should not be empty';
                                                      }
                                                      return null;
                                                    },
                                                  )),
                                              Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      15.0, 5.0, 15.0, 0.0),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height: 20.0,
                                                        ),
                                                        DropdownSearch<Event>(
                                                          mode: Mode.DIALOG,
                                                          dropdownSearchDecoration:
                                                              InputDecoration(
                                                            labelText:
                                                                "Event (Optional)",
                                                            hintText:
                                                                "Event (Optional)",
                                                          ),
                                                          maxHeight: 700,
                                                          isFilteredOnline:
                                                              true,
                                                          showSearchBox: true,
                                                          onChanged:
                                                              onEventChange,
                                                          onFind: bloc
                                                              .achievementBloc
                                                              .searchForEvent,
                                                          dropdownBuilder:
                                                              buildDropdownMenuItemsEvent,
                                                          popupItemBuilder:
                                                              _customPopupItemBuilderEvent,
                                                          // popupSafeArea:
                                                          // PopupSafeArea(
                                                          //     top: true,
                                                          //     bottom: true),
                                                          scrollbarProps:
                                                              ScrollbarProps(
                                                            isAlwaysShown: true,
                                                            thickness: 7,
                                                          ),
                                                          emptyBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  String? _) {
                                                            return Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(20),
                                                              child: Text(
                                                                "No events found. Refine your search!",
                                                                style: theme
                                                                    .textTheme
                                                                    .subtitle1,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        SizedBox(
                                                          height: this.selectedE
                                                              ? 20.0
                                                              : 0,
                                                        ),
                                                        _selectedEvent != null
                                                            ? VerifyCard(
                                                                thing: this
                                                                    ._selectedEvent!,
                                                                selected: this
                                                                    .selectedE)
                                                            : SizedBox(),
                                                      ])),
                                              Container(
                                                  // width: double.infinity,
                                                  margin: EdgeInsets.fromLTRB(
                                                      15.0, 0.0, 15.0, 10.0),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height: 20.0,
                                                        ),

                                                        DropdownSearch<Body>(
                                                          mode: Mode.DIALOG,
                                                          maxHeight: 700,
                                                          isFilteredOnline:
                                                              true,
                                                          showSearchBox: true,
                                                          dropdownSearchDecoration:
                                                              InputDecoration(
                                                                  labelText:
                                                                      "Verifying Authority",
                                                                  hintText:
                                                                      "Verifying Authority"),
                                                          validator: (value) {
                                                            if (value == null) {
                                                              return 'Please select a organization';
                                                            }
                                                            return null;
                                                          },
                                                          onChanged:
                                                              onBodyChange,
                                                          onFind: bloc
                                                              .achievementBloc
                                                              .searchForBody,
                                                          dropdownBuilder:
                                                              buildDropdownMenuItemsBody,
                                                          popupItemBuilder:
                                                              _customPopupItemBuilderBody,
                                                          // popupSafeArea:
                                                          // PopupSafeArea(
                                                          //     top: true,
                                                          //     bottom: true),
                                                          scrollbarProps:
                                                              ScrollbarProps(
                                                            isAlwaysShown: true,
                                                            thickness: 7,
                                                          ),
                                                          selectedItem:
                                                              _selectedBody,
                                                          emptyBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  String? _) {
                                                            return Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(20),
                                                              child: Text(
                                                                "No verifying authorities found. Refine your search!",
                                                                style: theme
                                                                    .textTheme
                                                                    .subtitle1,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        SizedBox(
                                                          height: this.selectedB
                                                              ? 20.0
                                                              : 0,
                                                        ),
                                                        _selectedBody != null
                                                            ? BodyCard(
                                                                thing: this
                                                                    ._selectedBody!,
                                                                selected: this
                                                                    .selectedB)
                                                            : SizedBox(),
                                                        //_buildEvent(theme, bloc, snapshot.data[0]);//verify_card(thing: this._selectedCompany, selected: this.selected);
                                                      ])),
                                              Container(
                                                width: double.infinity,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 15.0),
                                                child: TextButton(
                                                  onPressed: () async {
                                                    if (_formKey1.currentState!
                                                        .validate()) {
                                                      currRequest1.isSkill =
                                                          false;
                                                      var resp =
                                                          await achievementsBloc
                                                              .postForm(
                                                                  currRequest1);
                                                      if (resp!.result ==
                                                          "success") {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                                "/achievements");
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content:
                                                              new Text('Error'),
                                                          duration:
                                                              new Duration(
                                                                  seconds: 10),
                                                        ));
                                                      }
                                                    }

                                                    //log(currRequest.description);
                                                  },
                                                  child: Text(
                                                      'Request Verification'),
                                                  style: TextButton.styleFrom(
                                                      primary: Colors.black,
                                                      backgroundColor:
                                                          Color(0xffffd740),
                                                      onSurface: Colors.grey,
                                                      elevation: 5.0),
                                                ),
                                              ),
                                            ]),
                                      ),
                                    ),
                                  ),
                                ),
                                "Skills": RefreshIndicator(
                                  onRefresh: () => bloc.updateEvents(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(7.0),
                                    child: SingleChildScrollView(
                                      child: Form(
                                        key: _formKey2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  // width: double.infinity,
                                                  margin: EdgeInsets.fromLTRB(
                                                      15.0, 0.0, 15.0, 10.0),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height: 20.0,
                                                        ),

                                                        DropdownSearch<Skill>(
                                                          mode: Mode.DIALOG,
                                                          maxHeight: 700,
                                                          isFilteredOnline:
                                                              true,
                                                          showSearchBox: true,
                                                          dropdownSearchDecoration:
                                                              InputDecoration(
                                                                  labelText:
                                                                      "Title",
                                                                  hintText:
                                                                      "Titile"),
                                                          validator: (value) {
                                                            if (value == null) {
                                                              return 'Please select a Skill';
                                                            }
                                                            return null;
                                                          },
                                                          onChanged:
                                                              onSkillChange,
                                                          onFind: bloc
                                                              .achievementBloc
                                                              .searchForSkill,
                                                          dropdownBuilder:
                                                              buildDropdownMenuItemsSkill,
                                                          popupItemBuilder:
                                                              _customPopupItemBuilderSkill,
                                                          // popupSafeArea:
                                                          // PopupSafeArea(
                                                          //     top: true,
                                                          //     bottom: true),
                                                          scrollbarProps:
                                                              ScrollbarProps(
                                                            isAlwaysShown: true,
                                                            thickness: 7,
                                                          ),
                                                          selectedItem:
                                                              _selectedSkill,
                                                          emptyBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  String? _) {
                                                            return Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(20),
                                                              child: Text(
                                                                "No skills found. Refine your search!",
                                                                style: theme
                                                                    .textTheme
                                                                    .subtitle1,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        SizedBox(
                                                          height: this.selectedB
                                                              ? 20.0
                                                              : 0,
                                                        ),
                                                        _selectedSkill?.body !=
                                                                null
                                                            ? BodyCard(
                                                                thing: this
                                                                    ._selectedSkill
                                                                    ?.body,
                                                                selected: this
                                                                    .selectedS)
                                                            : SizedBox(),
                                                        //_buildEvent(theme, bloc, snapshot.data[0]);//verify_card(thing: this._selectedCompany, selected: this.selected);
                                                      ])),
                                              Container(
                                                width: double.infinity,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 15.0),
                                                child: TextButton(
                                                  onPressed: () async {
                                                    if (_formKey2.currentState!
                                                        .validate()) {
                                                      currRequest2.isSkill =
                                                          true;
                                                      // print(currRequest2.title);
                                                      var resp =
                                                          await achievementsBloc
                                                              .postForm(
                                                                  currRequest2);
                                                      if (resp?.result ==
                                                          "success") {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                                "/achievements");
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content:
                                                              new Text('Error'),
                                                          duration:
                                                              new Duration(
                                                                  seconds: 10),
                                                        ));
                                                      }
                                                    }

                                                    //log(currRequest.description);
                                                  },
                                                  child: Text(
                                                      'Request Verification'),
                                                  style: TextButton.styleFrom(
                                                      primary: Colors.black,
                                                      backgroundColor:
                                                          Color(0xffffd740),
                                                      onSurface: Colors.grey,
                                                      elevation: 5.0),
                                                ),
                                              ),
                                            ]),
                                      ),
                                    ),
                                  ),
                                ),
                              };
                              return delegates[name]!;
                              // return CustomScrollView(
                              //   // The "controller" and "primary" members should be left
                              //   // unset, so that the NestedScrollView can control this
                              //   // inner scroll view.
                              //   // If the "controller" property is set, then this scroll
                              //   // view will not be associated with the NestedScrollView.
                              //   // The PageStorageKey should be unique to this ScrollView;
                              //   // it allows the list to remember its scroll position when
                              //   // the tab view is not on the screen.
                              //   key: PageStorageKey<String>(name),
                              //   slivers: <Widget>[
                              //     // SliverOverlapInjector(
                              //     //   // This is the flip side of the SliverOverlapAbsorber above.
                              //     //   handle: NestedScrollView
                              //     //       .sliverOverlapAbsorberHandleFor(context),
                              //     // ),
                              //     SliverPadding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       // In this example, the inner scroll view has
                              //       // fixed-height list items, hence the use of
                              //       // SliverFixedExtentList. However, one could use any
                              //       // sliver widget here, e.g. SliverList or SliverGrid.
                              //       sliver: delegates[name].childCount == 0
                              //           ? SliverToBoxAdapter(
                              //               child: Center(
                              //                 child: Padding(
                              //                   padding: const EdgeInsets.all(8.0),
                              //                   child: Text(
                              //                     "No $name",
                              //                   ),
                              //                 ),
                              //               ),
                              //             )
                              //           : SliverList(
                              //               delegate: delegates[name],
                              //             ),
                              //     ),
                              //   ],
                              // );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          // body: SafeArea(
          //     child: bloc.currSession == null
          //         ? Container(
          //             alignment: Alignment.center,
          //             padding: EdgeInsets.all(50),
          //             child: Column(
          //               children: [
          //                 Icon(
          //                   Icons.cloud,
          //                   size: 200,
          //                   color: Colors.grey[600],
          //                 ),
          //                 Text(
          //                   "Login To View Achievements",
          //                   style: theme.textTheme.headline5,
          //                   textAlign: TextAlign.center,
          //                 )
          //               ],
          //               crossAxisAlignment: CrossAxisAlignment.center,
          //             ),
          //           )
          //         : RefreshIndicator(
          //             onRefresh: () => bloc.updateEvents(),
          //             child: Padding(
          //               padding: const EdgeInsets.all(7.0),
          //               child: SingleChildScrollView(
          //                 child: Form(
          //                   key: _formKey,
          //                   child: Column(
          //                       mainAxisAlignment: MainAxisAlignment.start,
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: [
          //                         Container(
          //                             margin: EdgeInsets.fromLTRB(
          //                                 15.0, 15.0, 10.0, 5.0),
          //                             child: Text(
          //                               'Verification Request',
          //                               style: theme.textTheme.headline4,
          //                             )),
          //                         SizedBox(
          //                           height: 40,
          //                         ),
          //                         Container(
          //                             margin: EdgeInsets.fromLTRB(
          //                                 15.0, 5.0, 15.0, 10.0),
          //                             child: TextFormField(
          //                               maxLength: 50,
          //                               decoration: InputDecoration(
          //                                 border: OutlineInputBorder(),
          //                                 labelText: "Title",
          //                               ),
          //                               autocorrect: true,
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   currRequest.title = value;
          //                                 });
          //                               },
          //                               validator: (value) {
          //                                 if (value == null || value.isEmpty) {
          //                                   return 'Title should not be empty';
          //                                 }
          //                                 return null;
          //                               },
          //                             )),
          //                         Container(
          //                             margin: EdgeInsets.fromLTRB(
          //                                 15.0, 5.0, 15.0, 10.0),
          //                             child: TextFormField(
          //                               decoration: InputDecoration(
          //                                 border: OutlineInputBorder(),
          //                                 labelText: "Description",
          //                               ),
          //                               autocorrect: true,
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   currRequest.description = value;
          //                                 });
          //                               },
          //                               validator: (value) {
          //                                 if (value == null || value.isEmpty) {
          //                                   return 'Description should not be empty';
          //                                 }
          //                                 return null;
          //                               },
          //                             )),
          //                         Container(
          //                             margin: EdgeInsets.fromLTRB(
          //                                 15.0, 5.0, 15.0, 10.0),
          //                             child: TextFormField(
          //                               decoration: InputDecoration(
          //                                 border: OutlineInputBorder(),
          //                                 labelText: "Admin Note",
          //                               ),
          //                               autocorrect: true,
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   currRequest.adminNote = value;
          //                                 });
          //                               },
          //                               validator: (value) {
          //                                 if (value == null || value.isEmpty) {
          //                                   return 'Admin Note should not be empty';
          //                                 }
          //                                 return null;
          //                               },
          //                             )),
          //                         Container(
          //                             margin:
          //                                 EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 0.0),
          //                             child: Column(
          //                                 crossAxisAlignment:
          //                                     CrossAxisAlignment.center,
          //                                 mainAxisAlignment:
          //                                     MainAxisAlignment.center,
          //                                 children: <Widget>[
          //                                   SizedBox(
          //                                     height: 20.0,
          //                                   ),
          //                                   DropdownSearch<Event>(
          //                                     mode: Mode.DIALOG,
          //                                     maxHeight: 700,
          //                                     isFilteredOnline: true,
          //                                     showSearchBox: true,
          //                                     label: "Event (Optional)",
          //                                     hint: "Event (Optional)",
          //                                     onChanged: onEventChange,
          //                                     onFind: bloc
          //                                         .achievementBloc.searchForEvent,
          //                                     dropdownBuilder:
          //                                         buildDropdownMenuItemsEvent,
          //                                     popupItemBuilder:
          //                                         _customPopupItemBuilderEvent,
          //                                     popupSafeArea: PopupSafeArea(
          //                                         top: true, bottom: true),
          //                                     scrollbarProps: ScrollbarProps(
          //                                       isAlwaysShown: true,
          //                                       thickness: 7,
          //                                     ),
          //                                     emptyBuilder:
          //                                         (BuildContext context, String _) {
          //                                       return Container(
          //                                         alignment: Alignment.center,
          //                                         padding: EdgeInsets.all(20),
          //                                         child: Text(
          //                                           "No events found. Refine your search!",
          //                                           style:
          //                                               theme.textTheme.subtitle1,
          //                                         ),
          //                                       );
          //                                     },
          //                                   ),
          //                                   SizedBox(
          //                                     height: this.selectedE ? 20.0 : 0,
          //                                   ),
          //                                   VerifyCard(
          //                                       thing: this._selectedEvent,
          //                                       selected: this.selectedE),
          //                                 ])),
          //                         Container(
          //                             // width: double.infinity,
          //                             margin: EdgeInsets.fromLTRB(
          //                                 15.0, 0.0, 15.0, 10.0),
          //                             child: Column(
          //                                 crossAxisAlignment:
          //                                     CrossAxisAlignment.center,
          //                                 mainAxisAlignment:
          //                                     MainAxisAlignment.center,
          //                                 children: <Widget>[
          //                                   SizedBox(
          //                                     height: 20.0,
          //                                   ),
          //
          //                                   DropdownSearch<Body>(
          //                                     mode: Mode.DIALOG,
          //                                     maxHeight: 700,
          //                                     isFilteredOnline: true,
          //                                     showSearchBox: true,
          //                                     label: "Verifying Authority",
          //                                     hint: "Verifying Authority",
          //                                     validator: (value) {
          //                                       if (value == null) {
          //                                         return 'Please select a organization';
          //                                       }
          //                                       return null;
          //                                     },
          //                                     onChanged: onBodyChange,
          //                                     onFind: bloc
          //                                         .achievementBloc.searchForBody,
          //                                     dropdownBuilder:
          //                                         buildDropdownMenuItemsBody,
          //                                     popupItemBuilder:
          //                                         _customPopupItemBuilderBody,
          //                                     popupSafeArea: PopupSafeArea(
          //                                         top: true, bottom: true),
          //                                     scrollbarProps: ScrollbarProps(
          //                                       isAlwaysShown: true,
          //                                       thickness: 7,
          //                                     ),
          //                                     selectedItem: _selectedBody,
          //                                     emptyBuilder:
          //                                         (BuildContext context, String _) {
          //                                       return Container(
          //                                         alignment: Alignment.center,
          //                                         padding: EdgeInsets.all(20),
          //                                         child: Text(
          //                                           "No verifying authorities found. Refine your search!",
          //                                           style:
          //                                               theme.textTheme.subtitle1,
          //                                           textAlign: TextAlign.center,
          //                                         ),
          //                                       );
          //                                     },
          //                                   ),
          //                                   SizedBox(
          //                                     height: this.selectedB ? 20.0 : 0,
          //                                   ),
          //                                   BodyCard(
          //                                       thing: this._selectedBody,
          //                                       selected: this.selectedB),
          //                                   //_buildEvent(theme, bloc, snapshot.data[0]);//verify_card(thing: this._selectedCompany, selected: this.selected);
          //                                 ])),
          //                         Container(
          //                           width: double.infinity,
          //                           margin: EdgeInsets.symmetric(
          //                               vertical: 10.0, horizontal: 15.0),
          //                           child: TextButton(
          //                             onPressed: () async {
          //                               if (_formKey.currentState.validate()) {
          //                                 var resp = await achievementsBloc
          //                                     .postForm(currRequest);
          //                                 if (resp.result == "success") {
          //                                   Navigator.of(context)
          //                                       .pushNamed("/achievements");
          //                                 } else {
          //                                   ScaffoldMessenger.of(context)
          //                                       .showSnackBar(SnackBar(
          //                                     content: new Text('Error'),
          //                                     duration: new Duration(seconds: 10),
          //                                   ));
          //                                 }
          //                               }
          //
          //                               //log(currRequest.description);
          //                             },
          //                             child: Text('Request Verification'),
          //                             style: TextButton.styleFrom(
          //                                 primary: Colors.black,
          //                                 backgroundColor: Colors.amber,
          //                                 onSurface: Colors.grey,
          //                                 elevation: 5.0),
          //                           ),
          //                         ),
          //                       ]),
          //                 ),
          //               ),
          //             ),
          //           )),
          floatingActionButton: fab,
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        ));
  }
}

class VerifyCard extends StatefulWidget {
  final Event thing;
  final bool selected;

  VerifyCard({required this.thing, required this.selected});

  Card createState() => Card();
}

class Card extends State<VerifyCard> {
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    if (widget.selected) {
      return ListTile(
        title: Text(
          widget.thing.eventName!,
          style: theme.textTheme.headline6,
        ),
        enabled: true,
        leading: NullableCircleAvatar(
          widget.thing.eventImageURL ??
              widget.thing.eventBodies![0].bodyImageURL!,
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
  final Body? thing;
  final bool selected;

  BodyCard({required this.thing, required this.selected});

  BodyCardState createState() => BodyCardState();
}

class BodyCardState extends State<BodyCard> {
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    if (widget.selected) {
      return ListTile(
        title: Text(
          widget.thing?.bodyName ?? "",
          style: theme.textTheme.headline6,
        ),
        enabled: true,
        leading: NullableCircleAvatar(
          widget.thing?.bodyImageURL ?? widget.thing?.bodyImageURL ?? "",
          Icons.event_outlined,
          heroTag: widget.thing?.bodyID,
        ),
        subtitle: Text(widget.thing?.bodyShortDescription ?? ""),
      );
    } else {
      return SizedBox(height: 10);
    }
  }
}

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  late Barcode result;
  bool processing = false;
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (Platform.isAndroid) {
  //     controller!.pauseCamera();
  //   }
  //   controller!.resumeCamera();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var bloc = BlocProvider.of(context)?.bloc;

    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;

    void getOfferedAchievements(String url) async {
      if (url.contains("https://www.insti.app/achievement-new/")) {
        var uri = url.substring(url.lastIndexOf("/") + 1);

        var offerid = uri.substring(0, uri.indexOf("s=") - 1);
        var secret = uri.substring(uri.lastIndexOf("s=") + 2);
        // if offerid is null return or scan again
        if (offerid == '' || secret == '') {
          bool? addToCal = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text("Invalid Achievement Code"),
                    actions: <Widget>[
                      TextButton(
                        child: Text("Scan Again"),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          controller.resumeCamera();
                          processing = false;
                        },
                      ),
                      TextButton(
                        child: Text("Return"),
                        onPressed: () {
                          controller.dispose();
                          processing = false;
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ));
          if (addToCal == null) {
            return;
          }
        }
        // check for a secret if offerid exists
        else {
          var achievements = bloc?.achievementBloc;
          SecretResponse? offer =
              await achievements?.postAchievementOffer(offerid, secret);
          log(offer?.message ?? "");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(offer?.message ?? "")),
          );
          controller.dispose();
          processing = false;
          Navigator.of(context).pop();
        }
      } else {
        log('1');
        bool? addToCal = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Invalid Qr Code"),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Scan Again"),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        controller.resumeCamera();
                        processing = false;
                      },
                    ),
                    TextButton(
                      child: Text("Return"),
                      onPressed: () {
                        controller.dispose();
                        processing = false;
                        Navigator.of(context).pop(true);
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ));
        if (addToCal == null) {
          return;
        }
        //processing=true;
      }
    }

    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: (QRViewController controller) {
        setState(() {
          this.controller = controller;
        });
        controller.scannedDataStream.listen((scanData) {
          setState(() {
            result = scanData;
            log(result.code!);
            if (!processing) {
              getOfferedAchievements(result.code!);
              processing = true;
              controller.pauseCamera();
            }
          });
        });
      },
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// ignore: unused_element
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSize child;

  _SliverTabBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => child.preferredSize.height;

  @override
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
