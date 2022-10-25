import 'dart:async';

import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:date_format/date_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CalendarBloc {
  // monthToEventMap StorageID
  static String mteKeysStorageID = "monthToEventsKeys";
  static String mteValuesStorageID = "monthToEventsValues";

  // eventsMap StorageID
  static String eventsMapKeysStorageID = "eventsMapKeys";
  static String eventsMapValuesStorageID = "eventsMapValues";
  // parent bloc
  InstiAppBloc bloc;

  // Streams
  ValueStream<Map<DateTime, List<Event>>> get events => _eventsSubject.stream;
  final _eventsSubject = BehaviorSubject<Map<DateTime, List<Event>>>();

  ValueStream<bool> get loading => _loadingSubject.stream;
  final _loadingSubject = BehaviorSubject<bool>();

  // State
  Map<DateTime, List<Event>> monthToEvents = {};
  Map<DateTime, List<Event>> eventsMap = {};
  List<DateTime> receivingMonths = [];
  bool _loading = false;

  CalendarBloc(this.bloc) {
    _loadingSubject.add(_loading);
  }

  DateTime _getMonthStart(DateTime date) {
    return DateTime(date.year, date.month);
  }

  List<Event> _getEventsOfMonth(List<Event> evs, DateTime month) {
    return evs.where((e) {
      return e.eventStartDate!.year == month.year &&
          e.eventStartDate!.month == month.month;
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

    var newsFeedResp = await bloc.client.getEventsBetweenDates(
        bloc.getSessionIdHeader(),
        formatDate(prevMonthStart, isoFormat),
        formatDate(nextNextMonthStart, isoFormat));
    var evs = newsFeedResp.events;
    evs!.forEach((e) {
      var time = DateTime.parse(e.eventStartTime!);
      e.eventStartDate = DateTime(time.year, time.month, time.day);
    });

    monthToEvents[prevMonthStart] = _getEventsOfMonth(evs, prevMonthStart);
    receivingMonths.remove(prevMonthStart);
    monthToEvents[currMonthStart] = _getEventsOfMonth(evs, currMonthStart);
    receivingMonths.remove(currMonthStart);
    monthToEvents[nextMonthStart] = _getEventsOfMonth(evs, nextMonthStart);
    receivingMonths.remove(nextMonthStart);
    for (Event e in evs) {
      var dateList = eventsMap.putIfAbsent(e.eventStartDate!, () => []);
      dateList.removeWhere((e1) => e1.eventID == e.eventID);
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
              .map((e) => e.map((k) => k.toJson()).toList())
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
              .map((e) => e.map((k) => k.toJson()).toList())
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
                .map((evs) =>
                    evs.map((e) => Event.fromJson(e)).toList().cast<Event>())
                .toList()
                .cast<List<Event>>();
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
        Iterable<List<Event>> values =
            (json.decode(prefs.getString(mteValuesStorageID) ?? '') as List)
                .map((evs) =>
                    evs.map((e) => Event.fromJson(e)).toList().cast<Event>());
        eventsMap = Map.fromIterables(keys, values);
        _eventsSubject.add(eventsMap);
      }
    }
  }
}
