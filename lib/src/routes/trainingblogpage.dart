import 'dart:core';

import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/routes/blogpage.dart';
import 'package:flutter/material.dart';

class TrainingBlogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlogPage(
      blogType: BlogType.Training,
      title: "Internship Blog",
    );
  }
}
