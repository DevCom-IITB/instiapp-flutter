import 'dart:core';

import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/routes/blogpage.dart';
import 'package:flutter/material.dart';

class PlacementBlogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlogPage(
      postType: PostType.Placement,
      title: "Placement Blog",
    );
  }
}
