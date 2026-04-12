import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:InstiApp/src/utils/research_blog_card.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';

class ResearchBlogPage extends StatefulWidget {
  @override
  _ResearchBlogPageState createState() => _ResearchBlogPageState();
}

class _ResearchBlogPageState extends State<ResearchBlogPage> {
  TextEditingController? _searchFieldController;
  FocusNode _focusNode = FocusNode();
  ScrollController? _scrollController;
  String? currquery = "";
  double isFabVisible = 0;

  // TODO: Replace with actual data from your bloc/API
  final List<Map<String, String>> _allResearch = [
    {
      'title': 'Game Theoretic Solutions for National Security Planning',
      'professor': 'Prof. Suneet Singh',
      'tag': 'AI/ML',
      'description':
          'Working on cutting edge Optimisation Techniques to enhance performance of energy systems...',
      'imageUrl': 'https://picsum.photos/113/189',
    },
    {
      'title':
          'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut .',
      'professor': 'Prof. Alpha Delta Omega',
      'tag': 'Systems',
      'description':
          'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...',
      'imageUrl': 'https://picsum.photos/113/189',
    },
    {
      'title':
          'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut .',
      'professor': 'Prof. Theta Epsilon Pi',
      'tag': 'Robotics',
      'description':
          'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna...',
      'imageUrl': 'https://picsum.photos/113/189',
    },
  ];

  List<Map<String, String>> get _filteredResearch {
    if (currquery == null || currquery!.isEmpty) return _allResearch;
    final q = currquery!.toLowerCase();
    return _allResearch.where((item) {
      return (item['title'] ?? '').toLowerCase().contains(q) ||
          (item['professor'] ?? '').toLowerCase().contains(q) ||
          (item['tag'] ?? '').toLowerCase().contains(q) ||
          (item['description'] ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchFieldController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchFieldController?.dispose();
    _focusNode.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted || _scrollController == null || !_scrollController!.hasClients)
      return;
    final visible =
        _scrollController!.position.userScrollDirection ==
            ScrollDirection.forward &&
        _scrollController!.offset > 100;
    setState(() => isFabVisible = visible ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(246, 246, 246, 1),
    ));

    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        floatingActionButton: AnimatedOpacity(
          opacity: isFabVisible,
          duration: Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: isFabVisible == 0,
            child: FloatingActionButton(
              backgroundColor: Color.fromRGBO(48, 111, 220, 1),
              onPressed: () {
                _scrollController?.animateTo(
                  0.0,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              },
              child: Icon(Icons.arrow_upward),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              Container(
                height: Responsive.height(52.0, context),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: Responsive.width(16.0, context)),
                      child: Container(
                        height: Responsive.height(52.0, context),
                        width: Responsive.width(52.0, context),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(235, 235, 235, 0.8),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: IconButton(
                          icon: SvgPicture.asset(
                            'assets/blogs/arrow-left.svg',
                            height: Responsive.height(24.0, context),
                            width: Responsive.width(24.0, context),
                            fit: BoxFit.none,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Research',
                          style: TextStyle(
                            fontSize: Responsive.text(24.0, context),
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontFamily: 'DM Sans',
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

              // ── Search Bar ──────────────────────────────────────────
              Container(
                margin: EdgeInsets.only(
                  left: Responsive.width(16.0, context),
                  right: Responsive.width(16.0, context),
                ),
                height: Responsive.height(53.0, context),
                padding: EdgeInsets.only(
                  left: Responsive.width(14.0, context),
                  right: Responsive.width(14.0, context),
                  top: Responsive.height(13.0, context),
                  bottom: Responsive.height(13.0, context),
                ),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/blogs/searchbar.png'),
                    fit: BoxFit.fill,
                  ),
                  borderRadius:
                      BorderRadius.circular(Responsive.height(2.0, context)),
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
                          hintText: 'Search research',
                          hintStyle: TextStyle(
                            fontSize: Responsive.text(16.0, context),
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            fontFamily: 'DM Sans',
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (query) {
                          setState(() => currquery = query);
                        },
                        onSubmitted: (query) {
                          setState(() => currquery = query);
                        },
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
                          setState(() => currquery = '');
                        },
                        child: Padding(
                          padding:
                              EdgeInsets.all(Responsive.width(3, context)),
                          child: SvgPicture.asset(
                            'assets/explore/x.svg',
                            width: Responsive.width(24.0, context),
                            height: Responsive.height(24.0, context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: Responsive.height(16.0, context)),

              // ── Cards List ──────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    bottom: Responsive.height(16.0, context),
                  ),
                  itemCount: _filteredResearch.length,
                 itemBuilder: (context, index) {
                  final item = _filteredResearch[index];
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(Responsive.width(16.0, context)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                'Open ReaCH?',
                                style: TextStyle(
                                  color: const Color(0xFF0F1620),
                                  fontSize: 18,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: Responsive.height(8.0, context)),
                              // Divider
                              Divider(color: const Color(0xFFD2D5DA), thickness: 1),
                              SizedBox(height: Responsive.height(8.0, context)),
                              // Body text
                              Text(
                                'You will be redirected to ReaCH to complete your application for this research project. Click open to proceed.',
                                style: TextStyle(
                                  color: const Color(0xCC0F1620),
                                  fontSize: 16,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: Responsive.height(16.0, context)),
                              // ReaCH image
                              Center(
                                child: Image.asset(
                                  'assets/blogs/reach_logo.png',
                                  width: Responsive.width(280.0, context),
                                  height: Responsive.height(86.27364, context),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(height: Responsive.height(16.0, context)),
                              // Buttons
                              Row(
                                children: [
                                  // Cancel
                                  Expanded(
                                    child: SizedBox(
                                      height: Responsive.height(52.0, context),
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            width: 2,
                                            color: Color(0xFF306FDC),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: const Color(0xFF306FDC),
                                            fontSize: 16,
                                            fontFamily: 'DM Sans',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: Responsive.width(8.0, context)),
                                  // Open
                                  Expanded(
                                    child: SizedBox(
                                      height: Responsive.height(52.0, context),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          // TODO: launchUrl(Uri.parse('https://reach.iitb.ac.in/...'));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF306FDC),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: Text(
                                          'Open',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'DM Sans',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      );
                    },
                    child: ResearchCard(
                      title: item['title'] ?? '',
                      professor: item['professor'] ?? '',
                      tag: item['tag'] ?? '',
                      description: item['description'] ?? '',
                      imageUrl: item['imageUrl'] ?? '',
                    ),
                  );
                },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}