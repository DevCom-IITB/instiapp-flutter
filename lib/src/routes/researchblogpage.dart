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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Widget buildChip({
              required String label,
              required bool selected,
              required VoidCallback onTap,
            }) {
              return ChoiceChip(
                label: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF0F1620),
                  ),
                ),
                selected: selected,
                onSelected: (_) => onTap(),
                selectedColor: const Color(0xFF306FDC),
                backgroundColor: const Color.fromARGB(255, 239, 239, 239),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF306FDC)
                        : const Color.fromRGBO(210, 213, 218, 1),
                  ),
                ),
              );
            }

            bool isSelectedDomain(String domain) {
              return tempDomains.contains(_normalizeValue(domain));
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: Responsive.width(20.0, context),
                right: Responsive.width(20.0, context),
                top: Responsive.height(18.0, context),
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
                    Responsive.height(18.0, context),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: Responsive.text(22.0, context),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F1620),
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close),
                            color: const Color(0xFF0F1620),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.height(8.0, context)),
                      Text(
                        'Domains',
                        style: TextStyle(
                          fontSize: Responsive.text(16.0, context),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F1620),
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      SizedBox(height: Responsive.height(12.0, context)),
                      Wrap(
                        spacing: Responsive.width(8.0, context),
                        runSpacing: Responsive.height(8.0, context),
                        children: [
                          buildChip(
                            label: 'All',
                            selected: tempDomains.isEmpty,
                            onTap: () => setSheetState(() => tempDomains.clear()),
                          ),
                          ...domains.map(
                            (domain) => buildChip(
                              label: domain,
                              selected: isSelectedDomain(domain),
                              onTap: () => setSheetState(() {
                                final key = _normalizeValue(domain);
                                if (!tempDomains.add(key)) {
                                  tempDomains.remove(key);
                                }
                              }),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.height(20.0, context)),
                      Text(
                        'CPI Criteria',
                        style: TextStyle(
                          fontSize: Responsive.text(16.0, context),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F1620),
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      SizedBox(height: Responsive.height(12.0, context)),
                      Wrap(
                        spacing: Responsive.width(8.0, context),
                        runSpacing: Responsive.height(8.0, context),
                        children: [
                          ...[0.0, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0].map(
                            (cpi) => buildChip(
                              label: _formatCpiLabel(cpi),
                              selected: tempMaxCpi == cpi,
                              onTap: () => setSheetState(() => tempMaxCpi = cpi),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.height(24.0, context)),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheetState(() {
                                  tempDomains.clear();
                                  tempMaxCpi = 0;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF306FDC)),
                                foregroundColor: const Color(0xFF306FDC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: Responsive.height(14.0, context),
                                ),
                              ),
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: Responsive.text(16.0, context),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: Responsive.width(12.0, context)),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDomains = <String>{...tempDomains};
                                  _selectedMaxCpi = tempMaxCpi;
                                });
                                Navigator.of(sheetContext).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF306FDC),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: Responsive.height(14.0, context),
                                ),
                              ),
                              child: Text(
                                'Apply',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: Responsive.text(16.0, context),
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
        );
      },
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
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.width(16.0, context),
                          ),
                          child: Row(
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
                                      if (_hasActiveFilters()) ...[
                                        SizedBox(
                                            width: Responsive.width(
                                                8.0, context)),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Responsive.width(6.0, context),
                                            vertical:
                                                Responsive.height(2.0, context),
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF306FDC),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${_activeFilterCount()}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  Responsive.text(12.0, context),
                                              fontFamily: 'DM Sans',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (_hasActiveFilters())
                                TextButton(
                                  onPressed: _clearFilters,
                                  child: Text(
                                    'Clear all',
                                    style: TextStyle(
                                      color: const Color(0xFF306FDC),
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: Responsive.text(14.0, context),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_hasActiveFilters())
                          Padding(
                            padding: EdgeInsets.only(
                              left: Responsive.width(16.0, context),
                              right: Responsive.width(16.0, context),
                              top: Responsive.height(6.0, context),
                            ),
                            child: Wrap(
                              spacing: Responsive.width(8.0, context),
                              runSpacing: Responsive.height(8.0, context),
                              children: [
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
        color: const Color.fromRGBO(235, 241, 255, 1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF306FDC).withOpacity(0.18)),
      ),
      padding: EdgeInsets.only(
        left: Responsive.width(12.0, context),
        right: Responsive.width(8.0, context),
        top: Responsive.height(6.0, context),
        bottom: Responsive.height(6.0, context),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF306FDC),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w600,
              fontSize: Responsive.text(13.0, context),
            ),
          ),
          SizedBox(width: Responsive.width(4.0, context)),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(999),
            child: const Icon(
              Icons.close,
              size: 16,
              color: Color(0xFF306FDC),
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
