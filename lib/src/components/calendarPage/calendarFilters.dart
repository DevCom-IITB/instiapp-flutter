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
                  decoration: BoxDecoration(
                color: Colors.white,
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
      final prefs = await bloc.getOrFetchCalendarPreferences();
      final bodies = await bloc.getOrFetchCalendarPrefBodies();
      final shared = await bloc.getOrFetchCalendarShared();
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
          padding:  EdgeInsets.fromLTRB(Responsive.width(20, context), Responsive.height(20, context), Responsive.width(20, context), Responsive.height(12, context)),
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
              Container(
                width: Responsive.width(125, context),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: Responsive.width(4, context),
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
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
                  decoration:  BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(Responsive.width(16, context)),
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
                                    value: _preferences.showInstiappFollowedBodies ?? true,
                                    onChanged: (val) {
                                      setState(() {
                                        _preferences.showInstiappFollowedBodies = val ?? false;
                                      });
                                      bloc.updateCalendarPreferences(_preferences);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(Responsive.width(4, context)),
                                    ),
                                    side: const BorderSide(color: Colors.grey),
                                    activeColor: const Color(0xFF1A56DB),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                              if (_bodiesExpanded && (_preferences.showInstiappFollowedBodies ?? true)) ...[
                                const SizedBox(height: 8),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: Responsive.height(150, context),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _bodies.length,
                                    itemBuilder: (context, idx) {
                                      final body = _bodies[idx];
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 20, bottom: 4),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: body.enabled ?? false,
                                              onChanged: (val) {
                                                setState(() {
                                                  body.enabled = val ?? false;
                                                });
                                                if (body.bodyId != null) {
                                                  bloc.updateSingleCalendarPrefBody(body.bodyId!, body);
                                                }
                                              },
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(Responsive.width(4, context)),
                                              ),
                                              side: const BorderSide(color: Colors.grey),
                                              activeColor: const Color(0xFF1A56DB),
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            SizedBox(width: Responsive.width(6, context)),
                                            Expanded(
                                              child: Text(
                                                body.bodyName ?? '',
                                                style: TextStyle(
                                                  fontSize: Responsive.width(13, context),
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
                              SizedBox(height: Responsive.height(16, context)),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _preferences.showResobin ?? true,
                                    onChanged: (val) {
                                      setState(() {
                                        _preferences.showResobin = val ?? false;
                                      });
                                      bloc.updateCalendarPreferences(_preferences);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(Responsive.width(4, context)),
                                    ),
                                    side: const BorderSide(color: Colors.grey),
                                    activeColor: const Color(0xFF1A56DB),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                                        padding: const EdgeInsets.only(left: 20, bottom: 4),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: cal.isActive ?? false,
                                              onChanged: (val) {
                                                setState(() {
                                                  cal.isActive = val ?? false;
                                                });
                                                if (cal.slug != null) {
                                                  bloc.toggleSharedCalendar(cal.slug!, val ?? false);
                                                }
                                              },
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(Responsive.width(4, context)),
                                              ),
                                              side: const BorderSide(color: Colors.grey),
                                              activeColor: const Color(0xFF1A56DB),
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            SizedBox(width: Responsive.width(6, context)),
                                            Expanded(
                                              child: Text(
                                                cal.name ?? '',
                                                style: TextStyle(
                                                  fontSize: Responsive.width(13, context),
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
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.width(20, context),
            vertical: Responsive.height(16, context),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Clear All btn
              GestureDetector(
                onTap: () {
                  if (!_loading) {
                    setState(() {
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
                child:  Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: Responsive.width(15, context),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dotted,
                  ),
                ),
              ),

              // Apply button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1B2A),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(40, context),
                    vertical: Responsive.height(14, context),
                  ),
                  elevation: 0,
                ),
                child:  Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: Responsive.width(16, context),
                    fontWeight: FontWeight.w600,
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

  const _SidebarTab({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: Responsive.height(18, context),
        horizontal: Responsive.width(12, context),
      ),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEEEEEE) : Colors.white,
        border: isSelected
            ? const Border(left: BorderSide(color: Color(0xFF1A56DB), width: 5))
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: Responsive.width(15, context),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: Colors.black87,
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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