import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:markdown/markdown.dart' as markdown;

class BodyPage extends StatefulWidget {
  final Future<Body> _bodyFuture;

  BodyPage(this._bodyFuture);

  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Body body;

  bool loadingFollow = false;

  bool _bottomSheetActive = false;

  @override
  void initState() {
    super.initState();
    body = null;
    widget._bodyFuture.then((b) {
      var tableParse = markdown.TableSyntax();
      b.bodyDescription = markdown.markdownToHtml(
          b.bodyDescription
              .split('\n')
              .map((s) => s.trimRight())
              .toList()
              .join('\n'),
          blockSyntaxes: [tableParse]);
      setState(() {
        body = b;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;
    var footerButtons = <Widget>[];
    if (body != null) {
      footerButtons.addAll([
        _buildFollowBody(theme, bloc),
      ]);

      if ((body.bodyWebsiteURL ?? "") != "") {
        footerButtons.add(IconButton(
          tooltip: "Open website",
          icon: Icon(OMIcons.language),
          onPressed: () async {
            if (await canLaunch(body.bodyWebsiteURL)) {
              await launch(body.bodyWebsiteURL);
            }
          },
        ));
      }
    }
    return Scaffold(
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
              onPressed: _bottomSheetActive
                  ? null
                  : () {
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
      body: Container(
        foregroundDecoration: _bottomSheetActive
            ? BoxDecoration(
                color: Color.fromRGBO(100, 100, 100, 12),
              )
            : null,
        child: body == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          body.bodyName,
                          style: theme.textTheme.display2.copyWith(
                              color: Colors.black, fontFamily: "Bitter"),
                        ),
                        SizedBox(height: 8.0),
                        Text(body.bodyShortDescription,
                            style: theme.textTheme.title),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Image.network(body.bodyImageURL, fit: BoxFit.fitWidth),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28.0, vertical: 16.0),
                    child: CommonHtml(
                      data: body.bodyDescription,
                      defaultTextStyle: theme.textTheme.subhead,
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Divider(),
                ] // Events
                  ..addAll(_nonEmptyListWithHeaderOrEmpty(
                      body.bodyEvents
                          .map((e) => _buildEventTile(e, theme))
                          .toList(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28.0, vertical: 16.0),
                        child: Text(
                          "Events",
                          style: theme.textTheme.headline,
                        ),
                      )))
                  // Children
                  ..addAll(_nonEmptyListWithHeaderOrEmpty(
                      body.bodyChildren
                          .map((b) => _buildBodyTile(b, theme.textTheme))
                          .toList(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28.0, vertical: 16.0),
                        child: Text(
                          "Organizations",
                          style: theme.textTheme.headline,
                        ),
                      )))
                  // People
                  ..addAll(_nonEmptyListWithHeaderOrEmpty(
                      body.bodyRoles
                          .expand((r) {
                            if (r.roleUsersDetail != null) {
                              return r.roleUsersDetail
                                  .map((u) => u..currentRole = r.roleName)
                                  .toList();
                            }
                          })
                          .map((u) => _buildUserTile(u, theme))
                          .toList(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28.0, vertical: 16.0),
                        child: Text(
                          "People",
                          style: theme.textTheme.headline,
                        ),
                      )))
                  // Parents
                  ..addAll(_nonEmptyListWithHeaderOrEmpty(
                      body.bodyParents
                          .map((b) => _buildBodyTile(b, theme.textTheme))
                          .toList(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28.0, vertical: 16.0),
                        child: Text(
                          "Part of",
                          style: theme.textTheme.headline,
                        ),
                      )))
                  ..addAll([
                    Divider(),
                    SizedBox(
                      height: 64.0,
                    )
                  ]),
              ),
      ),
      floatingActionButton: _bottomSheetActive || body == null
          ? null
          : FloatingActionButton(
              child: Icon(OMIcons.share),
              tooltip: "Share this body",
              onPressed: () async {
                await Share.share(
                    "Check this Institute Body: ${ShareURLMaker.getBodyURL(body)}");
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      persistentFooterButtons: footerButtons,
    );
  }

  List<Widget> _nonEmptyListWithHeaderOrEmpty(
      List<Widget> list, Widget header) {
    return list.isNotEmpty ? (list..insert(0, header)) : <Widget>[];
  }

  RaisedButton _buildFollowBody(ThemeData theme, InstiAppBloc bloc) {
    return RaisedButton(
      color: body.bodyUserFollows ? theme.accentColor : Colors.white,
      textColor: body.bodyUserFollows ? Colors.white : null,
      shape: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.accentColor,
          ),
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Row(children: () {
        var rowChildren = <Widget>[
          Text(body.bodyUserFollows ? "Following" : "Follow"),
          SizedBox(
            width: 8.0,
          ),
          Text("${body.bodyFollowersCount}"),
        ];
        if (loadingFollow) {
          rowChildren.insertAll(0, [
            SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      body.bodyUserFollows ? Colors.white : theme.accentColor),
                  strokeWidth: 2,
                )),
            SizedBox(
              width: 8.0,
            )
          ]);
        }
        return rowChildren;
      }()),
      onPressed: () async {
        if (bloc.currSession == null) {
          return;
        }
        setState(() {
          loadingFollow = true;
        });
        await bloc.updateFollowBody(body);
        setState(() {
          loadingFollow = false;
          // event has changes
        });
      },
    );
  }

  Widget _buildBodyTile(Body body, TextTheme theme) {
    return ListTile(
      title: Text(body.bodyName, style: theme.title),
      subtitle: Text(body.bodyShortDescription, style: theme.subtitle),
      leading: NullableCircleAvatar(body.bodyImageURL, OMIcons.peopleOutline),
      onTap: () {
        Navigator.of(context).pushNamed("/body/${body.bodyID}");
      },
    );
  }

  Widget _buildEventTile(Event event, ThemeData theme) {
    return ListTile(
      title: Text(
        event.eventName,
        style: theme.textTheme.title,
      ),
      enabled: true,
      leading: NullableCircleAvatar(
          event.eventImageURL ?? event.eventBodies[0].bodyImageURL,
          OMIcons.event),
      subtitle: Text(event.getSubTitle()),
      onTap: () {
        _openEventPage(event);
      },
    );
  }

  Widget _buildUserTile(User u, ThemeData theme) {
    return ListTile(
      leading:
          NullableCircleAvatar(u.userProfilePictureUrl, OMIcons.personOutline),
      title: Text(
        u.userName,
        style: theme.textTheme.title,
      ),
      subtitle: Text(u.getSubTitle()),
      onTap: () {
        _openUserPage(u);
      },
    );
  }

  void _openUserPage(User user) {
    Navigator.of(context).pushNamed("/user/${user.userID}");
  }

  void _openEventPage(Event event) {
    Navigator.of(context).pushNamed("/event/${event.eventID}");
  }
}
