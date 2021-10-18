import 'dart:core';

import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/routes/blogpage.dart';
import 'package:flutter/material.dart';

class ExternalBlogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlogPage(
      postType: PostType.External,
      title: "External Blog",
      loginNeeded: true,
    );
  }
}
