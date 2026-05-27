import 'package:flutter/material.dart';
import 'eventsSectionWidget.dart';

class ListViewWidget extends StatelessWidget {
  final ScrollController? controller;

  const ListViewWidget({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Center(child: EventsSectionWidget()),
        Center(child: EventsSectionWidget()),
        Center(child: EventsSectionWidget()),
      ],
    );
  }
}
