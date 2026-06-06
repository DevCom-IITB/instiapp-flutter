import 'package:flutter/material.dart';
import 'eventsSectionWidget.dart';
import '../../api/response/calendar_feed_response.dart';
class ListViewWidget extends StatelessWidget {
  final ScrollController? controller;
  final CalendarFeedResponse? response;

  const ListViewWidget({Key? key, this.controller, this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Center(child: EventsSectionWidget(response: response)),
        Center(child: EventsSectionWidget(response: response)),
        Center(child: EventsSectionWidget(response: response)),
      ],
    );
  }
}
