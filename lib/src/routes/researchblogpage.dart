import 'package:flutter/material.dart';
import 'package:InstiApp/src/utils/research_blog_card.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';

class ResearchBlogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Research",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
  padding: EdgeInsets.only(top: Responsive.height(10, context)),
  children: [
    ResearchCard(
      title: 'Game Theoretic Solutions for National Security Planning',
      professor: 'Prof. Suneet Singh',
      tag: 'AI/ML',
      description: 'Working on cutting edge Optimisation Techniques to enhance performance of energy systems...',
      imageUrl: 'https://placehold.co/113x189',
    ),
    ResearchCard(
      title: 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut .',
      professor: 'Prof. Alpha Delta Omega',
      tag: 'Systems',
      description: 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea...',
      imageUrl: 'https://placehold.co/113x189',
    ),
    ResearchCard(
      title: 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut .',
      professor: 'Prof. Theta Epsilon Pi',
      tag: 'Robotics',
      description: 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna...',
      imageUrl: 'https://placehold.co/113x189',
    ),
  ],
),
    );
  }
}