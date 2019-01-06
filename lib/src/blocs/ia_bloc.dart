import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/blocs/drawer_bloc.dart';
import 'package:InstiApp/src/api/apiclient.dart';
import 'package:InstiApp/src/api/model/mess.dart';
import 'package:InstiApp/src/api/model/serializers.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'dart:collection';
import 'package:rxdart/rxdart.dart';
import 'package:http/io_client.dart';
import 'package:jaguar_retrofit/jaguar_retrofit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstiAppBloc {
  // Different Streams for the state
  Stream<UnmodifiableListView<Hostel>> get hostels => _hostelsSubject.stream;
  final _hostelsSubject = BehaviorSubject<UnmodifiableListView<Hostel>>();

  Stream<Session> get session => _sessionSubject.stream;
  final _sessionSubject = BehaviorSubject<Session>();

  Stream<UnmodifiableListView<Event>> get events => _eventsSubject.stream;
  final _eventsSubject = BehaviorSubject<UnmodifiableListView<Event>>();

  // Sub Blocs
  PostBloc placementBloc;
  PostBloc trainingBloc;
  PostBloc newsBloc;
  DrawerBloc drawerState;

  // actual current state
  Session currSession;
  var _hostels = <Hostel>[];
  var _events = <Event>[];

  // api functions
  final client = InstiAppApi();

  // default homepage
  String homepageName = "/mess";

  InstiAppBloc() {
    globalClient = IOClient();
    placementBloc = PostBloc(this, postType: PostType.Placement);
    trainingBloc = PostBloc(this, postType: PostType.Training);
    newsBloc = PostBloc(this, postType: PostType.NewsArticle);
    drawerState = DrawerBloc(homepageName, highlightPageIndexVal: 3);
  }

  PostBloc getPostsBloc(PostType blogType) {
    return {
      PostType.Placement: placementBloc,
      PostType.Training: trainingBloc,
      PostType.NewsArticle: newsBloc,
    }[blogType];
  }

  String getSessionIdHeader() {
    return "sessionid=" + (currSession?.sessionid ?? "");
  }

  Future<Null> updateHostels() async {
    var hostels = await client.getHostelMess();
    hostels.sort((h1, h2) => h1.compareTo(h2));
    _hostels = hostels;
   _hostelsSubject.add(UnmodifiableListView(_hostels));
  }

  Future<Null> updateEvents() async {
    var newsFeedResponse = await client.getNewsFeed(getSessionIdHeader());
    _events = newsFeedResponse.events;
    if (_events.length >= 1) {
      _events[0].eventBigImage = true;
    }
    _eventsSubject.add(UnmodifiableListView(_events));
  }

  Future<Event> getEvent(String uuid) async {
    try {
      return _events?.firstWhere((event) => event.eventID == uuid);
    } catch (ex) {
      print(ex);
      return client.getEvent(getSessionIdHeader(), uuid);
    }
    // return client.getEvent(getSessionIdHeader(), uuid);
  }

  Future<Body> getBody(String uuid) async {
    return client.getBody(getSessionIdHeader(), uuid);
  }

  Future<User> getUser(String uuid) async {
    return uuid == "me"
        ? (currSession?.profile ?? client.getUserMe(getSessionIdHeader()))
        : client.getUser(getSessionIdHeader(), uuid);
  }

  void updateSession(Session sess) {
    currSession = sess;
    _sessionSubject.add(sess);
    _persistSession(sess);
  }

  Future<void> updateUesEvent(Event e, int ues) async {
    try {
      print("updating Ues from ${e.eventUserUes} to $ues");
      await client.updateUserEventStatus(getSessionIdHeader(), e.eventID, ues);
      if (e.eventUserUes == 2) {
        e.eventGoingCount--;
      }
      if (e.eventUserUes == 1) {
        e.eventInterestedCount--;
      }
      if (ues == 1) {
        e.eventInterestedCount++;
      } else if (ues == 2) {
        e.eventGoingCount++;
      }
      e.eventUserUes = ues;
      print("updated Ues from ${e.eventUserUes} to $ues");
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> updateFollowBody(Body b) async {
    try {
      await client.updateBodyFollowing(
          getSessionIdHeader(), b.bodyID, b.bodyUserFollows ? 0 : 1);
      b.bodyUserFollows = !b.bodyUserFollows;
      b.bodyFollowersCount += b.bodyUserFollows ? 1 : -1;
    } catch (ex) {
      print(ex);
    }
  }

  void _persistSession(Session sess) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("session", standardSerializers.encode(sess));
  }

  void logout() {
    updateSession(null);
  }
}
