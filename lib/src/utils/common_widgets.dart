import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class NullableCircleAvatar extends StatelessWidget {
  final String url;
  final IconData fallbackIcon;
  final double radius;
  final String heroTag;
  NullableCircleAvatar(this.url, this.fallbackIcon,
      {this.radius = 24, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return url != null
        ? (heroTag != null
            ? InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HeroPhotoViewWrapper(
                              imageProvider: NetworkImage(url),
                              heroTag: heroTag,
                              minScale: PhotoViewComputedScale.contained * 0.9,
                              maxScale: PhotoViewComputedScale.contained * 2.0,
                            ),
                      ));
                },
                child: Hero(
                  tag: heroTag,
                  child: CircleAvatar(
                    radius: radius,
                    backgroundImage: NetworkImage(url),
                  ),
                ))
            : CircleAvatar(
                radius: radius,
                backgroundImage: NetworkImage(url),
              ))
        : CircleAvatar(radius: radius, child: Icon(fallbackIcon, size: radius));
  }
}

class HeroPhotoViewWrapper extends StatelessWidget {
  const HeroPhotoViewWrapper(
      {this.imageProvider,
      this.loadingChild,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      this.heroTag});

  final ImageProvider imageProvider;
  final Widget loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          imageProvider: imageProvider,
          loadingChild: loadingChild,
          backgroundDecoration: backgroundDecoration,
          minScale: minScale,
          maxScale: maxScale,
          heroTag: heroTag,
        ));
  }
}

class PhotoViewableImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final String heroTag;
  final BoxFit fit;

  PhotoViewableImage(this.imageProvider, this.heroTag, {this.fit});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HeroPhotoViewWrapper(
                      imageProvider: imageProvider,
                      heroTag: heroTag,
                      minScale: PhotoViewComputedScale.contained * 0.9,
                      maxScale: PhotoViewComputedScale.contained * 2.0,
                    ),
              ));
        },
        child: Hero(
          tag: heroTag,
          child: Image(
            fit: fit,
            image: imageProvider,
          ),
        ));
  }
}
