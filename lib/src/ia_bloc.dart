import 'package:flutter/material.dart';
import 'package:instiapp/src/api/apiclient.dart';
import 'package:instiapp/src/api/model/mess.dart';
import 'package:instiapp/src/api/model/placementblogpost.dart';
import 'package:instiapp/src/api/model/user.dart';
import 'package:instiapp/src/drawer.dart';
import 'dart:collection';
import 'package:rxdart/rxdart.dart';
import 'package:http/io_client.dart';
import 'package:jaguar_retrofit/jaguar_retrofit.dart';

class InstiAppBloc {
  // Different Streams for the state
  Stream<UnmodifiableListView<Hostel>> get hostels => _hostelsSubject.stream;
  final _hostelsSubject = BehaviorSubject<UnmodifiableListView<Hostel>>();
  
  Stream<Session> get session => _sessionSubject.stream;
  final _sessionSubject = BehaviorSubject<Session>();

  Stream<UnmodifiableListView<PlacementBlogPost>> get placementBlog => _placementBlogSubject.stream;
  final _placementBlogSubject = BehaviorSubject<UnmodifiableListView<PlacementBlogPost>>();

  // actual current state
  Session currSession;
  var _hostels = <Hostel>[];
  var _placePosts = <PlacementBlogPost>[];

  // api functions
  final client = InstiAppApi();

  // drawer key
  final drawerKey = GlobalKey<DrawerOnlyState>();

  InstiAppBloc() {
    globalClient = IOClient();
  }

  String getSessionIdHeader() {
    return "sessionid=" + currSession?.sessionid;
  }

  Future<Null> updateHostels() async {
    var hostels = await client.getHostelMess();
    hostels.sort((h1, h2) => h1.compareTo(h2));
    _hostels = hostels;
    _hostelsSubject.add(UnmodifiableListView(_hostels));
  }

  void updateSession(Session sess) {
    currSession = sess;
    _sessionSubject.add(sess);
  }

  void updatePlacementBlogPosts() async {
    print("Getting placement posts");
    try {
      var posts = await client.getPlacementBlogFeed(getSessionIdHeader(), 0, 20, "");
      print("Got placement posts");
      _placePosts = posts;
      _placementBlogSubject.add(UnmodifiableListView(posts));
    }
    catch (e) {
      print(e);
    }
  }

  void logout() {
    updateSession(null);
  }
}