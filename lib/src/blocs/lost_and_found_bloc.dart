import 'package:InstiApp/src/api/model/lostandfoundPost.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';

enum lnFType { All }

class LostAndFoundPostBloc {
  final String storageID = "LostandFoundPost";

  InstiAppBloc bloc;

  List<LostAndFoundPost> _lostAndFoundPosts = [];

  ValueStream<List<LostAndFoundPost>> get lostAndFoundPosts =>
      _lnfSubject.stream;
  final _lnfSubject = BehaviorSubject<List<LostAndFoundPost>>();

  String query = "";

  LostAndFoundPostBloc(this.bloc);

  get buynsellpost => null;

  Future<LostAndFoundPost?> getLostAndFoundPost(String id) async {
    return await bloc.client.getLostAndFoundPost(bloc.getSessionIdHeader(), id);
  }

  Future<void> refresh({lnFType type = lnFType.All}) async {
    _lostAndFoundPosts =
        (await bloc.client.getLostAndFoundPosts(bloc.getSessionIdHeader()));
    _lnfSubject.add(_lostAndFoundPosts);
  }
}
