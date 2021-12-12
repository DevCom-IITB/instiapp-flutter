import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:InstiApp/src/api/model/venue.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapBloc {
  // Unique ID for use in SharedPrefs
  static String locationsStorageID = "alllocations";

  // parent bloc
  InstiAppBloc bloc;

  // Streams
  ValueStream<UnmodifiableListView<Venue>> get locations =>
      _locationsSubject.stream;
  final _locationsSubject = BehaviorSubject<UnmodifiableListView<Venue>>();

  // State
  List<Venue> _locations = <Venue>[];

  MapBloc(this.bloc);

  Future updateLocations() async {
    _locations = await bloc.client.getAllVenues();
    _locationsSubject.add(UnmodifiableListView(_locations));
  }

  Future saveToCache({SharedPreferences? sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (_locations.isNotEmpty) {
      prefs.setString(
          locationsStorageID, json.encode(_locations.map((e)=> e.toJson()).toList()));
    }
  }

  Future restoreFromCache({SharedPreferences? sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (prefs.getKeys().contains(locationsStorageID)) {
      var x = prefs.getString(locationsStorageID);
      if(x != null){
        _locations = json.decode(x).map((e)=>Venue.fromJson(e)).toList();
      _locationsSubject.add(UnmodifiableListView(_locations));
      }
    }
  }
}
