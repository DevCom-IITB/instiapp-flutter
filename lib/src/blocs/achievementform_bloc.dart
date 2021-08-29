import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/api/model/offeredAchievements.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:InstiApp/src/api/response/achievement_create_response.dart';
import 'package:InstiApp/src/api/response/secret_response.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:flutter/cupertino.dart';
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
  final _verBodySubject =
  BehaviorSubject<UnmodifiableListView<Body>>();

  Future<AchievementCreateResponse> postForm(
      AchievementCreateRequest req) async {
    try {
      log(req.title);
      var comment = await bloc.client.postForm(bloc.getSessionIdHeader(), req);
      comment.result="success";
      return comment;
    } catch (ex) {
      log("aa");
      print(ex);
      return null;
    }
  }
  Future<offeredAchievements> getOfferedAchievements(String id) async {
    try{
      var response=await bloc.client.getOfferedAchievements(bloc.getSessionIdHeader(), id);
      return response;
    } catch(ex){
      print(ex);
      return null;
    }

  }

  Future<Map<String, List<String>>> postAchievementOffer(String id,String secret) async {
    try{
      offersecret secretclass=offersecret();
      secretclass.secret=secret;
      log(secretclass.secret+'lll');
      Map<String, List<String>> response=await bloc.client.postAchievementOffer(bloc.getSessionIdHeader(), id,secretclass);
      log(response.toString());
      return response;
    } catch(ex){
      print(ex);
      return null;
    }

  }

  Future<void> getVerifiableBodies() async {
    var currUser= await bloc.client.getUserMe(bloc.getSessionIdHeader());
    print("got response");

    List<Body> ListBody= List<Body>();

    for(Role role in currUser.userRoles){
      if(role.rolePermissions.contains('VerA')){
        for(Body body in role.roleBodies){
          if(!ListBody.contains(body)){
            ListBody.add(body);
          }
        }
      }
    }
    print("returning");
    _verifiableBodies=ListBody;
    _verBodySubject.add(UnmodifiableListView(_verifiableBodies));

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
