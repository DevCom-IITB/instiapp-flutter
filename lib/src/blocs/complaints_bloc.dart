import 'dart:collection';

import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/api/request/comment_create_request.dart';
import 'package:InstiApp/src/api/request/complaint_create_request.dart';
import 'package:InstiApp/src/api/response/complaint_create_response.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';

class ComplaintsBloc {
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

  Future<void> updateAllComplaints() async {
    if (bloc.currSession != null) {
      _allComplaints =
          await bloc.client.getAllComplaints(bloc.getSessionIdHeader());
      _complaintsSubject.add(UnmodifiableListView(_allComplaints));
    }
    return Future.delayed(Duration(milliseconds: 300));
  }

  Future<void> updateMyComplaints() async {
    if (bloc.currSession != null) {
      _myComplaints =
          await bloc.client.getUserComplaints(bloc.getSessionIdHeader());
      _mycomplaintsSubject.add(UnmodifiableListView(_myComplaints));
    }
    return Future.delayed(Duration(milliseconds: 300));
  }

  Future<Complaint> getComplaint(String uuid) async {
    if (bloc.currSession == null) {
      return Future.delayed(Duration(milliseconds: 100));
    }

    Complaint c;
    try {
      c = _allComplaints?.firstWhere((c) => c.complaintID == uuid);
    } catch (ex) {
      print(ex);
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

  Future<void> postComment(
      Complaint complaint, CommentCreateRequest req) async {
    try {
      var comment = await bloc.client
          .postComment(bloc.getSessionIdHeader(), complaint.complaintID, req);
      complaint.comment.add(comment);
    } catch (ex) {
      print(ex);
    }
  }

  Future<ComplaintCreateResponse> postComplaint(
      ComplaintCreateRequest req) async {
    try {
      return bloc.client.postComplaint(bloc.getSessionIdHeader(), req);
    } catch (ex) {
      print(ex);
    }
  }
}
