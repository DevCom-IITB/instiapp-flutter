import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui' show Brightness;

String capitalize(String name) {
  if (name != null && name.isNotEmpty) {
    return name.substring(0, 1).toUpperCase() + name.substring(1);
  }
  return name;
}

String thumbnailUrl(String url, {int dim = 100}) {
  return url.replaceFirst(
      "api.insti.app/static/", "img.insti.app/static/$dim/");
}

class NullableCircleAvatar extends StatelessWidget {
  final String url;
  final IconData fallbackIcon;
  final double radius;
  final String heroTag;
  final bool photoViewable;
  final Color backgroundColor;
  NullableCircleAvatar(this.url, this.fallbackIcon,
      {this.radius = 24,
      this.heroTag,
      this.photoViewable = false,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return url != null
        ? (photoViewable
            ? InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HeroPhotoViewWrapper(
                          imageProvider: CachedNetworkImageProvider(url),
                          heroTag: heroTag,
                          minScale: PhotoViewComputedScale.contained * 0.9,
                          maxScale: PhotoViewComputedScale.contained * 2.0,
                        ),
                      ));
                },
                child: heroTag != null
                    ? Hero(
                        tag: heroTag,
                        child: CircleAvatar(
                          radius: radius,
                          backgroundImage: CachedNetworkImageProvider(
                            thumbnailUrl(url),
                            // url,
                          ),
                          backgroundColor: backgroundColor,
                        ),
                      )
                    : CircleAvatar(
                        radius: radius,
                        backgroundImage: CachedNetworkImageProvider(
                          thumbnailUrl(url),
                          // url,
                        ),
                        backgroundColor: backgroundColor,
                      ),
              )
            : heroTag != null
                ? Hero(
                    tag: heroTag,
                    child: CircleAvatar(
                      radius: radius,
                      backgroundImage: CachedNetworkImageProvider(
                        thumbnailUrl(url),
                        // url,
                      ),
                      backgroundColor: backgroundColor,
                    ),
                  )
                : CircleAvatar(
                    radius: radius,
                    backgroundImage: CachedNetworkImageProvider(
                      thumbnailUrl(url),
                      // url,
                    ),
                    backgroundColor: backgroundColor,
                  ))
        : heroTag != null
            ? Hero(
                tag: heroTag,
                child: CircleAvatar(
                  radius: radius,
                  child: Icon(fallbackIcon, size: radius),
                  backgroundColor: backgroundColor,
                ))
            : CircleAvatar(
                radius: radius,
                child: Icon(fallbackIcon, size: radius),
                backgroundColor: backgroundColor,
              );
  }
}

class HeroPhotoViewWrapper extends StatefulWidget {
  const HeroPhotoViewWrapper(
      {this.imageProvider,
      this.loadingChild,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      this.heroTag,
      this.theme});

  final ImageProvider imageProvider;
  final Widget loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final String heroTag;
  final ThemeData theme;

  @override
  HeroPhotoViewWrapperState createState() {
    return new HeroPhotoViewWrapperState();
  }
}

class HeroPhotoViewWrapperState extends State<HeroPhotoViewWrapper> {
  SystemUiOverlayStyle saveStyle;

  @override
  void initState() {
    super.initState();
    saveStyle = SystemChrome.latestStyle;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setSystemUIOverlayStyle(saveStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: true,
      ),
      body: Container(
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: PhotoView(
            imageProvider: widget.imageProvider,
            loadingBuilder: (_, __) => widget.loadingChild,
            backgroundDecoration: widget.backgroundDecoration,
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTag),
          )),
    );
  }
}

class PhotoViewableImage extends StatelessWidget {
  final String url;
  final ImageProvider imageProvider;
  final String heroTag;
  final BoxFit fit;
  final ShapeBorder customBorder;
  // final double height;
  // final double width;

  PhotoViewableImage({
    this.url,
    this.imageProvider,
    @required this.heroTag,
    this.fit,
    this.customBorder,
  }) : assert(url != null || imageProvider != null);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return InkWell(
        customBorder: customBorder,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HeroPhotoViewWrapper(
                  imageProvider:
                      imageProvider ?? CachedNetworkImageProvider(url),
                  heroTag: heroTag,
                  minScale: PhotoViewComputedScale.contained * 0.9,
                  maxScale: PhotoViewComputedScale.contained * 2.0,
                  theme: theme,
                ),
              ));
        },
        child: Hero(
          tag: heroTag,
          child: imageProvider != null
              ? Image(
                  image: imageProvider,
                  fit: fit,
                )
              : CachedNetworkImage(
                  imageUrl: url,
                  placeholder: (context, url) => CachedNetworkImage(
                    imageUrl: thumbnailUrl(url),
                    fit: fit,
                    placeholder: (context, url) =>
                        CircularProgressIndicatorExtended(),
                    errorWidget: (context, url, error) =>
                        new Icon(Icons.error_outline_outlined),
                  ),
                  errorWidget: (context, url, error) =>
                      new Icon(Icons.error_outline_outlined),
                  fit: fit,
                  fadeInDuration: Duration(milliseconds: 0),
                  fadeOutDuration: Duration(milliseconds: 0),
                ),
        ));
  }
}

class CommonHtml extends StatelessWidget {
  final String data;
  final TextStyle defaultTextStyle;

  CommonHtml({@required this.data, this.defaultTextStyle});

  @override
  Widget build(BuildContext context) {
    return data != null
        ? Html(
            data: data,
            onLinkTap: (link) async {
              print(link);
              if (await canLaunch(link)) {
                await launch(link);
              } else {
                throw "Couldn't launch $link";
              }
            },
            customRender: {
              "img": (_, __, attributes, ___) {
                return Text(attributes['src'] ?? attributes['href'] ?? "<img>");
              },
              "a": (_, __, ___, node) {
                return InkWell(
                  onTap: () async {
                    if (await canLaunch(node.attributes['href'])) {
                      await launch(node.attributes['href']);
                    }
                  },
                  child: Text(
                    node.innerHtml,
                    style: TextStyle(
                        color: Colors.lightBlue,
                        decoration: TextDecoration.underline),
                  ),
                );
              }
            },
          )
        : CircularProgressIndicatorExtended(
            label: Text("Loading content"),
          );
  }
}

/// A rectangle with a smooth circular notch.
class RoundedNotchedRectangle implements NotchedShape {
  /// Creates a `RoundedNotchedRectangle`.
  ///
  /// The same object can be used to create multiple shapes.
  const RoundedNotchedRectangle();

  /// Creates a [Path] that describes a rectangle with a smooth circular notch.
  ///
  /// `host` is the bounding box for the returned shape. Conceptually this is
  /// the rectangle to which the notch will be applied.
  ///
  /// `guest` is the bounding box of a circle that the notch accomodates. All
  /// points in the circle bounded by `guest` will be outside of the returned
  /// path.
  ///
  /// The notch is curve that smoothly connects the host's top edge and
  /// the guest circle.
  @override
  Path getOuterPath(Rect host, Rect guest) {
    if (guest == null || !host.overlaps(guest)) return Path()..addRect(host);

    // The guest's shape is a circle bounded by the guest rectangle.
    // So the guest's radius is half the guest width.
    final double notchRadius = guest.height / 2.0;

    // if (notchRadius - padding) is zero, basically no widget, then no notch
    if (notchRadius <= 4.0) {
      return Path()
        ..moveTo(host.left, host.top)
        ..lineTo(host.right, host.top)
        ..lineTo(host.right, host.bottom)
        ..lineTo(host.left, host.bottom)
        ..close();
    }

    // We build a path for the notch from 3 segments:
    // Segment A - a Bezier curve from the host's top edge to segment B.
    // Segment B - an arc with radius notchRadius.
    // Segment C - a Bezier curver from segment B back to the host's top edge.
    //
    // A detailed explanation and the derivation of the formulas below is
    // available at: https://goo.gl/Ufzrqn

    const double s1 = 15.0;
    const double s2 = 1.0;

    final double r = notchRadius;
    final double a = -1.0 * (guest.height / 2.0) - s2;
    final double ka = -1.0 * (guest.width / 2.0) - s2;
    final double b = host.top - guest.center.dy;

    final double n2 = math.sqrt(b * b * r * r * (a * a + b * b - r * r));
    final double p2xA = ((a * r * r) - n2) / (a * a + b * b);
    final double p2xB = ((a * r * r) + n2) / (a * a + b * b);
    final double p2yA = math.sqrt(r * r - p2xA * p2xA);
    final double p2yB = math.sqrt(r * r - p2xB * p2xB);

    final List<Offset> p = List<Offset>(8);

    // p0, p1, and p2 are the control points for segment A.
    p[0] = Offset(ka - s1, b);
    p[1] = Offset(ka, b);
    final double cmp = b < 0 ? -1.0 : 1.0;
    p[2] = cmp * p2yA > cmp * p2yB
        ? Offset(p2xA - 1.0 * (guest.width / 2.0) + r, p2yA)
        : Offset(p2xB - 1.0 * (guest.width / 2.0) + r, p2yB);

    // p3, p4, and p5 are the control points for segment B, which is a mirror
    // of segment A around the y axis.
    p[3] = Offset(-1.0 * p[2].dx, p[2].dy);
    p[4] = Offset(-1.0 * p[1].dx, p[1].dy);
    p[5] = Offset(-1.0 * p[0].dx, p[0].dy);

    p[6] = Offset(-1.0 * (guest.width / 2.0) + r, r);
    p[7] = Offset(-1.0 * p[6].dx, p[6].dy);

    // translate all points back to the absolute coordinate system.
    for (int i = 0; i < p.length; i += 1) p[i] += guest.center;

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(p[0].dx, p[0].dy)
      ..quadraticBezierTo(p[1].dx, p[1].dy, p[2].dx, p[2].dy)
      ..arcToPoint(
        p[6],
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(
        p[7].dx,
        p[7].dy,
      )
      ..arcToPoint(
        p[3],
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..quadraticBezierTo(p[4].dx, p[4].dy, p[5].dx, p[5].dy)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}

/// A container that is typically used with [Scaffold.bottomNavigationBar], and
/// can have a notch along the top that makes room for an overlapping
/// [FloatingActionButton].
///
/// Typically used with a [Scaffold] and a [FloatingActionButton].
///
/// {@tool sample}
/// ```dart
/// Scaffold(
///   bottomNavigationBar: BottomAppBar(
///     color: Colors.white,
///     child: bottomAppBarContents,
///   ),
///   floatingActionButton: FloatingActionButton(onPressed: null),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [ComputeNotch] a function used for creating a notch in a shape.
///  * [ScaffoldGeometry.floatingActionBarComputeNotch] the [ComputeNotch] used to
///    make a notch for the [FloatingActionButton]
///  * [FloatingActionButton] which the [BottomAppBar] makes a notch for.
///  * [AppBar] for a toolbar that is shown at the top of the screen.
class MyBottomAppBar extends StatelessWidget {
  /// Creates a bottom application bar.
  ///
  /// The [color], [elevation], and [clipBehavior] arguments must not be null.
  const MyBottomAppBar({
    Key key,
    this.color,
    this.elevation = 8.0,
    this.shape,
    this.clipBehavior = Clip.none,
    this.notchMargin = 4.0,
    this.child,
    this.iconSize,
  })  : assert(elevation != null),
        assert(elevation >= 0.0),
        assert(clipBehavior != null),
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  ///
  /// Typically this the child will be a [Row], with the first child
  /// being an [IconButton] with the [Icons.menu] icon.
  final Widget child;

  /// The bottom app bar's background color.
  ///
  /// When null defaults to [ThemeData.bottomAppBarColor].
  final Color color;

  /// The z-coordinate at which to place this bottom app bar. This controls the
  /// size of the shadow below the bottom app bar.
  ///
  /// Defaults to 8, the appropriate elevation for bottom app bars.
  final double elevation;

  /// The notch that is made for the floating action button.
  ///
  /// If null the bottom app bar will be rectangular with no notch.
  final NotchedShape shape;

  /// {@macro flutter.widgets.Clip}
  final Clip clipBehavior;

  /// The margin between the [FloatingActionButton] and the [BottomAppBar]'s
  /// notch.
  ///
  /// Not used if [shape] is null.
  final double notchMargin;

  /// The default icon size of all [Icon]'s and [IconButton]'s in [child]
  ///
  /// Default value is 24.0
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return BottomAppBar(
      clipBehavior: clipBehavior,
      color: color,
      elevation: elevation,
      notchMargin: notchMargin,
      shape: shape,
      child: IconTheme.merge(
        data: IconThemeData(
          color: theme.primaryIconTheme.color,
          size: iconSize ?? 64.0,
        ),
        child: child,
      ),
    );
  }
}

class CircularProgressIndicatorExtended extends StatelessWidget {
  CircularProgressIndicatorExtended({
    Key key,
    this.label,
    this.size = 18,
  }) : super(key: key);

  final Widget label;
  final double size;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(theme.accentColor),
            strokeWidth: 2,
          ),
        ),
      ]..addAll(label != null
          ? [
              SizedBox(
                width: 12.0,
              ),
              label
            ]
          : []),
    );
  }
}

class EditableChipList extends StatefulWidget {
  EditableChipList({
    Key key,
    this.editable = false,
    this.tags,
    this.preDefinedTags,
    this.controller,
  }) : super(key: key);

  /// Determines whether [Chip] should have a cross
  /// and whether there is a TextField to add new tags
  final bool editable;

  /// Useful when [editable] is true
  ///
  /// Uses these tags to search
  final FutureOr<List<String>> preDefinedTags;

  /// Tags to be shown initially
  final Set<String> tags;

  /// [TextEditingController] for controller to get new tags to add
  final TextEditingController controller;

  @override
  EditableChipListState createState() => EditableChipListState();
}

class EditableChipListState extends State<EditableChipList> {
  Set<String> tags = Set<String>();

  @override
  void initState() {
    super.initState();
    tags.clear();
    tags.addAll(widget.tags);

    if (widget.controller != null) {
      widget.controller.addListener(_onCreate);
    }
  }

  void _onCreate() async {
    String newTag;
    if ((widget.preDefinedTags is List<String> &&
            (widget.preDefinedTags as List<String>)
                .contains(widget.controller.text)) ||
        (widget.preDefinedTags is Future<List<String>> &&
            (await (widget.preDefinedTags as Future<List<String>>))
                .contains(widget.controller.text))) {
      newTag = widget.controller.text;
    } else {
      newTag = "${widget.controller.text} (U)";
    }
    setState(() {
      tags.add(newTag);
    });
  }

  @override
  void dispose() {
    widget?.controller?.removeListener(_onCreate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return ChipTheme(
      data: theme.chipTheme,
      child: Wrap(
          children: tags.map<Widget>((String name) {
        var chipColor = _nameToColor(name);
        var contentColor =
            ThemeData.estimateBrightnessForColor(chipColor) == Brightness.dark
                ? Colors.white
                : Colors.black;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Chip(
            key: ValueKey<String>(name),
            backgroundColor: chipColor,
            deleteIconColor: contentColor,
            labelStyle:
                theme.chipTheme.labelStyle.copyWith(color: contentColor),
            label: Text(
              _capitalize(name),
            ),
            onDeleted: widget.editable
                ? () {
                    setState(() {
                      tags.remove(name);
                    });
                  }
                : null,
          ),
        );
      }).toList()),
    );
  }

  // This converts a String to a unique color, based on the hash value of the
  // String object.  It takes the bottom 16 bits of the hash, and uses that to
  // pick a hue for an HSV color, and then creates the color (with a preset
  // saturation and value).  This means that any unique strings will also have
  // unique colors, but they'll all be readable, since they have the same
  // saturation and value.
  Color _nameToColor(String name) {
    assert(name.length > 1);
    final int hash = name.hashCode & 0xffff;
    final double hue = (360.0 * hash / (1 << 15)) % 360.0;
    return HSVColor.fromAHSV(1.0, hue, 0.4, 0.90).toColor();
  }

  String _capitalize(String name) {
    assert(name != null && name.isNotEmpty);
    return name.substring(0, 1).toUpperCase() + name.substring(1);
  }
}

class SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSize child;

  SliverHeaderDelegate({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => child.preferredSize.height;

  @override
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
