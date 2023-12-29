import 'dart:core';

import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/routes/blogpage.dart';
import 'package:flutter/material.dart';

import 'package:InstiApp/src/api/model/body.dart'; //follow-button plugins
import 'package:http/http.dart' as http;
import 'package:InstiApp/src/bloc_provider.dart';

class TrainingBlogPage extends StatefulWidget {
  @override
  _TrainingBlogPageState createState() => _TrainingBlogPageState();
}

class _TrainingBlogPageState extends State<TrainingBlogPage> {
  late Body definedBody = Body(bodyName: 'NULL');
  late var bloc;

  @override
  void initState() {
    super.initState();
    _fetchBody();
  }

  void _fetchBody() async {
    definedBody = await dostuff();
    setState(() {});
  }

  Future<Body> dostuff() async {
    // ignore: unused_local_variable
    final response = await http.get(Uri.parse(
        'https://gymkhana.iitb.ac.in/instiapp/api/bodies/9cb8659c-bfdf-4e30-a2f0-057f86697123'));
    Body internship_body =
        await bloc.getBody("9cb8659c-bfdf-4e30-a2f0-057f86697123");

    try {
      return internship_body;
    } catch (error) {
      return Body(bodyName: 'NULL');
    }
  }

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of(context)!.bloc;

    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (definedBody.bodyName != 'NULL') {
      return BlogPage(
        postType: PostType.Training,
        title: "Internship Blog",
        initialBody: definedBody,
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
