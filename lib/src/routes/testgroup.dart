import 'package:flutter/material.dart';

class Group extends StatefulWidget {
  String? ID;
  String? name;
  String? followerCount;

  Group({required this.ID, required this.name, required this.followerCount});

  static void navigateWith(BuildContext context, Group? group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/group/${(group)?.ID}",
        ),
        builder: (context) => Group(
          ID: group?.ID,
          name: group?.name,
          followerCount: group?.followerCount,
        ),
      ),
    );
  }

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
    );
  }
}
