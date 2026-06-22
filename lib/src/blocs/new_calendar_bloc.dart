// import 'package:InstiApp/src/api/apiclient.dart';
// import 'package:InstiApp/src/api/model/calendar_item.dart';
import 'package:InstiApp/src/api/response/calendar_feed_response.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';

class NewCalendarBloc {
  final InstiAppBloc bloc;

  final _calendarSubject = BehaviorSubject<CalendarFeedResponse>();

  ValueStream<CalendarFeedResponse> get calendar => _calendarSubject.stream;

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
  print('Calendar Response: $response');
    _calendarSubject.add(response);
    return response;
  }
}
