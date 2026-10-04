import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/api/response/calendar_preference_response.dart';
import 'package:InstiApp/src/api/model/calendar_body_preference.dart';
import 'package:InstiApp/src/api/model/calendar_body.dart';

Future<void> showCalendarFiltersBottomSheet(BuildContext context) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return FractionallySizedBox(
              heightFactor: 0.6632,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: FilterBottomSheet(),
              ));
        });
      });
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  bool _loading = true;
  late CalendarPreferencesResponse _preferences;
  List<CalendarBodyPreference> _bodies = [];
  List<CalendarBody> _sharedCalendars = [];
  bool _bodiesExpanded = false;
  bool _sharedExpanded = false;
  String _selectedTab = 'Preferences';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bloc = BlocProvider.of(context)!.bloc;
      final prefs =
          await bloc.getOrFetchCalendarPreferences(forceRefresh: true);
      final bodies =
          await bloc.getOrFetchCalendarPrefBodies(forceRefresh: true);
      final shared = await bloc.getOrFetchCalendarShared(forceRefresh: true);
      if (mounted) {
        setState(() {
          _preferences = prefs;
          _bodies = bodies;
          _sharedCalendars = shared;
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of(context)!.bloc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title
        Padding(
          padding: EdgeInsets.fromLTRB(
              Responsive.width(20, context),
              Responsive.height(20, context),
              Responsive.width(20, context),
              Responsive.height(12, context)),
          child: Text(
            'Show only...',
            style: TextStyle(
              fontSize: Responsive.width(18, context),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),

        // Body: sidebar + content
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left sidebar tab
              SizedBox(
                width: Responsive.width(125, context),
                child: Column(
                  children: [
                    _SidebarTab(label: 'Preferences', isSelected: true),
                  ],
                ),
              ),

              // Right content area
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(12, context),
                    vertical: Responsive.height(8, context),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.only(
                      bottomLeft:
                          Radius.circular(Responsive.width(16, context)),
                    ),
                  ),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _preferences.showAllEvents ?? true,
                                    onChanged: (val) {
                                      setState(() {
                                        _preferences.showAllEvents =
                                            val ?? false;
                                      });
                                      bloc.updateCalendarPreferences(
                                          _preferences);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Responsive.width(4, context)),
                                    ),
                                    side: const BorderSide(color: Colors.grey),
                                    activeColor: const Color(0xFF1A56DB),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  SizedBox(width: Responsive.width(6, context)),
                                  Text(
                                    'All Events',
                                    style: TextStyle(
                                      fontSize: Responsive.width(15, context),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Responsive.height(16, context)),
                              Row(
                                children: [
                                  Checkbox(
                                    value:
                                        _preferences.showInstiappGoing ?? true,
                                    onChanged: (val) {
                                      setState(() {
                                        _preferences.showInstiappGoing =
                                            val ?? false;
                                      });
                                      bloc.updateCalendarPreferences(
                                          _preferences);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Responsive.width(4, context)),
                                    ),
                                    side: const BorderSide(color: Colors.grey),
                                    activeColor: const Color(0xFF1A56DB),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  SizedBox(width: Responsive.width(6, context)),
                                  Text(
                                    'InstiApp Going',
                                    style: TextStyle(
                                      fontSize: Responsive.width(15, context),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Responsive.height(16, context)),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _preferences
                                            .showInstiappFollowedBodies ??
                                        true,
                                    onChanged: (val) {
                                      setState(() {
                                        _preferences
                                                .showInstiappFollowedBodies =
                                            val ?? false;
                                      });
                                      bloc.updateCalendarPreferences(
                                          _preferences);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Responsive.width(4, context)),
                                    ),
                                    side: const BorderSide(color: Colors.grey),
                                    activeColor: const Color(0xFF1A56DB),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  SizedBox(width: Responsive.width(6, context)),
                                  Expanded(
                                    child: Text(
                                      'Followed Bodies',
                                      style: TextStyle(
                                        fontSize: Responsive.width(15, context),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _bodiesExpanded = !_bodiesExpanded;
                                      });
                                    },
                                    child: Icon(
                                      _bodiesExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.black54,
                                      size: Responsive.width(22, context),
                                    ),
                                  ),
                                ],
                              ),
                              if (_bodiesExpanded &&
                                  (_preferences.showInstiappFollowedBodies ??
                                      true)) ...[
                                const SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _bodies.length,
                                  itemBuilder: (context, idx) {
                                    final body = _bodies[idx];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, bottom: 0),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: body.enabled ?? false,
                                            onChanged: (val) {
                                              setState(() {
                                                body.enabled = val ?? false;
                                              });
                                              if (body.bodyId != null) {
                                                bloc.updateSingleCalendarPrefBody(
                                                    body.bodyId!, body);
                                              }
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Responsive.width(
                                                          4, context)),
                                            ),
                                            side: const BorderSide(
                                                color: Colors.grey),
                                            activeColor:
                                                const Color(0xFF1A56DB),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                          SizedBox(
                                              width: Responsive.width(
                                                  6, context)),
                                          Expanded(
                                            child: Text(
                                              body.bodyName ?? '',
                                              style: TextStyle(
                                                fontSize: Responsive.width(
                                                    13, context),
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                              SizedBox(height: Responsive.height(16, context)),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _preferences.showResobin ?? true,
                                    onChanged: (val) {
                                      setState(() {
                                        _preferences.showResobin = val ?? false;
                                      });
                                      bloc.updateCalendarPreferences(
                                          _preferences);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Responsive.width(4, context)),
                                    ),
                                    side: const BorderSide(color: Colors.grey),
                                    activeColor: const Color(0xFF1A56DB),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  SizedBox(width: Responsive.width(6, context)),
                                  Text(
                                    'Resobin',
                                    style: TextStyle(
                                      fontSize: Responsive.width(15, context),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Responsive.height(16, context)),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Shared Calendars',
                                      style: TextStyle(
                                        fontSize: Responsive.width(15, context),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _sharedExpanded = !_sharedExpanded;
                                      });
                                    },
                                    child: Icon(
                                      _sharedExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.black54,
                                      size: Responsive.width(22, context),
                                    ),
                                  ),
                                ],
                              ),
                              if (_sharedExpanded) ...[
                                const SizedBox(height: 8),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: Responsive.height(200, context),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _sharedCalendars.length,
                                    itemBuilder: (context, idx) {
                                      final cal = _sharedCalendars[idx];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, bottom: 4),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: cal.isActive ?? false,
                                              onChanged: (val) {
                                                setState(() {
                                                  cal.isActive = val ?? false;
                                                });
                                                if (cal.slug != null) {
                                                  bloc.toggleSharedCalendar(
                                                      cal.slug!, val ?? false);
                                                }
                                              },
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Responsive.width(
                                                            4, context)),
                                              ),
                                              side: const BorderSide(
                                                  color: Colors.grey),
                                              activeColor:
                                                  const Color(0xFF1A56DB),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            SizedBox(
                                                width: Responsive.width(
                                                    6, context)),
                                            Expanded(
                                              child: Text(
                                                cal.name ?? '',
                                                style: TextStyle(
                                                  fontSize: Responsive.width(
                                                      13, context),
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
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
                    if (!_loading) {
                      setState(() {
                        _preferences.showAllEvents = false;
                        _preferences.showInstiappGoing = false;
                        _preferences.showInstiappFollowedBodies = false;
                        _preferences.showResobin = false;
                        bloc.updateCalendarPreferences(_preferences);
                        for (var cal in _sharedCalendars) {
                          if (cal.isActive == true) {
                            cal.isActive = false;
                            if (cal.slug != null) {
                              bloc.toggleSharedCalendar(cal.slug!, false);
                            }
                          }
                        }
                      });
                    }
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
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: Responsive.width(12, context)),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
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
      ],
    );
  }
}

class _SidebarTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SidebarTab({
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Responsive.width(125, context),
        height: Responsive.height(52, context),
        color: const Color(0xFFEFEFEF),
        child: Stack(
          children: [
            if (isSelected)
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
            if (isSelected)
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
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableCategory extends StatelessWidget {
  final String label;
  final bool isChecked;
  final bool isExpanded;
  final ValueChanged<bool?> onCheckChanged;
  final VoidCallback onToggleExpand;

  const _ExpandableCategory({
    required this.label,
    required this.isChecked,
    required this.isExpanded,
    required this.onCheckChanged,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: onCheckChanged,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: const BorderSide(color: Colors.grey),
          activeColor: const Color(0xFF1A56DB),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: Responsive.width(15, context),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        GestureDetector(
          onTap: onToggleExpand,
          child: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: Responsive.width(20, context),
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _SubCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _SubCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: Colors.grey),
            activeColor: const Color(0xFF1A56DB),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.width(13, context),
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
