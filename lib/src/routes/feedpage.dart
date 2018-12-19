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

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;

    bloc.updateEvents();

    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerOnly(),
      body: RefreshIndicator(
        onRefresh: () => bloc.updateEvents(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon: Icon(
                  OMIcons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ImageIcon(
                      AssetImage('assets/lotus.png'),
                      color: Colors.white,
                    ),
                  ),
                  Text("Feed",
                      style: theme.textTheme.headline
                          .copyWith(fontFamily: "Bitter", color: Colors.white)),
                ],
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
                          (context, index) => _buildEvent(snapshot.data[index]),
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
                event.eventImageURL ?? event.eventBodies[0].imageUrl,
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
              event.eventImageURL ?? event.eventBodies[0].imageUrl),
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
