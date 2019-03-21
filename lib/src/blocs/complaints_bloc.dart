import 'dart:async';
import 'dart:collection';

import 'package:InstiApp/src/api/model/serializers.dart';
import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/api/request/comment_create_request.dart';
import 'package:InstiApp/src/api/request/complaint_create_request.dart';
import 'package:InstiApp/src/api/request/image_upload_request.dart';
import 'package:InstiApp/src/api/response/image_upload_response.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintsBloc {
  // Unique ID for use in SharedPrefs
  static String allStorageID = "allcomplaints";
  static String myStorageID = "mycomplaints";

  // parent bloc
  InstiAppBloc bloc;

  // Streams
  Stream<UnmodifiableListView<Complaint>> get allComplaints =>
      _complaintsSubject.stream;
  final _complaintsSubject = BehaviorSubject<UnmodifiableListView<Complaint>>();

  Stream<UnmodifiableListView<Complaint>> get myComplaints =>
      _mycomplaintsSubject.stream;
  final _mycomplaintsSubject =
      BehaviorSubject<UnmodifiableListView<Complaint>>();

  // State
  List<Complaint> _allComplaints;
  List<Complaint> _myComplaints;
  // // //

  ComplaintsBloc(this.bloc);

  Future<ImageUploadResponse> uploadBase64Image(String base64Image) async {
    if (bloc.currSession != null) {
      var tmp = ImageUploadRequest();
      tmp.base64Image = base64Image;
      return bloc.client.uploadImage(bloc.getSessionIdHeader(), tmp);
    }
    return null;
  }

  Future<void> updateAllComplaints() async {
    if (bloc.currSession != null) {
      _allComplaints =
          await bloc.client.getAllComplaints(bloc.getSessionIdHeader());
      _complaintsSubject.add(UnmodifiableListView(_allComplaints));
    }
  }

  Future<void> updateMyComplaints() async {
    if (bloc.currSession != null) {
      _myComplaints =
          await bloc.client.getUserComplaints(bloc.getSessionIdHeader());
      _mycomplaintsSubject.add(UnmodifiableListView(_myComplaints));
    }
  }

  Future<Complaint> getComplaint(String uuid, {bool reload = false}) async {
    if (bloc.currSession == null) {
      return null;
    }

    Complaint c;
    try {
      c = reload
          ? await bloc.client.getComplaint(bloc.getSessionIdHeader(), uuid)
          : _allComplaints?.firstWhere((c) => c.complaintID == uuid);
    } catch (ex) {
      c = await bloc.client.getComplaint(bloc.getSessionIdHeader(), uuid);
    }
    c.voteCount =
        c.usersUpVoted.any((u) => u.userID == bloc.currSession.profile.userID)
            ? 1
            : 0;
    return c;
  }

  Future<void> updateUpvote(Complaint complaint, int voteCount) async {
    try {
      await bloc.client
          .upVote(bloc.getSessionIdHeader(), complaint.complaintID, voteCount);
      complaint.voteCount = voteCount;
      if (voteCount == 0) {
        complaint.usersUpVoted
            .removeWhere((u) => bloc.currSession.profile.userID == u.userID);
      } else {
        complaint.usersUpVoted.add(bloc.currSession.profile);
      }
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> updateSubs(Complaint complaint, int subsCount) async {
    try {
      await bloc.client.subscribleToComplaint(
          bloc.getSessionIdHeader(), complaint.complaintID, subsCount);
      complaint.isSubscribed = subsCount == 1;
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> postComment(
      Complaint complaint, CommentCreateRequest req) async {
    try {
      var comment = await bloc.client
          .postComment(bloc.getSessionIdHeader(), complaint.complaintID, req);
      complaint.comments.add(comment);
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> updateComment(
      Complaint complaint, Comment mComment, CommentCreateRequest req) async {
    try {
      var comment = await bloc.client
          .updateComment(bloc.getSessionIdHeader(), mComment.id, req);
      var idx = complaint.comments.indexWhere((c) => c.id == comment.id);
      complaint.comments[idx].text = comment.text;
      complaint.comments[idx].time = comment.time;
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> deleteComment(Complaint complaint, Comment comment) async {
    try {
      await bloc.client.deleteComment(bloc.getSessionIdHeader(), comment.id);
      complaint.comments.removeWhere((c) => c.id == comment.id);
    } catch (ex) {
      print(ex);
    }
  }

  Future<Complaint> postComplaint(ComplaintCreateRequest req) async {
    try {
      return bloc.client.postComplaint(bloc.getSessionIdHeader(), req);
    } catch (ex) {
      print(ex);
      return null;
    }
  }

  Future saveToCache({SharedPreferences sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (_allComplaints?.isNotEmpty ?? false) {
      prefs.setString(allStorageID, standardSerializers.encode(_allComplaints));
    }

    if (_myComplaints?.isNotEmpty ?? false) {
      prefs.setString(myStorageID, standardSerializers.encode(_myComplaints));
    }
  }

  Future restoreFromCache({SharedPreferences sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (prefs.getKeys().contains(allStorageID)) {
      _allComplaints = standardSerializers
          .decodeList<Complaint>(prefs.getString(allStorageID));
      _complaintsSubject.add(UnmodifiableListView(_allComplaints));
    }

    if (prefs.getKeys().contains(myStorageID)) {
      _myComplaints = standardSerializers
          .decodeList<Complaint>(prefs.getString(myStorageID));
      _mycomplaintsSubject.add(UnmodifiableListView(_myComplaints));
    }
  }
}
