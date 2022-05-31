import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/response/explore_response.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreBloc {
  // Unique ID for use in SharedPrefs
  static String storageID = "explore";

  // parent bloc
  InstiAppBloc bloc;

  // Streams
  ValueStream<ExploreResponse> get explore => _exploreSubject.stream;
  final _exploreSubject = BehaviorSubject<ExploreResponse>();

  ValueStream<UnmodifiableListView<Body>> get bodies => _bodiesSubject.stream;
  final _bodiesSubject = BehaviorSubject<UnmodifiableListView<Body>>();

  // Params
  String query = "";

  // State
  List<Body> allBodies = <Body>[];
  ExploreResponse? currExploreResponse;

  ExploreBloc(this.bloc);

  _push(ExploreResponse resp) {
    currExploreResponse = resp;
    _exploreSubject.add(resp);
  }

  Future saveToCache({SharedPreferences? sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (allBodies.isNotEmpty) {
      prefs.setString(
          storageID, json.encode(allBodies.map((e) => e.toJson()).toList()));
    }
  }

  Future restoreFromCache({SharedPreferences? sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (prefs.getKeys().contains(storageID)) {
      var x = prefs.getString(storageID);
      if (x != null) {
        allBodies = json.decode(x).map((e) => Body.fromJson(e)).toList().cast<Body>();
        _push(ExploreResponse(bodies: allBodies));
      }
    }
    _bodiesSubject.add(UnmodifiableListView(allBodies));
  }

  Future refresh() async {
    if (query == "") {
      if (allBodies.isEmpty) {
        allBodies = await bloc.client.getAllBodies(bloc.getSessionIdHeader());
      }
      _push(ExploreResponse(bodies: allBodies));
    } else {
      _push(await bloc.client.search(bloc.getSessionIdHeader(), query));
    }
  }
}
