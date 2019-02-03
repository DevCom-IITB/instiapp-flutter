import 'dart:collection';

import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/complaintpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
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
  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);
    var complaintsBloc = bloc.complaintsBloc;

    if (firstBuild) {
      complaintsBloc.updateAllComplaints();
      complaintsBloc.updateMyComplaints();
      firstBuild = false;
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
       // drawer: NavDrawer(),
        bottomNavigationBar: MyBottomAppBar(
          shape: RoundedNotchedRectangle(),
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
                  _scaffoldKey.currentState.openDrawer();
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
                          style: theme.textTheme.display2,
                        ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: bloc.session,
                  builder:
                      (BuildContext context, AsyncSnapshot<Session> snapshot) {
                    return (snapshot.hasData && snapshot.data != null)
                        ? SliverPersistentHeader(
                            floating: true,
                            pinned: true,
                            delegate: SliverHeaderDelegate(
                              child: PreferredSize(
                                preferredSize: Size.fromHeight(72),
                                child: Material(
                                  elevation: 4.0,
                                  child: TabBar(
                                    labelColor: theme.accentColor,
                                    unselectedLabelColor: theme.disabledColor,
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
                          return RefreshIndicator(
                            onRefresh: () => name == "Home"
                                ? complaintsBloc.updateAllComplaints()
                                : complaintsBloc.updateMyComplaints(),
                            child: SafeArea(
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
                                                  UnmodifiableListView<
                                                      Complaint>>
                                              snapshot) {
                                        return snapshot.hasData &&
                                                snapshot.data.isEmpty
                                            ? SliverToBoxAdapter(
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Text("No complaints",
                                                        style: theme
                                                            .textTheme.title
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                  ),
                                                ),
                                              )
                                            : SliverList(
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                (BuildContext context,
                                                    int index) {
                                                  return snapshot.hasData
                                                      ? _buildComplaint(
                                                          bloc,
                                                          theme,
                                                          snapshot.data[index])
                                                      : Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16.0),
                                                            child:
                                                                CircularProgressIndicatorExtended(
                                                              label: Text(
                                                                  "Fetching all complaints"),
                                                            ),
                                                          ),
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
                                                  UnmodifiableListView<
                                                      Complaint>>
                                              snapshot) {
                                        return snapshot.hasData &&
                                                snapshot.data.isEmpty
                                            ? SliverToBoxAdapter(
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Text("No complaints",
                                                        style: theme
                                                            .textTheme.title
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                  ),
                                                ),
                                              )
                                            : SliverList(
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                (BuildContext context,
                                                    int index) {
                                                  return snapshot.hasData
                                                      ? _buildComplaint(
                                                          bloc,
                                                          theme,
                                                          snapshot.data[index])
                                                      : Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16.0),
                                                            child:
                                                                CircularProgressIndicatorExtended(
                                                              label: Text(
                                                                  "Fetching complaints made by you"),
                                                            ),
                                                          ),
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
        floatingActionButton: StreamBuilder(
          stream: bloc.session,
          builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
            return snapshot.hasData && snapshot.data != null
                ? FloatingActionButton.extended(
                    label: Text("New Complaint"),
                    icon: Icon(OMIcons.feedback),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/newcomplaint");
                    },
                  )
                : Container(
                    width: 0,
                    height: 0,
                  );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }

  Widget _buildComplaint(
      InstiAppBloc bloc, ThemeData theme, Complaint complaint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        child: InkWell(
          onTap: () {
            ComplaintPage.navigateWith(context, bloc, complaint);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Hero(
                    tag: complaint.complaintID,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(complaint.complaintCreatedBy.userName,
                                  style: theme.textTheme.title
                                      .copyWith(fontWeight: FontWeight.bold)),
                              Text(
                                DateTimeUtil.getDate(
                                    complaint.complaintReportDate),
                                style: theme.textTheme.caption
                                    .copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        OutlineButton(
                          borderSide: BorderSide(
                              color: complaint.status.toLowerCase() ==
                                      "Reported".toLowerCase()
                                  ? Colors.red
                                  : complaint.status.toLowerCase() ==
                                          "In Progress".toLowerCase()
                                      ? Colors.yellow
                                      : Colors.green),
                          padding: EdgeInsets.all(0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                capitalize(complaint.status),
                                style: theme.textTheme.subhead,
                              ),
                            ]..insertAll(
                                0,
                                complaint.tags.isNotEmpty
                                    ? [
                                        Container(
                                          color: theme.accentColor,
                                          width: 4,
                                          height: 4,
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                      ]
                                    : []),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  complaint.locationDescription,
                  style: theme.textTheme.caption.copyWith(fontSize: 14),
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    complaint.suggestions.isNotEmpty ||
                            complaint.suggestions.isNotEmpty
                        ? Text(
                            "Description: ",
                            style: theme.textTheme.subhead,
                          )
                        : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        complaint.description,
                        style: theme.textTheme.subhead,
                      ),
                    ),
                  ]
                    ..addAll(complaint.suggestions.isNotEmpty
                        ? [
                            Text(
                              "Suggestions: ",
                              style: theme.textTheme.subhead,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                complaint.suggestions,
                                style: theme.textTheme.subhead,
                              ),
                            ),
                          ]
                        : [])
                    ..addAll(complaint.locationDetails.isNotEmpty
                        ? [
                            Text(
                              "Location Details: ",
                              style: theme.textTheme.subhead,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                complaint.locationDetails,
                                style: theme.textTheme.subhead,
                              ),
                            ),
                          ]
                        : []),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            OMIcons.comment,
                            color: theme.accentColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                              "${complaint.comments.isEmpty ? "No" : complaint.comments.length} comment${complaint.comments.length == 1 ? "" : "s"}",
                              style: theme.textTheme.caption),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            OMIcons.arrowUpward,
                            color: theme.accentColor,
                          ),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
