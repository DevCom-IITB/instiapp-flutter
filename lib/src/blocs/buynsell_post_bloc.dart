import 'package:InstiApp/src/api/model/buynsellPost.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';

enum BnSType { All }

class BuynSellPostBloc {
  final String storageID = "BuynSellPost";

  InstiAppBloc bloc;

  List<BuynSellPost> _buynsellPosts = [];

  ValueStream<List<BuynSellPost>> get buynsellposts => _buynsellSubject.stream;
  final _buynsellSubject = BehaviorSubject<List<BuynSellPost>>();

  String query = "";

  BuynSellPostBloc(this.bloc);

  get buynsellpost => null;

  Future<BuynSellPost?> getBuynSellPost(String id) async {
    return await bloc.client.getBuynSellPost(bloc.getSessionIdHeader(), id);
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
