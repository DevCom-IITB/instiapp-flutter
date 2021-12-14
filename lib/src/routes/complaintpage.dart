import 'dart:async';

import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/api/request/comment_create_request.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/datetime.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart' as LocationManager;

class ComplaintPage extends StatefulWidget {
  final String title = "Complaint";
  final Complaint? initialComplaint;
  final Future<Complaint?>? complaintFuture;

  ComplaintPage({required this.complaintFuture, this.initialComplaint});

  static void navigateWith(
      BuildContext context, InstiAppBloc bloc, Complaint complaint,
      {bool replace = false}) {
    var route = MaterialPageRoute(
      settings: RouteSettings(
        name: "/complaint/${complaint.complaintID ?? ""}",
      ),
      builder: (context) => ComplaintPage(
        initialComplaint: complaint,
        complaintFuture: bloc.getComplaint(complaint.complaintID ?? "")?? null,
      ),
    );
    replace
        ? Navigator.pushReplacement(context, route)
        : Navigator.push(context, route);
  }

  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  // GlobalKey<GoogleMapState> _mapsKey = GlobalKey();
  // LocalKey _mapsKey = Key("GoogleMapKey");
  Complaint? complaint;

  FocusNode? _commentFocusNode;
  TextEditingController? _commentController;
  bool loadingUpvote = false;
  bool loadingComment = false;

  bool loadingSubs = false;

  // Completer<GoogleMapController> _mapController = Completer();
  // LocationManager.Location _location;

  Comment? deletingComment;

  bool loadingEditComment = false;
  Comment? editingComment;
  FocusNode? _editingCommentFocusNode;
  TextEditingController? _editingCommentController;

  @override
  void initState() {
    super.initState();
    complaint = widget.initialComplaint;
    widget.complaintFuture?.then((c) {
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
    _editingCommentController = TextEditingController();
    _editingCommentFocusNode = FocusNode();
    // _location = LocationManager.Location();
  }

  @override
  void dispose() {
    _commentFocusNode?.dispose();
    _editingCommentFocusNode?.dispose();
    _commentController?.dispose();
    _editingCommentController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context)!.bloc;
    var theme = Theme.of(context);
    var complaintBloc = bloc.complaintsBloc;
    var fab;
    fab = null;

    if (complaint != null) {
      var userVoted = complaint!.voteCount == 1;
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
            : Icon(Icons.arrow_upward_outlined),
        label: Text(userVoted ? "Upvoted" : "Upvote"),
        onPressed: () async {
          setState(() {
            loadingUpvote = true;
          });
          await complaintBloc.updateUpvote(
              complaint!, 1 - (complaint!.voteCount ?? 0));
          setState(() {
            loadingUpvote = false;
          });
        },
      );
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
      // bottomSheet: ,
      body: SafeArea(
        child: complaint == null
            ? Center(
                child: CircularProgressIndicatorExtended(
                  label: Text("Loading the complaint page"),
                ),
              )
            : GestureDetector(
                onTap: () {
                  _commentFocusNode?.unfocus();
                  if (editingComment != null) {
                    _editingCommentFocusNode?.unfocus();
                  }
                },
                child: ListView(
                  children: <Widget>[
                    TitleWithBackButton(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.headline3,
                      ),
                    ),
                    (complaint!.images?.isNotEmpty ?? false)
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
                                children: complaint!.images?.map((im) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: PhotoViewableImage(
                                          url: im,
                                          heroTag: "$im",
                                          fit: BoxFit.scaleDown,
                                        ),
                                      );
                                    }).toList() ??
                                    [],
                              ),
                            ))
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 28),
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(text: "No "),
                                TextSpan(
                                    text: "images ",
                                    style: theme.textTheme.bodyText2?.copyWith(
                                        fontWeight: FontWeight.bold)),
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
                          Hero(
                            tag: complaint!.complaintID ?? "",
                            child: Material(
                              type: MaterialType.transparency,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            complaint!.complaintCreatedBy
                                                    ?.userName ??
                                                "",
                                            style: theme.textTheme.headline6
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        Text(
                                          complaint!.complaintReportDate != null
                                              ? DateTimeUtil.getDate(complaint!
                                                  .complaintReportDate!)
                                              : "",
                                          style: theme.textTheme.caption
                                              ?.copyWith(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: loadingSubs
                                            ? CircularProgressIndicatorExtended()
                                            : Icon(((complaint!.isSubscribed ??
                                                    false)
                                                ? Icons
                                                    .notifications_active_outlined
                                                : Icons
                                                    .notifications_off_outlined)),
                                        onPressed: () async {
                                          setState(() {
                                            loadingSubs = true;
                                          });
                                          await bloc.complaintsBloc.updateSubs(
                                              complaint!,
                                              (complaint!.isSubscribed ?? false)
                                                  ? 0
                                                  : 1);
                                          setState(() {
                                            loadingSubs = false;
                                          });
                                          ScaffoldMessenger.of(context)
                                            ..hideCurrentSnackBar()
                                            ..showSnackBar(SnackBar(
                                                content: Text(
                                                    "You are now ${(complaint!.isSubscribed ?? false) ? "" : "un"}subscribed to this complaint")));
                                        },
                                      ),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: complaint!.status
                                                          ?.toLowerCase() ==
                                                      "Reported".toLowerCase()
                                                  ? Colors.red
                                                  : complaint!.status
                                                              ?.toLowerCase() ==
                                                          "In Progress"
                                                              .toLowerCase()
                                                      ? Colors.yellow
                                                      : Colors.green),
                                          padding: EdgeInsets.all(0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              complaint!.status != null
                                                  ? capitalize(
                                                      complaint!.status!)
                                                  : "",
                                              style: theme.textTheme.subtitle1,
                                            ),
                                          ]..insertAll(
                                              0,
                                              (complaint!.tags?.isNotEmpty ??
                                                      false)
                                                  ? [
                                                      Container(
                                                        color:
                                                            theme.accentColor,
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
                                ],
                              ),
                            ),
                          ),
                          Text(
                            complaint!.locationDescription ?? "",
                            style:
                                theme.textTheme.caption?.copyWith(fontSize: 14),
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
                        (complaint!.suggestions?.isNotEmpty ?? false) ||
                                (complaint!.suggestions?.isNotEmpty ?? false)
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28.0),
                                child: Text(
                                  "Description: ",
                                  style: theme.textTheme.subtitle1,
                                ),
                              )
                            : SizedBox(),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 28.0, right: 28.0, bottom: 16.0),
                          child: Text(
                            complaint!.description ?? "",
                            style: theme.textTheme.subtitle1,
                          ),
                        ),
                      ]
                        ..addAll((complaint!.suggestions?.isNotEmpty ?? false)
                            ? [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28.0),
                                  child: Text(
                                    "Suggestions: ",
                                    style: theme.textTheme.subtitle1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 28.0, right: 28.0, bottom: 16.0),
                                  child: Text(
                                    complaint!.suggestions ?? "",
                                    style: theme.textTheme.subtitle1,
                                  ),
                                ),
                              ]
                            : [])
                        ..addAll(
                            (complaint!.locationDetails?.isNotEmpty ?? false)
                                ? [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 28.0),
                                      child: Text(
                                        "Location Details: ",
                                        style: theme.textTheme.subtitle1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 28.0,
                                          right: 28.0,
                                          bottom: 16.0),
                                      child: Text(
                                        complaint!.locationDetails ?? "",
                                        style: theme.textTheme.subtitle1,
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
                        gestureRecognizers:
                            <Factory<OneSequenceGestureRecognizer>>[
                          Factory<OneSequenceGestureRecognizer>(
                            () => HorizontalDragGestureRecognizer(),
                          ),
                        ].toSet(),
                        onMapCreated: null,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(complaint!.latitude ?? 0,
                                complaint!.longitude ?? 0),
                            zoom: 16.0),
                        markers: Set.from([
                          Marker(
                            markerId: MarkerId(complaint!.complaintID ?? ""),
                            infoWindow: InfoWindow(
                                title: "${complaint!.locationDescription}"),
                            position: LatLng(complaint!.latitude ?? 0,
                                complaint!.longitude ?? 0),
                          )
                        ]),
                        compassEnabled: true,
                        scrollGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        myLocationEnabled: true,
                        tiltGesturesEnabled: false,
                      ),
                    ),
                    complaint!.tags?.isNotEmpty ?? false
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 28.0, vertical: 8.0),
                            child: Text(
                              "Tags",
                              style: theme.textTheme.headline5,
                            ),
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: EditableChipList(
                        editable: false,
                        tags: Set.from(
                            complaint!.tags?.map((t) => t.tagUri) ?? []),
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
                            Icons.comment_outlined,
                            color: theme.accentColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                              "${(complaint!.comments?.isEmpty ?? false) ? "No" : complaint!.comments?.length} comment${complaint!.comments?.length == 1 ? "" : "s"}",
                              style: theme.textTheme.headline6),
                        ],
                      ),
                    ))
                    ..addAll(complaint!.comments
                            ?.map((v) => _buildComment(bloc, theme, v)) ??
                        [])
                    ..add(_buildCommentBox(bloc, theme))
                    ..addAll(<Widget>[
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28.0, vertical: 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.arrow_upward_outlined,
                              color: theme.accentColor,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                                "${complaint!.usersUpVoted?.isEmpty != null ? "No" : complaint!.usersUpVoted?.length} upvote${complaint!.usersUpVoted?.length == 1 ? "" : "s"}",
                                style: theme.textTheme.headline6),
                          ],
                        ),
                      ),
                    ])
                    ..addAll(complaint!.usersUpVoted
                            ?.map((u) => _buildUserTile(bloc, theme, u)) ??
                        [])
                    ..addAll([
                      Divider(),
                      SizedBox(
                        height: 32.0,
                      )
                    ]),
                ),
              ),
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
                UserPage.navigateWith(context, bloc, v.commentedBy!);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              leading: NullableCircleAvatar(
                v.commentedBy!.userProfilePictureUrl ?? "",
                Icons.person_outline_outlined,
                heroTag: v.id!,
              ),
              title: Text(v.commentedBy!.userName ?? ""),
              subtitle: Text(DateTimeUtil.getDate(v.time ?? "")),
              trailing: (deletingComment?.id?.compareTo(v.id!) ?? -1) != 0
                  ? ((v.commentedBy!.userID ?? "") ==
                          bloc.currSession?.profile?.userID
                      ? PopupMenuButton<String>(
                          onSelected: (s) async {
                            if (s == "Edit") {
                              _editingCommentController?.text = v.text ?? "";
                              setState(() {
                                editingComment = v;
                              });
                            } else if (s == "Delete") {
                              setState(() {
                                deletingComment = v;
                              });
                              await bloc.complaintsBloc
                                  .deleteComment(complaint!, v);
                              setState(() {
                                deletingComment = null;
                              });
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                  content:
                                      Text("Your comment has been deleted"),
                                ));
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuItem<String>>[
                            const PopupMenuItem<String>(
                                value: 'Edit', child: Text('Edit')),
                            const PopupMenuItem<String>(
                                value: 'Delete', child: Text('Delete')),
                          ],
                        )
                      : null)
                  : SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _commentController?.text =
                      "@${v.commentedBy!.userLDAPId} ${_commentController?.text}";
                });
                FocusScope.of(context).requestFocus(_commentFocusNode);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                child: (editingComment == null || editingComment?.id != v.id)
                    ? Text(v.text ?? "", style: theme.textTheme.subtitle1)
                    : TextField(
                        focusNode: _editingCommentFocusNode,
                        controller: _editingCommentController,
                        maxLines: null,
                        autofocus: false,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 8.0),
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: loadingEditComment
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(Icons.send_outlined),
                            onPressed: () async {
                              if (loadingEditComment) {
                                return;
                              }
                              setState(() {
                                loadingEditComment = true;
                              });
                              if ((_editingCommentController?.text.isNotEmpty ??
                                  false)) {
                                CommentCreateRequest req =
                                    CommentCreateRequest();
                                req.text = _editingCommentController?.text;
                                await bloc.complaintsBloc
                                    .updateComment(complaint!, v, req);

                                setState(() {
                                  editingComment = null;
                                });
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    content:
                                        Text("Your comment has been updated"),
                                  ));
                              } else {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    content: Text("Comment empty"),
                                  ));
                              }
                              setState(() {
                                loadingEditComment = false;
                              });
                            },
                          ),
                          labelText: "Editing Comment",
                        ),
                      ),
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
            bloc.currSession?.profile?.userProfilePictureUrl ?? "",
            Icons.person_outline_outlined,
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
                      : Icon(Icons.send_outlined),
                  onPressed: () async {
                    if (loadingComment) {
                      return;
                    }
                    setState(() {
                      loadingComment = true;
                    });
                    if ((_commentController?.text.isNotEmpty ?? false)) {
                      CommentCreateRequest req = CommentCreateRequest();
                      req.text = _commentController?.text;
                      await bloc.complaintsBloc.postComment(complaint!, req);
                      setState(() {
                        _commentController?.text = "";
                      });
                    } else {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
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
        u.userProfilePictureUrl ?? "",
        Icons.person_outline_outlined,
        heroTag: u.userID ?? "",
      ),
      title: Text(u.userName ?? ""),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      onTap: () {
        UserPage.navigateWith(context, bloc, u);
      },
    );
  }

//   void _onMapCreated(GoogleMapController controller) {
//   //   var ltlng = LatLng(complaint.latitude, complaint.longitude);
//   //   // var alreadyAnimated = _mapController != null;
//   //   _mapController.complete(controller);
//   //   controller.addMarker(MarkerOptions(
//   //     position: ltlng,
//   //     infoWindowText: InfoWindowText("${complaint.locationDescription}", null),
//   //   ));
//   //   // if (alreadyAnimated) {
//   //   controller.moveCamera(CameraUpdate.newLatLngZoom(ltlng, 16.0));
//   //   // } else {
//   //   //   _mapController.animateCamera(CameraUpdate.newLatLngZoom(ltlng, 16.0));
//   //   // }
//   // }
}
