import 'package:flutter/material.dart';
import 'monthGridWithEventsWidget.dart';

class MonthGridCalendarScroll extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onVisibleDateChanged;
  final PageController? pageController;

  const MonthGridCalendarScroll({
    Key? key,
    this.onDateSelected,
    this.onVisibleDateChanged,
    this.pageController,
  }) : super(key: key);

  @override
  State<MonthGridCalendarScroll> createState() => _MonthGridCalendarScrollState();
}

class _MonthGridCalendarScrollState extends State<MonthGridCalendarScroll> {
  final int _initialPage = 10000;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = widget.pageController ?? PageController(initialPage: _initialPage);
  }

  @override
  void didUpdateWidget(covariant MonthGridCalendarScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageController != oldWidget.pageController) {
      _pageController = widget.pageController ?? PageController(initialPage: _initialPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (int index) {
        int monthOffset = index - _initialPage;
        final now = DateTime.now();
        final visibleMonth = DateTime(now.year, now.month + monthOffset, 1);
        widget.onVisibleDateChanged?.call(visibleMonth);
      },
      itemBuilder: (context, index) {
        int monthOffset = index - _initialPage;
        return MonthGridWithEventsWidget(
          monthOffset: monthOffset,
        );
      },
    );
  }
}
