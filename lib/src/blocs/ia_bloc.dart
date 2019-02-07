import 'package:InstiApp/main.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/api/request/user_fcm_patch_request.dart';
import 'package:InstiApp/src/api/request/user_scn_patch_request.dart';
import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/blocs/calendar_bloc.dart';
import 'package:InstiApp/src/blocs/complaints_bloc.dart';
import 'package:InstiApp/src/blocs/drawer_bloc.dart';
import 'package:InstiApp/src/api/apiclient.dart';
import 'package:InstiApp/src/api/model/mess.dart';
import 'package:InstiApp/src/api/model/serializers.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/blocs/explore_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:rxdart/rxdart.dart';
import 'package:http/io_client.dart';
import 'package:jaguar_retrofit/jaguar_retrofit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:InstiApp/src/api/model/notification.dart' as ntf;

/// Describes the contrast needs of a color.
class AppBrightness {
  final index;
  const AppBrightness._internal(this.index);
  toString() => 'AppBrightness.$index';

  /// The color is dark and will require a light text color to achieve readable
  /// contrast.
  ///
  /// For example, the color might be dark grey, requiring white text.

  static const dark = const AppBrightness._internal(0);

  /// The color is light and will require a dark text color to achieve readable
  /// contrast.
  ///
  /// For example, the color might be bright white, requiring black text.

  static const light = const AppBrightness._internal(1);

  /// The color is black and will require a light text color to achieve readable
  /// contrast.
  ///
  /// For example, the color might be black, requiring white text.
  static const black = const AppBrightness._internal(2);

  static const brightnessToCanvasColor = {
    light: Colors.white,
    dark: Color(0xff303030),
    black: Colors.black,
  };

  static const values = [dark, light, black];

  Brightness toBrightness() {
    return index == 2 ? Brightness.dark : Brightness.values[index];
  }

  Color toColor() {
    return brightnessToCanvasColor[this];
  }
}

class InstiAppBloc {
  // Events StorageID
  static String eventStorageID = "events";
  // Mess StorageID
  static String messStorageID = "mess";
  // Notifications StorageID
  static String notificationsStorageID = "notifications";

  // FCM handle
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  // Different Streams for the state
  Stream<UnmodifiableListView<Hostel>> get hostels => _hostelsSubject.stream;
  final _hostelsSubject = BehaviorSubject<UnmodifiableListView<Hostel>>();

  Stream<Session> get session => _sessionSubject.stream;
  final _sessionSubject = BehaviorSubject<Session>();

  Stream<UnmodifiableListView<Event>> get events => _eventsSubject.stream;
  final _eventsSubject = BehaviorSubject<UnmodifiableListView<Event>>();

  Stream<UnmodifiableListView<ntf.Notification>> get notifications =>
      _notificationsSubject.stream;
  final _notificationsSubject =
      BehaviorSubject<UnmodifiableListView<ntf.Notification>>();

  // Sub Blocs
  PostBloc placementBloc;
  PostBloc trainingBloc;
  PostBloc newsBloc;
  ExploreBloc exploreBloc;
  CalendarBloc calendarBloc;
  ComplaintsBloc complaintsBloc;
  DrawerBloc drawerState;

  // actual current state
  Session currSession;
  var _hostels = <Hostel>[];
  var _events = <Event>[];
  var _notifications = <ntf.Notification>[];

  // api functions
  final client = InstiAppApi();

  // default homepage
  String homepageName = "/mess";

  // default theme
  AppBrightness _brightness = AppBrightness.light;
  // Color _primaryColor = Color.fromARGB(255, 63, 81, 181);
  Color _primaryColor = Color.fromARGB(255, 0, 98, 255);
  Color _accentColor = Color.fromARGB(255, 239, 83, 80);
  // Color _accentColor = Color.fromARGB(255, 139, 195, 74);

  // Navigator Stack
  MNavigatorObserver navigatorObserver;

  AppBrightness get brightness => _brightness;

  set brightness(AppBrightness newBrightness) {
    if (newBrightness != _brightness) {
      wholeAppKey.currentState.setTheme(() => _brightness = newBrightness);
      SharedPreferences.getInstance().then((s) {
        s.setInt("brightness", newBrightness.index);
      });
    }
  }

  Color get primaryColor => _primaryColor;

  set primaryColor(Color newColor) {
    if (newColor != _primaryColor) {
      wholeAppKey.currentState.setTheme(() => _primaryColor = newColor);
      SharedPreferences.getInstance().then((s) {
        s.setInt("primaryColor", newColor.value);
      });
    }
  }

  Color get accentColor => _accentColor;

  set accentColor(Color newColor) {
    if (newColor != _accentColor) {
      wholeAppKey.currentState.setTheme(() => _accentColor = newColor);
      SharedPreferences.getInstance().then((s) {
        s.setInt("accentColor", newColor.value);
      });
    }
  }

  // all pages
  Map<String, int> pageToIndex = {
    '/feed': 0,
    '/news': 1,
    '/explore': 2,
    '/mess': 3,
    '/placeblog': 4,
    '/trainblog': 5,
    '/calendar': 6,
    '/map': 7,
    '/complaints': 8,
    '/quicklinks': 9,
    '/settings': 10,
  };

  // MaterialApp reference
  GlobalKey<MyAppState> wholeAppKey;

  InstiAppBloc({@required this.wholeAppKey}) {
    globalClient = IOClient();
    placementBloc = PostBloc(this, postType: PostType.Placement);
    trainingBloc = PostBloc(this, postType: PostType.Training);
    newsBloc = PostBloc(this, postType: PostType.NewsArticle);
    exploreBloc = ExploreBloc(this);
    calendarBloc = CalendarBloc(this);
    complaintsBloc = ComplaintsBloc(this);
    drawerState = DrawerBloc(homepageName, highlightPageIndexVal: 3);
    navigatorObserver = MNavigatorObserver(this);
  }

  // Settings bloc
  Future<void> updateHomepage(String s) async {
    homepageName = s;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("homepage", s);
  }

  Future<void> patchUserShowContactNumber(bool userShowContactNumber) async {
    var userMe = await client.patchSCNUserMe(getSessionIdHeader(),
        UserSCNPatchRequest()..userShowContactNumber = userShowContactNumber);
    currSession.profile = userMe;
    updateSession(currSession);
  }

  // PostBloc helper function
  PostBloc getPostsBloc(PostType blogType) {
    return {
      PostType.Placement: placementBloc,
      PostType.Training: trainingBloc,
      PostType.NewsArticle: newsBloc,
    }[blogType];
  }

  // Mess bloc
  Future<void> updateHostels() async {
    var hostels = await client.getHostelMess();
    hostels.sort((h1, h2) => h1.compareTo(h2));
    _hostels = hostels;
    _hostelsSubject.add(UnmodifiableListView(_hostels));
  }

  // Event bloc
  Future<void> updateEvents() async {
    var newsFeedResponse = await client.getNewsFeed(getSessionIdHeader());
    _events = newsFeedResponse.events;
    if (_events.length >= 1) {
      _events[0].eventBigImage = true;
    }
    _eventsSubject.add(UnmodifiableListView(_events));
  }

  // Notifications bloc
  Future<void> updateNotifications() async {
    var notifs = await client.getNotifications(getSessionIdHeader());
    _notifications = notifs;
    _notificationsSubject.add(UnmodifiableListView(_notifications));
  }

  Future clearAllNotifications() async {
    await client.markAllNotificationsRead(getSessionIdHeader());
    _notifications = [];
    _notificationsSubject.add(UnmodifiableListView(_notifications));
  }

  Future clearNotification(ntf.Notification notification) async {
    await clearNotificationUsingID("${notification.notificationId}");
    var idx = _notifications
        .indexWhere((n) => n.notificationId == notification.notificationId);
    print(idx);
    if (idx != -1) {
      _notifications.removeAt(idx);
      _notificationsSubject.add(UnmodifiableListView(_notifications));
    }
  }

  Future clearNotificationUsingID(String notificationId) async {
    return client.markNotificationRead(getSessionIdHeader(), notificationId);
  }

  // Section
  // Navigator helper
  Future<Event> getEvent(String uuid) async {
    try {
      return _events?.firstWhere((event) => event.eventID == uuid);
    } catch (ex) {
      return client.getEvent(getSessionIdHeader(), uuid);
    }
  }

  Future<Body> getBody(String uuid) async {
    return client.getBody(getSessionIdHeader(), uuid);
  }

  Future<User> getUser(String uuid) async {
    return uuid == "me"
        ? (currSession?.profile ?? client.getUserMe(getSessionIdHeader()))
        : client.getUser(getSessionIdHeader(), uuid);
  }

  Future<Complaint> getComplaint(String uuid, {bool reload = false}) async {
    return complaintsBloc.getComplaint(uuid, reload: reload);
  }

  // Section
  // Send FCM key
  Future<void> patchFcmKey() async {
    var req = UserFCMPatchRequest()
      ..userAndroidVersion = 28
      ..userFCMId = await firebaseMessaging.getToken();
    var userMe = await client.patchFCMUserMe(getSessionIdHeader(), req);
    currSession.profile = userMe;
    updateSession(currSession);
  }

  // Section
  // User/Body/Event updates
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

  bool editEventAccess(Event event) {
    return currSession?.profile?.userRoles?.any((r) => r.roleBodies.any(
            (b) => event.eventBodies.any((b1) => b.bodyID == b1.bodyID))) ??
        false;
  }

  bool editBodyAccess(Body body) {
    return currSession?.profile?.userRoles
            ?.any((r) => r.roleBodies.any((b) => b.bodyID == body.bodyID)) ??
        false;
  }

  // Section
  // Bloc state management
  Future<void> restorePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getKeys().contains("session")) {
      Session sess = standardSerializers.decodeOne(prefs.getString("session"));
      if (sess?.sessionid != null) {
        updateSession(sess);
      }
    }
    if (prefs.getKeys().contains("homepage")) {
      homepageName = prefs.getString("homepage") ?? homepageName;
      drawerState.setPageIndex(pageToIndex[homepageName]);
    }
    if (prefs.getKeys().contains("brightness")) {
      _brightness =
          AppBrightness.values[prefs.getInt("brightness")] ?? _brightness;
    }
    if (prefs.getKeys().contains("accentColor")) {
      _accentColor = Color(prefs.getInt("accentColor")) ?? _accentColor;
    }
    if (prefs.getKeys().contains("primaryColor")) {
      _primaryColor = Color(prefs.getInt("primaryColor")) ?? _primaryColor;
    }

    restoreFromCache(sharedPrefs: prefs);
  }

  // Section
  // Session management
  void updateSession(Session sess) {
    currSession = sess;
    _sessionSubject.add(sess);
    _persistSession(sess);
  }

  void _persistSession(Session sess) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("session", standardSerializers.encode(sess));
  }

  Future<void> reloadCurrentUser() async {
    var userMe = await client.getUserMe(getSessionIdHeader());
    currSession.profile = userMe;
    updateSession(currSession);
  }

  String getSessionIdHeader() {
    return currSession?.sessionid != null
        ? "sessionid=${currSession.sessionid}"
        : "";
  }

  Future<void> logout() async {
    await client.logout(getSessionIdHeader());
    updateSession(null);
  }

  Future saveToCache({SharedPreferences sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (_hostels?.isNotEmpty ?? false) {
      prefs.setString(messStorageID, standardSerializers.encode(_hostels));
    }
    if (_events?.isNotEmpty ?? false) {
      prefs.setString(eventStorageID, standardSerializers.encode(_events));
    }
    if (_notifications?.isNotEmpty ?? false) {
      prefs.setString(
          notificationsStorageID, standardSerializers.encode(_notifications));
    }

    exploreBloc?.saveToCache(sharedPrefs: prefs);
    complaintsBloc?.saveToCache(sharedPrefs: prefs);
    calendarBloc?.saveToCache(sharedPrefs: prefs);
  }

  Future restoreFromCache({SharedPreferences sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (prefs.getKeys().contains(messStorageID)) {
      _hostels = standardSerializers
          .decodeList<Hostel>(prefs.getString(messStorageID));
      _hostelsSubject.add(UnmodifiableListView(_hostels));
    }

    if (prefs.getKeys().contains(eventStorageID)) {
      _events = standardSerializers
          .decodeList<Event>(prefs.getString(eventStorageID));
      if (_events.length >= 1) {
        _events[0].eventBigImage = true;
      }
      _eventsSubject.add(UnmodifiableListView(_events));
    }

    if (prefs.getKeys().contains(notificationsStorageID)) {
      _notifications = standardSerializers.decodeList<ntf.Notification>(
          prefs.getString(notificationsStorageID));
      _notificationsSubject.add(UnmodifiableListView(_notifications));
    }

    exploreBloc?.restoreFromCache(sharedPrefs: prefs);
    complaintsBloc?.restoreFromCache(sharedPrefs: prefs);
    calendarBloc?.restoreFromCache(sharedPrefs: prefs);
  }
}
