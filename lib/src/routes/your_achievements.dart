import 'dart:collection';

import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/verify_ach.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';

class YourAchievementPage extends StatefulWidget {
  const YourAchievementPage({Key? key}) : super(key: key);

  @override
  _YourAchievementPageState createState() => _YourAchievementPageState();
}

class _YourAchievementPageState extends State<YourAchievementPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool firstBuild = true;
  bool perToVerify = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    if (firstBuild && bloc.currSession != null) {
      bloc.updateAchievements();
      bloc.achievementBloc.getVerifiableBodies();
      firstBuild = false;
    }
    var fab;
    fab = FloatingActionButton.extended(
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
                _scaffoldKey.currentState?.openDrawer();
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
                onRefresh: () {
                  bloc.achievementBloc.getVerifiableBodies();
                  return bloc.updateAchievements();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomScrollView(
                    slivers: [
                      StreamBuilder(
                        stream: bloc.achievementBloc.verifiableBodies,
                        builder: (context,
                            AsyncSnapshot<UnmodifiableListView<Body>>
                                snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.length > 0) {
                              return SliverToBoxAdapter(
                                child: TitleWithBackButton(
                                  child: Text(
                                    "Verify",
                                    style: theme.textTheme.headline4,
                                  ),
                                ),
                              );
                            } else {
                              return SliverToBoxAdapter(
                                child: Center(),
                              );
                            }
                          } else {
                            return SliverToBoxAdapter(
                              child: Center(),
                            );
                          }
                        },
                      ),
                      StreamBuilder(
                        stream: bloc.achievementBloc.verifiableBodies,
                        builder: (context,
                            AsyncSnapshot<UnmodifiableListView<Body>>
                                snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.length > 0) {
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) =>
                                      BodyCard(thing: snapshot.data![index]),
                                  childCount: snapshot.data!.length,
                                ),
                              );
                            } else {
                              return SliverToBoxAdapter(
                                child: Center(),
                              );
                            }
                          } else {
                            return SliverToBoxAdapter(
                              child: Center(),
                            );
                          }
                        },
                      ),
                      SliverToBoxAdapter(
                        child: TitleWithBackButton(
                          child: Text(
                            "Your Acheivements",
                            style: theme.textTheme.headline4,
                          ),
                        ),
                      ),
                      StreamBuilder(
                        stream: bloc.achievements,
                        builder: (context,
                            AsyncSnapshot<UnmodifiableListView<Achievement>>
                                snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.length > 0) {
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                    (context, index) => AchListItem(
                                        achievement: snapshot.data![index]),
                                    childCount: snapshot.data!.length),
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
                                      'No achievments yet',
                                      style: TextStyle(
                                          fontSize: 25.0,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w300),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text('Let${"'"}s change that!!',
                                        style: TextStyle(
                                            fontSize: 25.0,
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w300))
                                  ],
                                ),
                              ));
                            }
                          } else {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: CircularProgressIndicatorExtended(
                                  label: Text("Getting your Achievements"),
                                ),
                              ),
                            );
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: bloc.currSession == null ? null : fab,
      floatingActionButtonLocation: bloc.currSession == null
          ? null
          : FloatingActionButtonLocation.endDocked,
    );
  }
}

class AchListItem extends StatefulWidget {
  final String title;
  final String company;
  final String icon;
  final String forText;
  final String importance;
  final bool isVerified;
  final bool isHidden;
  final bool isDismissed;
  final Achievement achievement;

  AchListItem({
    Key? key,
    required this.achievement,
  })  : this.title = achievement.title ?? "",
        this.company = achievement.body?.bodyName ?? "",
        this.icon = achievement.body?.bodyImageURL ?? "",
        this.forText = (achievement.event != null
            ? achievement.event!.eventName
            : "No event name specified")!,
        this.importance = achievement.description ?? "",
        this.isVerified = achievement.verified ?? false,
        this.isDismissed = achievement.dismissed ?? false,
        this.isHidden = achievement.hidden ?? false,
        super(key: key);

  @override
  _AchListItemState createState() => _AchListItemState();
}

class _AchListItemState extends State<AchListItem> {
  bool isSwitchOn = false;

  @override
  void initState() {
    // print(widget.company);
    isSwitchOn = widget.isHidden;
    super.initState();
  }

  void toggleSwitch(bool value) {
    if (isSwitchOn) {
      setState(() {
        isSwitchOn = false;
      });
    } else {
      setState(() {
        isSwitchOn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context)!.bloc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefListItem(
          title: widget.title,
          company: widget.company,
          icon: widget.icon,
          forText: widget.forText,
          importance: widget.importance,
          isVerified: widget.isVerified,
          isDismissed: widget.isDismissed,
        ),
        Row(
          children: [
            Switch(
              value: isSwitchOn,
              onChanged: (bool value) {
                toggleSwitch(value);
                bloc.updateHiddenAchievement(widget.achievement, value);
              },
              activeColor: Colors.yellow,
              activeTrackColor: Colors.yellow[200],
              inactiveThumbColor: Colors.grey[600],
              inactiveTrackColor: Colors.grey[400],
            ),
            Text("Hidden"),
          ],
        ),
        Divider(
          color: Colors.grey[600],
        ),
      ],
    );
  }
}

class BodyCard extends StatefulWidget {
  final Body? thing;

  BodyCard({this.thing});

  BodyCardState createState() => BodyCardState();
}

class BodyCardState extends State<BodyCard> {
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return ListTile(
      title: Text(
        widget.thing?.bodyName ?? "",
        style: theme.textTheme.headline6,
      ),
      enabled: true,
      leading: NullableCircleAvatar(
        widget.thing?.bodyImageURL ?? widget.thing?.bodyImageURL ?? "",
        Icons.event_outlined,
        heroTag: widget.thing?.bodyID ?? "",
      ),
      subtitle: Text(widget.thing?.bodyShortDescription ?? ""),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VerifyAchPage(
                      bodyId: widget.thing?.bodyID,
                    )));
      },
    );
  }
}
