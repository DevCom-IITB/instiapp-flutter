import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/api/request/comment_create_request.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/datetime.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintPage extends StatefulWidget {
  final String title = "Complaint";
  final Complaint initialComplaint;
  final Future<Complaint> complaintFuture;

  ComplaintPage({this.complaintFuture, this.initialComplaint});

  static void navigateWith(
      BuildContext context, InstiAppBloc bloc, Complaint complaint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComplaintPage(
              initialComplaint: complaint,
              complaintFuture: bloc.getComplaint(complaint.complaintID),
            ),
      ),
    );
  }

  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  // GlobalKey<GoogleMapState> _mapsKey = GlobalKey();
  LocalKey _mapsKey = Key("GoogleMapKey");
  Complaint complaint;

  FocusNode _commentFocusNode;
  TextEditingController _commentController;
  bool loadingUpvote = false;
  bool loadingComment = false;

  // bool firstBuild = true;

  GoogleMapController _mapController;
  LocationManager.Location _location;

  @override
  void initState() {
    super.initState();
    complaint = widget.initialComplaint;
    widget.complaintFuture.then((c) {
      if (this.mounted) {
        setState(() {
          complaint = c;
        });
      } else {
        complaint = c;
      }
    });
    _commentFocusNode = FocusNode();
    _commentController = TextEditingController();
    _location = LocationManager.Location();
  }

  @override
  void dispose() {
    _commentFocusNode.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);
    var complaintBloc = bloc.complaintsBloc;
    var fab;
    fab = null;

    if (complaint != null) {
      var userVoted = complaint.voteCount == 1;
      fab = FloatingActionButton.extended(
        foregroundColor: userVoted ? theme.accentColor : null,
        backgroundColor: userVoted ? theme.colorScheme.surface : null,
        icon: loadingUpvote
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(userVoted
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onPrimary),
                ),
              )
            : Icon(OMIcons.arrowUpward),
        label: Text(userVoted ? "Upvoted" : "Upvote"),
        onPressed: () async {
          setState(() {
            loadingUpvote = true;
          });
          await complaintBloc.updateUpvote(complaint, 1 - complaint.voteCount);
          setState(() {
            loadingUpvote = false;
          });
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
      // bottomSheet: ,
      body: complaint == null
          ? Center(
              child: CircularProgressIndicatorExtended(
                label: Text("Loading the complaint page"),
              ),
            )
          : ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: theme.textTheme.display2,
                      ),
                      // SizedBox(height: 8.0),
                      // Text(event.getSubTitle(), style: theme.textTheme.title),
                    ],
                  ),
                ),
                complaint.images.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.accentColor),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)),
                          ),
                          height: 200,
                          child: ListView(
                            padding: EdgeInsets.all(8.0),
                            scrollDirection: Axis.horizontal,
                            children: complaint.images.map((im) {
                              // TODO: test images
                              return PhotoViewableImage(
                                NetworkImage(im),
                                "$im",
                                fit: BoxFit.scaleDown,
                              );
                            }).toList(),
                          ),
                        ))
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28),
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(text: "No "),
                            TextSpan(
                                text: "images ",
                                style: theme.textTheme.body1
                                    .copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(text: "uploaded."),
                          ]),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Hero(
                          tag: complaint.complaintID,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(complaint.complaintCreatedBy.userName,
                                      style: theme.textTheme.title.copyWith(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    DateTimeUtil.getDate(
                                        complaint.complaintReportDate),
                                    style: theme.textTheme.caption
                                        .copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                              OutlineButton(
                                borderSide: BorderSide(
                                    color: complaint.status.toLowerCase() ==
                                            "Reported".toLowerCase()
                                        ? Colors.red
                                        : complaint.status.toLowerCase() ==
                                                "In Progress".toLowerCase()
                                            ? Colors.yellow
                                            : Colors.green),
                                padding: EdgeInsets.all(0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      capitalize(complaint.status),
                                      style: theme.textTheme.subhead,
                                    ),
                                  ]..insertAll(
                                      0,
                                      complaint.tags.isNotEmpty
                                          ? [
                                              Container(
                                                color: theme.accentColor,
                                                width: 4,
                                                height: 4,
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                            ]
                                          : []),
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        complaint.locationDescription,
                        style: theme.textTheme.caption.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    complaint.suggestions.isNotEmpty ||
                            complaint.suggestions.isNotEmpty
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 28.0),
                            child: Text(
                              "Description: ",
                              style: theme.textTheme.subhead,
                            ),
                          )
                        : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 28.0, right: 28.0, bottom: 16.0),
                      child: Text(
                        complaint.description,
                        style: theme.textTheme.subhead,
                      ),
                    ),
                  ]
                    ..addAll(complaint.suggestions.isNotEmpty
                        ? [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 28.0),
                              child: Text(
                                "Suggestions: ",
                                style: theme.textTheme.subhead,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 28.0, right: 28.0, bottom: 16.0),
                              child: Text(
                                complaint.suggestions,
                                style: theme.textTheme.subhead,
                              ),
                            ),
                          ]
                        : [])
                    ..addAll(complaint.locationDetails.isNotEmpty
                        ? [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 28.0),
                              child: Text(
                                "Location Details: ",
                                style: theme.textTheme.subhead,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 28.0, right: 28.0, bottom: 16.0),
                              child: Text(
                                complaint.locationDetails,
                                style: theme.textTheme.subhead,
                              ),
                            ),
                          ]
                        : []),
                ),
                SizedBox(
                  height: 16.0,
                ),
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                      Factory<OneSequenceGestureRecognizer>(
                        () => HorizontalDragGestureRecognizer(),
                      ),
                    ].toSet(),
                    onMapCreated: _onMapCreated,
                    options: GoogleMapOptions(
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                      compassEnabled: true,
                      myLocationEnabled: true,
                      tiltGesturesEnabled: false,
                    ),
                  ),
                ),
                complaint.tags?.isNotEmpty ?? false
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 28.0, vertical: 8.0),
                        child: Text(
                          "Tags",
                          style: theme.textTheme.headline,
                        ),
                      )
                    : SizedBox(
                        height: 0,
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: EditableChipList(
                    editable: false,
                    tags: Set.from(complaint.tags.map((t) => t.tagUri)),
                  ),
                ),
                Divider(),
              ]
                ..add(Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        OMIcons.comment,
                        color: Colors.blueGrey,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                          "${complaint.comments.isEmpty ? "No" : complaint.comments.length} comment${complaint.comments.length == 1 ? "" : "s"}",
                          style: theme.textTheme.title),
                    ],
                  ),
                ))
                ..addAll(complaint.comments
                    .map((v) => _buildComment(bloc, theme, v)))
                ..add(_buildCommentBox(bloc, theme))
                ..addAll(<Widget>[
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28.0, vertical: 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(OMIcons.arrowUpward, color: Colors.blueGrey),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                            "${complaint.usersUpVoted.isEmpty ? "No" : complaint.usersUpVoted.length} upvote${complaint.usersUpVoted.length == 1 ? "" : "s"}",
                            style: theme.textTheme.title),
                      ],
                    ),
                  ),
                ])
                ..addAll(complaint.usersUpVoted
                    .map((u) => _buildUserTile(bloc, theme, u)))
                ..addAll([
                  Divider(),
                  SizedBox(
                    height: 32.0,
                  )
                ]),
            ),

      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildComment(InstiAppBloc bloc, ThemeData theme, Comment v) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              onTap: () {
                UserPage.navigateWith(context, bloc, v.commentedBy);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              leading: NullableCircleAvatar(
                v.commentedBy.userProfilePictureUrl,
                OMIcons.personOutline,
                heroTag: v.commentedBy.userID,
              ),
              title: Text(v.commentedBy.userName),
              subtitle: Text(DateTimeUtil.getDate(v.time)),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _commentController.text =
                      "@${v.commentedBy.userLDAPId} ${_commentController.text}";
                });
                FocusScope.of(context).requestFocus(_commentFocusNode);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                child: Text(v.text, style: theme.textTheme.subhead),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentBox(InstiAppBloc bloc, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          NullableCircleAvatar(
            bloc.currSession.profile.userProfilePictureUrl,
            OMIcons.personOutline,
          ),
          SizedBox(
            width: 8.0,
          ),
          Expanded(
            child: TextField(
              focusNode: _commentFocusNode,
              controller: _commentController,
              maxLines: null,
              autofocus: false,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: loadingComment
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(OMIcons.send),
                  onPressed: () async {
                    if (loadingComment) {
                      return;
                    }
                    setState(() {
                      loadingComment = true;
                    });
                    if (_commentController.text.isNotEmpty) {
                      CommentCreateRequest req = CommentCreateRequest();
                      req.text = _commentController.text;
                      await bloc.complaintsBloc.postComment(complaint, req);
                      setState(() {
                        _commentController.text = "";
                      });
                    } else {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text("Comment empty"),
                      ));
                    }
                    setState(() {
                      loadingComment = false;
                    });
                  },
                ),
                labelText: "Comment",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(InstiAppBloc bloc, ThemeData theme, User u) {
    return ListTile(
      leading: NullableCircleAvatar(
        u.userProfilePictureUrl,
        OMIcons.personOutline,
        heroTag: u.userID,
      ),
      title: Text(u.userName),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      onTap: () {
        UserPage.navigateWith(context, bloc, u);
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    var ltlng = LatLng(complaint.latitude, complaint.longitude);
    // setState(() {
    var alreadyAnimated = _mapController != null;
    _mapController = controller;
    _mapController.addMarker(MarkerOptions(
      position: ltlng,
      infoWindowText: InfoWindowText("${complaint.locationDescription}", null),
    ));
    if (alreadyAnimated) {
      _mapController.moveCamera(CameraUpdate.newLatLngZoom(ltlng, 16.0));
    } else {
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(ltlng, 16.0));
    }
    // });
  }

  Widget _buildTag(TagUri t, ThemeData theme) {
    return Chip(
      backgroundColor: theme.accentColor,
      label: Text(
        t.tagUri,
        style: theme.accentTextTheme.body1,
      ),
    );
  }
}
