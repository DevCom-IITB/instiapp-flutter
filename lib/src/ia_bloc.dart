import 'package:instiapp/src/api/apiclient.dart';
import 'package:instiapp/src/api/model/mess.dart';
import 'package:instiapp/src/api/model/user.dart';
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

  // actual current state
  var _hostels = <Hostel>[];
  Session currSession;

  // api functions
  final client = InstiAppApi();

  InstiAppBloc() {
    globalClient = IOClient();
  }

  Future<Null> updateHostels() async {
    final hostels = await client.getSortedHostelMess();
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