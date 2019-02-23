import 'dart:collection';

import 'package:InstiApp/src/api/model/serializers.dart';
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
  Stream<UnmodifiableListView<Venue>> get locations =>
      _locationsSubject.stream;
  final _locationsSubject =
      BehaviorSubject<UnmodifiableListView<Venue>>();

  // State
  List<Venue> _locations;

  MapBloc(this.bloc);

  Future updateLocations() async {
    _locations = await bloc.client.getAllVenues();
    _locationsSubject.add(UnmodifiableListView(_locations));
  }

  Future saveToCache({SharedPreferences sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (_locations?.isNotEmpty ?? false) {
      prefs.setString(locationsStorageID, standardSerializers.encode(_locations));
    }
  }

  Future restoreFromCache({SharedPreferences sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (prefs.getKeys().contains(locationsStorageID)) {
      _locations = standardSerializers
          .decodeList<Venue>(prefs.getString(locationsStorageID));
      _locationsSubject.add(UnmodifiableListView(_locations));
    }
  }
} 