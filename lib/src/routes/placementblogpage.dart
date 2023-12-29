import 'dart:core';

import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/routes/blogpage.dart';
import 'package:flutter/material.dart';

import 'package:InstiApp/src/api/model/body.dart'; //follow-button plugins
import 'package:http/http.dart' as http;
import 'package:InstiApp/src/bloc_provider.dart';

class PlacementBlogPage extends StatefulWidget {
  @override
  _PlacementBlogPageState createState() => _PlacementBlogPageState();
}

class _PlacementBlogPageState extends State<PlacementBlogPage> {
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
        'https://gymkhana.iitb.ac.in/instiapp/api/bodies/5023aff7-4407-4e75-95c9-5f691e8c3efb'));
    Body placement_body =
        await bloc.getBody("5023aff7-4407-4e75-95c9-5f691e8c3efb");

    try {
      return placement_body;
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
        postType: PostType.Placement,
        title: "Placement Blog",
        initialBody: definedBody,
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
