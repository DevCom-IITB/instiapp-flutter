import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:markdown/markdown.dart' as markdown;

class BodyPage extends StatefulWidget {
  final Body initialBody;
  final Future<Body> bodyFuture;

  BodyPage({this.bodyFuture, this.initialBody});

  static void navigateWith(BuildContext context, InstiAppBloc bloc, Body body) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BodyPage(
              initialBody: body,
              bodyFuture: bloc.getBody(body.bodyID),
            ),
      ),
    );
  }

  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Body body;

  bool loadingFollow = false;

  @override
  void initState() {
    super.initState();
    body = widget.initialBody;
    widget?.bodyFuture?.then((b) {
      var tableParse = markdown.TableSyntax();
      b.bodyDescription = markdown.markdownToHtml(
          b.bodyDescription
              .split('\n')
              .map((s) => s.trimRight())
              .toList()
              .join('\n'),
          blockSyntaxes: [tableParse]);
      if (this.mounted) {
        setState(() {
          body = b;
        });
      } else {
        body = b;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context).bloc;
    var footerButtons = <Widget>[];
    var editAccess = false;
    if (body != null) {
      editAccess = bloc.editBodyAccess(body);
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

      if (editAccess) {
        footerButtons.add(IconButton(
          icon: Icon(OMIcons.share),
          tooltip: "Share this body",
          onPressed: () async {
            await Share.share(
                "Check this Institute Body: ${ShareURLMaker.getBodyURL(body)}");
          },
        ));
      }
    }
    return Scaffold(
      key: _scaffoldKey,
      drawer: BottomDrawer(),
      bottomNavigationBar: MyBottomAppBar(
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
        child: body == null
            ? Center(
                child: CircularProgressIndicatorExtended(
                label: Text("Loading the body page"),
              ))
            : ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          body.bodyName,
                          style: theme.textTheme.display2,
                        ),
                        SizedBox(height: 8.0),
                        Text(body.bodyShortDescription,
                            style: theme.textTheme.title),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PhotoViewableImage(
                      url: body.bodyImageURL,
                      heroTag: body.bodyID,
                      fit: BoxFit.fitWidth,
                    ),
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
                          ?.map((e) => _buildEventTile(bloc, theme, e))
                          ?.toList(),
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
                          ?.map((b) => _buildBodyTile(bloc, theme.textTheme, b))
                          ?.toList(),
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
                          ?.expand((r) {
                            if (r.roleUsersDetail != null) {
                              return r.roleUsersDetail
                                  .map((u) => u..currentRole = r.roleName)
                                  .toList();
                            }
                          })
                          ?.map((u) => _buildUserTile(bloc, theme, u))
                          ?.toList(),
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
                          ?.map((b) => _buildBodyTile(bloc, theme.textTheme, b))
                          ?.toList(),
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
      floatingActionButton: body == null
          ? null
          : editAccess
              ? FloatingActionButton.extended(
                  icon: Icon(OMIcons.edit),
                  label: Text("Edit"),
                  tooltip: "Edit this Body",
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed("/putentity/body/${body.bodyID}");
                  },
                )
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
    return list != null
        ? (list.isNotEmpty ? (list..insert(0, header)) : <Widget>[])
        : [
            CircularProgressIndicatorExtended(
              label: header,
            )
          ];
  }

  RaisedButton _buildFollowBody(ThemeData theme, InstiAppBloc bloc) {
    return RaisedButton(
      color: body.bodyUserFollows ?? false
          ? theme.accentColor
          : theme.scaffoldBackgroundColor,
      textColor:
          body.bodyUserFollows ?? false ? theme.accentIconTheme.color : null,
      shape: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.accentColor,
          ),
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Row(children: () {
        var rowChildren = <Widget>[
          Text(body.bodyUserFollows ?? false ? "Following" : "Follow"),
          SizedBox(
            width: 8.0,
          ),
          body.bodyFollowersCount != null
              ? Text("${body.bodyFollowersCount}")
              : SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        body.bodyUserFollows ?? false
                            ? theme.accentIconTheme.color
                            : theme.accentColor),
                    strokeWidth: 2,
                  )),
        ];
        if (loadingFollow) {
          rowChildren.insertAll(0, [
            SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      body.bodyUserFollows ?? false
                          ? theme.accentIconTheme.color
                          : theme.accentColor),
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

  Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
    return ListTile(
      title: Text(body.bodyName, style: theme.title),
      subtitle: Text(body.bodyShortDescription, style: theme.subtitle),
      leading: NullableCircleAvatar(
        body.bodyImageURL,
        OMIcons.peopleOutline,
        heroTag: body.bodyID,
      ),
      onTap: () {
        BodyPage.navigateWith(context, bloc, body);
      },
    );
  }

  Widget _buildEventTile(InstiAppBloc bloc, ThemeData theme, Event event) {
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
        EventPage.navigateWith(context, bloc, event);
      },
    );
  }

  Widget _buildUserTile(InstiAppBloc bloc, ThemeData theme, User u) {
    return ListTile(
      leading: NullableCircleAvatar(
        u.userProfilePictureUrl,
        OMIcons.personOutline,
        heroTag: u.userID,
      ),
      title: Text(
        u.userName,
        style: theme.textTheme.title,
      ),
      subtitle: Text(u.getSubTitle()),
      onTap: () {
        UserPage.navigateWith(context, bloc, u);
      },
    );
  }
}
