import 'dart:async';
import 'dart:core';
import 'dart:collection';
import 'dart:math' as math;
import 'package:InstiApp/src/routes/blogslogin.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/api/model/post.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_selectable_text/fwfh_selectable_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:InstiApp/src/utils/responsivenew.dart';
import 'dart:convert';
import 'package:html/dom.dart' as html_dom;

// How recent a post has to be to get the "New" pill.
const Duration kNewPostWindow = Duration(hours: 12);

/// Best-effort "is this post new" check.
///
/// Confirmed from post.dart: `Post.published` is just a plain `String?` --
/// there's no separate raw/ISO timestamp field on the model, and no
/// "mention" field either. So this has to work off the display string
/// itself (e.g. "Thur, Nov 28, 22:53:02"), which has NO YEAR in it.
///
/// This is a workaround, not a proper fix: it assumes the current year,
/// and rolls back a year if that would place the post in the future. That
/// mostly works, but is ambiguous right at year boundaries (e.g. a post
/// from ~12 months ago could misfire). The real fix is to have the API
/// expose a raw ISO timestamp on Post -- worth flagging to whoever owns
/// the backend if the "New" pill needs to be reliable.
bool isPostNew(Post? post) {
  final DateTime? parsed = _parsePublishedDate(post?.published);
  if (parsed == null) return false;
  return DateTime.now().difference(parsed) <= kNewPostWindow;
}

DateTime? _parsePublishedDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;

  // In case `published` is ever a proper ISO 8601 / RFC 3339 string.
  final DateTime? iso = DateTime.tryParse(raw);
  if (iso != null) return iso;

  // Fallback: parse the "EEE, MMM d, HH:mm:ss" shape seen in the UI today
  // (e.g. "Thur, Nov 28, 22:53:02"), assuming the current year.
  const Map<String, int> monthMap = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };
  final RegExpMatch? match = RegExp(
    r'^\s*\w+,\s*([A-Za-z]{3})[a-z]*\s+(\d{1,2}),\s*(\d{1,2}):(\d{2}):(\d{2})\s*$',
  ).firstMatch(raw);
  if (match == null) return null;

  final int? month = monthMap[match.group(1)!.toLowerCase()];
  final int? day = int.tryParse(match.group(2)!);
  final int? hour = int.tryParse(match.group(3)!);
  final int? minute = int.tryParse(match.group(4)!);
  final int? second = int.tryParse(match.group(5)!);
  if (month == null || day == null || hour == null || minute == null || second == null) {
    return null;
  }

  final DateTime now = DateTime.now();
  DateTime candidate = DateTime(now.year, month, day, hour, minute, second);
  if (candidate.isAfter(now.add(const Duration(days: 1)))) {
    candidate = DateTime(now.year - 1, month, day, hour, minute, second);
  }
  return candidate;
}

// Small pill used for the "New" / "Mention" tags on a post header.
class BlogTagPill extends StatelessWidget {
  final String label;
  final Color color;
  const BlogTagPill({Key? key, required this.label, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

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
  final int blogState; // 0: Placement, 1: Internship

  const BlogPage({Key? key, this.blogState = 0}) : super(key: key);

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  String view = 'normal'; // 'normal' or 'company wise'
  TextEditingController? _searchFieldController;
  Set<String> _selectedRoles = <String>{};
  Set<String> _selectedDepartments = <String>{};

  late PostType postType;
  String? selectedDepartment;
  String? currquery = "";
  @override
  void initState() {
    super.initState();
    _searchFieldController = TextEditingController();
    postType = widget.blogState == 1 ? PostType.Training : PostType.Placement;
    setUrl();
    _placementScrollController = ScrollController()..addListener(_handleScroll);
    _trainingScrollController = ScrollController()..addListener(_handleScroll);
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
    _focusNode.dispose();
    _placementScrollController?.dispose();
    _trainingScrollController?.dispose();
    _yearPillHideTimer?.cancel();
    super.dispose();
  }

  void setUrl() {
    postType = widget.blogState == 1 ? PostType.Training : PostType.Placement;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  FocusNode _focusNode = FocusNode();
  ScrollController? _placementScrollController;
  ScrollController? _trainingScrollController;
  double isFabVisible = 0;
  IconData actionIcon = Icons.search_outlined;

  // Floating "current year" pill for the company-wise view.
  // Keys let us measure where each year header actually ended up on screen
  // (no sticky-header package needed for a "fade in/out while scrolling"
  // indicator -- we just need to know which section is at the top).
  final Map<int, GlobalKey> _companyYearHeaderKeys = {};
  final GlobalKey _companyListViewportKey = GlobalKey();
  int? _visibleYear;
  double _yearPillOpacity = 0;
  Timer? _yearPillHideTimer;

  // Google Photos-style draggable scrollbar for the company-wise view.
  // _companyScrollFraction tracks where the thumb sits (0 = top, 1 =
  // bottom); it follows normal scrolling too, not just dragging.
  double _companyScrollFraction = 0.0;
  bool _isDraggingYearScrollbar = false;

  ScrollController? get _activeScrollController {
    return postType == PostType.Placement
        ? _placementScrollController
        : _trainingScrollController;
  }

  void _handleScroll() {
    final controller = _activeScrollController;
    if (!mounted || controller == null || !controller.hasClients) return;
    final visible =
        controller.position.userScrollDirection == ScrollDirection.forward &&
            controller.offset > 100;
    setState(() => isFabVisible = visible ? 1 : 0);

    if (view == 'company') {
      _updateVisibleYearIndicator();
      // Keep the scrollbar thumb in sync with normal scrolling too, but
      // don't fight the user's finger while they're actively dragging it.
      if (!_isDraggingYearScrollbar) {
        final double maxExtent = controller.position.maxScrollExtent;
        final double fraction =
        maxExtent > 0 ? (controller.offset / maxExtent).clamp(0.0, 1.0) : 0.0;
        if ((fraction - _companyScrollFraction).abs() > 0.001) {
          setState(() => _companyScrollFraction = fraction);
        }
      }
    }
  }

  // Finds the year header that's scrolled up to (or past) the top of the
  // list viewport, shows the floating pill for it, and schedules the pill
  // to fade back out shortly after scrolling settles (unless the
  // scrollbar is actively being held, in which case it should just stay).
  void _updateVisibleYearIndicator() {
    const double topThreshold = 12; // relative to the list's own viewport
    final RenderObject? viewport =
    _companyListViewportKey.currentContext?.findRenderObject();
    if (viewport is! RenderBox || !viewport.attached) return;

    int? matchedYear;
    double? matchedY;

    for (final entry in _companyYearHeaderKeys.entries) {
      final renderObject = entry.value.currentContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.attached) continue;
      final double y =
          renderObject.localToGlobal(Offset.zero, ancestor: viewport).dy;
      if (y <= topThreshold && (matchedY == null || y > matchedY!)) {
        matchedYear = entry.key;
        matchedY = y;
      }
    }

    if (matchedYear == null) return;

    if (matchedYear != _visibleYear || _yearPillOpacity == 0) {
      setState(() {
        _visibleYear = matchedYear;
        _yearPillOpacity = 1;
      });
    }

    if (_isDraggingYearScrollbar) return; // stay visible while held

    _yearPillHideTimer?.cancel();
    _yearPillHideTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _yearPillOpacity = 0);
    });
  }

  // Jumps the active list to the given fraction (0..1) of its scroll
  // extent -- used by the draggable year scrollbar.
  void _seekCompanyListToFraction(double fraction) {
    final controller = _activeScrollController;
    if (controller == null || !controller.hasClients) return;
    final double maxExtent = controller.position.maxScrollExtent;
    controller.jumpTo((fraction * maxExtent).clamp(0.0, maxExtent));
  }

  bool firstBuild = true;
  String? loadingReaction;

  static const List<String> _blogRoleOptions = <String>[
    'Software',
    'Developer',
    'Research',
    'Design',
    'Developer',
    'Research',
    'Design',
    'Developer',
    'Research',
    'Design',
  ];

  static const List<String> _blogDepartmentOptions = <String>[
    'CS',
    'Mech',
    'Civil',
    'IDC',
    'Aerospcae',
    'Management',
    'Electrical',
  ];

  int _activeBlogFilterCount() {
    return _selectedRoles.length + _selectedDepartments.length;
  }

  void _openBlogFiltersSheet() {
    final tempRoles = <String>{..._selectedRoles};
    final tempDepartments = <String>{..._selectedDepartments};
    String activeTab = 'roles';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return FractionallySizedBox(
              heightFactor: 0.663,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.width(16, context),
                        vertical: Responsive.height(24, context),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter By',
                            style: TextStyle(
                              fontSize: Responsive.text(20, context),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'DM Sans',
                              color: const Color(0xFF282828),
                            ),
                          ),
                          Text(
                            '${_activeBlogFilterCount()} active',
                            style: TextStyle(
                              fontSize: Responsive.text(14, context),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'DM Sans',
                              color: const Color(0xFF7E8287),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Responsive.width(125, context),
                            child: Column(
                              children: [
                                _buildBlogSidebarTab(
                                  label: 'Roles',
                                  isActive: activeTab == 'roles',
                                  onTap: () =>
                                      setSheetState(() => activeTab = 'roles'),
                                  context: context,
                                ),
                                _buildBlogSidebarTab(
                                  label: 'Department',
                                  isActive: activeTab == 'department',
                                  onTap: () => setSheetState(
                                          () => activeTab = 'department'),
                                  context: context,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                ),
                                color: const Color(0xFFEFEFEF),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.only(
                                  top: Responsive.height(16, context),
                                  left: Responsive.width(20, context),
                                  right: Responsive.width(12, context),
                                  bottom: Responsive.height(16, context),
                                ),
                                itemCount: activeTab == 'roles'
                                    ? _blogRoleOptions.length
                                    : _blogDepartmentOptions.length,
                                itemBuilder: (context, index) {
                                  final option = activeTab == 'roles'
                                      ? _blogRoleOptions[index]
                                      : _blogDepartmentOptions[index];
                                  final selectedSet = activeTab == 'roles'
                                      ? tempRoles
                                      : tempDepartments;
                                  final isSelected =
                                  selectedSet.contains(option);
                                  return GestureDetector(
                                    onTap: () => setSheetState(() {
                                      if (!selectedSet.add(option)) {
                                        selectedSet.remove(option);
                                      }
                                    }),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: Responsive.height(12, context),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width:
                                            Responsive.width(18, context),
                                            height:
                                            Responsive.height(18, context),
                                            decoration: BoxDecoration(
                                              // shape: BoxShape.circle,
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFF306FDC)
                                                    : const Color(0xFFD2D5DA),
                                                width: 1.5,
                                              ),
                                              color: isSelected
                                                  ? const Color(0xFF306FDC)
                                                  : Colors.transparent,
                                            ),
                                            child: isSelected
                                                ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                                : null,
                                          ),
                                          SizedBox(
                                              width: Responsive.width(
                                                  12, context)),
                                          Expanded(
                                            child: Text(
                                              option,
                                              style: TextStyle(
                                                color: const Color(0xFF0F1620),
                                                fontSize: Responsive.text(
                                                    14, context),
                                                fontFamily: 'DM Sans',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: const Color(0xFFF6F6F6),
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.width(16, context),
                        vertical: Responsive.height(16, context),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  tempRoles.clear();
                                  tempDepartments.clear();
                                });
                              },
                              child: SizedBox(
                                height: Responsive.height(60, context),
                                child: Center(
                                  child: Text(
                                    'Clear All',
                                    style: TextStyle(
                                      color: const Color(0xFF0F1620),
                                      fontSize: Responsive.text(18, context),
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.w700,
                                      // decoration: TextDecoration.underline,
                                      // decorationStyle:
                                      // TextDecorationStyle.dotted,
                                      // decorationColor: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: Responsive.width(12, context)),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRoles = <String>{...tempRoles};
                                  _selectedDepartments = <String>{
                                    ...tempDepartments
                                  };
                                });
                                Navigator.of(sheetContext).pop();
                              },
                              child: Container(
                                height: Responsive.height(60, context),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F1620),
                                  borderRadius: BorderRadius.circular(50),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        'assets/blogs/reachapply.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Apply',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Responsive.text(18, context),
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(sheetContext).viewInsets.bottom),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBlogSidebarTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Responsive.width(125, context),
        height: Responsive.height(52, context),
        color: const Color(0xFFEFEFEF),
        child: Stack(
          children: [
            if (isActive)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: Responsive.width(4, context),
                  decoration: const BoxDecoration(
                    color: Color(0xFF306FDC),
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(5),
                    ),
                  ),
                ),
              ),
            if (isActive)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: Responsive.width(104, context),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.0, 0.53),
                      end: Alignment(0.90, 0.53),
                      colors: [Color(0x33306FDC), Color(0x33EFEFEF)],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                left: Responsive.width(16, context),
                top: Responsive.height(16, context),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF0F1620),
                  fontSize: Responsive.text(16, context),
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Post>? threads;
  // ...existing code...
  String highlightHtml(String html, String? query) {
    if (html.isEmpty) return html;
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
                                        width: Responsive.width(24.0, context),
                                        fit: BoxFit.none,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                          '/feed', //navigate to homepage
                                              (route) => false,
                                        );
                                      },
                                    )),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    postType == PostType.Placement
                                        ? 'Placement'
                                        : 'Internship',
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
                        SizedBox(height: Responsive.height(4.0, context)),
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
                        Container(
                            margin: EdgeInsets.only(
                                left: Responsive.width(16.0, context),
                                right: Responsive.width(16.0, context)),
                            child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                      borderRadius: BorderRadius.circular(
                                          Responsive.height(50.0, context)),
                                      onTap: _openBlogFiltersSheet,
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 239, 239, 239),
                                            borderRadius: BorderRadius.circular(
                                                Responsive.height(
                                                    50.0, context)),
                                            border: Border.all(
                                              color: Color.fromRGBO(
                                                  210, 213, 218, 1),
                                              width: Responsive.height(
                                                  1.0, context),
                                            ),
                                          ),
                                          padding: EdgeInsets.only(
                                              left: Responsive.width(
                                                  16.0, context),
                                              right: Responsive.width(
                                                  16.0, context),
                                              top: Responsive.height(
                                                  8.0, context),
                                              bottom: Responsive.height(
                                                  8.0, context)),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                  'assets/blogs/box.svg'),
                                              SizedBox(
                                                  width: Responsive.width(
                                                      8.0, context)),
                                              Text(
                                                'Filters',
                                                style: TextStyle(
                                                  fontSize: Responsive.text(
                                                      14.0, context),
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  fontFamily: "DM Sans",
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                              if (_activeBlogFilterCount() >
                                                  0) ...[
                                                SizedBox(
                                                    width: Responsive.width(
                                                        8.0, context)),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                    Responsive.width(
                                                        8.0, context),
                                                    vertical: Responsive.height(
                                                        2.0, context),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                    const Color(0xFF306FDC),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        999),
                                                  ),
                                                  child: Text(
                                                    _activeBlogFilterCount()
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: Responsive.text(
                                                          12.0, context),
                                                      fontFamily: 'DM Sans',
                                                      fontWeight:
                                                      FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              SizedBox(
                                                  width: Responsive.width(
                                                      8.0, context)),
                                              SvgPicture.asset(
                                                  'assets/blogs/chevron-right.svg'),
                                            ],
                                          ))),
                                  Container(
                                      child: Row(
                                        children: [
                                          Container(
                                            height:
                                            Responsive.height(36.0, context),
                                            width: Responsive.width(36.0, context),
                                            decoration: BoxDecoration(
                                              color: view == 'normal'
                                                  ? const Color.fromRGBO(
                                                  48, 111, 220, 1)
                                                  : const Color.fromRGBO(
                                                  239, 239, 239, 1),
                                              borderRadius: BorderRadius.circular(
                                                  Responsive.height(18.0, context)),
                                            ),
                                            child: IconButton(
                                                icon: SvgPicture.asset(
                                                  'assets/blogs/list2.svg',
                                                  color: view == 'normal'
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fit: BoxFit.none,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    view = 'normal';
                                                  });
                                                }),
                                          ),
                                          SizedBox(
                                              width:
                                              Responsive.width(8.0, context)),
                                          Container(
                                            height:
                                            Responsive.height(36.0, context),
                                            width: Responsive.width(36.0, context),
                                            decoration: BoxDecoration(
                                              color: view == 'company wise'
                                                  ? const Color.fromRGBO(
                                                  48, 111, 220, 1)
                                                  : const Color.fromRGBO(
                                                  239, 239, 239, 1),
                                              borderRadius:
                                              BorderRadius.circular(18),
                                              border: Border.all(
                                                color: Color.fromRGBO(
                                                    210, 213, 218, 1),
                                                width:
                                                Responsive.width(1.0, context),
                                              ),
                                            ),
                                            child: IconButton(
                                                icon: SvgPicture.asset(
                                                  'assets/blogs/list_comp_dark.svg',
                                                  color: view == 'company wise'
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fit: BoxFit.none,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    view = 'company wise';
                                                  });
                                                }),
                                          ),
                                        ],
                                      ))
                                ])),
                        SizedBox(height: Responsive.height(24.0, context)),
                        Expanded(
                          child: _buildTabContent(postType, context, blogBloc),
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

  // Groups posts first by year, then by company within each year.
  //
  // Same caveat as `isPostNew`: `published` has no year in it, so this
  // reuses the same best-effort parser and can really only distinguish
  // "this year" vs "last year" reliably, not a true multi-year archive.
  // Posts with an unparseable date fall back to the current year.
  Map<int, Map<String, List<Post>>> groupPostsByYearAndCompany(
      List<Post> posts) {
    final Map<int, Map<String, List<Post>>> result = {};
    final int fallbackYear = DateTime.now().year;
    for (final post in posts) {
      final DateTime? parsed = _parsePublishedDate(post.published);
      final int year = parsed?.year ?? fallbackYear;
      final String company = extractCompanyName(post.title ?? '');
      result.putIfAbsent(year, () => <String, List<Post>>{});
      result[year]!.putIfAbsent(company, () => <Post>[]);
      result[year]![company]!.add(post);
    }
    return result;
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
            onRefresh: () => blogBloc.refresh(force: tabBlogBloc.query.isEmpty),
            child: ListView.builder(
              controller: tabPostType == PostType.Placement
                  ? _placementScrollController
                  : _trainingScrollController,
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
          final Map<int, Map<String, List<Post>>> yearMap =
          groupPostsByYearAndCompany(posts);
          final List<int> years = yearMap.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          // Keep the header-key map in sync with what's actually on screen
          // right now, so the scroll listener isn't measuring stale keys.
          _companyYearHeaderKeys
              .removeWhere((year, _) => !years.contains(year));
          for (final year in years) {
            _companyYearHeaderKeys.putIfAbsent(year, () => GlobalKey());
          }

          return LayoutBuilder(builder: (context, constraints) {
            final double trackHeight = constraints.maxHeight;
            final double thumbHeight = Responsive.height(48.0, context);
            final double thumbTravel =
            (trackHeight - thumbHeight).clamp(0.0, double.infinity);
            final double thumbTop = thumbTravel * _companyScrollFraction;
            final String labelText =
                '${_visibleYear ?? (years.isNotEmpty ? years.first : '')}';

            void seekFromLocalDy(double localDy) {
              final double fraction =
              thumbTravel > 0 ? ((localDy - thumbHeight / 2) / thumbTravel) : 0.0;
              final double clamped = fraction.clamp(0.0, 1.0);
              setState(() => _companyScrollFraction = clamped);
              _seekCompanyListToFraction(clamped);
            }

            return Stack(
              key: _companyListViewportKey,
              children: [
                ListView(
                  controller: tabPostType == PostType.Placement
                      ? _placementScrollController
                      : _trainingScrollController,
                  children: <Widget>[
                    for (final year in years) ...[
                      Container(
                        key: _companyYearHeaderKeys[year],
                        margin: EdgeInsets.only(
                          left: Responsive.width(19.0, context),
                          top: Responsive.height(8.0, context),
                          bottom: Responsive.height(8.0, context),
                        ),
                        child: Text(
                          '$year',
                          style: TextStyle(
                            fontSize: Responsive.text(20.0, context),
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      for (final entry in yearMap[year]!.entries)
                        Blogthread(entry.value, entry.key),
                    ],
                  ],
                ),
                // Label bubble -- follows the thumb vertically, matches the
                // Google Photos "date while scrubbing" look. Bigger/bolder
                // while actively held, small pill otherwise.
                Positioned(
                  top: (thumbTop - Responsive.height(8.0, context))
                      .clamp(0.0, double.infinity),
                  right: Responsive.width(28.0, context),
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _yearPillOpacity,
                      duration: const Duration(milliseconds: 150),
                      child: AnimatedScale(
                        scale: _isDraggingYearScrollbar ? 1.0 : 0.85,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.width(
                                _isDraggingYearScrollbar ? 18.0 : 14.0,
                                context),
                            vertical: Responsive.height(
                                _isDraggingYearScrollbar ? 10.0 : 8.0,
                                context),
                          ),
                          decoration: BoxDecoration(
                            color: _isDraggingYearScrollbar
                                ? const Color.fromRGBO(48, 111, 220, 1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            labelText,
                            style: TextStyle(
                              fontSize: Responsive.text(
                                  _isDraggingYearScrollbar ? 16.0 : 14.0,
                                  context),
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w700,
                              color: _isDraggingYearScrollbar
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Draggable track -- press and hold anywhere along the right
                // edge to scrub through the list; the thumb + label follow.
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: Responsive.width(28.0, context),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (details) =>
                        seekFromLocalDy(details.localPosition.dy),
                    onVerticalDragStart: (details) {
                      _yearPillHideTimer?.cancel();
                      setState(() {
                        _isDraggingYearScrollbar = true;
                        _yearPillOpacity = 1;
                      });
                      seekFromLocalDy(details.localPosition.dy);
                    },
                    onVerticalDragUpdate: (details) =>
                        seekFromLocalDy(details.localPosition.dy),
                    onVerticalDragEnd: (details) {
                      setState(() => _isDraggingYearScrollbar = false);
                      _yearPillHideTimer?.cancel();
                      _yearPillHideTimer =
                          Timer(const Duration(milliseconds: 900), () {
                            if (mounted) setState(() => _yearPillOpacity = 0);
                          });
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: Responsive.width(6.0, context)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(top: thumbTop),
                          width: _isDraggingYearScrollbar ? 6 : 4,
                          height: thumbHeight,
                          decoration: BoxDecoration(
                            color: _isDraggingYearScrollbar
                                ? const Color.fromRGBO(48, 111, 220, 1)
                                : const Color.fromRGBO(0, 0, 0, 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
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
    if (post.content == null) {
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
  // Indices of posts currently expanded within the shared card.
  // Multiple can be open at once -- opening one no longer closes the others.
  Set<int> expandedIndices = {0};

  String extractDepartmentName(String title) {
    if (title.contains('|')) {
      return title.split('|')[1].trim();
    }
    return '';
  }

  // Subject/label shown on each post row, e.g. "Interview Shortlist",
  // "Interview Waitlist", "Second Round Shortlist".
  // NOTE: reusing the same '|' split as extractDepartmentName for now --
  // this will be revisited in the "post card header redesign" part.
  String extractSubject(String title) {
    if (title.contains('|')) {
      final parts = title.split('|');
      return parts.length > 1 ? parts[1].trim() : title.trim();
    }
    return title.trim();
  }

  @override
  Widget build(BuildContext context) {
    final posts = widget.posts ?? <Post>[];
    return Container(
        margin: const EdgeInsets.only(left: 15, right: 16, bottom: 16),
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
                                extractDepartmentName(
                                    posts.isNotEmpty ? (posts.first.title ?? '') : ''),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              // "view company timeline" row -- removed from
                              // the UI for now (kept here, commented out, in
                              // case it needs to come back).
                              // Row(
                              //   children: [
                              //     SvgPicture.asset(
                              //       'assets/blogs/clock.svg',
                              //       height: 18,
                              //       width: 18,
                              //       fit: BoxFit.none,
                              //     ),
                              //     const SizedBox(width: 4),
                              //     Text(
                              //       'view company timeline',
                              //       style: TextStyle(
                              //         color: const Color.fromRGBO(48, 111, 220, 1),
                              //         fontSize: 16,
                              //         fontFamily: 'DM Sans',
                              //         fontWeight: FontWeight.w700,
                              //         decoration: TextDecoration.underline,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ])),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 40,
                      height: 48,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(2),
                          onTap: () {},
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/blogs/external-link.svg',
                              height: 24,
                              width: 24,
                              fit: BoxFit.none,
                            ),
                          ),
                        ),
                      ),
                    )
                  ])),
              const SizedBox(height: 12),
              // All posts for this company now live inside ONE shared card,
              // instead of each post getting its own bordered box.
              if (posts.isNotEmpty) _buildSharedCard(context, posts),
            ],
          ),
        ]));
  }

  Widget _buildSharedCard(BuildContext context, List<Post> posts) {
    return Container(
      margin: const EdgeInsets.only(left: 19),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(48, 111, 220, 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(left: 6),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(239, 239, 239, 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < posts.length; i++) ...[
                Companywiseblog(
                  post: posts[i],
                  isExpanded: expandedIndices.contains(i),
                  subject: extractSubject(posts[i].title ?? ''),
                  onToggle: () {
                    setState(() {
                      if (expandedIndices.contains(i)) {
                        expandedIndices.remove(i);
                      } else {
                        expandedIndices.add(i);
                      }
                    });
                  },
                ),
                if (i != posts.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    indent: 18,
                    endIndent: 16,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class Companywiseblog extends StatelessWidget {
  final Post? post;
  final bool isExpanded;
  final String subject;
  final VoidCallback onToggle;
  // TODO: post.dart has no "mention" field at all, so this is always false
  // for now. Once you decide what defines a mention (tagged role/dept on
  // the post? current user's roll no. in the content?), wire it in here.
  final bool isMention;

  const Companywiseblog({
    Key? key,
    required this.post,
    required this.isExpanded,
    required this.subject,
    required this.onToggle,
    this.isMention = false,
  }) : super(key: key);

  String htmlToPlainText(String htmlData) {
    final document = html_parser.parse(htmlData);
    return document.body?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (!isExpanded) {
      // Collapsed: flat row, just the subject label + a chevron pointing down.
      return InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // TODO: swap for a proper chevron-down.svg asset if you have
              // one -- rotating chevron-right.svg as a stand-in for now.
              Transform.rotate(
                angle: 0,
                child: SvgPicture.asset(
                  'assets/blogs/chevron-right.svg',
                  height: 20,
                  width: 20,
                  fit: BoxFit.none,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Expanded: subject header (tap chevron to collapse) + date + content.
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 16, top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(builder: (context) {
            final bool showNew = isPostNew(post);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      if (showNew)
                        const BlogTagPill(
                          label: 'New',
                          color: Color.fromRGBO(104, 189, 0, 1),
                        ),
                      if (isMention)
                        const BlogTagPill(
                          label: 'Mention',
                          color: Color.fromRGBO(255, 171, 81, 1),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onToggle,
                  // TODO: swap for chevron-up.svg if available.
                  child: Transform.rotate(
                    angle: math.pi,
                    child: SvgPicture.asset(
                      'assets/blogs/chevron-right.svg',
                      height: 24,
                      width: 24,
                      fit: BoxFit.none,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 4),
          Text(
            post?.published ?? "",
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
              color: const Color.fromRGBO(48, 111, 220, 1),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            child: CommonHtml(
              data: post?.content,
              defaultTextStyle:
              Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
            ),
          ),
        ],
      ),
    );
  }
}