import 'package:flutter/material.dart';

class FooterButtons extends StatelessWidget {
  final List<Widget> footerButtons;
  const FooterButtons({Key? key, required this.footerButtons})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: footerButtons.map((e) {
          return Container(
            margin: EdgeInsets.only(right: 10),
            child: e,
          );
        }).toList(),
      ),
    );
  }
}
