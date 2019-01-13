import 'dart:collection';

import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_calendar_carousel/classes/event.dart' as ev;
import 'package:date_format/date_format.dart';

class CalendarBloc {
  // parent bloc
  InstiAppBloc bloc;

  // Streams
  Stream<Map<DateTime, List<ev.Event>>> get events => _eventsSubject.stream;
  final _eventsSubject = BehaviorSubject<Map<DateTime, List<ev.Event>>>();

  Stream<bool> get loading => _loadingSubject.stream;
  final _loadingSubject = BehaviorSubject<bool>();

  // State
  Map<DateTime, List<Event>> monthToEvents = {};
  Map<DateTime, List<ev.Event>> calEventsMap = {};
  Map<DateTime, List<Event>> eventsMap = {};
  List<DateTime> receivingMonths = [];
  bool _loading = true;

  CalendarBloc(this.bloc) {
    _loadingSubject.add(_loading);
  }

  DateTime _getMonthStart(DateTime date) {
    return DateTime(date.year, date.month);
  }

  List<Event> _getEventsOfMonth(List<Event> evs, DateTime month) {
    return evs.where((e) {
      return e.eventStartDate.year == month.year &&
          e.eventStartDate.month == month.month;
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

    var havePrev = monthToEvents.containsKey(prevMonthStart) ||
        receivingMonths.contains(prevMonthStart);
    var haveCurr = monthToEvents.containsKey(currMonthStart) ||
        receivingMonths.contains(currMonthStart);
    var haveNext = monthToEvents.containsKey(nextMonthStart) ||
        receivingMonths.contains(nextMonthStart);
    if (!(havePrev && haveCurr && haveNext)) {
      if (!havePrev) {
        receivingMonths.add(prevMonthStart);
      }
      if (!haveCurr) {
        receivingMonths.add(currMonthStart);
      }
      if (!haveNext) {
        receivingMonths.add(nextMonthStart);
      }

      var newsFeedResp = await bloc.client.getEventsBetweenDates(
          bloc.getSessionIdHeader(),
          formatDate(
              havePrev
                  ? (haveCurr ? nextMonthStart : currMonthStart)
                  : prevMonthStart,
              isoFormat),
          formatDate(
              haveNext
                  ? (haveCurr ? currMonth : nextMonthStart)
                  : nextNextMonthStart,
              isoFormat));
      var evs = newsFeedResp.events;
      evs.forEach((e) {
        var time = DateTime.parse(e.eventStartTime);
        e.eventStartDate = DateTime(time.year, time.month, time.day);
      });

      if (!havePrev) {
        monthToEvents[prevMonthStart] = _getEventsOfMonth(evs, prevMonthStart);
        receivingMonths.remove(prevMonthStart);
      }
      if (!haveCurr) {
        monthToEvents[currMonthStart] = _getEventsOfMonth(evs, currMonthStart);
        receivingMonths.remove(currMonthStart);
      }
      if (!haveNext) {
        monthToEvents[nextMonthStart] = _getEventsOfMonth(evs, nextMonthStart);
        receivingMonths.remove(nextMonthStart);
      }
      for (Event e in evs) {
        calEventsMap.putIfAbsent(e.eventStartDate, () => []).add(
            ev.Event(date: e.eventStartDate, title: e.eventID, icon: icon));
        eventsMap.putIfAbsent(e.eventStartDate, () => []).add(e);
      }
      _eventsSubject.add(calEventsMap);
    }
    if (_loading) {
      _loading = false;
      _loadingSubject.add(_loading);
    }
  }
}
