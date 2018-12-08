import 'package:instiapp/src/api/apiclient.dart';
import 'package:instiapp/src/api/model/mess.dart';
import 'package:instiapp/src/api/model/user.dart';
import 'dart:collection';
import 'package:rxdart/rxdart.dart';
import 'package:http/io_client.dart';
import 'package:jaguar_retrofit/jaguar_retrofit.dart';

class InstiAppBloc {
  Stream<UnmodifiableListView<Hostel>> get hostels => _hostelsSubject.stream;
  final _hostelsSubject = BehaviorSubject<UnmodifiableListView<Hostel>>();

  final client = InstiAppApi();

  Session session;
  var loggedIn = false;

  var _hostels = <Hostel>[];


  InstiAppBloc({this.session}) {
    globalClient = IOClient();
    _updateHostels().then((_) {
        _hostelsSubject.add(UnmodifiableListView(_hostels));
    });
  }

  Future<Null> _updateHostels() async {
    final hostels = await client.getSortedHostelMess();
    _hostels = hostels;
  } 
}