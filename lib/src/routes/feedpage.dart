import 'dart:collection';

import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _bottomSheetActive = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;

    bloc.updateEvents();

    var footerButtons = null;

    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              tooltip: "Show bottom sheet",
              icon: Icon(
                OMIcons.menu,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: _bottomSheetActive
                  ? null
                  : () {
                      setState(() {
                        //disable button
                        _bottomSheetActive = true;
                      });
                      _scaffoldKey.currentState
                          .showBottomSheet((context) {
                            BottomDrawer.setPageIndex(bloc, 0);
                            return BottomDrawer();
                          })
                          .closed
                          .whenComplete(() {
                            setState(() {
                              _bottomSheetActive = false;
                            });
                          });
                    },
            ),
          ],
        ),
      ),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        foregroundDecoration: _bottomSheetActive
            ? BoxDecoration(
                color: Color.fromRGBO(100, 100, 100, 12),
              )
            : null,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => bloc.updateEvents(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Feed",
                          style: theme.textTheme.display2.copyWith(
                              color: Colors.black, fontFamily: "Bitter"),
                        ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: bloc.events,
                  builder: (context,
                      AsyncSnapshot<UnmodifiableListView<Event>> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length > 0) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _buildEvent(snapshot.data[index]),
                              childCount: snapshot.data.length),
                        );
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
                          child: CircularProgressIndicator(),
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
      persistentFooterButtons: footerButtons,
    );
  }

  Widget _buildEvent(Event event) {
    var theme = Theme.of(context);

    if (event.eventBigImage ?? false) {
      return InkWell(
        onTap: () {
          _openEventPage(event);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Ink.image(
              child: Container(),
              image: NetworkImage(
                event.eventImageURL ?? event.eventBodies[0].bodyImageURL,
              ),
              height: 200,
              fit: BoxFit.cover,
            ),
            ListTile(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              title: Text(
                event.eventName,
                style: theme.textTheme.title,
              ),
              enabled: true,
              subtitle: Text(event.getSubTitle()),
            )
          ],
        ),
      );
    } else {
      return ListTile(
        title: Text(
          event.eventName,
          style: theme.textTheme.title,
        ),
        contentPadding: EdgeInsets.all(8.0),
        enabled: true,
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              event.eventImageURL ?? event.eventBodies[0].bodyImageURL),
        ),
        subtitle: Text(event.getSubTitle()),
        onTap: () {
          _openEventPage(event);
        },
      );
    }
  }

  _openEventPage(Event event) {
    Navigator.of(context).pushNamed("/event/${event.eventID}");
  }
}
