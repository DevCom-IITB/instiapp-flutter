import 'dart:math';

import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/api/model/notification.dart' as ntf;

class NotificationsPage extends StatefulWidget {
  final String title = "Notifications";

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool clearAllLoading = false;
  bool shouldMarkAsRead = true;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;

    bloc.updateNotifications();

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
        child: StreamBuilder<UnmodifiableListView<ntf.Notification>>(
          stream: bloc.notifications,
          builder: (BuildContext context,
              AsyncSnapshot<UnmodifiableListView<ntf.Notification>> snapshot) {
            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () {
                return bloc.updateNotifications();
              },
              child: ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                      TitleWithBackButton(
                        child: Text(
                          widget.title,
                          style: theme.textTheme.headline3,
                        ),
                      )
                    ] +
                    _buildContent(snapshot, theme, bloc),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton.extended(
        tooltip: "Clear all notifications",
        onPressed: () async {
          setState(() {
            clearAllLoading = true;
          });
          await bloc.clearAllNotifications();
          setState(() {
            clearAllLoading = false;
          });
        },
        icon: clearAllLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary),
                ),
              )
            : Icon(Icons.clear_all_outlined),
        label: Text("Clear All"),
      ),
    );
  }

  List<Widget> _buildContent(
      AsyncSnapshot<UnmodifiableListView<ntf.Notification>> snapshot,
      ThemeData theme,
      InstiAppBloc bloc) {
    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
      return snapshot.data!
          .map((n) => _buildNotificationTile(theme, bloc, n))
          .toList();
    } else {
      return [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
          child:
              Text.rich(TextSpan(style: theme.textTheme.headline6, children: [
            TextSpan(text: "No new "),
            TextSpan(
                text: "notifications",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: "."),
          ])),
        )
      ];
    }
  }

  Widget _buildNotificationTile(
      ThemeData theme, InstiAppBloc bloc, ntf.Notification notification) {
    return Dismissible(
      key: Key("${notification.notificationId}" +
          Random().nextInt(10000).toString()),
      background: Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.delete_outlined, color: Colors.white),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.delete_outlined, color: Colors.white),
            ),
          ],
        ),
      ),
      onDismissed: (direction) async {
        await ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
              content: Text("Marked \"${notification.getTitle()}\" as read "),
              action: SnackBarAction(
                label: "Undo",
                onPressed: () {
                  shouldMarkAsRead = false;
                },
              ),
            ))
            .closed;
        if (shouldMarkAsRead) {
          await bloc.clearNotification(notification);
        }
        shouldMarkAsRead = true;
        setState(() {});
      },
      child: ListTile(
        title: Text(notification.getTitle() ?? ""),
        subtitle: Text(notification.getSubtitle() ?? ""),
        leading: NullableCircleAvatar(
          notification.getAvatarUrl() ?? "",
          Icons.notifications_outlined,
          heroTag: notification.getID() ?? "",
        ),
        onTap: () {
          if (notification.isBlogPost) {
            Navigator.of(context).pushNamed(
                (notification.getBlogPost().link?.contains("training") ?? false)
                    ? "/trainblog"
                    : "/placeblog");
          } else if (notification.isEvent) {
            EventPage.navigateWith(context, bloc, notification.getEvent());
          } else if (notification.isNews) {
            Navigator.of(context).pushNamed("/news");
          } else if (notification.isComplaintComment) {
            Navigator.of(context).pushNamed(
                "/complaint/${notification.getComment().complaintID}?reload=true");
          }

          bloc.client.markNotificationRead(
              bloc.getSessionIdHeader(), "${notification.notificationId}");
        },
      ),
    );
  }
}
