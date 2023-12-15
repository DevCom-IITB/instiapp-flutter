import 'dart:core';

import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/routes/blogpage.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:InstiApp/src/api/model/body.dart'; //follow-button plugins
import 'package:InstiApp/src/bloc_provider.dart';

class ExternalBlogPage extends StatefulWidget {
  @override
  _ExternalBlogPageState createState() => _ExternalBlogPageState();
}

class _ExternalBlogPageState extends State<ExternalBlogPage> {
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
    final response = await http.get(Uri.parse(
        'https://gymkhana.iitb.ac.in/instiapp/api/bodies/8e303dca-9b2d-4501-bf7e-addca5e0c798'));
    Body external_body =
        await bloc.getBody("8e303dca-9b2d-4501-bf7e-addca5e0c798");

    try {
      return external_body;
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
        postType: PostType.External,
        title: "External Blog",
        initialBody: definedBody,
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
