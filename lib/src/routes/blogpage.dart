// import 'dart:async';
import 'dart:core';
import 'dart:collection';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/routes/blogslogin.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/api/model/post.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_selectable_text/fwfh_selectable_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:InstiApp/src/utils/responsivenew.dart';
import 'package:html/parser.dart' as html_parser;
import 'dart:convert';
import 'package:html/dom.dart' as html_dom;

TextSpan highlight(String result, String query, BuildContext context) {
  TextStyle posRes = TextStyle(
    color: Colors.black,
    backgroundColor: Color.fromRGBO(0, 94, 255, 0.5),
    fontSize: 16,
    fontFamily: 'DM Sans',
    fontWeight: FontWeight.w700,
  );
  TextStyle negRes = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontFamily: 'DM Sans',
    fontWeight: FontWeight.w700,
  );
  if (result == "" || query == "") return TextSpan(text: result, style: negRes);
  result = result.replaceAll('\n', " ").replaceAll("  ", "");

  var refinedMatch = result.toLowerCase();
  var refinedsearch = query.toLowerCase();

  if (refinedsearch.isEmpty || !refinedMatch.contains(refinedsearch)) {
    return TextSpan(text: result, style: negRes);
  }

  int matchIndex = refinedMatch.indexOf(refinedsearch);
  int matchEnd = matchIndex + refinedsearch.length;

  return TextSpan(
    children: [
      if (matchIndex > 0)
        TextSpan(
          text: result.substring(0, matchIndex),
          style: negRes,
        ),
      TextSpan(
        text: result.substring(matchIndex, matchEnd),
        style: posRes,
      ),
      if (matchEnd < result.length)
        highlight(result.substring(matchEnd), query, context),
    ],
  );
}

class BlogPage extends StatefulWidget {
  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  String view = 'normal'; // 'normal' or 'company wise'
  TextEditingController? _searchFieldController;
  PageController? _pageController;
  int currentTabIndex = 0; // 0: Placement, 1: Internship, 2: External

  late PostType postType;
  String? selectedDepartment;
  String? currquery = "";
  @override
  void initState() {
    super.initState();
    _searchFieldController = TextEditingController();
    _pageController = PageController(initialPage: 0);
    setUrl();
    _placementScrollController = ScrollController()..addListener(_handleScroll);
    _trainingScrollController = ScrollController()..addListener(_handleScroll);
    _externalScrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (firstBuild) {
      var bloc = BlocProvider.of(context)!.bloc;
      var blogBloc = bloc.getPostsBloc(postType);

      // Initialize query and trigger the first refresh
      blogBloc?.query = "";
      blogBloc?.refresh();

      firstBuild = false;
    }
  }

  @override
  void dispose() {
    _searchFieldController?.dispose();
    _pageController?.dispose();
    _focusNode.dispose();
    _placementScrollController?.dispose();
    _trainingScrollController?.dispose();
    _externalScrollController?.dispose();
    super.dispose();
  }

  double placement = 1, internship = 0, external = 0;

  void switchToTab(int index) {
    setState(() {
      currentTabIndex = index;
      placement = index == 0 ? 1 : 0;
      internship = index == 1 ? 1 : 0;
      external = index == 2 ? 1 : 0;

      _searchFieldController?.clear();
      _focusNode.unfocus();
      setUrl();
    });

    var bloc = BlocProvider.of(context)?.bloc;
    var blogBloc = bloc?.getPostsBloc(postType);
    if (blogBloc != null) {
      blogBloc.query = '';
      blogBloc.refresh();
    }
  }

  void setUrl() {
    if (placement == 1) {
      postType = PostType.Placement;
    } else if (internship == 1) {
      postType = PostType.Training;
    } else if (external == 1) {
      postType = PostType.External;
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  FocusNode _focusNode = FocusNode();
  ScrollController? _placementScrollController;
  ScrollController? _trainingScrollController;
  ScrollController? _externalScrollController;
  double isFabVisible = 0;
  IconData actionIcon = Icons.search_outlined;

  ScrollController? get _activeScrollController {
    if (currentTabIndex == 0) return _placementScrollController;
    if (currentTabIndex == 1) return _trainingScrollController;
    return _externalScrollController;
  }

  void _handleScroll() {
    final controller = _activeScrollController;
    if (!mounted || controller == null || !controller.hasClients) return;
    final visible =
        controller.position.userScrollDirection == ScrollDirection.forward &&
            controller.offset > 100;
    setState(() => isFabVisible = visible ? 1 : 0);
  }

  bool firstBuild = true;
  String? loadingReaction;

  List<Post>? threads;
  // ...existing code...
  String highlightHtml(String html, String? query) {
    if (html == null || html.isEmpty) return html;
    if (query == null) query = "";
    if (query.length < 4) return html;
    if (query.length > 32) return html;
    final q = query.trim();
    if (q.isEmpty) return html;

    final pattern = RegExp(RegExp.escape(q), caseSensitive: false);
    final fragment = html_parser.parseFragment(html);

    void walk(html_dom.Node node) {
      final children = node.nodes.toList();
      for (final html_dom.Node child in children) {
        // Text node
        if (child.nodeType == html_dom.Node.TEXT_NODE) {
          final text = child.text ?? "";
          if (pattern.hasMatch(text)) {
            final sb = StringBuffer();
            int last = 0;
            for (final m in pattern.allMatches(text)) {
              if (m.start > last) {
                sb.write(HtmlEscape().convert(text.substring(last, m.start)));
              }
              sb.write('<span class="hl">');
              sb.write(HtmlEscape().convert(text.substring(m.start, m.end)));
              sb.write('</span>');
              last = m.end;
            }
            if (last < text.length) {
              sb.write(HtmlEscape().convert(text.substring(last)));
            }
            // replace the text node with parsed fragments containing spans
            child.replaceWith(html_parser.parseFragment(sb.toString()));
          }
        } else {
          // Recurse into element nodes
          walk(child);
        }
      }
    }

    walk(fragment);
    return fragment.outerHtml;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(246, 246, 246, 1),
    ));
    var bloc = BlocProvider.of(context)!.bloc;
    bool isLoggedIn = bloc.currSession != null;
    var blogBloc = bloc.getPostsBloc(postType);
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          key: _scaffoldKey,
          body: StreamBuilder(
            stream: bloc.session,
            builder: (BuildContext context, AsyncSnapshot<Session?> snapshot) {
              if ((snapshot.hasData && snapshot.data != null) && isLoggedIn) {
                return Scaffold(
                  floatingActionButton: AnimatedOpacity(
                    opacity: isFabVisible, // 1 = visible, 0 = hidden
                    duration: Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: isFabVisible == 0,
                      child: FloatingActionButton(
                        backgroundColor: Color.fromRGBO(48, 111, 220, 1),
                        onPressed: () {
                          _activeScrollController?.animateTo(
                            0.0,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Icon(Icons.arrow_upward),
                      ),
                    ),
                  ),
                  backgroundColor: const Color.fromRGBO(246, 246, 246, 1),
                  body: SafeArea(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: Responsive.height(52.0, context),
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: Responsive.width(16.0, context),
                                ),
                                child: Container(
                                    height: Responsive.height(52.0, context),
                                    width: Responsive.width(52.0, context),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          235, 235, 235, 0.8),
                                      borderRadius: BorderRadius.circular(26),
                                    ),
                                    child: IconButton(
                                        icon: SvgPicture.asset(
                                          'assets/blogs/arrow-left.svg',
                                          height:
                                              Responsive.height(24.0, context),
                                          width:
                                              Responsive.width(24.0, context),
                                          fit: BoxFit.none,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        })),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Blogs',
                                    style: TextStyle(
                                      fontSize: Responsive.text(24.0, context),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      fontFamily: "DM Sans",
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: Responsive.width(52.0, context)),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.height(20.0, context)),
                        Container(
                          height: Responsive.height(60.0, context),
                          margin: EdgeInsets.only(
                              left: Responsive.width(16.0, context),
                              right: Responsive.width(16.0, context)),
                          padding:
                              EdgeInsets.all(Responsive.height(6.0, context)),
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/blogs/background.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(
                                Responsive.height(30.0, context)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Material(
                                color: Color.fromRGBO(48, 111, 220, placement),
                                borderRadius: BorderRadius.circular(
                                    Responsive.height(30.0, context)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                      Responsive.height(30.0, context)),
                                  splashColor: Color.fromRGBO(48, 111, 220, 1),
                                  onTap: () {
                                    _pageController?.animateToPage(
                                      0,
                                      duration: Duration(milliseconds: 1),
                                      curve: Curves.linear,
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: Responsive.width(20.0, context),
                                        right: Responsive.width(24.0, context),
                                        top: Responsive.height(14.0, context),
                                        bottom:
                                            Responsive.height(13.0, context)),
                                    child: Center(
                                      child: Text(
                                        'Placement',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'DM Sans',
                                          fontSize:
                                              Responsive.text(16.0, context),
                                          fontWeight: placement == 1
                                              ? FontWeight.w900
                                              : FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          height:
                                              Responsive.height(1.0, context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: Color.fromRGBO(48, 111, 220, internship),
                                borderRadius: BorderRadius.circular(
                                    Responsive.height(30.0, context)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                      Responsive.height(30.0, context)),
                                  splashColor: Color.fromRGBO(48, 111, 220, 1),
                                  onTap: () {
                                    _pageController?.animateToPage(
                                      1,
                                      duration: Duration(milliseconds:1),
                                      curve: Curves.linear,
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: Responsive.width(20.0, context),
                                        right: Responsive.width(24.0, context),
                                        top: Responsive.height(14.0, context),
                                        bottom:
                                            Responsive.height(13.0, context)),
                                    child: Center(
                                      child: Text(
                                        'Internship',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'DM Sans',
                                          fontSize:
                                              Responsive.text(16.0, context),
                                          fontWeight: internship == 1
                                              ? FontWeight.w900
                                              : FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          height:
                                              Responsive.height(1.0, context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: Color.fromRGBO(48, 111, 220, external),
                                borderRadius: BorderRadius.circular(
                                    Responsive.height(30.0, context)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                      Responsive.height(30.0, context)),
                                  splashColor: Color.fromRGBO(48, 111, 220, 1),
                                  onTap: () {
                                    _pageController?.animateToPage(
                                      2,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: Responsive.width(20.0, context),
                                        right: Responsive.width(24.0, context),
                                        top: Responsive.height(14.0, context),
                                        bottom:
                                            Responsive.height(13.0, context)),
                                    child: Center(
                                      child: Text(
                                        'External',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'DM Sans',
                                          fontSize:
                                              Responsive.text(16.0, context),
                                          fontWeight: external == 1
                                              ? FontWeight.w900
                                              : FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          height:
                                              Responsive.height(1.0, context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 16, right: 16, top: 16),
                          height: Responsive.height(53.0, context),
                          padding: EdgeInsets.only(
                              left: Responsive.width(14.0, context),
                              right: Responsive.width(14.0, context),
                              top: Responsive.height(13.0, context),
                              bottom: Responsive.height(13.0, context)),
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/blogs/searchbar.png'),
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(
                                Responsive.height(2.0, context)),
                          ),
                          child: Row(
                            children: [
                              Image(
                                image: AssetImage('assets/blogs/search.png'),
                                height: Responsive.height(24.0, context),
                                width: Responsive.width(24.0, context),
                              ),
                              SizedBox(width: Responsive.width(8.0, context)),
                              Expanded(
                                child: TextField(
                                  controller: _searchFieldController,
                                  focusNode: _focusNode,
                                  style: TextStyle(
                                    fontSize: Responsive.text(16.0, context),
                                    color: Color.fromRGBO(0, 0, 0, 0.8),
                                    fontFamily: 'DM Sans',
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search blogs',
                                    hintStyle: TextStyle(
                                      fontSize: Responsive.text(16.0, context),
                                      color: Color.fromRGBO(0, 0, 0, 0.4),
                                      fontFamily: 'DM Sans',
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (query) async {
                                    setState(() {
                                      currquery = query;
                                    });
                                    if ((postType != PostType.ChatBot &&
                                            query.length >= 4) ||
                                        query.length == 0) {
                                      blogBloc!.query = query;
                                      await blogBloc.refresh(
                                          force: query.isEmpty);
                                    }
                                  },
                                  onSubmitted: (query) async {
                                    setState(() {
                                      currquery = query;
                                    });
                                    blogBloc!.query = query;
                                    await blogBloc.refresh(
                                        force: query.isEmpty);
                                  },
                                  // autofocus: true,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: Responsive.width(8.0, context)),
                              if (currquery != null && currquery!.isNotEmpty)
                                InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () {
                                    _searchFieldController?.clear();
                                    _focusNode.unfocus();
                                    blogBloc!.query = '';
                                    blogBloc.refresh();
                                    setState(() {
                                      currquery = "";
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        Responsive.width(3, context)),
                                    child: SvgPicture.asset(
                                        'assets/explore/x.svg',
                                        width: Responsive.width(24.0, context),
                                        height:
                                            Responsive.height(24.0, context)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.height(16.0, context)),
                        // Container(
                        //     margin:
                        //         EdgeInsets.only(left: Responsive.width(16.0, context), right: Responsive.width(16.0, context)),
                        //     child: Row(
                        //         mainAxisAlignment:
                        //             MainAxisAlignment.spaceBetween,
                        //         children: [
                        //           Container(
                        //               decoration: BoxDecoration(
                        //                 color: const Color.fromARGB(
                        //                     255, 239, 239, 239),
                        //                 borderRadius:
                        //                     BorderRadius.circular(Responsive.height(50.0, context)),
                        //                 border: Border.all(
                        //                   color: Color.fromRGBO(
                        //                       210, 213, 218, 1),
                        //                   width: Responsive.height(1.0, context),
                        //                 ),
                        //               ),
                        //               padding: EdgeInsets.only(
                        //                   left: Responsive.width(16.0, context),
                        //                   right: Responsive.width(16.0, context),
                        //                   top: Responsive.height(8.0, context),
                        //                   bottom: Responsive.height(8.0, context)),
                        //               child: Row(
                        //                 children: [
                        //                   SvgPicture.asset(
                        //                       'assets/blogs/box.svg'),
                        //                   SizedBox(width: Responsive.width(8.0, context)),
                        //                   Text(
                        //                     'Filters',
                        //                     style: TextStyle(
                        //                       fontSize: Responsive.text(14.0, context),
                        //                       fontWeight: FontWeight.w500,
                        //                       color: Colors.black,
                        //                       fontFamily: "DM Sans",
                        //                       fontStyle: FontStyle.normal,
                        //                     ),
                        //                   ),
                        //                   SizedBox(width: Responsive.width(8.0, context)),
                        //                   SvgPicture.asset(
                        //                       'assets/blogs/chevron-right.svg'),
                        //                 ],
                        //               )),
                        //           Container(
                        //               child: Row(
                        //             children: [
                        //               Container(
                        //                 height: Responsive.height(36.0, context),
                        //                 width: Responsive.width(36.0, context),
                        //                 decoration: BoxDecoration(
                        //                   color: view == 'normal'
                        //                       ? const Color.fromRGBO(
                        //                           48, 111, 220, 1)
                        //                       : const Color.fromRGBO(
                        //                           239, 239, 239, 1),
                        //                   borderRadius:
                        //                       BorderRadius.circular(Responsive.height(18.0, context)),
                        //                 ),
                        //                 child: IconButton(
                        //                     icon: SvgPicture.asset(
                        //                       'assets/blogs/list.svg',
                        //                       color: view == 'normal'
                        //                           ? Colors.white
                        //                           : Colors.black,
                        //                       fit: BoxFit.none,
                        //                     ),
                        //                     onPressed: () {
                        //                       setState(() {
                        //                         view = 'normal';
                        //                       });
                        //                     }),
                        //               ),
                        //               SizedBox(width: Responsive.width(8.0, context)),
                        //               Container(
                        //                 height: Responsive.height(36.0, context),
                        //                 width: Responsive.width(36.0, context),
                        //                 decoration: BoxDecoration(
                        //                   color: view == 'company wise'
                        //                       ? const Color.fromRGBO(
                        //                           48, 111, 220, 1)
                        //                       : const Color.fromRGBO(
                        //                           239, 239, 239, 1),
                        //                   borderRadius:
                        //                       BorderRadius.circular(18),
                        //                   border: Border.all(
                        //                     color: Color.fromRGBO(
                        //                         210, 213, 218, 1),
                        //                     width: Responsive.width(1.0, context),
                        //                   ),
                        //                 ),
                        //                 child: IconButton(
                        //                     icon: SvgPicture.asset(
                        //                       'assets/blogs/list2.svg',
                        //                       color: view == 'company wise'
                        //                           ? Colors.white
                        //                           : Colors.black,
                        //                       fit: BoxFit.none,
                        //                     ),
                        //                     onPressed: () {
                        //                       setState(() {
                        //                         view = 'company wise';
                        //                       });
                        //                     }),
                        //               ),
                        //             ],
                        //           ))
                        //         ])),
                        // SizedBox(height: Responsive.height(24.0, context)),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              switchToTab(index);
                            },
                            children: [
                              // Placement Tab
                              _buildTabContent(
                                  PostType.Placement, context, blogBloc),
                              // Internship Tab
                              _buildTabContent(
                                  PostType.Training, context, blogBloc),
                              // External Tab
                              _buildTabContent(
                                  PostType.External, context, blogBloc),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return BlogsLogin();
                // return ListView(
                //   children: <Widget>[
                //     TitleWithBackButton(
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: <Widget>[
                //           Text(
                //             "Blogs",
                //             style: theme.textTheme.displaySmall,
                //           ),
                //         ],
                //       ),
                //     ),
                //     Center(
                //       child: Padding(
                //         padding: const EdgeInsets.all(28.0),
                //         child: Text(
                //           "You must be logged in to view Blogs",
                //           style: theme.textTheme.titleLarge,
                //           textAlign: TextAlign.center,
                //         ),
                //       ),
                //     ),
                //   ],
                // );
              }
            },
          )),
    );
  }

  Map<String, List<Post>> groupPostsByCompany(List<Post> posts) {
    final Map<String, List<Post>> companyMap = {};
    for (final post in posts) {
      final company = extractCompanyName(post.title!);
      companyMap.putIfAbsent(company, () => []);
      companyMap[company]!.add(post);
    }
    return companyMap;
  }

  String extractCompanyName(String title) {
    if (title.contains('|')) {
      return title.split('|')[0].trim();
    }
    return title.trim();
  }

  Widget _buildTabContent(
      PostType tabPostType, BuildContext context, blogBloc) {
    var bloc = BlocProvider.of(context)!.bloc;
    var tabBlogBloc = bloc.getPostsBloc(tabPostType);

    if (view == 'normal') {
      return StreamBuilder<UnmodifiableListView<Post>>(
        stream: tabBlogBloc!.blog,
        builder: (BuildContext context,
            AsyncSnapshot<UnmodifiableListView<Post>> snapshot) {
          final posts = snapshot.data;
          final int baseCount = (posts == null || posts.isEmpty)
              ? 0
              : ((posts.isNotEmpty && posts.last.content == null)
                  ? posts.length - 1
                  : posts.length);
          final int totalItemCount = baseCount + 1;

          return RefreshIndicator(
            onRefresh: () =>
                blogBloc.refresh(force: tabBlogBloc.query.isEmpty),
            child: ListView.builder(
              controller: tabPostType == PostType.Placement
                  ? _placementScrollController
                  : tabPostType == PostType.Training
                      ? _trainingScrollController
                      : _externalScrollController,
              itemBuilder: (BuildContext context, int index) {
                return _buildPost(tabBlogBloc, index, snapshot.data, context);
              },
              itemCount: totalItemCount,
            ),
          );
        },
      );
    } else {
      // Company wise view
      return StreamBuilder<UnmodifiableListView<Post>>(
        stream: tabBlogBloc!.blog,
        builder: (BuildContext context,
            AsyncSnapshot<UnmodifiableListView<Post>> snapshot) {
          final List<Post> posts = snapshot.data?.toList() ?? [];
          final Map<String, List<Post>> companyMap = groupPostsByCompany(posts);
          return ListView(
            children: <Widget>[
              for (final entry in companyMap.entries)
                Blogthread(
                  entry.value,
                  entry.key,
                ),
            ],
          );
        },
      );
    }
  }

  Widget _buildPost(
      PostBloc bloc, int index, List<Post>? posts, BuildContext context) {
    bloc.inPostIndex.add(index);

    final Post? post =
        (posts != null && posts.length > index) ? posts[index] : null;

    if (post == null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (post?.content == null) {
      return Container(
          child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: Responsive.height(4.0, context),
            horizontal: Responsive.width(4.0, context)),
        child: Center(
          child: Text("End of Results",
              style: TextStyle(
                fontSize: Responsive.text(16.0, context),
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                color: Colors.black,
              )),
        ),
      ));
    }
    return _post(post, bloc, context);
  }

  Widget _post(dynamic post, PostBloc bloc, BuildContext context) {
    return Container(
      key: ValueKey(post.id),
      child: Container(
        margin: EdgeInsets.only(
            left: Responsive.width(16.0, context),
            right: Responsive.width(16.0, context),
            bottom: Responsive.height(16.0, context)),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(48, 111, 220, 1),
          borderRadius: BorderRadius.circular(Responsive.height(14.0, context)),
        ),
        child: ClipRRect(
            borderRadius:
                BorderRadius.circular(Responsive.height(14.0, context)),
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                    left: Responsive.width(18.0, context),
                    right: Responsive.width(16.0, context),
                    top: Responsive.height(16.0, context),
                    bottom: Responsive.height(16.0, context)),
                margin: EdgeInsets.only(left: Responsive.width(6.0, context)),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(239, 239, 239, 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: const Color.fromRGBO(239, 239, 239, 1),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                            Responsive.height(2.0, context)),
                        onTap: () async {
                          if (await canLaunchUrl(Uri.parse(post.link))) {
                            await launchUrl(
                              Uri.parse(post.link),
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              height: Responsive.height(48.0, context),
                              width: Responsive.width(48.0, context),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(48, 111, 220, 1),
                                borderRadius: BorderRadius.circular(
                                    Responsive.height(24.0, context)),
                              ),
                              child: SvgPicture.asset(
                                'assets/blogs/briefcase.svg',
                                height: Responsive.height(24.0, context),
                                width: Responsive.width(24.0, context),
                                fit: BoxFit.none,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: Responsive.height(3.0, context),
                                    bottom: Responsive.height(3.0, context),
                                    right: Responsive.width(16.0, context)),
                                child: Container(
                                  child: RichText(
                                    text: highlight(
                                        post.title, bloc.query, context),
                                    strutStyle: StrutStyle.fromTextStyle(
                                      TextStyle(
                                        fontSize:
                                            Responsive.text(14.0, context),
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w700,
                                      ),
                                      height: Responsive.height(1.0, context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    // style: TextStyle(
                                    //   fontSize: 16,
                                    //   fontFamily: 'DM Sans',
                                    //   fontWeight: FontWeight.w700,
                                    // ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: Responsive.width(40.0, context),
                              height: Responsive.height(48.0, context),
                              child: Material(
                                color: Colors.transparent,
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/blogs/external-link.svg',
                                    height: Responsive.height(24.0, context),
                                    width: Responsive.width(24.0, context),
                                    fit: BoxFit.none,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Responsive.height(20.0, context),
                    ),
                    Container(
                        child: Text(
                      post.published,
                      style: TextStyle(
                        fontSize: Responsive.text(16.0, context),
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        color: const Color.fromRGBO(48, 111, 220, 1),
                      ),
                    )),
                    SizedBox(
                      height: Responsive.height(8.0, context),
                    ),
                    Container(
                      child: CommonHtml(
                        data: wrapTableWithDiv(
                            highlightHtml(post.content ?? "", bloc.query)),
                        defaultTextStyle:
                            Theme.of(context).textTheme.bodyMedium ??
                                TextStyle(),
                      ),
                    ),
                  ],
                ))),
      ),
    );
  }
}

String wrapTableWithDiv(String html) {
  return html.replaceAllMapped(
    RegExp(r'(<table[\s\S]*?>[\s\S]*?<\/table>)',
        multiLine: true, caseSensitive: false),
    (match) => '<div class="table-radius">${match.group(0)}</div>',
  );
}

class CommonHtml extends StatelessWidget {
  final String? data;
  final TextStyle defaultTextStyle;

  CommonHtml({this.data, required this.defaultTextStyle});

  @override
  Widget build(BuildContext context) {
    return data != null
        ? HtmlWidget(
            data ?? "",
            customStylesBuilder: (element) {
              if (element.classes.contains('hl')) {
                return {
                  'background-color': '#ffd54f',
                  'padding': '0px',
                  'border-radius': '2px',
                };
              }
              if (element.classes.contains('table-radius')) {
                return {
                  'border-radius': '8px',
                  'overflow': 'hidden',
                };
              }
              if (element.localName == 'table') {
                return {
                  'background-color': '#f6f6f6',
                  'padding': '16px',
                };
              }
              return null;
            },
            factoryBuilder: () => SelectableWidgetFactory(),
            onTapUrl: (link) async {
              if (await canLaunchUrl(Uri.parse(link))) {
                await launchUrl(
                  Uri.parse(link),
                  mode: LaunchMode.externalApplication,
                );
                return true;
              } else {
                throw "Couldn't launch $link";
              }
            },
          )
        : CircularProgressIndicatorExtended(
            label: Text("Loading content"),
          );
  }
}

class SelectableWidgetFactory extends WidgetFactory with SelectableTextFactory {
  @override
  SelectionChangedCallback? get selectableTextOnChanged => (selection, cause) {
        // do something when the selection changes
      };
}

class CircularProgressIndicatorExtended extends StatelessWidget {
  CircularProgressIndicatorExtended({
    Key? key,
    this.label,
    this.size = 18,
  }) : super(key: key);

  final Widget? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            valueColor:
                new AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
            strokeWidth: 2,
          ),
        ),
      ]..addAll(label != null
          ? [
              SizedBox(
                width: Responsive.width(12.0, context),
              ),
              label!
            ]
          : []),
    );
  }
}

class Blogthread extends StatefulWidget {
  const Blogthread(this.posts, this.CompanyName);
  final List<Post>? posts;
  final String CompanyName;
  @override
  _BlogthreadState createState() => _BlogthreadState();
}

class _BlogthreadState extends State<Blogthread> {
  String extractDepartmentName(String title) {
    if (title.contains('|')) {
      return title.split('|')[1].trim();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 15, right: 16, bottom: 102),
        child: Stack(children: [
          Positioned(
            left: Responsive.width(24.0, context),
            top: Responsive.height(12.0, context),
            bottom: Responsive.height(4.0, context),
            child: Container(
              width: Responsive.width(1.0, context),
              decoration: BoxDecoration(
                color: Color.fromRGBO(48, 111, 220, 1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                  margin: const EdgeInsets.only(
                    left: 1,
                    right: 1,
                  ),
                  child: Row(children: [
                    Container(
                      height: Responsive.height(48.0, context),
                      width: Responsive.width(48.0, context),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(48, 111, 220, 1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: SvgPicture.asset(
                        'assets/blogs/briefcase.svg',
                        height: 24,
                        width: 24,
                        fit: BoxFit.none,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            widget.CompanyName,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          Text(
                            extractDepartmentName(widget.posts!.first.title!),
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ])),
                    const SizedBox(width: 16),
                    // SizedBox(
                    //   width: 40,
                    //   height: 48,
                    //   child: Material(
                    //     color: Colors.transparent,
                    //     child: InkWell(
                    //       borderRadius: BorderRadius.circular(2),
                    //       onTap: () {},
                    //       child: Center(
                    //         child: SvgPicture.asset(
                    //           'assets/blogs/external-link.svg',
                    //           height: 24,
                    //           width: 24,
                    //           fit: BoxFit.none,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ])),
              for (int i = 0; i < widget.posts!.length; i++)
                Companywiseblog(widget.posts![i]),
            ],
          ),
        ]));
  }
}

class Companywiseblog extends StatefulWidget {
  final Post? post;
  const Companywiseblog(this.post);
  @override
  _CompanywiseblogState createState() => _CompanywiseblogState();
}

class _CompanywiseblogState extends State<Companywiseblog> {
  String htmlToPlainText(String htmlData) {
    final document = html_parser.parse(htmlData);
    return document.body?.text ?? '';
  }

  String getFirstLine(String document) {
    return document.split('\n').first;
  }

  bool expandedview = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      if (!expandedview)
        Container(
            margin: const EdgeInsets.only(
              left: 19,
              top: 20,
            ),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(48, 111, 220, 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(239, 239, 239, 1),
                    ),
                    padding: const EdgeInsets.only(
                        left: 17, right: 16, top: 15, bottom: 18),
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post!.published ?? "",
                                  style: TextStyle(
                                    color:
                                        const Color.fromRGBO(48, 111, 220, 1),
                                    fontSize: 16,
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Container(
                                //   margin: const EdgeInsets.only(right: 4),
                                //   padding: const EdgeInsets.only(
                                //       left: 8,
                                //       right: 8,
                                //       top: 4,
                                //       bottom: 4),
                                //   decoration: BoxDecoration(
                                //     border: Border.all(
                                //         color: const Color.fromRGBO(
                                //             104, 189, 0, 1),
                                //         width: 1.33),
                                //     borderRadius:
                                //         BorderRadius.circular(12),
                                //   ),
                                //   child: Text(
                                //     'New',
                                //     style: TextStyle(
                                //       color:
                                //           Color.fromRGBO(104, 189, 0, 1),
                                //       fontSize: 10,
                                //       fontFamily: 'Inter',
                                //       fontWeight: FontWeight.w700,
                                //     ),
                                //   ),
                                // ),
                                // Container(
                                //   margin: const EdgeInsets.only(right: 4),
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 8, vertical: 4),
                                //   decoration: BoxDecoration(
                                //     border: Border.all(
                                //         color: const Color.fromRGBO(
                                //             255, 171, 81, 1),
                                //         width: 1.33),
                                //     borderRadius:
                                //         BorderRadius.circular(12),
                                //   ),
                                //   child: Text(
                                //     'Mention',
                                //     style: TextStyle(
                                //       color:
                                //           Color.fromRGBO(255, 171, 81, 1),
                                //       fontSize: 10,
                                //       fontFamily: 'Inter',
                                //       fontWeight: FontWeight.w700,
                                //     ),
                                //   ),
                                // )
                              ]),
                          SizedBox(height: 8),
                          Container(
                              child: Text(
                                  // getFirstLine(htmlToPlainText(
                                  //     widget.post?.content ?? "") == "" ? htmlToPlainText(widget.post?.content ?? "") : getFirstLine(htmlToPlainText(
                                  //     widget.post?.content ?? ""))),
                                  //     maxLines: 2,
                                  htmlToPlainText(widget.post?.content ?? ""),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w400,
                                  ))),
                        ])),
                        InkWell(
                          child: SvgPicture.asset(
                            'assets/blogs/chevron-right.svg',
                            height: 24,
                            width: 24,
                            fit: BoxFit.none,
                          ),
                          onTap: () {
                            setState(() {
                              expandedview = true;
                            });
                          },
                        ),
                      ],
                    )))),
      if (expandedview)
        Container(
          margin: const EdgeInsets.only(
            left: 19,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(48, 111, 220, 1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(239, 239, 239, 1),
                ),
                padding: const EdgeInsets.only(
                    left: 18, right: 16, top: 16, bottom: 16),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      child: SvgPicture.asset(
                        'assets/blogs/chevron-right.svg',
                        height: 24,
                        width: 24,
                        fit: BoxFit.none,
                      ),
                      onTap: () {
                        setState(() {
                          expandedview = false;
                        });
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        child: Text(
                      widget.post!.published ?? "",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        color: const Color.fromRGBO(48, 111, 220, 1),
                      ),
                    )),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      child: CommonHtml(
                        data: widget.post?.content,
                        defaultTextStyle:
                            Theme.of(context).textTheme.bodyMedium ??
                                TextStyle(),
                      ),
                    ),
                  ],
                )),
          ),
        )
    ]));
  }
}
