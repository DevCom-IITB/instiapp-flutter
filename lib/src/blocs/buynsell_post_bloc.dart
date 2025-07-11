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

  Future<void> deleteBuynSellPost(String id) async {
    try {
      final deletedPost = await bloc.client.deleteBuynSellPost(
        bloc.getSessionIdHeader(), 
        id
      );
      
      if (deletedPost != null) {
        if (deletedPost.deleted == true) {
          _buynsellPosts.removeWhere((post) => post.id == id);
          _buynsellSubject.add(_buynsellPosts);
        } else {
          throw Exception('Unauthorized deletion attempt');
        }
      } else {
        _buynsellPosts.removeWhere((post) => post.id == id);
        _buynsellSubject.add(_buynsellPosts);
      }
    } catch (e) {
      _buynsellSubject.addError('Failed to delete item: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateBuynSellPost(BuynSellPost post) async {
    final updatedPost = await bloc.client.updateBuynSellPost(
      bloc.getSessionIdHeader(), 
      post.id!, 
      post
    );
    final index = _buynsellPosts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      _buynsellPosts[index] = updatedPost;
      _buynsellSubject.add(_buynsellPosts);
    }
  }

  Future<void> refresh({bool showAll = true}) async {
    _buynsellPosts = await bloc.client.getBuynSellPosts(
      bloc.getSessionIdHeader(),
      showAll: showAll
    );
    _buynsellSubject.add(_buynsellPosts);
  }

  Future<void> createBuynSellPost(BuynSellPost post) async {
    final newPost = await bloc.client.createBuynSellPost(
      bloc.getSessionIdHeader(), 
      post
    );
    _buynsellPosts.add(newPost);
    _buynsellSubject.add(_buynsellPosts);
  }

  Future<void> markAsSold(String id) async {
    await bloc.client.markBuynSellPostAsSold(bloc.getSessionIdHeader(), id);
    await refresh();
  }
}
