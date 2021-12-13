// import 'dart:async';
import 'dart:collection';
import 'dart:math';

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
  ValueStream<UnmodifiableListView<Complaint>> get allComplaints =>
      _complaintsSubject.stream;
  final _complaintsSubject = BehaviorSubject<UnmodifiableListView<Complaint>>();

  ValueStream<UnmodifiableListView<Complaint>> get myComplaints =>
      _mycomplaintsSubject.stream;
  final _mycomplaintsSubject =
      BehaviorSubject<UnmodifiableListView<Complaint>>();

  Sink<int> get inComplaintIndex => _indexController.sink;
  PublishSubject<int> _indexController = PublishSubject<int>();

  // Params
  int _noOfComplaintsPerPage = 20;
  String query = "";

  // State
  List<Complaint> _allComplaints = [] as List<Complaint>;
  List<Complaint> _myComplaints = [] as List<Complaint>;
  // // //

  final _fetchPages = <int, List<Complaint>>{};
  final _pagesBeingFetched = Set<int>();

  final _searchFetchPages = <int, List<Complaint>>{};
  final _searchPagesBeingFetched = Set<int>();

  ComplaintsBloc(this.bloc) {
    _setIndexListener();
  }

  void _setIndexListener() {
    _indexController.stream
        .bufferTime(Duration(milliseconds: 500))
        .where((batch) => batch.isNotEmpty)
        .listen(_handleIndexes);
  }

  Future<ImageUploadResponse?> uploadBase64Image(String base64Image) async {
    if (bloc.currSession != null) {
      var tmp = ImageUploadRequest();
      tmp.base64Image = base64Image;
      return bloc.client.uploadImage(bloc.getSessionIdHeader(), tmp);
    }
    return null;
  }

  Future<List<Complaint>> getAllComplaintsPage(int page) async {
    var allComplaints = await bloc.client.getAllComplaints(
        bloc.getSessionIdHeader(),
        page * _noOfComplaintsPerPage,
        _noOfComplaintsPerPage,
        query);
    return allComplaints;
  }

  void _handleIndexes(List<int> indexes) {
    var pages = query.isEmpty ? _fetchPages : _searchFetchPages;
    var pagesBeingFetched =
        query.isEmpty ? _pagesBeingFetched : _searchPagesBeingFetched;
    indexes.forEach((int index) {
      final int pageIndex = ((index + 1) ~/ _noOfComplaintsPerPage);

      // check if the page has already been fetched
      if (!pages.containsKey(pageIndex)) {
        // the page has NOT yet been fetched, so we need to
        // fetch it from Internet
        // (except if we are already currently fetching it)
        if (!pagesBeingFetched.contains(pageIndex)) {
          // Remember that we are fetching it
          pagesBeingFetched.add(pageIndex);
          // Fetch it
          getAllComplaintsPage(pageIndex).then((List<Complaint> fetchedPage) =>
              _handleFetchedPage(fetchedPage, pageIndex));
        }
      }
    });
  }

  ///
  /// Once a page has been fetched from Internet, we need to
  /// 1) record it
  /// 2) notify everyone who might be interested in knowing it
  ///
  void _handleFetchedPage(List<Complaint> page, int pageIndex) {
    var pages = query.isEmpty ? _fetchPages : _searchFetchPages;
    var pagesBeingFetched =
        query.isEmpty ? _pagesBeingFetched : _searchPagesBeingFetched;

    // Remember the page
    pages[pageIndex] = page;
    // Remove it from the ones being fetched
    pagesBeingFetched.remove(pageIndex);

    // Notify anyone interested in getting access to the content
    // of all pages... however, we need to only return the pages
    // which respect the sequence (since MovieCard are in sequence)
    // therefore, we need to iterate through the pages that are
    // actually fetched and stop if there is a gap.
    List<Complaint> complaints = <Complaint>[];
    List<int> pageIndexes = pages.keys.toList();

    final int minPageIndex = pageIndexes.reduce(min);
    final int maxPageIndex = pageIndexes.reduce(max);

    // If the first page being fetched does not correspond to the first one, skip
    // and as soon as it will become available, it will be time to notify
    if (minPageIndex == 0) {
      for (int i = 0; i <= maxPageIndex; i++) {
        if (!pages.containsKey(i)) {
          // As soon as there is a hole, stop
          break;
        }
        // Add the list of fetched complaints to the list
        complaints.addAll(pages[i]!);
      }
    }

    if (pages[maxPageIndex]!.length < _noOfComplaintsPerPage) {
      complaints.add(Complaint());
    }

    // Only notify when there are complaints
    if (complaints.length > 0) {
      _complaintsSubject.add(UnmodifiableListView<Complaint>(complaints));
    }
  }

  Future refreshAllComplaints({bool force = false}) async {
    _indexController.close();

    _searchFetchPages.clear();
    _searchPagesBeingFetched.clear();

    List<Complaint> complaints = <Complaint>[];
    if (force) {
      _fetchPages.clear();
      _pagesBeingFetched.clear();
    } else if (_fetchPages.isNotEmpty && query.isEmpty) {
      List<int> pageIndexes = _fetchPages.keys.toList();

      final int minPageIndex = pageIndexes.reduce(min);
      final int maxPageIndex = pageIndexes.reduce(max);

      if (minPageIndex == 0) {
        for (int i = 0; i <= maxPageIndex; i++) {
          if (!_fetchPages.containsKey(i)) {
            // As soon as there is a hole, stop
            break;
          }
          complaints.addAll(_fetchPages[i]!);
        }
      }
    }

    _complaintsSubject.add(UnmodifiableListView(complaints));

    _indexController = PublishSubject<int>();
    _setIndexListener();
  }

  Future<void> updateMyComplaints() async {
    if (bloc.currSession != null) {
      _myComplaints =
          await bloc.client.getUserComplaints(bloc.getSessionIdHeader());
      _mycomplaintsSubject.add(UnmodifiableListView(_myComplaints));
    }
  }

  Future<Complaint>? getComplaint(String uuid, {bool reload = false}) async {
    if (bloc.currSession == null) {
      return null;
    }

    Complaint c;
    try {
      c = (reload
          ? await bloc.client.getComplaint(bloc.getSessionIdHeader(), uuid)
          : _allComplaints?.firstWhere((c) => c.complaintID == uuid))!;
    } catch (ex) {
      c = await bloc.client.getComplaint(bloc.getSessionIdHeader(), uuid);
    }
    c.voteCount =
        c.usersUpVoted!.any((u) => u.userID == bloc.currSession!.profile!.userID)
            ? 1
            : 0;
    return c;
  }

  Future<List<TagUri>> getAllTags() async {
    try {
      return await bloc.client.getAllTags(bloc.getSessionIdHeader());
    } catch (ex) {
      print(ex);
      return Future.delayed(Duration(seconds: 0));
    }
  }

  Future<void> updateUpvote(Complaint complaint, int voteCount) async {
    try {
      await bloc.client
          .upVote(bloc.getSessionIdHeader(), complaint.complaintID!, voteCount);
      complaint.voteCount = voteCount;
      if (voteCount == 0) {
        complaint.usersUpVoted?? []
            .removeWhere((u) => bloc.currSession!.profile?.userID == u.userID);
      } else {
        complaint.usersUpVoted?.add(bloc.currSession!.profile!);
      }
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> updateSubs(Complaint complaint, int subsCount) async {
    try {
      await bloc.client.subscribleToComplaint(
          bloc.getSessionIdHeader(), complaint.complaintID!, subsCount);
      complaint.isSubscribed = subsCount == 1;
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> postComment(
      Complaint complaint, CommentCreateRequest req) async {
    try {
      var comment = await bloc.client
          .postComment(bloc.getSessionIdHeader(), complaint.complaintID!, req);
      complaint.comments!.add(comment);
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> updateComment(
      Complaint complaint, Comment mComment, CommentCreateRequest req) async {
    try {
      var comment = await bloc.client
          .updateComment(bloc.getSessionIdHeader(), mComment.id!, req);
      var idx = complaint.comments?.indexWhere((c) => c.id == comment.id);
      complaint.comments![idx!].text = comment.text;
      complaint.comments![idx!].time = comment.time;
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> deleteComment(Complaint complaint, Comment comment) async {
    try {
      await bloc.client.deleteComment(bloc.getSessionIdHeader(), comment.id!);
      complaint.comments?.removeWhere((c) => c.id == comment.id);
    } catch (ex) {
      print(ex);
    }
  }

  Future<Complaint?> postComplaint(ComplaintCreateRequest req) async {
    try {
      return bloc.client.postComplaint(bloc.getSessionIdHeader(), req);
    } catch (ex) {
      print(ex);
      return null;
    }
  }

  // Future saveToCache({SharedPreferences sharedPrefs}) async {
  //   var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
  //   if (_allComplaints?.isNotEmpty ?? false) {
  //     prefs.setString(allStorageID, standardSerializers.encode(_allComplaints));
  //   }

  //   if (_myComplaints?.isNotEmpty ?? false) {
  //     prefs.setString(myStorageID, standardSerializers.encode(_myComplaints));
  //   }
  // }

  // Future restoreFromCache({SharedPreferences sharedPrefs}) async {
  //   var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
  //   if (prefs.getKeys().contains(allStorageID)) {
  //     _allComplaints = standardSerializers
  //         .decodeList<Complaint>(prefs.getString(allStorageID));
  //     _complaintsSubject.add(UnmodifiableListView(_allComplaints));
  //   }

  //   if (prefs.getKeys().contains(myStorageID)) {
  //     _myComplaints = standardSerializers
  //         .decodeList<Complaint>(prefs.getString(myStorageID));
  //     _mycomplaintsSubject.add(UnmodifiableListView(_myComplaints));
  //   }
  // }
}
