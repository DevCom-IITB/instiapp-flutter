import 'dart:collection';

import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';

class ComplaintsBloc {
  // parent bloc
  InstiAppBloc bloc;

  // Streams
  Stream<UnmodifiableListView<Complaint>> get allComplaints => _complaintsSubject.stream;
  final _complaintsSubject = BehaviorSubject<UnmodifiableListView<Complaint>>();

  Stream<UnmodifiableListView<Complaint>> get myComplaints => _mycomplaintsSubject.stream;
  final _mycomplaintsSubject = BehaviorSubject<UnmodifiableListView<Complaint>>();

  // State
  List<Complaint> _allComplaints;
  List<Complaint> _myComplaints;
  // // //

  ComplaintsBloc(this.bloc);

  Future<void> updateAllComplaints() async {
    _allComplaints = await bloc.client.getAllComplaints(bloc.getSessionIdHeader());
    _complaintsSubject.add(UnmodifiableListView(_allComplaints));
    return Future.delayed(Duration(milliseconds: 300));
  }

  Future<void> updateMyComplaints() async {
    _myComplaints = await bloc.client.getUserComplaints(bloc.getSessionIdHeader());
    _mycomplaintsSubject.add(UnmodifiableListView(_myComplaints));
    return Future.delayed(Duration(milliseconds: 300));
  }

  Future<Complaint> getComplaint(String uuid) async {
    try {
      return _allComplaints?.firstWhere((c) => c.complaintID == uuid);
    } catch (ex) {
      print(ex);
      return bloc.client.getComplaint(bloc.getSessionIdHeader(), uuid);
    }
  }
}