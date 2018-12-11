import 'package:flutter/material.dart';
import 'package:instiapp/src/api/apiclient.dart';
import 'package:instiapp/src/api/model/mess.dart';
import 'package:instiapp/src/api/model/placementblogpost.dart';
import 'package:instiapp/src/api/model/user.dart';
import 'package:instiapp/src/blocs/placement_bloc.dart';
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

  // Sub Blocs
  PlacementBlogBloc placementBloc;

  // actual current state
  Session currSession;
  var _hostels = <Hostel>[];

  // api functions
  final client = InstiAppApi();


  // drawer key
  final drawerKey = GlobalKey<DrawerOnlyState>();

  InstiAppBloc() {
    globalClient = IOClient();
    placementBloc = PlacementBlogBloc(this);
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

  void logout() {
    updateSession(null);
  }
}
