import 'package:InstiApp/src/components/calendarPage/monthViewWidget.dart';
import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';

class MonthCalendarScroll extends StatefulWidget {
  const MonthCalendarScroll({Key? key}) : super(key: key);

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
    _pageController = PageController(initialPage: _initialPage);
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
        },
        itemBuilder: (context, index) {
          int monthOffset = index - _initialPage;
          return _buildMonthWidget(monthOffset);
        },
      ),
    );
  }

  Widget _buildMonthWidget(int monthOffset) {
    return MonthViewWidget(monthOffset: monthOffset);
  }
}
