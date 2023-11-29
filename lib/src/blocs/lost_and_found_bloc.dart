import 'package:InstiApp/src/api/model/lostandfound.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';

enum lostAndFoundType { All }

class LostAndFoundPostBloc {
  final String storageID = "LostandFoundPost";

  InstiAppBloc bloc;

  List<LostAndFoundPost> _lostAndFoundPosts = [];

  ValueStream<List<LostAndFoundPost>> get lostAndFoundPosts => _buynsellSubject.stream;
  final _buynsellSubject = BehaviorSubject<List<BuynSellPost>>();

  String query = "";

  LostAndFoundPostBloc(this.bloc);

  get buynsellpost => null;

  Future<BuynSellPost?> getBuynSellPost(String id) async {
    return await bloc.client.getLostAndFoundPost(bloc.getSessionIdHeader(), id);
  }

  Future<BuynSellPost?> deleteBuynSellPost(String id) async {
    return await bloc.client.deleteBuynSellPost(bloc.getSessionIdHeader(), id);
  }

  Future<void> updateBuynSellPost(BuynSellPost post) async {
    await bloc.client
        .updateBuynSellPost(bloc.getSessionIdHeader(), post.id!, post);
  }

  Future<void> refresh({BnSType type = BnSType.All}) async {
    _buynsellPosts =
    (await bloc.client.getBuynSellPosts(bloc.getSessionIdHeader()));
    _buynsellSubject.add(_buynsellPosts);
  }

  Future<void> createBuynSellPost(BuynSellPost post) async {
    await bloc.client.createBuynSellPost(bloc.getSessionIdHeader(), post);
  }
}
