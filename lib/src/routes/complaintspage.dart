import 'dart:collection';

import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/datetime.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class ComplaintsPage extends StatefulWidget {
  final String title = "Complaints/Suggestions";
  @override
  _ComplaintsPageState createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);
    var complaintsBloc = bloc.complaintsBloc;
    var footerButtons = <Widget>[];

    complaintsBloc.updateAllComplaints();
    complaintsBloc.updateMyComplaints();

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: BottomDrawer(),
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
                onPressed: () {
                  BottomDrawer.setPageIndex(bloc, 8);
                  _scaffoldKey.currentState.openDrawer();
                  // setState(() {
                  //   //disable button
                  //   _bottomSheetActive = true;
                  // });
                  // _scaffoldKey.currentState
                  //     .showBottomSheet((context) {
                  //       return BottomDrawer();
                  //     })
                  //     .closed
                  //     .whenComplete(() {
                  //       setState(() {
                  //         _bottomSheetActive = false;
                  //       });
                  //     });
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: theme.textTheme.display2.copyWith(
                              color: Colors.black, fontFamily: "Bitter"),
                        ),
                      ],
                    ),
                  ),
                ),
                // SliverToBoxAdapter(
                //   child: StreamBuilder(
                //       stream: bloc.session,
                //       builder: (BuildContext context,
                //           AsyncSnapshot<Session> snapshot) {
                //         return (snapshot.hasData && snapshot.data != null)
                //             ? Container(
                //                 padding: EdgeInsets.fromLTRB(28, 0, 28, 28),
                //                 child: RaisedButton(
                //                   onPressed: () {},
                //                   padding: EdgeInsets.symmetric(vertical: 8.0),
                //                   color: theme.accentColor,
                //                   child: Text("Vent your issue",
                //                       style: theme.accentTextTheme.title),
                //                 ),
                //               )
                //             : Container(
                //                 width: 0,
                //                 height: 0,
                //               );
                //       }),
                // ),
                StreamBuilder(
                  stream: bloc.session,
                  builder:
                      (BuildContext context, AsyncSnapshot<Session> snapshot) {
                    return (snapshot.hasData && snapshot.data != null)
                        ? SliverPersistentHeader(
                            floating: true,
                            pinned: true,
                            delegate: _SliverTabBarDelegate(
                              child: PreferredSize(
                                preferredSize: Size.fromHeight(72),
                                child: Material(
                                  // color: Colors.white,
                                  elevation: 4.0,
                                  child: TabBar(
                                    labelColor: theme.accentColor,
                                    unselectedLabelColor: Colors.black,
                                    tabs: [
                                      Tab(
                                          text: "Home",
                                          icon: Icon(OMIcons.home)),
                                      Tab(
                                          text: "Me",
                                          icon: Icon(OMIcons.personOutline)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SliverToBoxAdapter(
                            child: Container(
                            width: 0,
                            height: 0,
                          ));
                  },
                ),
              ];
            },
            body: StreamBuilder(
              stream: bloc.session,
              builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
                return (snapshot.hasData && snapshot.data != null)
                    ? TabBarView(
                        // These are the contents of the tab views, below the tabs.
                        children: ["Home", "Me"].map((name) {
                          return SafeArea(
                            top: false,
                            bottom: false,
                            child: Builder(
                              // This Builder is needed to provide a BuildContext that is "inside"
                              // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
                              // find the NestedScrollView.
                              builder: (BuildContext context) {
                                var lists = {
                                  "Home": StreamBuilder(
                                    stream: complaintsBloc.allComplaints,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<
                                                UnmodifiableListView<Complaint>>
                                            snapshot) {
                                      return snapshot.hasData &&
                                              snapshot.data.isEmpty
                                          ? SliverToBoxAdapter(
                                              child: Center(
                                                child: Text(
                                                    "No more complaints",
                                                    style: theme.textTheme.title
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                              ),
                                            )
                                          : SliverList(
                                              delegate:
                                                  SliverChildBuilderDelegate(
                                              (BuildContext context,
                                                  int index) {
                                                return snapshot.hasData
                                                    ? _buildComplaint(
                                                        snapshot.data[index],
                                                        theme)
                                                    : Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                              },
                                              childCount: snapshot.hasData
                                                  ? snapshot.data.length
                                                  : 1,
                                            ));
                                    },
                                  ),
                                  "Me": StreamBuilder(
                                    stream: complaintsBloc.myComplaints,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<
                                                UnmodifiableListView<Complaint>>
                                            snapshot) {
                                      return snapshot.hasData &&
                                              snapshot.data.isEmpty
                                          ? SliverToBoxAdapter(
                                              child: Center(
                                                child: Text(
                                                    "No more complaints",
                                                    style: theme.textTheme.title
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                              ),
                                            )
                                          : SliverList(
                                              delegate:
                                                  SliverChildBuilderDelegate(
                                              (BuildContext context,
                                                  int index) {
                                                return snapshot.hasData
                                                    ? _buildComplaint(
                                                        snapshot.data[index],
                                                        theme)
                                                    : Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                              },
                                              childCount: snapshot.hasData
                                                  ? snapshot.data.length
                                                  : 1,
                                            ));
                                    },
                                  ),
                                };
                                return CustomScrollView(
                                  key: PageStorageKey<String>(name),
                                  slivers: <Widget>[
                                    SliverPadding(
                                      padding: const EdgeInsets.all(8.0),
                                      sliver: lists[name],
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        }).toList(),
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Text(
                            "You need to be logged in to view and complaint",
                            style: theme.textTheme.headline,
                          ),
                        ),
                      );
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Text("Vent"),
          icon: Icon(OMIcons.feedback),
          onPressed: () {},
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }

  Widget _buildComplaint(Complaint complaint, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.of(context)
                .pushNamed("/complaint/${complaint.complaintID}");
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(complaint.complaintCreatedBy.userName,
                              style: theme.textTheme.title
                                  .copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            DateTimeUtil.getDate(complaint.complaintReportDate),
                            style:
                                theme.textTheme.caption.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                      OutlineButton(
                        borderSide: BorderSide(
                            color: complaint.status == "Reported"
                                ? Colors.red
                                : complaint.status == "In Progress"
                                    ? Colors.yellow
                                    : Colors.green),
                        padding: EdgeInsets.all(0),
                        child: Text(
                          complaint.status,
                          style: theme.textTheme.subhead,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Text(
                  complaint.locationDescription,
                  style: theme.textTheme.caption.copyWith(fontSize: 14),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(complaint.description, style: theme.textTheme.subtitle),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            side: BorderSide(color: theme.accentColor))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                OMIcons.comment,
                                color: Colors.blueGrey,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                  "${complaint.comment.isEmpty ? "No" : complaint.comment.length} comment${complaint.comment.length == 1 ? "" : "s"}",
                                  style: theme.textTheme.caption),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(OMIcons.arrowUpward, color: Colors.blueGrey),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                  "${complaint.usersUpVoted.isEmpty ? "No" : complaint.usersUpVoted.length} upvote${complaint.usersUpVoted.length == 1 ? "" : "s"}",
                                  style: theme.textTheme.caption),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSize child;

  _SliverTabBarDelegate({this.child});

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
