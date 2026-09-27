import 'dart:collection';

import 'package:InstiApp/src/api/model/buynsellPost.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';

enum BnSType { All }

class BuynSellPostBloc {
  final String storageID = "BuynSellPost";

  InstiAppBloc bloc;

  BuynSellPostBloc(this.bloc);

  /// Items fetched per page. Keep in sync with whatever the backend
  /// treats as a sane page size for /buy/products.
  static const int postsPerPage = 20;

  final List<BuynSellPost> _buynsellPosts = [];
  int _nextPage = 0;
  bool _hasMore = true;
  bool _isFetching = false;
  bool _showAll = true;

  /// The posts loaded so far, in order. Grows page by page as
  /// [loadNextPage] is called; reset to empty by [refresh].
  ValueStream<UnmodifiableListView<BuynSellPost>> get buynsellposts =>
      _buynsellSubject.stream;
  final _buynsellSubject =
  BehaviorSubject<UnmodifiableListView<BuynSellPost>>();

  /// True while a page fetch is in flight -- drives the bottom-of-list
  /// spinner.
  ValueStream<bool> get isLoadingMore => _loadingSubject.stream;
  final _loadingSubject = BehaviorSubject<bool>.seeded(false);

  /// True until the backend returns a page shorter than [postsPerPage],
  /// at which point there's nothing left to fetch.
  bool get hasMore => _hasMore;

  String query = "";

  get buynsellpost => null;

  void _emit() {
    _buynsellSubject.add(UnmodifiableListView<BuynSellPost>(_buynsellPosts));
  }

  /// Fetches page 1 and replaces whatever is currently loaded. Called on
  /// first load and on pull-to-refresh.
  Future<void> refresh({bool showAll = true, bool force = true}) async {
    _showAll = showAll;
    _nextPage = 0;
    _hasMore = true;
    if (force) {
      _buynsellPosts.clear();
      _emit();
    }
    await loadNextPage();
  }

  /// Fetches the next page and appends it to what's already loaded.
  /// Safe to call repeatedly (e.g. from a scroll listener) -- it's a
  /// no-op while a fetch is already in flight, or once [hasMore] is
  /// false.
  Future<void> loadNextPage() async {
    if (_isFetching || !_hasMore) return;
    _isFetching = true;
    _loadingSubject.add(true);
    try {
      final response = await bloc.client.getBuynSellPostsPage(
        bloc.getSessionIdHeader(),
        _nextPage,
        showAll: _showAll,
        query: query.isEmpty ? null : query,
      );
      final page = response.results ?? [];
      _buynsellPosts.addAll(page);
      _nextPage += 1;
      // list_v2's page size is fixed at 20 server-side (postsPerPage
      // here just mirrors that for the hasMore check).
      _hasMore = page.length == postsPerPage;
      _emit();
    } finally {
      _isFetching = false;
      _loadingSubject.add(false);
    }
  }

  /// Updates the server-side search term (the backend's query_search
  /// ignores anything under 3 chars and returns everything unfiltered
  /// in that case) and re-fetches from page 1. No-ops if unchanged.
  Future<void> setQuery(String q) async {
    if (q == query) return;
    query = q;
    await refresh(showAll: _showAll, force: true);
  }

  Future<BuynSellPost?> getBuynSellPost(String id) async {
    return await bloc.client.getBuynSellPost(bloc.getSessionIdHeader(), id);
  }

  Future<void> deleteBuynSellPost(String id) async {
    try {
      final deletedPost = await bloc.client.deleteBuynSellPost(
        bloc.getSessionIdHeader(),
        id,
      );

      if (deletedPost != null) {
        if (deletedPost.deleted == true) {
          _buynsellPosts.removeWhere((post) => post.id == id);
          _emit();
        } else {
          throw Exception('Unauthorized deletion attempt');
        }
      } else {
        _buynsellPosts.removeWhere((post) => post.id == id);
        _emit();
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
      post,
    );
    final index = _buynsellPosts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      _buynsellPosts[index] = updatedPost;
      _emit();
    }
  }

  Future<void> createBuynSellPost(BuynSellPost post) async {
    await bloc.client.createBuynSellPost(bloc.getSessionIdHeader(), post);
    // A new post sorts first under "Recently Added", so re-pull from
    // page 1 rather than guessing where it belongs in the loaded window.
    await refresh(showAll: _showAll, force: true);
  }

  Future<void> markAsSold(String id) async {
    await bloc.client.markBuynSellPostAsSold(bloc.getSessionIdHeader(), id);
    await refresh(showAll: _showAll, force: true);
  }
}