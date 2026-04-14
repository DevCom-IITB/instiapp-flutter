import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:InstiApp/src/utils/research_blog_card.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';
import 'package:InstiApp/src/api/model/research_project.dart';
import 'package:InstiApp/src/api/research_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/dotted_divider.dart';

const String base = "assets/reach_images/";

final Map<String, String> domainImages = {
  'AI/ML': 'Cminds.png',
  'BSBE': 'bsbe.jpeg',
  'CHEMISTRY': 'chemistry.jpg',
  'CHEMICAL': 'chemical.jpeg',
  'CLIMATE STUDIES': 'climate_studies.png',
  'COMPUTER SCIENCE': 'computer_science.jpeg',
  'CTARA': 'ctara.jpg',
  'ELECTRICAL': 'electrical.jpg',
  'ENERGY': 'energy.png',
  'ENVIRONMENTAL STUDIES': 'environmental_studies.png',
  'EARTH SCIENCES': 'earth_sciences.jpeg',
  'MATHEMATICS': 'mathematics.png',
  'MECHANICAL': 'mechanical_engineering.jpg',
  'CIVIL': 'civil.jpeg',
  'MEMS': 'mems.png',
  'SYSCON': 'syscon.png',
  'PHYSICS': 'physics.png',
  'MANAGEMENT (SOM)': 'som.jpg',
  'MULTIDISCIPLINARY': 'idp.jpg',
};

String getDomainImage(String domain) {
  final key = domain.trim().toUpperCase();
  return base + (domainImages[key] ?? 'computer_science.jpeg');
}

class ResearchBlogPage extends StatefulWidget {
  @override
  _ResearchBlogPageState createState() => _ResearchBlogPageState();
}

class _ResearchBlogPageState extends State<ResearchBlogPage> {
  TextEditingController? _searchFieldController;
  FocusNode _focusNode = FocusNode();
  ScrollController? _scrollController;
  String? currquery = "";
  Set<String> _selectedDomains = <String>{};
  double _selectedMaxCpi = 0;
  double isFabVisible = 0;
  late Future<List<ResearchProject>> _projectsFuture;

  List<ResearchProject> _filterProjects(List<ResearchProject> projects) {
    final q = currquery?.trim().toLowerCase() ?? '';
    return projects.where((p) {
      final matchesQuery = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.professorName.toLowerCase().contains(q) ||
          p.domain.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
        final matchesDomain = _selectedDomains.isEmpty ||
          _selectedDomains.contains(_normalizeValue(p.domain));
        final matchesCpi = _selectedMaxCpi == 0 || p.cpi < _selectedMaxCpi;
        return matchesQuery && matchesDomain && matchesCpi;
    }).toList();
  }

  List<String> _distinctValues(Iterable<String> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      final key = trimmed.toLowerCase();
      if (seen.add(key)) {
        result.add(trimmed);
      }
    }
    result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }

  String _normalizeValue(String value) => value.trim().toLowerCase();

  String _formatCpiLabel(double value) {
    if (value == 0) return 'Any';
    return '< ${value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1)}';
  }

  int _activeFilterCount() {
    var count = 0;
    count += _selectedDomains.length;
    if (_selectedMaxCpi > 0) count++;
    return count;
  }

  bool _hasActiveFilters() => _activeFilterCount() > 0;

  void _clearFilters() {
    setState(() {
      _selectedDomains.clear();
      _selectedMaxCpi = 0;
    });
  }

void _openFiltersSheet(List<ResearchProject> projects) {
  final domains = _distinctValues(projects.map((p) => p.domain));
  double tempMaxCpi = _selectedMaxCpi;
  final tempDomains = <String>{..._selectedDomains};
  String _activeTab = 'filter'; // 'sort' or 'filter'

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          // Group domains alphabetically
          final Map<String, List<String>> grouped = {};
          for (final domain in domains) {
            final letter = domain.trim().isNotEmpty
                ? domain.trim()[0].toUpperCase()
                : '#';
            grouped.putIfAbsent(letter, () => []).add(domain);
          }
          final sortedLetters = grouped.keys.toList()..sort();

          return FractionallySizedBox(
            heightFactor: 0.75,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF6F6F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title Row ──
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
                          '${_filterProjects(projects).length} results',
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

                  // ── Two-Panel Body ──
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Left Sidebar ──
                        SizedBox(
                          width: Responsive.width(125, context),
                          child: Column(
                            children: [
                              _buildSidebarTab(
                                label: 'CPI',
                                isActive: _activeTab == 'sort',
                                onTap: () => setSheetState(() => _activeTab = 'sort'),
                                context: context,
                              ),
                              _buildSidebarTab(
                                label: 'Domain',
                                isActive: _activeTab == 'filter',
                                onTap: () => setSheetState(() => _activeTab = 'filter'),
                                context: context,
                              ),
                            ],
                          ),
                        ),

                        // ── Right Content Panel ──
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(                              
                              borderRadius: BorderRadius.only(
                                bottomLeft: _activeTab == 'sort'? Radius.circular(0) :Radius.circular(16),
                              ),
                              color: const Color(0xFFEFEFEF),
                            ),                            
                            child: _activeTab == 'sort'
                                // CPI Panel
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.width(12, context),
                                      vertical: Responsive.height(12, context),
                                    ),
                                    child: Wrap(
                                      spacing: Responsive.width(8, context),
                                      runSpacing: Responsive.height(8, context),
                                      children: [0.0, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0].map((cpi) {
                                        final isSelected = tempMaxCpi == cpi;
                                        return GestureDetector(
                                          onTap: () => setSheetState(() => tempMaxCpi = cpi),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: Responsive.width(14, context),
                                              vertical: Responsive.height(7, context),
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF306FDC)
                                                  : const Color(0xFFEFEFEF),
                                              borderRadius: BorderRadius.circular(50),
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFF306FDC)
                                                    : const Color(0xFFD2D5DA),
                                              ),
                                            ),
                                            child: Text(
                                              _formatCpiLabel(cpi),
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : const Color(0xFF0F1620),
                                                fontSize: Responsive.text(13, context),
                                                fontFamily: 'DM Sans',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )
                                // Domain Panel - alphabetically grouped
                                : ListView.builder(
                                    padding: EdgeInsets.only(
                                      top: Responsive.height(16, context),
                                      left: Responsive.width(20, context),
                                      right: Responsive.width(12, context),
                                      bottom: Responsive.height(16, context),
                                    ),
                                    itemCount: sortedLetters.length,
                                    itemBuilder: (context, index) {
                                      final letter = sortedLetters[index];
                                      final domainGroup = grouped[letter]!;
                                      return ClipRect(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              letter,
                                              style: TextStyle(
                                                color: const Color(0xFF7E8287),
                                                fontSize: Responsive.text(12, context),
                                                fontFamily: 'DM Sans',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: Responsive.height(6, context)),
                                            ...domainGroup.map((domain) {
                                              final key = _normalizeValue(domain);
                                              final isSelected = tempDomains.contains(key);
                                              return GestureDetector(
                                                onTap: () => setSheetState(() {
                                                  if (!tempDomains.add(key)) {
                                                    tempDomains.remove(key);
                                                  }
                                                }),
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: Responsive.height(12, context)),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: Responsive.width(24, context),
                                                        height: Responsive.height(24, context),
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
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
                                                      SizedBox(width: Responsive.width(12, context)),
                                                      Expanded(
                                                        child: Text(
                                                          domain,
                                                          style: TextStyle(
                                                            color: const Color(0xFF0F1620),
                                                            fontSize: Responsive.text(14, context),
                                                            fontFamily: 'DM Sans',
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                            SizedBox(height: Responsive.height(4, context)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Bottom Buttons ──
                  Container(
                    color: const Color.fromARGB(255, 246, 246, 246),
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.width(16, context),
                      vertical: Responsive.height(16, context),
                    ),
                    child: Row(
                      children: [
                        // Reset button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                tempDomains.clear();
                                tempMaxCpi = 0;
                              });
                            },
                            child: Container(
                              height: Responsive.height(60, context),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: const Color(0xFF0F1620)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  color: const Color(0xFF0F1620),
                                  fontSize: Responsive.text(18, context),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.width(12, context)),
                        // Apply button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDomains = <String>{...tempDomains};
                                _selectedMaxCpi = tempMaxCpi;
                              });
                              Navigator.of(sheetContext).pop();
                            },
                            child: Container(
                              height: Responsive.height(60, context),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1620),
                                borderRadius: BorderRadius.circular(50),
                                image: const DecorationImage(
                                  image: AssetImage('assets/blogs/reachapply.png'),
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

                  SizedBox(height: MediaQuery.of(sheetContext).viewInsets.bottom),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Helper widget for sidebar tabs
Widget _buildSidebarTab({
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
                decoration: BoxDecoration(
                  color: const Color(0xFF306FDC),
                  borderRadius: const BorderRadius.horizontal(
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


  @override
  void initState() {
    super.initState();
    _searchFieldController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _projectsFuture = ResearchService.fetchProjects();
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
    final visible = _scrollController!.position.userScrollDirection ==
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
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/feed', //navigate to homepage
                              (route) => false,
                            );
                          },
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
                          padding: EdgeInsets.all(Responsive.width(3, context)),
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
                child: FutureBuilder<List<ResearchProject>>(
                  future: _projectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF306FDC),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load projects'));
                    }

                    final projects = snapshot.data ?? [];
                    final filteredProjects = _filterProjects(projects);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.width(16.0, context),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(
                                      Responsive.height(50.0, context)),
                                  onTap: () => _openFiltersSheet(projects),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 239, 239, 239),
                                      borderRadius: BorderRadius.circular(
                                          Responsive.height(50.0, context)),
                                      border: Border.all(
                                        color: const Color.fromRGBO(
                                            210, 213, 218, 1),
                                        width: Responsive.height(1.0, context),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.width(16.0, context),
                                      vertical: Responsive.height(8.0, context),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.tune,
                                          size: 18,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                            width:
                                                Responsive.width(8.0, context)),
                                        Text(
                                          'Filters',
                                          style: TextStyle(
                                            fontSize:
                                                Responsive.text(14.0, context),
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                            fontFamily: 'DM Sans',
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),   
                                 SizedBox(width: Responsive.width(12.0, context)),                                    
                                if (_selectedDomains.isNotEmpty)
                                  ..._selectedDomains.map(
                                    (domain) => _buildActiveFilterChip(
                                      'Domain: ${_displayDomainLabel(domain)}',
                                      () => setState(() {
                                        _selectedDomains.remove(domain);
                                      }),
                                    ),
                                  ),
                                if (_selectedMaxCpi > 0)
                                  _buildActiveFilterChip(
                                    'CPI: ${_formatCpiLabel(_selectedMaxCpi)}',
                                    () => setState(() => _selectedMaxCpi = 0),
                                  ),                         
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(height: Responsive.height(8.0, context)),
                        Expanded(
                          child: filteredProjects.isEmpty
                              ? Center(
                                  child: Text(
                                    'No projects found',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: Responsive.text(16.0, context),
                                      color: const Color.fromRGBO(
                                          15, 22, 32, 0.8),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.only(
                                    bottom: Responsive.height(16.0, context),
                                  ),
                                  itemCount: filteredProjects.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredProjects[index];
                                    return GestureDetector(
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                Responsive.height(20, context)),
                                          ),
                                          backgroundColor: Colors.white,
                                          insetPadding: EdgeInsets.zero,
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            width: Responsive.width(380, context),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Open ReaCH?',
                                                  style: TextStyle(
                                                    fontSize: Responsive.text(
                                                        20.0, context),
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color.fromRGBO(
                                                        15, 22, 32, 1),
                                                    fontFamily: 'DM Sans',
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                const DottedDivider(
                                                    padding: EdgeInsets.zero),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'You will be redirected to ReaCH to complete your application for this research project. Click open to proceed.',
                                                  style: TextStyle(
                                                    fontSize: Responsive.text(
                                                        16.0, context),
                                                    color: const Color.fromRGBO(
                                                        15, 22, 32, 0.8),
                                                    height: 1.4,
                                                    fontFamily: 'DM Sans',
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Center(
                                                  child: Image.asset(
                                                    'assets/blogs/reach_logo.png',
                                                    width: Responsive.width(
                                                        280, context),
                                                    height: Responsive.height(
                                                        86, context),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      onTap: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  25),
                                                          border: Border.all(
                                                              color: const Color(
                                                                  0xFF306FDC)),
                                                        ),
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                          horizontal:
                                                              Responsive.width(
                                                                  25, context),
                                                          vertical:
                                                              Responsive.height(
                                                                  15, context),
                                                        ),
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            color: const Color(
                                                                0xFF306FDC),
                                                            fontSize:
                                                                Responsive.text(
                                                                    16.0,
                                                                    context),
                                                            fontFamily:
                                                                'DM Sans',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: Responsive.height(
                                                            8, context)),
                                                    InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      onTap: () async {
                                                        Navigator.of(context)
                                                            .pop();
                                                        const String baseUrl =
                                                            'https://reach.gymkhana.iitb.ac.in/projects';
                                                        final String websiteUrl =
                                                            "$baseUrl?id=${item.id}";
                                                        final Uri uri = Uri.parse(
                                                            websiteUrl);

                                                        try {
                                                          if (await canLaunchUrl(
                                                              uri)) {
                                                            await launchUrl(
                                                              uri,
                                                              mode: LaunchMode
                                                                  .externalApplication,
                                                            );
                                                          } else {
                                                            ScaffoldMessenger.of(
                                                                    context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'Could not open ReaCH'),
                                                              ),
                                                            );
                                                          }
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Error opening ReaCH'),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                          horizontal:
                                                              Responsive.width(
                                                                  25, context),
                                                          vertical:
                                                              Responsive.height(
                                                                  15, context),
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                              0xFF306FDC),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  25),
                                                          border: Border.all(
                                                              color: const Color(
                                                                  0xFF306FDC)),
                                                        ),
                                                        child: Text(
                                                          'Open',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                Responsive.text(
                                                                    16.0,
                                                                    context),
                                                            fontFamily:
                                                                'DM Sans',
                                                            fontWeight:
                                                                FontWeight.w700,
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
                                      ),
                                      child: ResearchCard(
                                        title: item.title,
                                        professor: item.professorName,
                                        tag: item.domain,
                                        description: item.description,
                                        imageUrl:
                                            item.image ?? getDomainImage(item.domain),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
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

  Widget _buildActiveFilterChip(String label, VoidCallback onClear) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF306FDC),
        borderRadius: BorderRadius.circular(20),      
      ),
      margin: EdgeInsets.only(right: Responsive.width(8.0, context)),
      padding: EdgeInsets.only(
        left: Responsive.width(16.0, context),
        right: Responsive.width(16.0, context),
        top: Responsive.height(8.0, context),
        bottom: Responsive.height(8.0, context),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w600,
              fontSize: Responsive.text(14.0, context),
            ),
          ),
          SizedBox(width: Responsive.width(4.0, context)),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(999),
            child: const Icon(
              Icons.close,
              size: 18,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ],
      ),
    );
  }

  String _displayDomainLabel(String normalizedDomain) {
    return normalizedDomain
        .split(RegExp(r'\s+'))
        .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
