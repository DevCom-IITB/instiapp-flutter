import 'package:flutter/material.dart';

class NullableCircleAvatar extends StatelessWidget {
  final String url;
  final IconData fallbackIcon;

  NullableCircleAvatar(this.url, this.fallbackIcon);

  @override
  Widget build(BuildContext context) {
    return url != null
        ? CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(url),
          )
        : CircleAvatar(
            radius: 24,
          child: Icon(fallbackIcon));
  }
}
