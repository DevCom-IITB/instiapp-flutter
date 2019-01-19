import 'dart:collection';

import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;

    bloc.updateEvents();

    var fab = null;

    if (bloc.currSession?.profile?.userRoles?.isNotEmpty ?? false) {
      // fab = FloatingActionButton(child: Icon(OMIcons.add), onPressed: () {},);
      fab = FloatingActionButton.extended(
        icon: Icon(OMIcons.add),
        label: Text("Add Event"),
        onPressed: () {
          Navigator.of(context).pushNamed("/putentity/event");
        },
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: BottomDrawer(),
      bottomNavigationBar: MyBottomAppBar(
        shape: RoundedNotchedRectangle(),
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
              onPressed: () {
                BottomDrawer.setPageIndex(bloc, 0);
                _scaffoldKey.currentState.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
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
                        style: theme.textTheme.display2,
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
                                _buildEvent(theme, bloc, snapshot.data[index]),
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
                        child: CircularProgressIndicatorExtended(
                          label: Text("Getting the latest events"),
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
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildEvent(ThemeData theme, InstiAppBloc bloc, Event event) {
    if (event.eventBigImage ?? false) {
      return InkWell(
        onTap: () {
          _openEventPage(bloc, event);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: event.eventID,
              child: Material(
                type: MaterialType.transparency,
                child: Ink.image(
                  child: Container(),
                  image: NetworkImage(
                    event.eventImageURL ?? event.eventBodies[0].bodyImageURL,
                  ),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
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
        enabled: true,
        leading: NullableCircleAvatar(
          event.eventImageURL ?? event.eventBodies[0].bodyImageURL,
          OMIcons.event,
          heroTag: event.eventID,
        ),
        subtitle: Text(event.getSubTitle()),
        onTap: () {
          _openEventPage(bloc, event);
        },
      );
    }
  }

  _openEventPage(InstiAppBloc bloc, Event event) {
    EventPage.navigateWith(context, bloc, event);
  }
}
