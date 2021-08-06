import 'dart:collection';

import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({Key key}) : super(key: key);

  @override
  _AchievementPageState createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;
    if (firstBuild && bloc.currSession != null) {
      bloc.getVerifiableBodies();
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
          onRefresh: () => bloc.updateAchievements(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: TitleWithBackButton(
                    child: Text(
                      "Verify",
                      style: theme.textTheme.headline4,
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: bloc.verifiableBodies,
                  builder: (context,
                      AsyncSnapshot<UnmodifiableListView<Body>>
                      snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length > 0) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                                  (context, index) => body_card(
                                  thing: snapshot.data[index]),
                              childCount: snapshot.data.length),
                        );
                      } else {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Text("No Achievements"),
                          ),
                        );
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
    );
  }
}



class body_card extends StatefulWidget {
  final Body thing;

  body_card({this.thing});

  bodycard createState() => bodycard();
}

class bodycard extends State<body_card> {
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);
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

  }
}

