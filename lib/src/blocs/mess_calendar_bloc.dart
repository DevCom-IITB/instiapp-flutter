import 'dart:async';

import 'package:InstiApp/src/api/model/messCalEvent.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:date_format/date_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MessCalendarBloc {
  // monthToEventMap StorageID
  static String mteKeysStorageID = "monthToMessEventsKeys";
  static String mteValuesStorageID = "monthToMessEventsValues";

  // eventsMap StorageID
  static String eventsMapKeysStorageID = "MessEventsMapKeys";
  static String eventsMapValuesStorageID = "MessEventsMapValues";

  // parent bloc
  InstiAppBloc bloc;

  // Streams
  ValueStream<Map<DateTime, List<MessCalEvent>>> get events =>
      _eventsSubject.stream;
  final _eventsSubject = BehaviorSubject<Map<DateTime, List<MessCalEvent>>>();

  ValueStream<bool> get loading => _loadingSubject.stream;
  final _loadingSubject = BehaviorSubject<bool>();

  // State
  Map<DateTime, List<MessCalEvent>> monthToEvents = {};
  Map<DateTime, List<MessCalEvent>> eventsMap = {};
  List<DateTime> receivingMonths = [];
  bool _loading = false;

  MessCalendarBloc(this.bloc) {
    _loadingSubject.add(_loading);
  }

  DateTime _getMonthStart(DateTime date) {
    return DateTime(date.year, date.month);
  }

  List<MessCalEvent> _getEventsOfMonth(List<MessCalEvent> evs, DateTime month) {
    return evs.where((e) {
      return e.date.year == month.year && e.date.month == month.month;
    }).toList();
  }

  void fetchEvents(DateTime currMonth, Widget icon) async {
    if (!_loading) {
      _loading = true;
      _loadingSubject.add(_loading);
    }
    var isoFormat = [yyyy, "-", mm, "-", dd, " ", HH, ":", nn, ":", ss];

    var currMonthStart = _getMonthStart(currMonth);
    var prevMonthStart =
        DateTime(currMonthStart.year, currMonthStart.month - 1);
    var nextMonthStart =
        DateTime(currMonthStart.year, currMonthStart.month + 1);
    var nextNextMonthStart =
        DateTime(currMonthStart.year, currMonthStart.month + 2);

    receivingMonths.add(prevMonthStart);
    receivingMonths.add(currMonthStart);
    receivingMonths.add(nextMonthStart);

    List<MessCalEvent> newsFeedResp = await bloc.client
        .getMessEventsBetweenDates(
            bloc.getSessionIdHeader(),
            formatDate(prevMonthStart, isoFormat),
            formatDate(nextNextMonthStart, isoFormat));
    var evs = newsFeedResp;

    monthToEvents[prevMonthStart] = _getEventsOfMonth(evs, prevMonthStart);
    receivingMonths.remove(prevMonthStart);
    monthToEvents[currMonthStart] = _getEventsOfMonth(evs, currMonthStart);
    receivingMonths.remove(currMonthStart);
    monthToEvents[nextMonthStart] = _getEventsOfMonth(evs, nextMonthStart);
    receivingMonths.remove(nextMonthStart);
    for (MessCalEvent e in evs) {
      var dateList = eventsMap.putIfAbsent(e.date, () => []);
      dateList.removeWhere((e1) => e1.eid == e.eid);
      dateList.add(e);
    }
    _eventsSubject.add(eventsMap);
    if (_loading) {
      _loading = false;
      _loadingSubject.add(_loading);
    }
  }

  Future saveToCache({SharedPreferences? sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (monthToEvents.isNotEmpty) {
      List<String> keys = [];
      for (DateTime i in monthToEvents.keys) {
        keys.add(i.toIso8601String());
      }
      prefs.setString(mteKeysStorageID, json.encode(keys));
      prefs.setString(
          mteValuesStorageID,
          json.encode(monthToEvents.values
              .map((e) => {
                    e.map((k) => {k.toJson()}).toList()
                  })
              .toList()));
    }

    if (eventsMap.isNotEmpty) {
      List<String> keys = [];
      for (DateTime i in eventsMap.keys) {
        keys.add(i.toIso8601String());
      }
      prefs.setString(eventsMapKeysStorageID, json.encode(keys));
      prefs.setString(
          eventsMapValuesStorageID,
          json.encode(eventsMap.values
              .map((e) => {
                    e.map((k) => {k.toJson()}).toList()
                  })
              .toList()));
    }
  }

  Future restoreFromCache({SharedPreferences? sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (prefs.getKeys().contains(mteKeysStorageID) &&
        prefs.getKeys().contains(mteValuesStorageID)) {
      if (prefs.getString(mteKeysStorageID) != null &&
          prefs.getString(mteValuesStorageID) != null) {
        var keys =
            (json.decode(prefs.getString(mteKeysStorageID) ?? '') as List)
                .map((e) => DateTime.parse(e as String));
        var values =
            (json.decode(prefs.getString(mteValuesStorageID) ?? '') as List)
                .map((evs) => evs
                    .map((e) => MessCalEvent.fromJson(e))
                    .toList()
                    .cast<MessCalEvent>())
                .toList()
                .cast<List<MessCalEvent>>();
        monthToEvents = Map.fromIterables(keys, values);
      }
    }

    if (prefs.getKeys().contains(eventsMapKeysStorageID) &&
        prefs.getKeys().contains(eventsMapValuesStorageID)) {
      if (prefs.getString(mteKeysStorageID) != null &&
          prefs.getString(mteValuesStorageID) != null) {
        var keys =
            (json.decode(prefs.getString(mteKeysStorageID) ?? '') as List)
                .map((e) => DateTime.parse(e as String));
        var values =
            (json.decode(prefs.getString(mteValuesStorageID) ?? '') as List)
                .map((evs) => evs.map((e) => MessCalEvent.fromJson(e)).toList()
                    as List<MessCalEvent>);
        eventsMap = Map.fromIterables(keys, values);
        _eventsSubject.add(eventsMap);
      }
    }
  }
}
