import 'package:InstiApp/src/components/calendarPage/weekViewWidget.dart';
import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';

class WeekCalendarScroll extends StatefulWidget {
  const WeekCalendarScroll({Key? key}) : super(key: key);

  @override
  State<WeekCalendarScroll> createState() => _WeekCalendarScrollState();
}

class _WeekCalendarScrollState extends State<WeekCalendarScroll> {
  // A large number to simulate infinite scrolling
  final int _initialPage = 10000; 
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.height(70, context), // Adjust based on your week widget design
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (int index) {
          int weekOffset = index - _initialPage;
          // weekOffset is 0 for current week, -1 for last week, 1 for next week
          print("Selected week offset: $weekOffset");
        },
        itemBuilder: (context, index) {
          int weekOffset = index - _initialPage;
          return _buildWeekWidget(weekOffset);
        },
      ),
    );
  }

  Widget _buildWeekWidget(int weekOffset) {
    // 1. Calculate the target week's Monday based on DateTime.now()
    // 2. Render your 7-day row item here

    return WeekViewWidget(weekOffset: weekOffset);
  }
}
