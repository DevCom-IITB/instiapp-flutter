import 'dart:collection';

import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ach_to_vefiry_bloc.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';

import '../drawer.dart';

class VerifyAchPage extends StatefulWidget {
  final String bodyId;
  const VerifyAchPage({Key key, this.bodyId}) : super(key: key);

  @override
  _VerifyAchPageState createState() => _VerifyAchPageState();
}

class _VerifyAchPageState extends State<VerifyAchPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;
    var verifyBloc = bloc.bodyAchBloc;
    print("Body id:" + widget.bodyId);

    if (bloc.currSession == null) {
      Navigator.pop(context);
    }

    if (firstBuild) {
      verifyBloc.updateAchievements(widget.bodyId);
    }

    var fab = FloatingActionButton.extended(
      icon: Icon(Icons.add_outlined),
      label: Text("Add Acheivement"),
      onPressed: () {
        Navigator.of(context).pushNamed("/achievements/add");
      },
    );

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
        child: RefreshIndicator(
          onRefresh: () {
            return verifyBloc.updateAchievements(widget.bodyId);
          },
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Text(
                    "Verify",
                    style: theme.textTheme.headline3,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 10,
                  ),
                ),
                StreamBuilder(
                  stream: verifyBloc.achievements,
                  builder: (context,
                      AsyncSnapshot<UnmodifiableListView<Achievement>>
                          snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length > 0) {
                        print(snapshot.data);
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              print(index);
                              var data = snapshot.data[index];
                              print("Data " +
                                  index.toString() +
                                  ": " +
                                  data.title.toString());
                              return VerifyListItem(
                                achievement: data,
                              );
                            },
                            childCount: snapshot.data.length,
                          ),
                        );
                      } else {
                        return SliverToBoxAdapter(
                            child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sports_basketball,
                                color: Colors.grey[500],
                                size: 200.0,
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Text(
                                'Nothing to verify here!',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ));
                      }
                    } else {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicatorExtended(
                            label: Text("Getting achievements to verify"),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class VerifyListItem extends StatefulWidget {
  final Achievement achievement;

  const VerifyListItem({Key key, this.achievement}) : super(key: key);

  @override
  _VerifyListItemState createState() => _VerifyListItemState();
}

class _VerifyListItemState extends State<VerifyListItem> {
  bool isVerified = false;
  bool isDismissed = false;

  String verifyText = "Verify";

  void showAlertDialog(BuildContext context, VerifyBloc verifyBloc) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Yes"),
      onPressed: () {
        verifyBloc.deleteAchievement(widget.achievement.id, widget.achievement.body.bodyID);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Are you sure you want to delete achievement forever?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var verifyBloc = BlocProvider.of(context).bloc.bodyAchBloc;
    return Column(
      children: [
        DefListItem(
          title: widget.achievement.title ?? "No title",
          company: widget.achievement.user?.userName ?? "Anonymous",
          forText: widget.achievement.event != null
              ? widget.achievement.event?.eventName
              : null,
          importance: widget.achievement.description!,
          adminNote: widget.achievement.adminNote!,
          isVerified: isVerified,
          isDismissed: isDismissed,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                verifyBloc.dismissAchievement(true, widget.achievement);

                setState(() {
                  isVerified = !isVerified;
                  if (isVerified) {
                    verifyText = "Unverify";
                    isDismissed = false;
                  } else {
                    verifyText = "Verify";
                    isDismissed = true;
                  }
                });
              },
              child: Text(verifyText),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
              ),
            ),
            ElevatedButton(
              onPressed: isVerified || isDismissed
                  ? null
                  : () {
                      verifyBloc.dismissAchievement(false, widget.achievement);
                      setState(() {
                        isDismissed = true;
                      });
                    },
              child: Text(
                "Dismiss",
                style: TextStyle(color: Colors.black),
              ),
              style: ButtonStyle(
                backgroundColor: isVerified || isDismissed
                    ? MaterialStateProperty.all(Colors.grey)
                    : MaterialStateProperty.all(Colors.yellow),
              ),
            ),
            TextButton(
              onPressed: () {
                showAlertDialog(context, verifyBloc);
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
              ),
            ),
          ],
        ),
        Divider(
          color: Colors.grey[600],
        ),
      ],
    );
  }
}
