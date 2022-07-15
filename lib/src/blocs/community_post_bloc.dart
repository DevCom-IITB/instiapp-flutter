import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';

class CommunityPostBloc {
  final String storageID = "communityPost";

  InstiAppBloc bloc;

  List<CommunityPost> _communityPosts = [];

  ValueStream<List<CommunityPost>> get communityposts =>
      _communitySubject.stream;
  final _communitySubject = BehaviorSubject<List<CommunityPost>>();

  String query = "";

  CommunityPostBloc(this.bloc);

  Future<CommunityPost?> getCommunityPost(String id) async {
    // try {
    //   return _communityPosts.firstWhere((community) => community.id == id);
    // } catch (ex) {
    return await bloc.client.getCommunityPost(bloc.getSessionIdHeader(), id);
    // }
  }

  Future refresh() async {
    // _communityPosts = defCommunities;
    // _communitySubject.add(defCommunities);
    // print("refresh");
    _communityPosts =
        (await bloc.client.getCommunityPosts(bloc.getSessionIdHeader())).data ??
            [];
    // print("community" + _communityPosts.toString());
    _communitySubject.add(_communityPosts);
  }

  Future<void> createCommunityPost(CommunityPost post) async {
    await bloc.client.createCommunityPost(bloc.getSessionIdHeader(), post);
  }

  Future<void> deleteCommunityPost(String id) async {
    await bloc.client.deleteCommunityPost(bloc.getSessionIdHeader(), id);
  }
}
