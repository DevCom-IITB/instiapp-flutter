import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:InstiApp/src/api/response/calendar_feed_response.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';

class NewCalendarState {
  final DateTime currentDate;
  final DateTime selectedDate;

  const NewCalendarState({
    required this.currentDate,
    required this.selectedDate,
  });

  NewCalendarState copyWith({
    DateTime? currentDate,
    DateTime? selectedDate,
  }) {
    return NewCalendarState(
      currentDate: currentDate ?? this.currentDate,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class NewCalendarCubit extends ChangeNotifier {
  NewCalendarCubit({DateTime? initialDate})
      : _state = NewCalendarState(
          currentDate: _normalize(initialDate ?? DateTime.now()),
          selectedDate: _normalize(initialDate ?? DateTime.now()),
        );

  NewCalendarState _state;

  NewCalendarState get state => _state;

  DateTime get currentDate => _state.currentDate;
  DateTime get selectedDate => _state.selectedDate;

  int get selectedDay => _state.selectedDate.day;
  int get selectedMonth => _state.selectedDate.month;
  int get selectedYear => _state.selectedDate.year;
  String get selectedWeekday => _weekdayLabel(_state.selectedDate.weekday);

  static DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _weekdayLabel(int weekday) {
    const labels = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[weekday - 1];
  }

  bool isSelected(DateTime date) {
    final normalized = _normalize(date);
    return normalized.year == _state.selectedDate.year &&
        normalized.month == _state.selectedDate.month &&
        normalized.day == _state.selectedDate.day;
  }

  void selectDate(DateTime date) {
    final normalized = _normalize(date);
    if (isSelected(normalized) && normalized == _state.currentDate) {
      return;
    }
    _state = _state.copyWith(selectedDate: normalized, currentDate: normalized);
    notifyListeners();
  }

  void setVisibleDate(DateTime date) {
    final normalized = _normalize(date);
    if (normalized.year == _state.currentDate.year &&
        normalized.month == _state.currentDate.month &&
        normalized.day == _state.currentDate.day) {
      return;
    }
    _state = _state.copyWith(currentDate: normalized);
    notifyListeners();
  }

  void resetToToday() {
    final today = _normalize(DateTime.now());
    _state = _state.copyWith(selectedDate: today, currentDate: today);
    notifyListeners();
  }
}

class NewCalendarScope extends InheritedNotifier<NewCalendarCubit> {
  const NewCalendarScope({
    super.key,
    required NewCalendarCubit cubit,
    required Widget child,
  }) : super(notifier: cubit, child: child);

  static NewCalendarCubit of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<NewCalendarScope>();
    assert(scope != null, 'NewCalendarScope is not available in this context.');
    return scope!.notifier!;
  }
}

class NewCalendarBloc {
  final InstiAppBloc bloc;

  final ValueNotifier<CalendarFeedResponse?> _calendarNotifier =
      ValueNotifier<CalendarFeedResponse?>(null);

  ValueListenable<CalendarFeedResponse?> get calendar => _calendarNotifier;

  NewCalendarBloc(this.bloc);

  Future<CalendarFeedResponse> fetchCalendar(
    String sessionId,
    String start,
    String end,
  ) async {
    final response = await bloc.client.getCalendarFeed(
      sessionId,
      start,
      end,
      'Asia/Kolkata',
    );
    debugPrint('Calendar Response: $response');
    _calendarNotifier.value = response;
    return response;
  }
}
