import 'dart:async';
import 'dart:collection';
import 'dart:developer';
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

  Bloc(this.bloc);

  ValueStream<UnmodifiableListView<Body>> get verifiableBodies =>
      _verBodySubject.stream;
  final _verBodySubject = BehaviorSubject<UnmodifiableListView<Body>>();

  Future<AchievementCreateResponse?> postForm(
      AchievementCreateRequest req) async {
    try {
      var comment = await bloc.client.postForm(bloc.getSessionIdHeader(), req);
      comment.result = "success";
      return comment;
    } catch (ex) {
      return null;
    }
  }

  Future<SecretResponse?> postAchievementOffer(String id, String secret) async {
    try {
      Offersecret secretclass = Offersecret();
      secretclass.secret = secret;
      SecretResponse response = await bloc.client
          .postAchievementOffer(bloc.getSessionIdHeader(), id, secretclass);
      return response;
    } catch (ex) {
      print(ex);
      return null;
    }
  }

  Future<void> getVerifiableBodies() async {
    var currUser = await bloc.client.getUserMe(bloc.getSessionIdHeader());

    List<Body> listBody = [];
    if(currUser.userRoles == null){
      return;
    }
    for (Role role in currUser.userRoles!) {
      if (role.rolePermissions!.contains('VerA')) {
        for (Body body in role.roleBodies!) {
          if (!listBody.contains(body)) {
            listBody.add(body);
          }
        }
      }
    }
    _verifiableBodies = listBody;
    _verBodySubject.add(UnmodifiableListView(_verifiableBodies));
  }

  Future<List<Event>?> searchForEvent(String query) async {
    if (query.length < 3) {
      return [];
    }
    var searchResponse =
        await bloc.client.search(bloc.getSessionIdHeader(), query);

    if(searchResponse.events== null){
      return [];
    }
    _events = searchResponse.events!;

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

    if(searchResponse.bodies == null){
      return [];
    }

    _bodies = searchResponse.bodies!;
    print(_bodies.map((e) => e.bodyName));
    return _bodies;
  }
}
