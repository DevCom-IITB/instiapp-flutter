import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';


void showCalendarFiltersBottomSheet(BuildContext context) {
  showModalBottomSheet(
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
  bool eventsExpanded = true;
  bool academicsExpanded = false;


  bool eventsAll = false;
  bool cultural = false;
  bool tech1 = false;
  bool ib = false;
  bool tech2 = false;
  bool academics = false;
  bool reminders = false;

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    _SidebarTab(label: 'Categories', isSelected: true),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ExpandableCategory(
                        label: 'Events and Announcements',
                        isChecked: eventsAll,
                        isExpanded: eventsExpanded,
                        onCheckChanged: (val) => setState(() => eventsAll = val ?? false),
                        onToggleExpand: () => setState(() => eventsExpanded = !eventsExpanded),
                      ),
                      if (eventsExpanded) ...[
                        _SubCheckbox(
                          label: 'Cultural',
                          value: cultural,
                          onChanged: (val) => setState(() => cultural = val ?? false),
                        ),
                        _SubCheckbox(
                          label: 'Tech',
                          value: tech1,
                          onChanged: (val) => setState(() => tech1 = val ?? false),
                        ),
                        _SubCheckbox(
                          label: 'IB',
                          value: ib,
                          onChanged: (val) => setState(() => ib = val ?? false),
                        ),
                        _SubCheckbox(
                          label: 'Tech',
                          value: tech2,
                          onChanged: (val) => setState(() => tech2 = val ?? false),
                        ),
                         SizedBox(height: Responsive.height(8, context)),
                      ],


                      _ExpandableCategory(
                        label: 'Academics',
                        isChecked: academics,
                        isExpanded: academicsExpanded,
                        onCheckChanged: (val) => setState(() => academics = val ?? false),
                        onToggleExpand: () => setState(() => academicsExpanded = !academicsExpanded),
                      ),
                       SizedBox(height: Responsive.height(4, context)),


                      Row(
                        children: [
                          Checkbox(
                            value: reminders,
                            onChanged: (val) => setState(() => reminders = val ?? false),
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
                            'Reminders',
                            style: TextStyle(
                              fontSize: Responsive.width(15, context),
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
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
              // Clear All btnn
              GestureDetector(
                onTap: () {
                  setState(() {
                    eventsAll = false;
                    cultural = false;
                    tech1 = false;
                    ib = false;
                    tech2 = false;
                    academics = false;
                    reminders = false;
                  });
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