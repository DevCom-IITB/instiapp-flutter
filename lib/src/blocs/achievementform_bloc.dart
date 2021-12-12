import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:InstiApp/src/api/response/achievement_create_response.dart';
import 'package:InstiApp/src/api/response/secret_response.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:rxdart/rxdart.dart';
import 'package:InstiApp/src/api/model/offersecret.dart';



class Bloc extends Object {
  InstiAppBloc bloc;

  List<Event> _events = [];
  List<Body> _bodies = [];
  var _verifiableBodies = <Body>[];
  var _Interests = <Interest>[];

  Bloc(this.bloc);

  ValueStream<UnmodifiableListView<Body>> get verifiableBodies =>
      _verBodySubject.stream;
  final _verBodySubject = BehaviorSubject<UnmodifiableListView<Body>>();

  ValueStream<UnmodifiableListView<Interest>> get myInterests =>
      _verInterestSubject.stream;
  final _verInterestSubject = BehaviorSubject<UnmodifiableListView<Interest>>();

  Future<AchievementCreateResponse> postForm(
      AchievementCreateRequest req) async {
    try {
      log(req.title);
      var comment = await bloc.client.postForm(bloc.getSessionIdHeader(), req);
      comment.result = "success";
      return comment;
    } catch (ex) {
      log("aa");
      print(ex);
      return null;
    }
  }

  Future<SecretResponse> postAchievementOffer(String id, String secret) async {
    try {
      Offersecret secretclass = Offersecret();
      secretclass.secret = secret;
      log(secretclass.secret + 'lll');
      SecretResponse response = await bloc.client
          .postAchievementOffer(bloc.getSessionIdHeader(), id, secretclass);
      log(response.message);
      return response;
    } catch (ex) {
      print(ex);
      return null;
    }
  }

  Future<SecretResponse> postInterest(String id,String title) async {
    try {
      SecretResponse response = await bloc.client
          .postInterests(bloc.getSessionIdHeader(), id, title);
      log(response.message);
      return response;
    } catch (ex) {
      print(ex);
      return null;
    }
  }

  Future<SecretResponse> postDelInterest(String title) async {
    try {
      var currUser = await bloc.client.getUserMe(bloc.getSessionIdHeader());
      SecretResponse response = await bloc.client
          .postDelInterests(bloc.getSessionIdHeader(), currUser.userID, title);
      log(response.message);
      return response;
    } catch (ex) {
      print(ex);
      return null;
    }
  }

  Future<void> getVerifiableBodies() async {
    var currUser = await bloc.client.getUserMe(bloc.getSessionIdHeader());
    print("got response");

    List<Body> listBody = [];

    for (Role role in currUser.userRoles) {
      if (role.rolePermissions.contains('VerA')) {
        for (Body body in role.roleBodies) {
          if (!listBody.contains(body)) {
            listBody.add(body);
          }
        }
      }
    }
    print("returning");
    _verifiableBodies = listBody;
    _verBodySubject.add(UnmodifiableListView(_verifiableBodies));
  }

  Future<void> getMyInterests() async {
    var currUser = await bloc.client.getUserMe(bloc.getSessionIdHeader());
    print("got response");

    List<Interest> listInterest = [];

    for (Interest interest in currUser.interests) {
          if (!listInterest.contains(interest)) {
            listInterest.add(interest);
          }
    }
    print("returning");
    _Interests = listInterest;
    _verInterestSubject.add(UnmodifiableListView(listInterest));
  }

  Future<List<Interest>> searchForInterest(String query) async {
    print("Search called");
    if (query.length < 3) {
      return [];
    }
    var searchResponse =
    await bloc.client.search(bloc.getSessionIdHeader(), query);
    print("Search responed");

    _bodies = searchResponse.interests;
    print(_bodies.map((e) => e.bodyName));
    return _bodies;
  }



  Future<List<Event>> searchForEvent(String query) async {
    print("Search called");
    if (query.length < 3) {
      return [];
    }
    var searchResponse =
        await bloc.client.search(bloc.getSessionIdHeader(), query);
    print("Search responed");

    _events = searchResponse.events;
    print(_events.map((e) => e.eventName));
    return _events;
  }

  Future<List<Body>> searchForBody(String query) async {
    print("Search called");
    if (query.length < 3) {
      return [];
    }
    var searchResponse =
        await bloc.client.search(bloc.getSessionIdHeader(), query);
    print("Search responed");

    _bodies = searchResponse.bodies;
    print(_bodies.map((e) => e.bodyName));
    return _bodies;
  }
}
