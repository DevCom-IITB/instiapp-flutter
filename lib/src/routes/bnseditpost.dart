import 'package:flutter/material.dart';

class EditPostPage extends StatelessWidget {
  final Map<String, dynamic> post;

  const EditPostPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: Center(
        child: Text('Edit post page for ${post['title']}'),
      ),
    );
  }
}