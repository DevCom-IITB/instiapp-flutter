import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/api/request/action_community_post_request.dart';
import 'package:InstiApp/src/api/request/update_community_post_request.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';

enum CPType {
  All,
  YourPosts,
  PendingPosts,
  ReportedContent,
  Featured,
}

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

  Future<void> updateUserCommunityPostReaction(
      CommunityPost post, int reaction) async {
    await bloc.client.updateUserCommunityPostReaction(
        bloc.getSessionIdHeader(), post.id!, reaction);
  }

  Future refresh({CPType type = CPType.All, required String? id}) async {
    // _communityPosts = defCommunities;
    // _communitySubject.add(defCommunities);
    // print("refresh");
    if (id == null) {
      _communitySubject.add([]);
      return;
    }

    int? status;
    switch (type) {
      case CPType.All:
        status = 1;
        break;
      case CPType.PendingPosts:
        status = 0;
        break;
      case CPType.ReportedContent:
        status = 3;
        break;
      default:
        status = null;
        break;
    }
    _communityPosts = (await bloc.client.getCommunityPosts(
                bloc.getSessionIdHeader(), status, query, id))
            .data ??
        [];

    // print("community" + _communityPosts.toString());
    _communitySubject.add(_communityPosts);
  }

  Future<void> updateCommunityPostStatus(String id, int status) async {
    _communitySubject.add([]);
    try {
      await bloc.client.updateCommunityPostStatus(bloc.getSessionIdHeader(), id,
          UpdateCommunityPostRequest(status: status));

      _communityPosts.removeWhere((element) => element.id == id);
      _communitySubject.add(_communityPosts);
    } catch (e) {
      _communitySubject.add(_communityPosts);
    }
  }

  Future<void> featureCommunityPost(
    String id,
    bool isFeatured,
  ) async {
    await bloc.client.updateCommunityPostAction(bloc.getSessionIdHeader(), id,
        "feature", ActionCommunityPostRequest(isFeatured: isFeatured));
  }

  Future<void> updateCommunityPost(CommunityPost post) async {
    await bloc.client
        .updateCommunityPost(bloc.getSessionIdHeader(), post.id!, post);
  }

  Future<void> createCommunityPost(CommunityPost post) async {
    await bloc.client.createCommunityPost(bloc.getSessionIdHeader(), post);
  }

  Future<void> deleteCommunityPost(String id) async {
    await bloc.client.updateCommunityPostAction(
        bloc.getSessionIdHeader(), id, "delete", ActionCommunityPostRequest());
  }

  Future<void> reportCommunityPost(String id) async {
    await bloc.client.updateCommunityPostAction(
        bloc.getSessionIdHeader(), id, "report", ActionCommunityPostRequest());
  }
}
