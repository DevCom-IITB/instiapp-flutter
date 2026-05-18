import 'dart:math';

import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
// import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';
// import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:InstiApp/src/api/model/notification.dart' as ntf;

class NotificationsPage extends StatefulWidget {
  final String title = "Notifications";

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

final List<Map<String, dynamic>> filters = [
  {'label': 'All', 'color': Colors.transparent, 'type': 'all'},
  {'label': 'Unread', 'color': Colors.transparent, 'type': 'unread'},
  {'label': 'Events', 'color': Colors.blueAccent, 'type': 'event'},
  {'label': 'Blogs', 'color': Colors.purpleAccent, 'type': 'blog'},
  {'label': 'News', 'color': Colors.orangeAccent, 'type': 'news'},
  {'label': 'Complaints', 'color': Colors.redAccent, 'type': 'complaint'},
];

class _NotificationsPageState extends State<NotificationsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool isPersonalSelected = true;
  bool clearAllLoading = false;
  bool shouldMarkAsRead = true;

  Future<void> _clearAllNotifications() async {
    setState(() => clearAllLoading = true);
    try {
      final bloc = BlocProvider.of(context)!.bloc;
      final list = await bloc.notifications.first; // get current list from stream
      // Clear all notifications in parallel instead of sequentially
      await Future.wait(list.map((n) => bloc.clearNotification(n)));
      await bloc.updateNotifications();
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => clearAllLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;

    bloc.updateNotifications();

    return Scaffold(
      backgroundColor: Color.fromRGBO(246,246,246,1),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          title: SizedBox(
            height: 31,
            child: Container(
              child: Center(
                child: Text(
                  "Notifications",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          backgroundColor: const Color(0xFFF6F6F6),
          centerTitle: true,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12,),
            child: IconButton(
              iconSize: 52,
              padding: EdgeInsets.zero,
              icon: const CircleAvatar(
                backgroundColor: Color(0xCCEBEBEB),
                radius: 25,
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 28,
                ),
              ),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: clearAllLoading
                  ? SizedBox(
                      width: 52,
                      height: 52,
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : IconButton(
                      iconSize: 52,
                      padding: EdgeInsets.zero,
                      icon: const CircleAvatar(
                        backgroundColor: Color(0xCCEBEBEB),
                        radius: 25,
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                      onPressed: () async {
                        await _clearAllNotifications();
                      },
                    ),
            ),
          ],
        ),
      ),
      key: _scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left:16.0, right: 16, bottom: 16.0, top: 4.0),
          child: Column(
            children: [
              // Notification List with StreamBuilder
              Expanded(
                child: StreamBuilder<UnmodifiableListView<ntf.Notification>>(
                  stream: bloc.notifications,
                  builder: (BuildContext context,
                      AsyncSnapshot<UnmodifiableListView<ntf.Notification>>
                          snapshot) {
                    if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/explore/Social.svg',
                              width: 380,
                              height: 190,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No notifications right now',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/explore/Social.svg',
                              width: 380,
                              height: 190,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No notifications right now',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: () {
                        return bloc.updateNotifications();
                      },
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        children: _buildContent(snapshot, theme, bloc),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
      return [];
    }
  }

  Widget _buildNotificationTile(
      ThemeData theme, InstiAppBloc bloc, ntf.Notification notification) {
    return Dismissible(
      key: Key("${notification.notificationId}" +
          Random().nextInt(10000).toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withAlpha((0.15 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 28),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) async {
        await ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
              content: Text("${notification.getTitle()}" +" is deleted"),
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
          await bloc.updateNotifications(); // ensure both views refresh
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
            Navigator.of(context).pushNamed("/placeblog");
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
