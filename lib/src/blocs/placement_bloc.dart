import 'dart:collection';

import 'package:instiapp/src/api/model/placementblogpost.dart';
import 'package:instiapp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'dart:math';

class PlacementBlogBloc {
  // Streams
  Stream<UnmodifiableListView<PlacementBlogPost>> get placementBlog =>
      _placementBlogSubject.stream;
  final _placementBlogSubject =
      BehaviorSubject<UnmodifiableListView<PlacementBlogPost>>();

  Sink<int> get inPostIndex => _indexController.sink;
  PublishSubject<int> _indexController = PublishSubject<int>();

  // Params
  int _noOfPostsPerPage = 20;

  // parent bloc
  InstiAppBloc bloc;

  // bloc state
  var _placePosts = <PlacementBlogPost>[];

  PlacementBlogBloc(this.bloc) {
    _indexController.stream
        .bufferTime(Duration(milliseconds: 5000))
        .where((batch) => batch.isNotEmpty)
        .listen(_handleIndexes);
  }

  final _fetchPages = <int, List<PlacementBlogPost>>{};

  final _pagesBeingFetched = Set<int>();

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
    return "${week[dt.weekday - 1]}, ${month[dt.month - 1]} ${dt.day.toString()}${dt.year == DateTime.now().year ? "" : dt.year.toString()}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
  }

  Future<List<PlacementBlogPost>> getBlogPage(int page, {String query = ""}) async {
    var sessId = bloc.getSessionIdHeader(); 
    var posts = await bloc.client.getPlacementBlogFeed(bloc.getSessionIdHeader(),
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
    indexes.forEach((int index) {
      final int pageIndex = ((index + 1) ~/ _noOfPostsPerPage);

      // check if the page has already been fetched
      if (!_fetchPages.containsKey(pageIndex)) {
        // the page has NOT yet been fetched, so we need to
        // fetch it from Internet
        // (except if we are already currently fetching it)
        if (!_pagesBeingFetched.contains(pageIndex)) {
          // Remember that we are fetching it
          _pagesBeingFetched.add(pageIndex);
          // Fetch it
          getBlogPage(pageIndex)
              .then((List<PlacementBlogPost> fetchedPage) =>
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
  void _handleFetchedPage(List<PlacementBlogPost> page, int pageIndex) {
    // Remember the page
    _fetchPages[pageIndex] = page;
    // Remove it from the ones being fetched
    _pagesBeingFetched.remove(pageIndex);

    // Notify anyone interested in getting access to the content
    // of all pages... however, we need to only return the pages
    // which respect the sequence (since MovieCard are in sequence)
    // therefore, we need to iterate through the pages that are
    // actually fetched and stop if there is a gap.
    List<PlacementBlogPost> posts = <PlacementBlogPost>[];
    List<int> pageIndexes = _fetchPages.keys.toList();

    final int minPageIndex = pageIndexes.reduce(min);
    final int maxPageIndex = pageIndexes.reduce(max);

    // If the first page being fetched does not correspond to the first one, skip
    // and as soon as it will become available, it will be time to notify
    if (minPageIndex == 0) {
      for (int i = 0; i <= maxPageIndex; i++) {
        if (!_fetchPages.containsKey(i)) {
          // As soon as there is a hole, stop
          break;
        }
        // Add the list of fetched posts to the list
        posts.addAll(_fetchPages[i]);
      }
    }

    // Only notify when there are posts
    if (posts.length > 0) {
      _placePosts = posts;
      _placementBlogSubject.add(UnmodifiableListView<PlacementBlogPost>(posts));
    }
  }

  void updatePlacementBlogPosts({String query = ""}) async {
    print("Getting placement posts");
    try {
      var posts = await getBlogPage(0, query: query);
      print("Got placement posts");
      var tableParse = markdown.TableSyntax();
      posts.forEach((p) {
        p.content = markdown.markdownToHtml(
            p.content.split('\n').map((s) => s.trimRight()).toList().join('\n'),
            blockSyntaxes: [tableParse]);
        p.published = dateTimeFormatter(p.published);
      });
      _placePosts = posts;
      _placementBlogSubject.add(UnmodifiableListView(posts));
    } catch (e) {
      print(e);
    }
  }
}
