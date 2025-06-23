// import 'dart:async';
import 'dart:core';
import 'dart:collection';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/api/model/post.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_selectable_text/fwfh_selectable_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

TextSpan highlight(String result, String query, BuildContext context) {
  var theme = Theme.of(context);
  TextStyle posRes =
      TextStyle(color: Colors.white, backgroundColor: Colors.red);
  TextStyle? negRes = theme.textTheme
      .titleMedium; // TextStyle(backgroundColor: bloc.bloc.brightness.toColor().withOpacity(1.0),);
  if (result == "" || query == "") return TextSpan(text: result, style: negRes);
  result.replaceAll('\n', " ").replaceAll("  ", "");

  var refinedMatch = result.toLowerCase();
  var refinedsearch = query.toLowerCase();

  if (refinedMatch.contains(refinedsearch)) {
    if (refinedMatch.substring(0, refinedsearch.length) == refinedsearch) {
      return TextSpan(
          style: posRes,
          text: result.substring(0, refinedsearch.length),
          children: [
            highlight(result.substring(refinedsearch.length), query, context),
          ]);
    } else if (refinedsearch.length == refinedMatch.length) {
      return TextSpan(text: result, style: posRes);
    } else {
      return TextSpan(
          style: negRes,
          text: result.substring(0, refinedMatch.indexOf(refinedsearch)),
          children: [
            highlight(result.substring(refinedMatch.indexOf(refinedsearch)),
                query, context)
          ]);
    }
  } else if (!refinedMatch.contains(refinedsearch)) {
    return TextSpan(text: result, style: negRes);
  }

  return TextSpan(
    text: result.substring(0, refinedMatch.indexOf(refinedsearch)),
    style: negRes,
    children: [
      highlight(
          result.substring(refinedMatch.indexOf(refinedsearch)), query, context)
    ],
  );
}

class BlogPage extends StatefulWidget {
  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  String view = 'normal';
  final bool loginNeeded = true;
  late Body body = Body(bodyName: 'Null');
  late var bloc;
  late PostType postType;
  String? selectedDepartment;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchBody();
  }

  void _fetchBody() async {
    setUrl();
    bloc = BlocProvider.of(context)!.bloc;
    body = await dostuff();
    setState(() {
      isLoading = true;
    });
  }

  Future<Body> dostuff() async {
    try {
      final response = await http.get(
          Uri.parse('https://gymkhana.iitb.ac.in/instiapp/api/bodies/${url}'));
      Body _body = await bloc.getBody(url);
      return _body;
    } catch (error) {
      return Body(bodyName: 'NULL');
    }
  }

  final List<String> departments = [
    'Aerospace Engineering',
    'Chemical Engineering',
    'Civil Engineering',
    'Computer Science and Engineering',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Metallurgical Engineering and Materials Science',
    'Engineering Physics',
    'Environmental Science and Engineering',
    'Energy Science and Engineering',
    'Industrial Engineering and Operations Research (IEOR)',
  ];
  double placement = 1, internship = 0, external = 0;
  String url = '';
  void setUrl() {
    if (placement == 1) {
      postType = PostType.Placement;
      url = '5023aff7-4407-4e75-95c9-5f691e8c3efb';
    } else if (internship == 1) {
      postType = PostType.Training;
      url = '9cb8659c-bfdf-4e30-a2f0-057f86697123';
    } else if (external == 1) {
      postType = PostType.External;
      url = '8e303dca-9b2d-4501-bf7e-addca5e0c798';
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  FocusNode _focusNode = FocusNode();
  TextEditingController? _searchFieldController;
  ScrollController? _hideButtonController;
  double isFabVisible = 0;

  bool searchMode = false;
  IconData actionIcon = Icons.search_outlined;

  bool firstBuild = true;
  String? loadingReaction;

  List<String>? currCat;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc; // follow-button plugin
    var blogBloc = bloc.getPostsBloc(postType);

    if (firstBuild) {
      blogBloc?.query = "";
      blogBloc?.refresh();
      firstBuild = false;
      isLoading = true;
    }
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            key: _scaffoldKey,
            // drawer: NavDrawer(),
            body: StreamBuilder(
              stream: bloc.session,
              builder:
                  (BuildContext context, AsyncSnapshot<Session?> snapshot) {
                if ((snapshot.hasData && snapshot.data != null) ||
                    loginNeeded) {
                  return Scaffold(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    body: SafeArea(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 52,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16.0,
                                  ),
                                  child: Container(
                                      height: 52,
                                      width: 52,
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            235, 235, 235, 0.8),
                                        borderRadius: BorderRadius.circular(26),
                                      ),
                                      child: IconButton(
                                          icon: SvgPicture.asset(
                                            'assets/blogs/arrow-left.svg',
                                            height: 24,
                                            width: 24,
                                            fit: BoxFit.none,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          })),
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'Blogs',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                        fontFamily: "DM Sans",
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 52),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 60,
                            margin: const EdgeInsets.only(left: 16, right: 16),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image:
                                    AssetImage('assets/blogs/background.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Material(
                                  color:
                                      Color.fromRGBO(48, 111, 220, placement),
                                  borderRadius: BorderRadius.circular(30),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    splashColor:
                                        Color.fromRGBO(48, 111, 220, 1),
                                    onTap: () {
                                      setState(() {
                                        placement = 1;
                                        internship = 0;
                                        external = 0;
                                        isLoading = true;
                                        _fetchBody();
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 24,
                                          top: 14,
                                          bottom: 13),
                                      child: Center(
                                        child: Text(
                                          'Placement',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'DM Sans',
                                            fontSize: 16,
                                            fontWeight: placement == 1
                                                ? FontWeight.w900
                                                : FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            height: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color:
                                      Color.fromRGBO(48, 111, 220, internship),
                                  borderRadius: BorderRadius.circular(30),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    splashColor:
                                        Color.fromRGBO(48, 111, 220, 1),
                                    onTap: () {
                                      setState(() {
                                        placement = 0;
                                        internship = 1;
                                        external = 0;
                                        isLoading = true;
                                        _fetchBody();
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 24,
                                          top: 14,
                                          bottom: 13),
                                      child: Center(
                                        child: Text(
                                          'Internship',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'DM Sans',
                                            fontSize: 16,
                                            fontWeight: internship == 1
                                                ? FontWeight.w900
                                                : FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            height: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Color.fromRGBO(48, 111, 220, external),
                                  borderRadius: BorderRadius.circular(30),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    splashColor:
                                        Color.fromRGBO(48, 111, 220, 1),
                                    onTap: () {
                                      setState(() {
                                        placement = 0;
                                        internship = 0;
                                        external = 1;
                                        isLoading = true;
                                        _fetchBody();
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 24,
                                          top: 14,
                                          bottom: 13),
                                      child: Center(
                                        child: Text(
                                          'External',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'DM Sans',
                                            fontSize: 16,
                                            fontWeight: external == 1
                                                ? FontWeight.w900
                                                : FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            height: 1.0,
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
                            height: 53,
                            padding: const EdgeInsets.only(
                                left: 14, right: 14, top: 13, bottom: 13),
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('assets/blogs/searchbar.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                Image(
                                  image: AssetImage('assets/blogs/search.png'),
                                  height: 24,
                                  width: 24,
                                ),
                                const SizedBox(width: 20),
                                Container(
                                  width: 205,
                                  child: TextField(
                                    controller: _searchFieldController,
                                    focusNode: _focusNode,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      fontFamily: 'DM Sans',
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search blogs',
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        color: Color.fromRGBO(0, 0, 0, 0.4),
                                        fontFamily: 'DM Sans',
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (query) async {   
                                      if (postType != PostType.ChatBot &&
                                          query.length > 4) {
                                      blogBloc!.query = query;
                                        blogBloc.refresh();
                                      }
                                    },
                                    onSubmitted: (query) async {
                                      blogBloc!.query = query;
                                      await blogBloc.refresh();
                                    },
                                    autofocus: true,
                                    maxLines: 1,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                              margin:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 239, 239, 239),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border.all(
                                            color: Color.fromRGBO(
                                                210, 213, 218, 1),
                                            width: 1.0,
                                          ),
                                        ),
                                        padding: const EdgeInsets.only(
                                            left: 16.0,
                                            right: 16.0,
                                            top: 8.0,
                                            bottom: 8.0),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                                'assets/blogs/box.svg'),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Filters',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontFamily: "DM Sans",
                                                fontStyle: FontStyle.normal,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SvgPicture.asset(
                                                'assets/blogs/chevron-down.svg'),
                                          ],
                                        )),
                                    Container(
                                        child: Row(
                                      children: [
                                        Container(
                                          height: 36,
                                          width: 36,
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                48, 111, 220, 1),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          child: IconButton(
                                              icon: SvgPicture.asset(
                                                'assets/blogs/list.svg',
                                                fit: BoxFit.none,
                                              ),
                                              onPressed: () {
                                                print('Sort');
                                              }),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          height: 36,
                                          width: 36,
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                239, 239, 239, 1),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            border: Border.all(
                                              color: Color.fromRGBO(
                                                  210, 213, 218, 1),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: IconButton(
                                              icon: SvgPicture.asset(
                                                'assets/blogs/list2.svg',
                                                fit: BoxFit.none,
                                              ),
                                              onPressed: () {
                                                print('Grid');
                                              }),
                                        ),
                                      ],
                                    ))
                                  ])),
                          const SizedBox(height: 24),
                          isLoading
                              ? CircularProgressIndicator()
                              : Expanded(
                                  child: StreamBuilder<
                                          UnmodifiableListView<Post>>(
                                      stream: blogBloc!.blog,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<
                                                  UnmodifiableListView<Post>>
                                              snapshot) {                                      
                                        return ListView.builder(
                                          controller: _hideButtonController,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return _buildPost(blogBloc, index,
                                                snapshot.data, theme, context);
                                          },
                                          itemCount: (snapshot.data == null
                                                  ? 0
                                                  : ((snapshot.data!
                                                              .isNotEmpty &&
                                                          snapshot.data!.last
                                                                  .content ==
                                                              null)
                                                      ? snapshot.data!.length -
                                                          1
                                                      : snapshot
                                                          .data!.length)) +
                                              1,
                                        );
                                      }),
                                )
                        ],
                      ),
                    ),
                  );
                } else {
                  return ListView(
                    children: <Widget>[
                      TitleWithBackButton(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Blogs",
                              style: theme.textTheme.displaySmall,
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Text(
                            "You must be logged in to view Blogs",
                            style: theme.textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            )),
      ),
    );
  }

  Future<void> _handleRefresh() {
    var blogbloc = BlocProvider.of(context)!.bloc.getPostsBloc(postType);
    return blogbloc!.refresh(force: blogbloc.query.isEmpty);
  }

  Widget _buildPost(PostBloc bloc, int index, List<Post>? posts,
      ThemeData theme, BuildContext context) {
    bloc.inPostIndex.add(index);

    final Post? post =
        (posts != null && posts.length > index) ? posts[index] : null;
    if (post?.content == null) {
      return Container(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(""),
        ),
      ));
    }
    return _post(post, bloc, context);
  }

  Widget _post(dynamic post, PostBloc bloc, BuildContext context) {
    return Container(
      key: ValueKey(post.id),
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(48, 111, 220, 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    left: 18, right: 16, top: 16, bottom: 16),
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(246, 246, 246, 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
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
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(
                                top: 3, bottom: 3, right: 16),
                            child: Container(
                              child: RichText(
                                text: highlight(post.title, bloc.query, context),
                                strutStyle: StrutStyle.fromTextStyle(
                                  TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  height: 1.0,
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
                          width: 40,
                          height: 48,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(2),
                              onTap: () async {
                                if (await canLaunchUrl(Uri.parse(post.link))) {
                                  await launchUrl(
                                    Uri.parse(post.link),
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
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
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        child: Text(
                      post.published,
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
                        data: post.content,
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

class CommonHtml extends StatelessWidget {
  final String? data;
  final TextStyle defaultTextStyle;

  CommonHtml({this.data, required this.defaultTextStyle});

  @override
  Widget build(BuildContext context) {
    return data != null
        ? HtmlWidget(
            data ?? "",
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
                width: 12.0,
              ),
              label!
            ]
          : []),
    );
  }
}

class Blogthread extends StatefulWidget {
  const Blogthread({Key? key}) : super(key: key);

  @override
  _BlogthreadState createState() => _BlogthreadState();
}

class _BlogthreadState extends State<Blogthread> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 15, right: 16, bottom: 102),
        child: Stack(children: [
          Positioned(
            left: 24,
            top: 0,
            bottom: 4,
            child: Container(
              width: 1,
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
                      height: 48,
                      width: 48,
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
                            'Google',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          Text(
                            'Interaction Design',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
              Companywiseblog(),
            ],
          ),
        ]));
  }
}

class Companywiseblog extends StatefulWidget {
  const Companywiseblog({Key? key}) : super(key: key);
  @override
  _CompanywiseblogState createState() => _CompanywiseblogState();
}

class _CompanywiseblogState extends State<Companywiseblog> {
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
              color: const Color.fromRGBO(246, 246, 246, 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: IntrinsicHeight(
                    child: Row(children: [
                  Container(
                    width: 6,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(48, 111, 220, 1),
                    ),
                  ),
                  Expanded(
                      child: Container(
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
                                        'Thur, Nov 28, 22:53:02',
                                        style: TextStyle(
                                          color: const Color.fromRGBO(
                                              48, 111, 220, 1),
                                          fontSize: 16,
                                          fontFamily: 'DM Sans',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                            top: 4,
                                            bottom: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromRGBO(
                                                  104, 189, 0, 1),
                                              width: 1.33),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'New',
                                          style: TextStyle(
                                            color:
                                                Color.fromRGBO(104, 189, 0, 1),
                                            fontSize: 10,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromRGBO(
                                                  255, 171, 81, 1),
                                              width: 1.33),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Mention',
                                          style: TextStyle(
                                            color:
                                                Color.fromRGBO(255, 171, 81, 1),
                                            fontSize: 10,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      )
                                    ]),
                                SizedBox(height: 8),
                                Container(
                                  child: Text(
                                      'The following students are waitlisted for the role of Iteraction Designer',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400,
                                      )),
                                ),
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
                          )))
                ])))),
      if (expandedview)
        Container(
          margin: const EdgeInsets.only(
            left: 19,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(246, 246, 246, 1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: IntrinsicHeight(
                  child: Row(children: [
                Container(
                  width: 6,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(48, 111, 220, 1),
                  ),
                ),
                Expanded(
                  child: Container(
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
                            'Thur, Nov 28, 22:53:02',
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
                            width: 340,
                            child: Text.rich(
                              TextSpan(
                                text:
                                    'The following students are waitlisted for the role of ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Iteraction Designer',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Table(columnWidths: const {
                                0: IntrinsicColumnWidth(),
                                1: IntrinsicColumnWidth(),
                                2: FlexColumnWidth(),
                              }, children: [
                                TableRow(children: [
                                  Text('Roll no:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w700,
                                      )),
                                  SizedBox(width: 24),
                                  Text('Name',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w700,
                                      )),
                                ]),
                                TableRow(children: [
                                  SizedBox(height: 8),
                                  SizedBox(height: 8),
                                  SizedBox(height: 8)
                                ]),
                                TableRow(children: [
                                  Text('24B2399',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400,
                                      )),
                                  SizedBox(width: 24),
                                  Text('Lorem Ipsum Dolor',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400,
                                      )),
                                ]),
                                TableRow(children: [
                                  Text('25B3256',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400,
                                      )),
                                  SizedBox(width: 24),
                                  Text('Dolor Ipsum ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400,
                                      )),
                                ]),
                                TableRow(children: [
                                  Text('24B2345',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400,
                                      )),
                                  SizedBox(width: 24),
                                  Text('Ipsum Dolor Lorem ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400,
                                      )),
                                ]),
                                TableRow(children: [
                                  Text('23B8973',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400,
                                      )),
                                  SizedBox(width: 24),
                                  Text('Dolor Lorem Ipsum ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400,
                                      )),
                                ]),
                              ])),
                        ],
                      )),
                )
              ]))),
        )
    ]));
  }
}
