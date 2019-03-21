import 'dart:async';

import 'package:rxdart/rxdart.dart';

class DrawerBloc {
  Stream<int> get highlightPageIndex => _pageIndexSubject.stream;
  final _pageIndexSubject = BehaviorSubject<int>();

  String currentRoute;
  int _highlightPageIndex;

  bool reloadNotifications = true;

  DrawerBloc(this.currentRoute, {int highlightPageIndexVal = 0}) {
    setPageIndex(highlightPageIndexVal);
  }

  setPageIndex(int pageIndex) {
    _highlightPageIndex = pageIndex;
    _pageIndexSubject.add(_highlightPageIndex);
  }
}
