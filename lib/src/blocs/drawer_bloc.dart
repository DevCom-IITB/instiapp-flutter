
import 'package:rxdart/rxdart.dart';

class DrawerBloc {
  ValueStream<int> get highlightPageIndex => _pageIndexSubject.stream;
  final _pageIndexSubject = BehaviorSubject<int>();

  String currentRoute;
  late int _highlightPageIndex;

  bool reloadNotifications = true;

  DrawerBloc(this.currentRoute, {int highlightPageIndexVal = 0}) {
    setPageIndex(highlightPageIndexVal);
  }

  setPageIndex(int pageIndex) {
    _highlightPageIndex = pageIndex;
    _pageIndexSubject.add(_highlightPageIndex);
  }
}
