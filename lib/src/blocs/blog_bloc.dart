import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:InstiApp/src/api/model/post.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'dart:math';

enum PostType { Placement, Training, NewsArticle }

class PostBloc {
  // Streams
  Stream<UnmodifiableListView<Post>> get blog => _blogSubject.stream;
  final _blogSubject = BehaviorSubject<UnmodifiableListView<Post>>();

  Sink<int> get inPostIndex => _indexController.sink;
  PublishSubject<int> _indexController = PublishSubject<int>();

  // Params
  int _noOfPostsPerPage = 20;
  String query = "";

  // parent bloc
  InstiAppBloc bloc;

  // Training or Placement or News Article
  final PostType postType;

  PostBloc(this.bloc, {@required this.postType}) {
    _setIndexListener();
  }

  void _setIndexListener() {
    _indexController.stream
        .bufferTime(Duration(milliseconds: 500))
        .where((batch) => batch.isNotEmpty)
        .listen(_handleIndexes);
  }

  final _fetchPages = <int, List<Post>>{};
  final _pagesBeingFetched = Set<int>();

  final _searchFetchPages = <int, List<Post>>{};
  final _searchPagesBeingFetched = Set<int>();

  static final month = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sept",
    "Oct",
    "Nov",
    "Dec"
  ];
  static final week = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"];
  String dateTimeFormatter(String pub) {
    var dt = DateTime.parse(pub).toLocal();
    return "${week[dt.weekday - 1]}, ${month[dt.month - 1]} ${dt.day.toString()}${dt.year == DateTime.now().year ? "" : (" " + dt.year.toString())}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
  }

  Future<List<Post>> getBlogPage(int page) async {
    var httpGetFunc = {
      PostType.Placement: bloc.client.getPlacementBlogFeed,
      PostType.Training: bloc.client.getTrainingBlogFeed,
      PostType.NewsArticle: bloc.client.getNews
    }[postType];
    var posts = await httpGetFunc(bloc.getSessionIdHeader(),
        page * _noOfPostsPerPage, _noOfPostsPerPage, query);
    var tableParse = markdown.TableSyntax();
    posts.forEach((p) {
      p.content = markdown.markdownToHtml(
          p.content.split('\n').map((s) => s.trimRight()).toList().join('\n'),
          blockSyntaxes: [tableParse]);
      p.published = dateTimeFormatter(p.published);
    });
    return posts;
  }

  void _handleIndexes(List<int> indexes) {
    var pages = query.isEmpty ? _fetchPages : _searchFetchPages;
    var pagesBeingFetched = query.isEmpty ? _pagesBeingFetched : _searchPagesBeingFetched;
    indexes.forEach((int index) {
      final int pageIndex = ((index + 1) ~/ _noOfPostsPerPage);

      // check if the page has already been fetched
      if (!pages.containsKey(pageIndex)) {
        // the page has NOT yet been fetched, so we need to
        // fetch it from Internet
        // (except if we are already currently fetching it)
        if (!pagesBeingFetched.contains(pageIndex)) {
          // Remember that we are fetching it
          pagesBeingFetched.add(pageIndex);
          // Fetch it
          getBlogPage(pageIndex).then((List<Post> fetchedPage) =>
              _handleFetchedPage(fetchedPage, pageIndex));
        }
      }
    });
  }

  ///
  /// Once a page has been fetched from Internet, we need to
  /// 1) record it
  /// 2) notify everyone who might be interested in knowing it
  ///
  void _handleFetchedPage(List<Post> page, int pageIndex) {
    var pages = query.isEmpty ? _fetchPages : _searchFetchPages;
    var pagesBeingFetched = query.isEmpty ? _pagesBeingFetched : _searchPagesBeingFetched;

    // Remember the page
    pages[pageIndex] = page;
    // Remove it from the ones being fetched
    pagesBeingFetched.remove(pageIndex);

    // Notify anyone interested in getting access to the content
    // of all pages... however, we need to only return the pages
    // which respect the sequence (since MovieCard are in sequence)
    // therefore, we need to iterate through the pages that are
    // actually fetched and stop if there is a gap.
    List<Post> posts = <Post>[];
    List<int> pageIndexes = pages.keys.toList();

    final int minPageIndex = pageIndexes.reduce(min);
    final int maxPageIndex = pageIndexes.reduce(max);

    // If the first page being fetched does not correspond to the first one, skip
    // and as soon as it will become available, it will be time to notify
    if (minPageIndex == 0) {
      for (int i = 0; i <= maxPageIndex; i++) {
        if (!pages.containsKey(i)) {
          // As soon as there is a hole, stop
          break;
        }
        // Add the list of fetched posts to the list
        posts.addAll(pages[i]);
      }
    }

    if (pages[maxPageIndex].length < _noOfPostsPerPage) {
      posts.add(Post());
    }

    // Only notify when there are posts
    if (posts.length > 0) {
      _blogSubject.add(UnmodifiableListView<Post>(posts));
    }
  }

  Future<void> refresh({bool force = false}) {
    _indexController.close();

    _searchFetchPages.clear();
    _searchPagesBeingFetched.clear();
    
    List<Post> posts = <Post>[];
    if (force) {
      _fetchPages.clear();
      _pagesBeingFetched.clear();
    }
    else if (_fetchPages.isNotEmpty && query.isEmpty) {
      List<int> pageIndexes = _fetchPages.keys.toList();

      final int minPageIndex = pageIndexes.reduce(min);
      final int maxPageIndex = pageIndexes.reduce(max);

      if (minPageIndex == 0) {
        for (int i = 0; i <= maxPageIndex; i++) {
          if (!_fetchPages.containsKey(i)) {
            // As soon as there is a hole, stop
            break;
          }
          posts.addAll(_fetchPages[i]);
        }
      }
    }
    
    _blogSubject.add(UnmodifiableListView(posts));

    _indexController = PublishSubject<int>();
    _setIndexListener();

    return Future.delayed(Duration(milliseconds: 300));
  }
}
