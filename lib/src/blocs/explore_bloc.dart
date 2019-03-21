import 'dart:async';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/serializers.dart';
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
  Stream<ExploreResponse> get explore => _exploreSubject.stream;
  final _exploreSubject = BehaviorSubject<ExploreResponse>();

  // Params
  String query = "";

  // State
  List<Body> allBodies;
  ExploreResponse currExploreResponse;

  ExploreBloc(this.bloc);

  _push(ExploreResponse resp) {
    currExploreResponse = resp;
    _exploreSubject.add(resp);
  }

  Future saveToCache({SharedPreferences sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (allBodies?.isNotEmpty ?? false) {
      prefs.setString(storageID, standardSerializers.encode(allBodies));
    }
  }

  Future restoreFromCache({SharedPreferences sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (prefs.getKeys().contains(storageID)) {
      allBodies =
          standardSerializers.decodeList<Body>(prefs.getString(storageID));
      _push(ExploreResponse(bodies: allBodies));
    }
  }

  Future refresh() async {
    if ((query ?? "") == "") {
      if (allBodies?.isEmpty ?? true) {
        allBodies = await bloc.client.getAllBodies(bloc.getSessionIdHeader());
      }
      _push(ExploreResponse(bodies: allBodies));
    } else {
      _push(await bloc.client.search(bloc.getSessionIdHeader(), query));
    }
  }
}
