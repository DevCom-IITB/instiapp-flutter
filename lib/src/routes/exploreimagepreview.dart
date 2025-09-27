import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ExploreImagePreview extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const ExploreImagePreview({required this.imageUrls,this.initialIndex = 0,super.key});

  @override
  State<ExploreImagePreview> createState() => _ExploreImagePreviewState();
}

class _ExploreImagePreviewState extends State<ExploreImagePreview> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color.fromRGBO(235, 235, 235, 0.8),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.arrow_back, color: Colors.black, size: 28),
              ),
            ),
          ),
        ),
        title: Text(
          '${_currentIndex+1}/${widget.imageUrls.length}',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        }, 
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: AssetImage(widget.imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4,
            basePosition: Alignment.center,
            heroAttributes: PhotoViewHeroAttributes(tag: widget.imageUrls[index]),
          );
        },
      ),
    );
  }
}