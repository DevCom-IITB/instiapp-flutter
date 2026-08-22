import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:InstiApp/main.dart';
import 'package:InstiApp/src/api/apiclient.dart';
import 'package:InstiApp/src/api/chatbotapiclient.dart';
import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/mess.dart';
import 'package:InstiApp/src/api/model/notification.dart' as ntf;
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/api/request/achievement_hidden_patch_request.dart';
import 'package:InstiApp/src/api/request/postFAQ_request.dart';
import 'package:InstiApp/src/api/request/user_fcm_patch_request.dart';
import 'package:InstiApp/src/api/request/user_scn_patch_request.dart';
import 'package:InstiApp/src/api/response/alumni_login_response.dart';
import 'package:InstiApp/src/api/response/getencr_response.dart';
import 'package:InstiApp/src/blocs/ach_to_vefiry_bloc.dart';
import 'package:InstiApp/src/blocs/achievementform_bloc.dart';
import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/blocs/buynsell_post_bloc.dart';
import 'package:InstiApp/src/blocs/calendar_bloc.dart';
import 'package:InstiApp/src/blocs/community_bloc.dart';
import 'package:InstiApp/src/blocs/community_post_bloc.dart';
import 'package:InstiApp/src/blocs/complaints_bloc.dart';
import 'package:InstiApp/src/blocs/drawer_bloc.dart';
import 'package:InstiApp/src/blocs/explore_bloc.dart';
import 'package:InstiApp/src/blocs/lost_and_found_bloc.dart';
import 'package:InstiApp/src/blocs/map_bloc.dart';
import 'package:InstiApp/src/blocs/mess_calendar_bloc.dart';
import 'package:InstiApp/src/api/response/calendar_feed_response.dart';
import 'package:InstiApp/src/api/model/calendar_item.dart';
import 'package:InstiApp/src/api/model/resobin_course.dart';
import 'package:InstiApp/src/api/model/calendar_body_preference.dart';
import 'package:InstiApp/src/api/model/calendar_body.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/app_brightness.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
// import 'package:http/io_client.dart';
// import 'package:http/browser_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:InstiApp/src/api/response/calendar_preference_response.dart';

enum AddToCalendar { AlwaysAsk, Yes, No }

ColorSwatch _getMatSwatch(int darkColor, int lightColor) {
  return MaterialColor(
    darkColor,
    {
      50: Color(lightColor),
      100: Color(lightColor),
      200: Color(lightColor),
      300: Color(lightColor),
      400: Color(lightColor),
      500: Color(darkColor),
      600: Color(darkColor),
      700: Color(darkColor),
      800: Color(darkColor),
      900: Color(darkColor),
    },
  );
}

List<ColorSwatch<dynamic>> appColors = [
  _getMatSwatch(0xFF9747FF, 0xFFE4CCFF),
  _getMatSwatch(0xFF435FFE, 0xFFC0C9FF),
  _getMatSwatch(0xFF0D99FF, 0xFFBDE3FF),
  _getMatSwatch(0xFF14AE5C, 0xFFAFF4C6),
  _getMatSwatch(0xFFFFCD29, 0xFFFFE8A3),
  _getMatSwatch(0xFFFFA629, 0xFFFCD19C),
  _getMatSwatch(0xFFF24822, 0xFFFFC7C2),
  _getMatSwatch(0xFFB3B3B3, 0xFFE6E6E6),
  _getMatSwatch(0xFF1E1E1E, 0xFF757575),
];

class InstiAppBloc {
  // Dio instance
  final dio = Dio();

  // Cache for calendar feeds: key is "start_end_showInstiappGoing_showInstiappFollowedBodies_showResobin" -> response
  final Map<String, CalendarFeedResponse> _calendarFeedCache = {};

  // Cache for Resobin schedule
  List<ResobinCourse>? _cachedResobinFeed;

  void clearCalendarFeedCache() {
    _calendarFeedCache.clear();
    debugPrint('InstiAppBloc: cleared calendar feed cache');
  }

  // Events StorageID
  static String eventStorageID = "events";
  // Mess StorageID
  static String messStorageID = "mess";
  // Notifications StorageID
  static String notificationsStorageID = "notifications";
  // Achievement StorageID
  static String achievementStorageID = "achievement";

  // FCM handle
  // final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // Different Streams for the state
  ValueStream<UnmodifiableListView<Hostel>> get hostels =>
      _hostelsSubject.stream;
  final _hostelsSubject = BehaviorSubject<UnmodifiableListView<Hostel>>();

  ValueStream<Session?> get session => _sessionSubject.stream;
  final _sessionSubject = BehaviorSubject<Session?>();

  ValueStream<UnmodifiableListView<Event>> get events => _eventsSubject.stream;
  final _eventsSubject = BehaviorSubject<UnmodifiableListView<Event>>();

  ValueStream<UnmodifiableListView<ntf.Notification>> get notifications =>
      _notificationsSubject.stream;
  final _notificationsSubject =
      BehaviorSubject<UnmodifiableListView<ntf.Notification>>();

  ValueStream<UnmodifiableListView<Achievement>> get achievements =>
      _achievementSubject.stream;
  final _achievementSubject =
      BehaviorSubject<UnmodifiableListView<Achievement>>();

  // Sub Blocs
  late PostBloc placementBloc;
  late PostBloc externalBloc;
  late PostBloc trainingBloc;
  late PostBloc newsBloc;
  late PostBloc queryBloc;
  late PostBloc chatBotBloc;
  late ExploreBloc exploreBloc;
  late CalendarBloc calendarBloc;
  late MessCalendarBloc messCalendarBloc;
  late ComplaintsBloc complaintsBloc;
  late DrawerBloc drawerState;
  late MapBloc mapBloc;
  late Bloc achievementBloc;
  late VerifyBloc bodyAchBloc;
  late CommunityBloc communityBloc;
  late CommunityPostBloc communityPostBloc;
  late BuynSellPostBloc buynSellPostBloc;
  late LostAndFoundPostBloc lostAndFoundPostBloc;
  // actual current state
  Session? currSession;
  CalendarPreferencesResponse? calendarPreferences;
  List<CalendarBodyPreference>? calendarPrefBodies;
  List<CalendarBody>? calendarShared;
  var _hostels = <Hostel>[];
  var _events = <Event>[];
  var _achievements = <Achievement>[];
  var _notifications = <ntf.Notification>[];

  // api functions
  late final InstiAppApi client;
  late final ChatBotApi clientChatBot;

  // default homepage
  String homepageName = "/feed";
  bool isAlumni = false;
  String msg = "";
  String alumniLoginPage = "/alumniLoginPage";
  String ldap = "";
  //to implement method for toggling isAlumnReg
  String alumni_OTP_Page = "/alumni-OTP-Page";
  String _alumniOTP = "";
  // to create method to update this from apiclient.dart
  // default theme
  AppBrightness _brightness = AppBrightness.light;
  // Color _primaryColor = Color.fromARGB(255, 63, 81, 181);
  // Color _accentColor = Color.fromARGB(255, 139, 195, 74);
  ColorSwatch _primaryColor = appColors[1];
  ColorSwatch _accentColor = appColors[6];

  List<List<ColorSwatch>> defaultThemes = [
    // default theme 1
    [
      appColors[1],
      appColors[6],
    ]
  ];

  // Default Add To Calendar
  AddToCalendar _addToCalendarSetting = AddToCalendar.AlwaysAsk;

  AddToCalendar get addToCalendarSetting => _addToCalendarSetting;

  set addToCalendarSetting(AddToCalendar mAddToCalendarSetting) {
    if (mAddToCalendarSetting != _addToCalendarSetting) {
      _addToCalendarSetting = mAddToCalendarSetting;
      SharedPreferences.getInstance().then((s) {
        s.setInt("addToCalendarSetting", _addToCalendarSetting.index);
      });
    }
  }

  // Default Calendars to add
  List<String> _defaultCalendarsSetting = <String>[];

  List<String> get defaultCalendarsSetting => _defaultCalendarsSetting;

  set defaultCalendarsSetting(List<String> mDefaultCalendarsSetting) {
    if (mDefaultCalendarsSetting != _defaultCalendarsSetting) {
      _defaultCalendarsSetting = mDefaultCalendarsSetting;
      SharedPreferences.getInstance().then((s) {
        s.setStringList("defaultCalendarsSetting", _defaultCalendarsSetting);
      });
    }
  }

  // Navigator Stack
  late MNavigatorObserver navigatorObserver;

  AppBrightness get brightness => _brightness;

  set brightness(AppBrightness newBrightness) {
    if (newBrightness != _brightness) {
      wholeAppKey.currentState?.setTheme(() => _brightness = newBrightness);
      SharedPreferences.getInstance().then((s) {
        s.setInt("brightness", newBrightness.index);
      });
    }
  }

  ColorSwatch get primaryColor => _primaryColor;

  set primaryColor(ColorSwatch newColor) {
    if (newColor != _primaryColor) {
      wholeAppKey.currentState?.setTheme(() => _primaryColor = newColor);
      SharedPreferences.getInstance().then((s) {
        s.setInt("primaryColor", appColors.indexOf(newColor));
      });
    }
  }

  ColorSwatch get accentColor => _accentColor;

  set accentColor(ColorSwatch newColor) {
    if (newColor != _accentColor) {
      wholeAppKey.currentState?.setTheme(() => _accentColor = newColor);
      SharedPreferences.getInstance().then((s) {
        s.setInt("accentColor", appColors.indexOf(newColor));
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
    '/externalblog': 12,
    '/groups': 15,
  };

  // MaterialApp reference
  GlobalKey<MyAppState> wholeAppKey;

  InstiAppBloc({required this.wholeAppKey}) {
    // if (kIsWeb) {
    //   globalClient = BrowserClient();
    // } else {
    // }
    client = InstiAppApi(dio);
    clientChatBot = ChatBotApi(dio);
    placementBloc = PostBloc(this, postType: PostType.Placement);
    externalBloc = PostBloc(this, postType: PostType.External);
    trainingBloc = PostBloc(this, postType: PostType.Training);
    newsBloc = PostBloc(this, postType: PostType.NewsArticle);
    queryBloc = PostBloc(this, postType: PostType.Query);
    chatBotBloc = PostBloc(this, postType: PostType.ChatBot);
    exploreBloc = ExploreBloc(this);
    calendarBloc = CalendarBloc(this);
    // complaintsBloc = ComplaintsBloc(this);
    drawerState = DrawerBloc(homepageName, highlightPageIndexVal: 0);
    navigatorObserver = MNavigatorObserver(this);
    mapBloc = MapBloc(this);
    achievementBloc = Bloc(this);
    bodyAchBloc = VerifyBloc(this);
    messCalendarBloc = MessCalendarBloc(this);
    communityBloc = CommunityBloc(this);
    communityPostBloc = CommunityPostBloc(this);
    buynSellPostBloc = BuynSellPostBloc(this);
    lostAndFoundPostBloc = LostAndFoundPostBloc(this);

    _initNotificationBatch();
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
    currSession?.profile = userMe;
    updateSession(currSession!);
  }

  // PostBloc helper function
  PostBloc? getPostsBloc(PostType blogType) {
    return {
      PostType.Placement: placementBloc,
      PostType.External: externalBloc,
      PostType.Training: trainingBloc,
      PostType.NewsArticle: newsBloc,
      PostType.Query: queryBloc,
      PostType.ChatBot: chatBotBloc,
    }[blogType];
  }

  // Mess bloc
  static const _hostelCacheKey = 'cached_hostel_mess';

  Future<void> _saveHostelsToCache(List<Hostel> hostels) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = hostels.map((h) => h.toJson()).toList();
    prefs.setString(_hostelCacheKey, jsonEncode(jsonList));
  }

  Future<List<Hostel>> _loadHostelsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_hostelCacheKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Hostel.fromJson(e)).toList();
  }

  final _hostelNetworkErrorController = StreamController<bool>.broadcast();
  Stream<bool> get hostelNetworkError => _hostelNetworkErrorController.stream;

  Future<void> updateHostels() async {
    // 1. Load cache FIRST
    final cached = await _loadHostelsFromCache();
    if (cached.isNotEmpty) {
      cached.sort((a, b) => a.compareTo(b));
      _hostels = cached;
      _hostelsSubject.add(UnmodifiableListView(_hostels));
    }

    // 2. Try network fetch
    try {
      final fresh = await client.getHostelMess();
      fresh.sort((a, b) => a.compareTo(b));

      _hostels = fresh;
      _hostelsSubject.add(UnmodifiableListView(_hostels));

      // 3. Save new data
      await _saveHostelsToCache(fresh);
      _hostelNetworkErrorController.add(false);
    } on DioException catch (e) {
      // Network error → keep cached data
      debugPrint('Mess fetch failed, using cache: ${e.message}');
      _hostelNetworkErrorController.add(true);
    } catch (e) {
      debugPrint('Unexpected error in updateHostels: $e');
    }
  }

  Future<String?> getQRString() async {
    GetEncrResponse res = await client.getEncr(getSessionIdHeader());
    return res.qrstring;
  }

  // Event bloc
  Future<void> updateEvents() async {
    var newsFeedResponse = await client.getNewsFeed(getSessionIdHeader());
    _events = newsFeedResponse.events ?? [];
    if (_events.length >= 1) {
      _events[0].eventBigImage = true;
    }
    _eventsSubject.add(UnmodifiableListView(_events));
  }

  String get alumniID => ldap;
  setAlumniID(updtAlumniID) {
    ldap = updtAlumniID;
  }

  String get alumniOTP => _alumniOTP;
  setAlumniOTP(updtAlumniOTP) {
    _alumniOTP = updtAlumniOTP;
  }

  Future<void> updateAlumni() async {
    var _alumniLoginResponse = await client.AlumniLogin(ldap);
    isAlumni = _alumniLoginResponse.exist ?? false;
    msg = _alumniLoginResponse.msg ?? "";
  }

  Future<void> logAlumniIn(bool resend) async {
    AlumniLoginResponse _alumniLoginResponse = resend
        ? await client.ResendAlumniOTP(ldap)
        : await client.AlumniOTP(ldap, _alumniOTP);
    isAlumni = !(_alumniLoginResponse.error_status ?? true);
    msg = _alumniLoginResponse.msg ?? "";
    if (!resend) {
      if (isAlumni) {
        Session newSession = Session(
          sessionid: _alumniLoginResponse.sessionid,
          user: _alumniLoginResponse.user,
          profile: _alumniLoginResponse.profile,
          profileId: _alumniLoginResponse.profileId,
        );
        // print(newSession.toJson());
        updateSession(newSession);
      }
    }
  }

  // Your Achievement Bloc
  Future<void> updateAchievements() async {
    var yourAchievementResponse =
        await client.getYourAchievements(getSessionIdHeader());
    _achievements = yourAchievementResponse;
    _achievementSubject.add(UnmodifiableListView(_achievements));
  }

  // Notifications bloc
  void updateNotificationPermission(bool permitted) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("notifP", permitted);
  }

  Future<bool?> hasNotificationPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("notifP");
  }

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
    // print(idx);
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
  Future<Event?> getEvent(String uuid) async {
    // try {
    //   return _events.firstWhere((event) => event.eventID == uuid);
    // } catch (ex) {
    return client.getEvent(getSessionIdHeader(), uuid);
  }

  Future<Body> getBody(String uuid) async {
    return client.getBody(getSessionIdHeader(), uuid);
  }

  Future<User> getUser(String uuid) async {
    return uuid == "me"
        ? (currSession?.profile ?? await client.getUserMe(getSessionIdHeader()))
        : await client.getUser(getSessionIdHeader(), uuid);
  }

  Future<Complaint?>? getComplaint(String uuid, {bool reload = false}) async {
    return complaintsBloc.getComplaint(uuid, reload: reload);
  }

  // Section
  // Send FCM key
  Future<void> patchFcmKey() async {
    if (currSession == null || currSession?.sessionid == null) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;

      var req = UserFCMPatchRequest()
        ..userAndroidVersion = 28
        ..userFCMId = token;

      var userMe = await client.patchFCMUserMe(getSessionIdHeader(), req);
      currSession?.profile = userMe;
      updateSession(currSession!);
    } catch (e, st) {
      print("patchFcmKey failed: $e\n$st");
    }
  }

  Future<void> refreshUserProfile() async {
    if (currSession == null || currSession!.sessionid == null) return;

    try {
      final userMe = await client.getUserMe(getSessionIdHeader());
      currSession!.profile = userMe;
      _sessionSubject.add(currSession);
      _persistSession(currSession); // update cached session
    } catch (e) {
      print("Error refreshing profile: $e");
    }
  }

  // Section
  // User/Body/Event updates
  Future<void> updateUesEvent(Event e, UES ues) async {
    try {
      // print("updating Ues from ${e.eventUserUes} to $ues");
      await client.updateUserEventStatus(
          getSessionIdHeader(), e.eventID ?? "", ues.index);
      if (e.eventUserUes == UES.Going) {
        e.eventGoingCount--;
      }
      if (e.eventUserUes == UES.Interested) {
        e.eventInterestedCount--;
      }
      if (ues == UES.Interested) {
        e.eventInterestedCount++;
      } else if (ues == UES.Going) {
        e.eventGoingCount++;
      }
      // print("updated Ues from ${e.eventUserUes} to $ues");
      e.eventUserUes = ues;
    } catch (ex) {
      // print(ex);
    }
  }

  Future<void> updateHiddenAchievement(
      Achievement achievement, bool hidden) async {
    try {
      // print("Updating hidden");
      await client.toggleHidden(getSessionIdHeader(), achievement.id ?? "",
          AchievementHiddenPathRequest()..hidden = hidden);
      achievement.hidden = hidden;
      // print("Updated hidden");
    } catch (e) {
      // print(e);
    }
  }

  Future<void> postFAQ(PostFAQRequest postFAQRequest) async {
    try {
      await client.postFAQ(getSessionIdHeader(), postFAQRequest);
    } catch (e) {
      // print(e);
    }
  }

  Future<void> updateFollowBody(Body b) async {
    try {
      await client.updateBodyFollowing(
          getSessionIdHeader(), b.bodyID ?? "", b.bodyUserFollows! ? 0 : 1);
      b.bodyUserFollows = !b.bodyUserFollows!;
      b.bodyFollowersCount =
          b.bodyFollowersCount! + (b.bodyUserFollows! ? 1 : -1);
    } catch (ex) {
      // print(ex);
    }
  }

  Future<void> updateFollowCommunity(Community c) async {
    try {
      await client.updateBodyFollowing(
          getSessionIdHeader(), c.body ?? "", c.isUserFollowing! ? 0 : 1);
      c.isUserFollowing = !c.isUserFollowing!;
      c.followersCount = c.followersCount! + (c.isUserFollowing! ? 1 : -1);
    } catch (ex) {
      // print(ex);
    }
  }

  bool editEventAccess(Event event) {
    return currSession?.profile?.userRoles?.any((r) => r.roleBodies!.any(
            (b) => event.eventBodies!.any((b1) => b.bodyID == b1.bodyID))) ??
        false;
  }

  List<Body> getBodiesWithPermission(String permission) {
    if (currSession?.profile == null) {
      return [];
    }
    List<Body> bodies = [];
    List<Role>? roles = this.currSession?.profile?.userRoles!;
    if (roles != null) {
      for (Role role in roles) {
        if (role.rolePermissions!.contains(permission)) {
          for (Body body in role.roleBodies!) {
            bodies.add(body);
          }
        }
      }
    }
    return bodies;
  }

  bool deleteEventAccess(Event event) {
    for (Body body in event.eventBodies!) {
      if (this
              .getBodiesWithPermission('DelE')
              .map((e) => e.bodyID!)
              .toList()
              .indexOf(body.bodyID!) !=
          -1) {
        return true;
      }
    }
    return currSession?.profile?.userRoles?.any((r) => r.roleBodies!.any(
            (b) => event.eventBodies!.any((b1) => b.bodyID == b1.bodyID))) ??
        false;
  }

  bool editBodyAccess(Body body) {
    return currSession?.profile?.userRoles
            ?.any((r) => r.roleBodies!.any((b) => b.bodyID == body.bodyID)) ??
        false;
  }

  bool hasPermission(String bodyId, String permission) {
    if (currSession == null) {
      return false;
    }

    return currSession?.profile?.userRoles?.any((element) =>
            ((element.rolePermissions?.contains(permission) ?? false) &&
                element.roleBody == bodyId)) ??
        false;
  }

  // Section
  // Bloc state management
  Future<void> restorePrefs() async {
    // print("Restoring prefs");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getKeys().contains("session")) {
      var x = prefs.getString("session");
      if (x != null && x != "") {
        Session? sess = Session.fromJson(json.decode(x));
        if (sess.sessionid != null) {
          updateSession(sess);
        }
      }
    }
    if (prefs.getKeys().contains("homepage")) {
      homepageName = prefs.getString("homepage") ?? homepageName;
      int? x = pageToIndex[homepageName];
      drawerState.setPageIndex(x!);
    }
    if (prefs.getKeys().contains("brightness")) {
      int? x = prefs.getInt("brightness");
      if (x != null) _brightness = AppBrightness.values[x];
    }
    if (prefs.getKeys().contains("accentColor")) {
      int? x = prefs.getInt("accentColor");
      if (x != null) {
        if (x < 0 || x >= appColors.length)
          prefs.remove("accentColor");
        else
          _accentColor = appColors[x];
      }
    }
    if (prefs.getKeys().contains("primaryColor")) {
      int? x = prefs.getInt("primaryColor");
      if (x != null) {
        if (x < 0 || x >= appColors.length)
          prefs.remove("primaryColor");
        else
          _primaryColor = appColors[x];
      }
    }
    if (prefs.getKeys().contains("addToCalendarSetting")) {
      int? x = prefs.getInt("addToCalendarSetting");
      if (x != null) _addToCalendarSetting = AddToCalendar.values[x];
    }
    if (prefs.getKeys().contains("defaultCalendarsSetting")) {
      _defaultCalendarsSetting =
          prefs.getStringList("defaultCalendarsSetting") ??
              _defaultCalendarsSetting;
    }

    restoreFromCache(sharedPrefs: prefs);
  }

  // Section
  // Session management
  void updateSession(Session? sess) {
    currSession = sess;
    _sessionSubject.add(sess);
    _persistSession(sess);
  }

  void _persistSession(Session? sess) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (sess == null) {
      prefs.setString("session", "");
      return;
    }
    prefs.setString("session", json.encode(sess.toJson()));
  }

  Future<void> reloadCurrentUser() async {
    var userMe = await client.getUserMe(getSessionIdHeader());
    currSession?.profile = userMe;
    updateSession(currSession!);
  }

  String getSessionIdHeader() {
    return currSession?.sessionid != null
        ? "sessionid=${currSession?.sessionid}"
        : "";
  }

  Future<CalendarPreferencesResponse> getOrFetchCalendarPreferences() async {
    if (calendarPreferences != null) {
      return calendarPreferences!;
    }
    final sessionHeader = getSessionIdHeader();
    if (sessionHeader.isEmpty) {
      debugPrint('getOrFetchCalendarPreferences: sessionHeader is empty');
      return CalendarPreferencesResponse(
        showAllEvents: true,
        showInstiappGoing: true,
        showInstiappFollowedBodies: true,
        showResobin: true,
        notificationsEnabled: true,
      );
    }
    try {
      final prefsList = await client.getCalendarPreferences(sessionHeader);
      debugPrint(
          'getOrFetchCalendarPreferences: prefsList fetched successfully. Length=${prefsList.length}');
      if (prefsList.isNotEmpty) {
        calendarPreferences = prefsList.first;
        debugPrint(
            'getOrFetchCalendarPreferences: first pref showAllEvents=${calendarPreferences!.showAllEvents}, showGoing=${calendarPreferences!.showInstiappGoing}, showFollowed=${calendarPreferences!.showInstiappFollowedBodies}, showResobin=${calendarPreferences!.showResobin}');
      }
    } catch (e) {
      debugPrint(
          'getOrFetchCalendarPreferences: Error fetching calendar preferences: $e');
    }
    calendarPreferences ??= CalendarPreferencesResponse();
    calendarPreferences!.showAllEvents ??= true;
    calendarPreferences!.showInstiappGoing ??= true;
    calendarPreferences!.showInstiappFollowedBodies ??= true;
    calendarPreferences!.showResobin ??= true;
    calendarPreferences!.notificationsEnabled ??= true;
    return calendarPreferences!;
  }

  Future<void> updateCalendarPreferences(
      CalendarPreferencesResponse prefs) async {
    calendarPreferences = prefs;
    clearCalendarFeedCache();
    final sessionHeader = getSessionIdHeader();
    if (sessionHeader.isNotEmpty) {
      try {
        await client.updateCalendarPreferences(sessionHeader, prefs);
      } catch (e) {
        debugPrint('Error updating calendar preferences: $e');
      }
    }
  }

  Future<List<CalendarBodyPreference>> getOrFetchCalendarPrefBodies() async {
    if (calendarPrefBodies != null) {
      return calendarPrefBodies!;
    }
    final sessionHeader = getSessionIdHeader();
    if (sessionHeader.isEmpty) {
      return [];
    }
    try {
      final list = await client.getCalendarPrefBodies(sessionHeader);
      calendarPrefBodies = list;
    } catch (e) {
      debugPrint('Error fetching calendar body preferences: $e');
    }
    calendarPrefBodies ??= [];
    return calendarPrefBodies!;
  }

  Future<void> updateSingleCalendarPrefBody(
      String id, CalendarBodyPreference body) async {
    clearCalendarFeedCache();
    final sessionHeader = getSessionIdHeader();
    if (sessionHeader.isNotEmpty) {
      try {
        await client.updateCalendarPrefBody(sessionHeader, id, body);
        if (calendarPrefBodies != null) {
          final idx =
              calendarPrefBodies!.indexWhere((element) => element.bodyId == id);
          if (idx != -1) {
            calendarPrefBodies![idx] = body;
          }
        }
      } catch (e) {
        debugPrint('Error updating single calendar body preference: $e');
      }
    }
  }

  Future<List<CalendarBody>> getOrFetchCalendarShared() async {
    if (calendarShared != null) {
      return calendarShared!;
    }
    final sessionHeader = getSessionIdHeader();
    if (sessionHeader.isEmpty) {
      return [];
    }
    try {
      final list = await client.getCalendarShared(sessionHeader);
      for (var item in list) {
        item.isActive ??= true;
      }
      calendarShared = list;
    } catch (e) {
      debugPrint('Error fetching shared calendars: $e');
    }
    calendarShared ??= [];
    return calendarShared!;
  }

  Future<void> toggleSharedCalendar(String slug, bool enabled) async {
    if (calendarShared != null) {
      final idx = calendarShared!.indexWhere((element) => element.slug == slug);
      if (idx != -1) {
        calendarShared![idx].isActive = enabled;
      }
    }
    clearCalendarFeedCache();
    final sessionHeader = getSessionIdHeader();
    if (sessionHeader.isNotEmpty) {
      try {
        if (enabled) {
          await client.subscribeToSharedCalendar(sessionHeader, slug);
        } else {
          await client.unsubscribeFromSharedCalendar(sessionHeader, slug);
        }
      } catch (e) {
        debugPrint('Error toggling shared calendar: $e');
      }
    }
  }

  bool _isSlotOnWeekday(ResobinSlot slot, DateTime date) {
    final dayRaw = slot.day?.trim().toLowerCase();
    if (dayRaw == null || dayRaw.isEmpty) return false;

    final weekday = date.weekday; // 1 = Monday, ..., 7 = Sunday
    const weekdayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    const shortWeekdayNames = [
      'mon',
      'tue',
      'wed',
      'thu',
      'fri',
      'sat',
      'sun'
    ];

    final targetName = weekdayNames[weekday - 1];
    final targetShort = shortWeekdayNames[weekday - 1];
    final targetNum = weekday.toString();

    return dayRaw == targetName ||
        dayRaw == targetShort ||
        dayRaw == targetNum ||
        dayRaw.startsWith(targetShort);
  }

  String _normalizeTime(String time) {
    final parts = time.trim().split(':');
    if (parts.length >= 2) {
      final hour = parts[0].padLeft(2, '0');
      final min = parts[1].padLeft(2, '0');
      final sec = parts.length > 2 ? parts[2].padLeft(2, '0') : '00';
      return '$hour:$min:$sec';
    }
    return time.trim();
  }

  Future<CalendarFeedResponse> getCalendarFeedCombined(
    String sessionId,
    String start,
    String end,
    String tz,
  ) async {
    final prefs = await getOrFetchCalendarPreferences();
    final cacheKey = "${start}_${end}_${prefs.showAllEvents}_${prefs.showInstiappGoing}_${prefs.showInstiappFollowedBodies}_${prefs.showResobin}";
    if (_calendarFeedCache.containsKey(cacheKey)) {
      debugPrint('getCalendarFeedCombined: cache hit for key $cacheKey');
      return _calendarFeedCache[cacheKey]!;
    }

    debugPrint(
        'getCalendarFeedCombined: prefs showAllEvents=${prefs.showAllEvents}, showInstiappGoing=${prefs.showInstiappGoing}, showInstiappFollowedBodies=${prefs.showInstiappFollowedBodies}, showResobin=${prefs.showResobin}');

    CalendarFeedResponse originalFeed;
    try {
      originalFeed = await client.getCalendarFeed(sessionId, start, end, tz);
      debugPrint(
          'getCalendarFeedCombined: originalFeed fetched successfully with ${originalFeed.items.length} items');
    } catch (e) {
      if (e is DioException) {
        debugPrint(
            'getCalendarFeedCombined: request uri: ${e.requestOptions.uri}');
        debugPrint(
            'getCalendarFeedCombined: request headers: ${e.requestOptions.headers}');
      }
      debugPrint(
          'getCalendarFeedCombined: Error fetching base calendar feed: $e');
      originalFeed = CalendarFeedResponse(items: []);
    }

    if (prefs.showResobin == false) {
      debugPrint(
          'getCalendarFeedCombined: showResobin is false, returning original feed directly');
      _calendarFeedCache[cacheKey] = originalFeed;
      return originalFeed;
    }

    var rollNo = currSession?.profile?.userRollNumber;
    if (rollNo == null || rollNo.isEmpty) {
      if (getSessionIdHeader().isNotEmpty) {
        try {
          await reloadCurrentUser();
          rollNo = currSession?.profile?.userRollNumber;
        } catch (e) {
          debugPrint('Error reloading user profile for rollNo: $e');
        }
      }
    }

    if (rollNo == null || rollNo.isEmpty) {
      debugPrint(
          'getCalendarFeedCombined: rollNo is null/empty, returning original feed');
      _calendarFeedCache[cacheKey] = originalFeed;
      return originalFeed;
    }

    List<ResobinCourse> resobinFeed = [];
    if (_cachedResobinFeed != null) {
      resobinFeed = _cachedResobinFeed!;
    } else {
      try {
        resobinFeed = await client.getResobinSchedule(rollNo, "ResInstiance");
        _cachedResobinFeed = resobinFeed;
        debugPrint(
            'getCalendarFeedCombined: Resobin schedule fetched successfully with ${resobinFeed.length} courses for rollNo $rollNo');
      } catch (e) {
        debugPrint('Error fetching Resobin schedule: $e');
      }
    }

    if (resobinFeed.isEmpty) {
      _calendarFeedCache[cacheKey] = originalFeed;
      return originalFeed;
    }

    final items = List<CalendarItem>.from(originalFeed.items);
    final startDate = DateTime.tryParse(start);
    final endDate = DateTime.tryParse(end);

    if (startDate != null && endDate != null) {
      for (var date = startDate;
          date.isBefore(endDate);
          date = date.add(const Duration(days: 1))) {
        for (final course in resobinFeed) {
          final venue = (course.lectureVenue != null &&
                  course.lectureVenue!.trim().isNotEmpty)
              ? course.lectureVenue!.trim()
              : null;

          if (course.lectureSlots != null) {
            for (final slot in course.lectureSlots!) {
              if (_isSlotOnWeekday(slot, date) &&
                  slot.startTime != null &&
                  slot.endTime != null) {
                final dateStr =
                    "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                final startIso =
                    "${dateStr}T${_normalizeTime(slot.startTime!)}+05:30";
                final endIso =
                    "${dateStr}T${_normalizeTime(slot.endTime!)}+05:30";
                items.add(CalendarItem(
                  uid: "resobin-lec-${course.id}-${slot.slot ?? ''}-${dateStr}",
                  title:
                      "${course.course?.code ?? ''} - ${course.course?.title ?? ''}",
                  startTime: startIso,
                  endTime: endIso,
                  all_day: false,
                  location: venue,
                  source: "resobin",
                  subsource: "lectures-n-labs",
                ));
              }
            }
          }
          if (course.tutorialSlots != null) {
            for (final slot in course.tutorialSlots!) {
              if (_isSlotOnWeekday(slot, date) &&
                  slot.startTime != null &&
                  slot.endTime != null) {
                final dateStr =
                    "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                final startIso =
                    "${dateStr}T${_normalizeTime(slot.startTime!)}+05:30";
                final endIso =
                    "${dateStr}T${_normalizeTime(slot.endTime!)}+05:30";
                items.add(CalendarItem(
                  uid: "resobin-tut-${course.id}-${slot.slot ?? ''}-${dateStr}",
                  title:
                      "${course.course?.code ?? ''} - ${course.course?.title ?? ''}",
                  startTime: startIso,
                  endTime: endIso,
                  all_day: false,
                  location: venue,
                  source: "resobin",
                  subsource: "lectures-n-labs",
                ));
              }
            }
          }
        }
      }
    }

    final combinedResponse = CalendarFeedResponse(items: items);
    _calendarFeedCache[cacheKey] = combinedResponse;
    return combinedResponse;
  }

  Future<void> logout() async {
    await client.logout(getSessionIdHeader());
    updateSession(null);
    _notificationsSubject.add(UnmodifiableListView([]));
    _cachedResobinFeed = null;
    clearCalendarFeedCache();
  }

  Future saveToCache({SharedPreferences? sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (_hostels.isNotEmpty) {
      prefs.setString(
          messStorageID, json.encode(_hostels.map((e) => e.toJson()).toList()));
    }
    if (_events.isNotEmpty) {
      prefs.setString(
          eventStorageID, json.encode(_events.map((e) => e.toJson()).toList()));
    }
    if (_achievements.isNotEmpty) {
      prefs.setString(achievementStorageID,
          json.encode(_achievements.map((e) => e.toJson()).toList()));
    }
    if (_notifications.isNotEmpty) {
      prefs.setString(notificationsStorageID,
          json.encode(_notifications.map((e) => e.toJson()).toList()));
    }

    exploreBloc.saveToCache(sharedPrefs: prefs);
    // complaintsBloc?.saveToCache(sharedPrefs: prefs);
    calendarBloc.saveToCache(sharedPrefs: prefs);
    messCalendarBloc.saveToCache(sharedPrefs: prefs);
    mapBloc.saveToCache(sharedPrefs: prefs);
  }

  Future restoreFromCache({SharedPreferences? sharedPrefs}) async {
    var prefs = sharedPrefs ?? await SharedPreferences.getInstance();
    if (prefs.getKeys().contains(messStorageID)) {
      var x = prefs.getString(messStorageID);
      if (x != null) {
        _hostels = json
            .decode(x)
            .map((e) => Hostel.fromJson(e))
            .toList()
            .cast<Hostel>();
        _hostelsSubject.add(UnmodifiableListView(_hostels));
      }
    }

    if (prefs.getKeys().contains(eventStorageID)) {
      var x = prefs.getString(eventStorageID);
      if (x != null) {
        _events =
            json.decode(x).map((e) => Event.fromJson(e)).toList().cast<Event>();
        if (_events.length >= 1) {
          _events[0].eventBigImage = true;
        }
        _eventsSubject.add(UnmodifiableListView(_events));
      }
    }

    if (prefs.getKeys().contains(achievementStorageID)) {
      var x = prefs.getString(achievementStorageID);
      if (x != null) {
        _achievements = json
            .decode(x)
            .map((e) => Achievement.fromJson(e))
            .toList()
            .cast<Achievement>();
        _achievementSubject.add(UnmodifiableListView(_achievements));
      }
    }

    if (prefs.getKeys().contains(notificationsStorageID)) {
      var x = prefs.getString(notificationsStorageID);
      if (x != null) {
        _notifications = json
            .decode(x)
            .map((e) => ntf.Notification.fromJson(e))
            .toList()
            .cast<ntf.Notification>();
        _notificationsSubject.add(UnmodifiableListView(_notifications));
      }
    }

    exploreBloc.restoreFromCache(sharedPrefs: prefs);
    // complaintsBloc?.restoreFromCache(sharedPrefs: prefs);
    calendarBloc.restoreFromCache(sharedPrefs: prefs);
    messCalendarBloc.restoreFromCache(sharedPrefs: prefs);
    mapBloc.restoreFromCache(sharedPrefs: prefs);
  }

  // Set batch number on icon for iOS
  void _initNotificationBatch() {
    if (!kIsWeb && Platform.isIOS) {
      notifications.listen((notifs) async {
        try {
          await AwesomeNotifications().setGlobalBadgeCounter(notifs.length);
        } on PlatformException {}
      });
    }
  }
}
