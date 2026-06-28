import 'package:InstiApp/src/components/calendarPage/monthViewWidget.dart';
import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';

class MonthCalendarScroll extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onVisibleDateChanged;
  final PageController? pageController;

  const MonthCalendarScroll({
    Key? key,
    this.onDateSelected,
    this.onVisibleDateChanged,
    this.pageController,
  }) : super(key: key);

  @override
  State<MonthCalendarScroll> createState() => _MonthCalendarScrollState();
}

class _MonthCalendarScrollState extends State<MonthCalendarScroll> {
  // A large number to simulate infinite scrolling
  final int _initialPage = 10000;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = widget.pageController ?? PageController(initialPage: _initialPage);
  }

  @override
  void didUpdateWidget(covariant MonthCalendarScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageController != oldWidget.pageController) {
      _pageController = widget.pageController ?? PageController(initialPage: _initialPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.height(300, context),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (int index) {
          int monthOffset = index - _initialPage;
          // monthOffset is 0 for current month, -1 for last month, 1 for next month
          print("Selected month offset: $monthOffset");
          final now = DateTime.now();
          final visibleMonth = DateTime(now.year, now.month + monthOffset, 1);
          widget.onVisibleDateChanged?.call(visibleMonth);
        },
        itemBuilder: (context, index) {
          int monthOffset = index - _initialPage;
          return _buildMonthWidget(monthOffset);
        },
      ),
    );
  }

  Widget _buildMonthWidget(int monthOffset) {
    return MonthViewWidget(
      monthOffset: monthOffset,
      onDateSelected: widget.onDateSelected,
    );
  }
}
