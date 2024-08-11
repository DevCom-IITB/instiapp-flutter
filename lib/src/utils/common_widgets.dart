import 'dart:async';

// import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/components/dropdowns.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/routes/communitypostpage.dart';
import 'package:InstiApp/src/blocs/community_post_bloc.dart';
import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/routes/createpost_form.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_selectable_text/fwfh_selectable_text.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';

// ignore: unnecessary_import
import 'dart:ui' show Brightness;

import '../bloc_provider.dart';

String defUrl = "https://devcom-iitb.org/images/logos/DC_footer.png";

String capitalize(String name) {
  if (name.isNotEmpty) {
    return name.substring(0, 1).toUpperCase() + name.substring(1);
  }
  return name;
}

String thumbnailUrl(String url, {int dim = 100}) {
  return url;
  // TODO: Fix this
  // .replaceFirst(
  //     "api.insti.app/static/", "img.insti.app/static/$dim/");
}

class NullableCircleAvatar extends StatelessWidget {
  final String url;
  final IconData fallbackIcon;
  final double radius;
  final String? heroTag;
  final bool photoViewable;
  final Color? backgroundColor;
  NullableCircleAvatar(this.url, this.fallbackIcon,
      {this.radius = 24,
      this.heroTag,
      this.photoViewable = false,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return url != ""
        ? (photoViewable
            ? InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HeroPhotoViewWrapper(
                          imageProvider: CachedNetworkImageProvider(url),
                          heroTag: heroTag!,
                          minScale: PhotoViewComputedScale.contained * 0.9,
                          maxScale: PhotoViewComputedScale.contained * 2.0,
                        ),
                      ));
                },
                child: heroTag != null
                    ? Hero(
                        tag: heroTag!,
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
                    tag: heroTag!,
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
                tag: heroTag!,
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
      {required this.imageProvider,
      this.loadingChild,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      required this.heroTag,
      this.theme});

  final ImageProvider imageProvider;
  final Widget? loadingChild;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final String heroTag;
  final ThemeData? theme;

  @override
  HeroPhotoViewWrapperState createState() {
    return new HeroPhotoViewWrapperState();
  }
}

class HeroPhotoViewWrapperState extends State<HeroPhotoViewWrapper> {
  // late SystemUiOverlayStyle saveStyle;

  @override
  void initState() {
    super.initState();
    // saveStyle = SystemChrome.latestStyle!;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
    super.dispose();
    // SystemChrome.setSystemUIOverlayStyle(saveStyle);
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
            loadingBuilder: (_, __) => widget.loadingChild ?? Container(),
            backgroundDecoration: widget.backgroundDecoration,
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTag),
          )),
    );
  }
}

class PhotoViewableImage extends StatelessWidget {
  final String? url;
  final ImageProvider? imageProvider;
  final String heroTag;
  final BoxFit? fit;
  final ShapeBorder? customBorder;
  // final double height;
  // final double width;

  PhotoViewableImage({
    this.url,
    this.imageProvider,
    required this.heroTag,
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
                  imageProvider: imageProvider ??
                      CachedNetworkImageProvider(url ?? defUrl),
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
                  image: imageProvider!,
                  fit: fit,
                )
              : CachedNetworkImage(
                  imageUrl: url ?? "",
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

String refineText(String text) {
  text = text.replaceAll("<br>", "\n");
  text = text.replaceAll("<strong>", " ");
  text = text.replaceAll("</strong>", " ");
  text = text.replaceAll("&nbsp;", "  ");
  text = text.replaceAll("&amp;", "&");
  return text;
}

class SelectableWidgetFactory extends WidgetFactory with SelectableTextFactory {
  @override
  SelectionChangedCallback? get selectableTextOnChanged => (selection, cause) {
        // do something when the selection changes
      };
}

class CommonHtml extends StatelessWidget {
  final String? data;
  final TextStyle defaultTextStyle;

  CommonHtml({this.data, required this.defaultTextStyle});

  @override
  Widget build(BuildContext context) {
    return data != null
        ? HtmlWidget(
            data ?? "",
            factoryBuilder: () => SelectableWidgetFactory(),
            onTapUrl: (link) async {
              if (await canLaunchUrl(Uri.parse(link))) {
                await launchUrl(
                  Uri.parse(link),
                  mode: LaunchMode.externalApplication,
                );
                return true;
              } else {
                throw "Couldn't launch $link";
              }
            },
          )
        : CircularProgressIndicatorExtended(
            label: Text("Loading content"),
          );
  }
}

// class CommonHtmlBlog extends StatelessWidget {
//   final String? data;
//   final String? query;
//   final TextStyle defaultTextStyle;

//   CommonHtmlBlog({this.data, required this.defaultTextStyle, this.query});

//   @override
//   Widget build(BuildContext context1) {
//     // var theme = Theme.of(context1);
//     // var bloc = BlocProvider.of(context1)!.bloc;
//     // print(data);
//     return data != null
//         ? Html(
//             shrinkWrap: true,
//             data: data,
//             onLinkTap: (link, _, __, ____) async {
//               //print(link);
//               if (await canLaunchUrl(Uri.parse(link!))) {
//                 await launchUrl(
//                   Uri.parse(link),
//                   mode: LaunchMode.externalApplication,
//                 );
//               } else {
//                 throw "Couldn't launch $link";
//               }
//             },
//             customRender: {
//               "img": (context, child) {
//                 var attributes = context.tree.element!.attributes;
//                 return Text(attributes['src'] ?? attributes['href'] ?? "<img>");
//               },
//               "a": (context, child) {
//                 var attributes = context.tree.element!.attributes;
//                 var innerHtml = context.tree.element?.innerHtml;
//                 return InkWell(
//                   onTap: () async {
//                     if (await canLaunchUrl(Uri.parse(attributes['href']!))) {
//                       await launchUrl(
//                         Uri.parse(attributes['href']!),
//                         mode: LaunchMode.externalApplication,
//                       );
//                     }
//                   },
//                   child: Text(
//                     innerHtml ?? "",
//                     style: TextStyle(
//                         color: Colors.lightBlue,
//                         decoration: TextDecoration.underline),
//                   ),
//                   // child: RichText(
//                   //   textScaleFactor:2,
//                   //   text: highlight(node.innerHtml,"electro"),
//                   // )
//                 );
//               },
//               "p": (context, child) {
//                 // String text =context.tree.element?.innerHtml??"";
//                 var nodes = context.tree.element?.children;
//                 var nodes1 = context.tree.element?.nodes;
//                 // print(nodes1);
//                 // print(nodes);
//                 List<Widget> w = [];
//                 int j = 0;

//                 // for(int i=0;i<(nodes1?.length??0);i++ ){
//                 //
//                 // }

//                 for (int i = 0; i < (nodes1?.length ?? 0); i++) {
//                   if (j >= (nodes?.length ?? 0)) j = (nodes?.length ?? 0) - 1;
//                   // nodes?.length==0?print(""):print(nodes![j].localName);
//                   // print(nodes1![i].runtimeType);
//                   String type = nodes1![i].runtimeType.toString();
//                   if (type == "Text") {
//                     w.add(SelectableText.rich(
//                       highlight(
//                           refineText(nodes1[i].text!), query ?? '', context1),
//                       //strutStyle: StrutStyle.fromTextStyle(theme.textTheme.subtitle1!.copyWith(color: Colors.lightBlue)),
//                     ));
//                   } else if (type == "Element") {
//                     if (nodes![j].localName == "a") {
//                       var attributes = nodes[j].attributes;
//                       var innerHtml = nodes[j].innerHtml;
//                       w.add(InkWell(
//                         onTap: () async {
//                           if (await canLaunchUrl(
//                               Uri.parse(attributes['href']!))) {
//                             await launchUrl(
//                               Uri.parse(attributes['href']!),
//                               mode: LaunchMode.externalApplication,
//                             );
//                           }
//                         },
//                         child: Text(
//                           innerHtml,
//                           style: TextStyle(
//                               color: Colors.lightBlue,
//                               decoration: TextDecoration.underline),
//                         ),
//                         // child: RichText(
//                         //   textScaleFactor:2,
//                         //   text: highlight(node.innerHtml,"electro"),
//                         // )
//                       ));
//                     } else if (nodes[j].localName == "strong") {
//                       w.add(SelectableText.rich(
//                         highlight(
//                             refineText(nodes[j].text), query ?? '', context1,
//                             isStrong: true),
//                         // strutStyle: StrutStyle.fromTextStyle(theme.textTheme.headline5!
//                         //     .copyWith(fontWeight: FontWeight.w900),height: 0.7, fontWeight: FontWeight.w900 )
//                       ));
//                     } else if (nodes[j].localName == "br") {
//                       w.add(SelectableText.rich(
//                         highlight(" \n", query ?? '', context1),
//                         // strutStyle: StrutStyle.fromTextStyle(theme.textTheme.headline5!
//                         //     .copyWith(fontWeight: FontWeight.w900),height: 0.7, fontWeight: FontWeight.w900 )
//                       ));
//                     }
//                     j++;
//                   }
//                 }
//                 return Container(
//                   padding: const EdgeInsets.fromLTRB(0, 2, 6, 2),
//                   alignment: Alignment.centerLeft,
//                   child: Wrap(
//                     children: w,
//                   ),
//                 );
//                 // return RichText(
//                 //       textScaleFactor:1,
//                 //       text: highlight(refineText(text),query?? ''),
//                 //     );
//               },
//               "td": (context, child) {
//                 String text = context.tree.element?.innerHtml ?? "";
//                 // text="    "+text+"   ";
//                 return Padding(
//                   padding: const EdgeInsets.fromLTRB(0, 2, 6, 2),
//                   child: SelectableText.rich(
//                     highlight(refineText(text), query ?? '', context1),
//                   ),
//                 );
//               },
//               "th": (context, child) {
//                 String text = context.tree.element?.innerHtml ?? "";
//                 // text="    "+text+"   ";
//                 return Padding(
//                   padding: const EdgeInsets.fromLTRB(0, 2, 6, 2),
//                   child: SelectableText.rich(
//                     highlight(refineText(text), query ?? '', context1),
//                   ),
//                 );
//               },
//               "table": (context, child) {},
//               "thread": (context, child) {}
//               // "td":(context,child){
//               //   context.tree.style.padding=const EdgeInsets.only(
//               //     left: 12.0,
//               //     top: 12.0,
//               //     right: 12.0,
//               //   );
//               //   context.tree.style.width=500;
//               //   print(context.tree.style.width);
//               // }
//             },
//           )
//         : CircularProgressIndicatorExtended(
//             label: Text("Loading content"),
//           );
//   }

//   TextSpan highlight(String result, String query, BuildContext context,
//       {bool isStrong = false}) {
//     var bloc = BlocProvider.of(context)!.bloc;
//     var theme = Theme.of(context);
//     // print(result);
//     TextStyle posRes =
//         TextStyle(color: Colors.white, backgroundColor: bloc.accentColor);
//     TextStyle? negRes = isStrong
//         ? theme.textTheme.subtitle2
//             ?.copyWith(fontWeight: FontWeight.w700, fontSize: 13)
//         : theme.textTheme.subtitle2?.copyWith(
//             fontSize:
//                 13); // TextStyle(backgroundColor: bloc.bloc.brightness.toColor().withOpacity(1.0),);
//     if (result == "" || query == "")
//       return TextSpan(text: result, style: negRes);
//     result.replaceAll('\n', " ").replaceAll(" ", "");

//     var refinedMatch = result.toLowerCase();
//     var refinedsearch = query.toLowerCase();

//     if (refinedMatch.contains(refinedsearch)) {
//       if (refinedMatch.substring(0, refinedsearch.length) == refinedsearch) {
//         return TextSpan(
//             style: posRes,
//             text: result.substring(0, refinedsearch.length),
//             children: [
//               highlight(result.substring(refinedsearch.length), query, context),
//             ]);
//       } else if (refinedsearch.length == refinedMatch.length) {
//         return TextSpan(text: result, style: posRes);
//       } else {
//         return TextSpan(
//             style: negRes,
//             text: result.substring(0, refinedMatch.indexOf(refinedsearch)),
//             children: [
//               highlight(result.substring(refinedMatch.indexOf(refinedsearch)),
//                   query, context)
//             ]);
//       }
//     } else if (!refinedMatch.contains(refinedsearch)) {
//       return TextSpan(text: result, style: negRes);
//     }

//     return TextSpan(
//       text: result.substring(0, refinedMatch.indexOf(refinedsearch)),
//       style: negRes,
//       children: [
//         highlight(result.substring(refinedMatch.indexOf(refinedsearch)), query,
//             context)
//       ],
//     );
//   }
// }

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
  Path getOuterPath(Rect host, Rect? guest) {
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

    final List<Offset> p = [];

    // p0, p1, and p2 are the control points for segment A.
    p.add(Offset(ka - s1, b));
    p.add(Offset(ka, b));
    final double cmp = b < 0 ? -1.0 : 1.0;
    p.add(cmp * p2yA > cmp * p2yB
        ? Offset(p2xA - 1.0 * (guest.width / 2.0) + r, p2yA)
        : Offset(p2xB - 1.0 * (guest.width / 2.0) + r, p2yB));

    // p3, p4, and p5 are the control points for segment B, which is a mirror
    // of segment A around the y axis.
    p.add(Offset(-1.0 * p[2].dx, p[2].dy));
    p.add(Offset(-1.0 * p[1].dx, p[1].dy));
    p.add(Offset(-1.0 * p[0].dx, p[0].dy));

    p.add(Offset(-1.0 * (guest.width / 2.0) + r, r));
    p.add(Offset(-1.0 * p[6].dx, p[6].dy));

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
    Key? key,
    this.color,
    this.elevation = 8.0,
    this.shape,
    this.clipBehavior = Clip.none,
    this.notchMargin = 4.0,
    this.child,
    this.iconSize,
  })  : assert(elevation >= 0.0),
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  ///
  /// Typically this the child will be a [Row], with the first child
  /// being an [IconButton] with the [Icons.menu] icon.
  final Widget? child;

  /// The bottom app bar's background color.
  ///
  /// When null defaults to [ThemeData.bottomAppBarColor].
  final Color? color;

  /// The z-coordinate at which to place this bottom app bar. This controls the
  /// size of the shadow below the bottom app bar.
  ///
  /// Defaults to 8, the appropriate elevation for bottom app bars.
  final double elevation;

  /// The notch that is made for the floating action button.
  ///
  /// If null the bottom app bar will be rectangular with no notch.
  final NotchedShape? shape;

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
  final double? iconSize;

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
          size: iconSize ?? 30.0,
        ),
        child: child!,
      ),
    );
  }
}

class CircularProgressIndicatorExtended extends StatelessWidget {
  CircularProgressIndicatorExtended({
    Key? key,
    this.label,
    this.size = 18,
  }) : super(key: key);

  final Widget? label;
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
            valueColor:
                new AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
            strokeWidth: 2,
          ),
        ),
      ]..addAll(label != null
          ? [
              SizedBox(
                width: 12.0,
              ),
              label!
            ]
          : []),
    );
  }
}

class EditableChipList extends StatefulWidget {
  EditableChipList({
    Key? key,
    this.editable = false,
    required this.tags,
    this.preDefinedTags,
    this.controller,
  }) : super(key: key);

  /// Determines whether [Chip] should have a cross
  /// and whether there is a TextField to add new tags
  final bool editable;

  /// Useful when [editable] is true
  ///
  /// Uses these tags to search
  final FutureOr<List<String>>? preDefinedTags;

  /// Tags to be shown initially
  final Set<String> tags;

  /// [TextEditingController] for controller to get new tags to add
  final TextEditingController? controller;

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
      widget.controller?.addListener(_onCreate);
    }
  }

  void _onCreate() async {
    String newTag;
    if ((widget.preDefinedTags is List<String> &&
            (widget.preDefinedTags as List<String>)
                .contains(widget.controller?.text)) ||
        (widget.preDefinedTags is Future<List<String>> &&
            (await (widget.preDefinedTags as Future<List<String>>))
                .contains(widget.controller?.text))) {
      newTag = widget.controller!.text;
    } else {
      newTag = "${widget.controller?.text} (U)";
    }
    setState(() {
      tags.add(newTag);
    });
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onCreate);
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
                theme.chipTheme.labelStyle?.copyWith(color: contentColor),
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
    assert(name.isNotEmpty);
    return name.substring(0, 1).toUpperCase() + name.substring(1);
  }
}

class SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSize child;

  SliverHeaderDelegate({required this.child});

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

class DefListItem extends StatelessWidget {
  final String? title;
  final String? company;
  final String? icon;
  final String? forText;
  final String? importance;
  final bool? isVerified;
  final bool? isDismissed;
  final String? adminNote;

  const DefListItem(
      {Key? key,
      this.title,
      this.company,
      this.icon,
      this.forText,
      this.importance,
      this.isVerified,
      this.isDismissed,
      this.adminNote})
      : super(key: key);

  Widget verifiedText() {
    if (isVerified!) {
      return Text(
        "Verified",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      );
    } else if (isDismissed!) {
      return Text(
        "Dismissed",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );
    } else {
      return Text(
        "Verification Pending",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: icon == null
              ? null
              : CircleAvatar(
                  foregroundImage: NetworkImage(icon!),
                ),
          title: Text(title!),
          subtitle: Text(company!),
        ),
        forText == null
            ? SizedBox()
            : Row(
                children: [
                  Text("For: "),
                  Text(
                    forText!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
        importance == null ? SizedBox() : Text(importance!),
        adminNote == null
            ? SizedBox()
            : Row(
                children: [
                  Text("Admin Note: "),
                  Text(
                    adminNote!,
                  ),
                ],
              ),
        Row(
          children: [
            Text("Status: "),
            verifiedText(),
          ],
        ),
      ],
    );
  }
}

// class MapEntry {
//   int key;
//   String val;

//   MapEntry(this.key, this.val);
// }

class ImageGallery extends StatefulWidget {
  final List<String> images;
  final int galleryLength;
  final void Function()? onRightIndTap;

  const ImageGallery(
      {Key? key,
      required this.images,
      this.onRightIndTap,
      this.galleryLength = 4})
      : super(key: key);

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  late List<String> galleryImages;
  // late Map<int, String> imgMap;

  int _currIndex = 0;

  double scale = 4 / 5;

  double screenWidth = 0;
  bool firstBuild = true;

  bool _isRight = true;

  @override
  void initState() {
    super.initState();

    if (widget.images.length == 0 || widget.images.length == 1) {
      return;
    }
    galleryImages = widget.images
        .sublist(0, math.min(widget.galleryLength, widget.images.length));

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );

    animation = Tween<double>(begin: 0, end: 1).animate(controller)
      ..addStatusListener((status) {
        if ((status == AnimationStatus.completed && !_isRight) ||
            (status == AnimationStatus.dismissed && _isRight)) {
          _swapUptoInd(_isRight);
        }
      })
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      screenWidth = MediaQuery.of(context).size.width;
      firstBuild = false;
    }

    if (widget.images.length == 0) {
      return Container();
    }

    if (widget.images.length == 1) {
      String img = widget.images[0];
      return Material(
        type: MaterialType.transparency,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.all(10),
          child: Ink(
            // width: 100,
            width: screenWidth * scale,
            // height: 100,
            height: screenWidth * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  img,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: screenWidth,
      height: (screenWidth + 40) * scale,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swiping in right direction.
          if (details.primaryVelocity! > 0) {
            _startAnimation(true);
          }

          // Swiping in left direction.
          if (details.primaryVelocity! < 0) {
            _startAnimation(false);
          }
        },
        // onTap: () {
        //   _swapUptoInd(true);
        // },
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: galleryImages
              .asMap()
              .entries
              .map<Widget>((e) {
                bool useAnim =
                    !((controller.status == AnimationStatus.completed &&
                            !_isRight) ||
                        (controller.status == AnimationStatus.dismissed &&
                            _isRight));

                double firstVisibility = (!_isRight
                        ? e.key == 0 && useAnim
                            ? animation.value
                            : useAnim
                                ? e.key - animation.value
                                : e.key
                        : useAnim
                            ? e.key + (1 - animation.value)
                            : e.key)
                    .toDouble();

                double normalAnim = (!_isRight
                        ? useAnim
                            ? e.key - animation.value
                            : e.key
                        : useAnim
                            ? e.key + (1 - animation.value)
                            : e.key)
                    .toDouble();

                double imgWidth = screenWidth * scale - firstVisibility * 20;
                double left = normalAnim * 30;
                double opacity = 1 - firstVisibility * 0.2;
                if (opacity > 1) opacity = 1;
                if (opacity < 0) opacity = 0;

                return Positioned(
                  // top: 0,
                  left: left,
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => _startAnimation(false),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: Ink(
                          width: imgWidth,
                          height: imgWidth,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                e.value,
                              ),
                              colorFilter: ColorFilter.mode(
                                Colors.white.withOpacity(opacity),
                                BlendMode.dstATop,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              })
              .toList()
              .reversed
              .toList(),
        ),
      ),
    );
  }

  void _startAnimation(bool right) {
    if (controller.value != 1 && controller.value != 0) {
      _swapUptoInd(right);
    }
    if (!right) {
      controller.forward(from: 0);
    } else {
      controller.reverse(from: 1);
    }
    _isRight = right;
  }

  void _swapUptoInd(bool right) {
    int index = right ? _currIndex - 1 : _currIndex + 1;
    if (index == -1) index = widget.images.length - 1;
    if (index == widget.images.length) index = 0;
    List<String> newGalleryImages = [
      ...widget.images.sublist(index),
      ...widget.images.sublist(0, index)
    ].sublist(0, math.min(widget.galleryLength, widget.images.length));
    setState(() {
      galleryImages = newGalleryImages;
      _currIndex = index;
    });
  }
}

class CommunityPostWidget extends StatefulWidget {
  // const CommunityPostWidget({Key? key}) : super(key: key);
  final CommunityPost communityPost;
  final void Function()? onPressedComment;
  final bool shouldTap;
  final CPType postType;

  CommunityPostWidget({
    required this.communityPost,
    this.onPressedComment,
    this.shouldTap = true,
    this.postType = CPType.All,
  });
  @override
  State<CommunityPostWidget> createState() =>
      _CommunityPostWidgetState(communityPost: communityPost);
}

class _CommunityPostWidgetState extends State<CommunityPostWidget> {
  CommunityPost communityPost;
  bool contentExpanded = false;
  bool isAnon = false;
  _CommunityPostWidgetState({required this.communityPost});

  bool showSelf() {
    if (widget.postType == CPType.YourPosts) return true;
    return !(communityPost.deleted == true);
  }

  @override
  Widget build(BuildContext context) {
    if (!showSelf()) {
      return Container();
    }

    ThemeData theme = Theme.of(context);
    InstiAppBloc bloc = BlocProvider.of(context)!.bloc;
    CommunityPostBloc communityPostBloc = bloc.communityPostBloc;
    String content = communityPost.content ?? "";
    int contentChars = widget.postType == CPType.Featured
        ? communityPost.imageUrl == null || communityPost.imageUrl!.length == 0
            ? 310
            : 30
        : 310;
    if (widget.postType == CPType.All) {
      if (communityPost.anonymous == true) {
        isAnon = true;
      } else {
        isAnon = false;
      }
    } else {
      isAnon = false;
    }

    void Function()? postOnTap = contentExpanded ||
            content.length <= contentChars ||
            widget.postType == CPType.Featured
        ? widget.shouldTap && (communityPost.status == 1)
            ? () => CommunityPostPage.navigateWith(
                context, bloc.communityPostBloc, communityPost)
            : null
        : () => setState(() {
              contentExpanded = true;
            });

    return Container(
      width: CPType.Featured == widget.postType ? 300 : null,
      margin: widget.shouldTap
          ? EdgeInsets.all(10)
          : EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: 1,
                        color: theme.colorScheme.surfaceContainerHighest))),
            child: ListTile(
              leading: NullableCircleAvatar(
                isAnon
                    ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSM9q9XJKxlskry5gXTz1OXUyem5Ap59lcEGg&usqp=CAU"
                    : communityPost.postedBy?.userProfilePictureUrl ?? "",
                Icons.person,
                radius: 18,
              ),
              title: Text(
                isAnon
                    ? "Anonymous User"
                    : (communityPost.postedBy?.userName ?? "Anonymous user") +
                        ((communityPost.anonymous ?? false) ? " (Anon)" : ""),
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: Text(
                DateFormat("dd MMM, yyyy")
                    .format(DateTime.parse(communityPost.timeOfCreation!)),
                style: theme.textTheme.bodySmall,
              ),
              trailing: Container(
                width: widget.postType == CPType.Featured
                    ? 100
                    : MediaQuery.of(context).size.width / 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    communityPost.status != 1 || communityPost.deleted == true
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: communityPost.deleted == true
                                    ? Color(0xFFF24822)
                                    : communityPost.status == 0
                                        ? Color(0xFFFFCD29)
                                        : Color(0xFFF24822),
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text(
                              communityPost.deleted == true
                                  ? "Deleted"
                                  : communityPost.status == 0
                                      ? "Pending"
                                      : communityPost.status == 2
                                          ? "Rejected"
                                          : "Reported",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: communityPost.deleted == true
                                    ? Color(0xFFF24822)
                                    : communityPost.status == 0
                                        ? Color(0xFFFFCD29)
                                        : Color(0xFFF24822),
                              ),
                            ),
                          )
                        : Container(),
                    PopupMenuButton<int>(
                      itemBuilder: (context) {
                        List<PopupMenuItem<int>> items = [];

                        bool isAuthor = communityPost.postedBy?.userID ==
                            bloc.currSession!.profile!.userID;

                        bool isAdmin = bloc.hasPermission(
                            communityPost.community?.body ?? "", "AppP");

                        if (isAuthor) {
                          items.add(
                            PopupMenuItem(
                              value: 1,
                              // row has two child icon and text.
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(
                                    // sized box with width 10
                                    width: 10,
                                  ),
                                  Text("Edit")
                                ],
                              ),
                              onTap: () => Future(() async {
                                CommunityPost? post =
                                    (await Navigator.of(context).pushNamed(
                                  "/posts/add",
                                  arguments:
                                      NavigateArguments(post: communityPost),
                                )) as CommunityPost?;
                                if (post != null) {
                                  setState(() {
                                    communityPost = post;
                                  });
                                }
                              }),
                            ),
                          );
                        }

                        if ((isAuthor || isAdmin) &&
                            !(communityPost.deleted == true)) {
                          items.add(
                            PopupMenuItem(
                              value: 2,
                              // row has two child icon and text
                              child: Row(
                                children: [
                                  Icon(Icons.delete),
                                  SizedBox(
                                    // sized box with width 10
                                    width: 10,
                                  ),
                                  Text("Delete")
                                ],
                              ),
                              onTap: () async {
                                await communityPostBloc.deleteCommunityPost(
                                    communityPost.id ?? "");
                                setState(() {
                                  communityPost.deleted = true;
                                });
                              },
                            ),
                          );
                        }
                        if (isAdmin) {
                          items.add(
                            PopupMenuItem(
                              value: 3,
                              // row has two child icon and text
                              child: Row(
                                children: [
                                  Icon((communityPost.featured ?? false)
                                      ? Icons.published_with_changes_sharp
                                      : Icons.push_pin_outlined),
                                  SizedBox(
                                    // sized box with width 10
                                    width: 10,
                                  ),
                                  Text((communityPost.featured ?? false)
                                      ? "Unpin from featured"
                                      : "Pin to featured")
                                ],
                              ),
                              onTap: () async {
                                bool isFeatured =
                                    !(communityPost.featured ?? false);

                                await bloc.communityPostBloc
                                    .featureCommunityPost(
                                        communityPost.id!, isFeatured);

                                setState(() {
                                  communityPost.featured = isFeatured;
                                });
                              },
                            ),
                          );
                        }

                        items.add(
                          PopupMenuItem(
                            value: 4,
                            // row has two child icon and text
                            child: Row(
                              children: [
                                Icon(Icons.share),
                                SizedBox(
                                  // sized box with width 10
                                  width: 10,
                                ),
                                Text("Share")
                              ],
                            ),
                            onTap: () async {
                              await Share.share(
                                  "Check this post: ${ShareURLMaker.getCommunityPostURL(communityPost)}");
                            },
                          ),
                        );
                        return items;
                      },
                      // offset: Offset(0, 100),
                      elevation: 2,
                      tooltip: "More",
                      icon: Icon(
                        Icons.more_vert,
                      ),
                    ),
                  ],
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              minVerticalPadding: 0,
              dense: true,
              horizontalTitleGap: 4,
              onTap: communityPost.postedBy != null &&
                      !(communityPost.anonymous ?? false)
                  ? () => UserPage.navigateWith(
                      context, bloc, communityPost.postedBy)
                  : null,
            ),
          ),
          GestureDetector(
            onTap: contentExpanded ||
                    content.length <= contentChars ||
                    widget.postType == CPType.Featured
                ? widget.shouldTap && (communityPost.status == 1)
                    ? () => CommunityPostPage.navigateWith(
                        context, bloc.communityPostBloc, communityPost)
                    : null
                : () => setState(() {
                      contentExpanded = true;
                    }),
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableLinkify(
                      text: content.length > contentChars && !contentExpanded
                          ? content.substring(0, contentChars - 10) +
                              (contentExpanded ? "" : "...")
                          : content,
                      onOpen: (link) async {
                        if (await canLaunchUrl(Uri.parse(link.url))) {
                          await launchUrl(
                            Uri.parse(link.url),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      onTap: postOnTap,
                    ),
                    Text.rich(
                      new TextSpan(
                        children: !contentExpanded &&
                                content.length > contentChars
                            ? [
                                new TextSpan(
                                  text: 'Read More.',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.primary),
                                  // recognizer: new TapGestureRecognizer()
                                  //   ..onTap = () => setState(() {
                                  //         contentExpanded = true;
                                  //       }),
                                )
                              ]
                            : [],
                      ),
                    ),
                  ],
                )
                // child: Text(
                //   communityPost.content ?? '''post''',
                // ),
                ),
          ),
          communityPost.imageUrl != null
              ? GestureDetector(
                  onTap: widget.postType == CPType.Featured
                      ? () => CommunityPostPage.navigateWith(
                          context, bloc.communityPostBloc, communityPost)
                      : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ImageGallery(
                      images: (widget.postType == CPType.Featured
                          ? [communityPost.imageUrl![0]]
                          : communityPost.imageUrl)!,
                    ),
                  ),
                )
              : Container(),
          _buildFooter(theme, bloc, communityPost),
        ],
      ),
    );
  }

  Widget _buildFooter(
      ThemeData theme, InstiAppBloc bloc, CommunityPost communityPost) {
    switch (widget.postType) {
      case CPType.All:
      case CPType.YourPosts:
        int numReactions = communityPost.reactionCount?.values
                .reduce((sum, element) => sum + element) ??
            0;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.colorScheme.surface,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              // border:
              //     Border(top: BorderSide(color: theme.colorScheme.surfaceVariant)),
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 30,
                  spreadRadius: -18,
                  color: theme.colorScheme.onSurface,
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    PopupMenuButton<int>(
                      onSelected: (val) async {
                        await bloc.communityPostBloc
                            .updateUserCommunityPostReaction(
                                communityPost, val);

                        setState(() {
                          if ((communityPost.userReaction ?? -1) != -1) {
                            communityPost.reactionCount![
                                    communityPost.userReaction!.toString()] =
                                (communityPost.reactionCount![communityPost
                                            .userReaction!
                                            .toString()] ??
                                        1) -
                                    1;
                          }
                          communityPost.reactionCount![val.toString()] =
                              (communityPost.reactionCount![val.toString()] ??
                                              0) +
                                          (communityPost.userReaction ?? -1) ==
                                      val
                                  ? 0
                                  : 1;
                          communityPost.userReaction =
                              communityPost.userReaction == val ? -1 : val;
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          new PopupMenuWidget(
                            height: 20,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: emojis
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => Container(
                                        color:
                                            e.key == communityPost.userReaction
                                                ? Colors.blue
                                                : Colors.transparent,
                                        child: InkWell(
                                          onTap: () =>
                                              Navigator.of(context).pop(e.key),
                                          child:
                                              Image.asset(e.value, width: 30),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ];
                      },
                      child: Row(children: [
                        communityPost.userReaction == -1
                            ? Icon(
                                Icons.add_reaction_outlined,
                                size: 20,
                              )
                            : Image.asset(emojis[communityPost.userReaction!],
                                width: 20),
                        numReactions > 0
                            ? Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                ),
                                child: Row(
                                  children: emojis
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => (communityPost.reactionCount?[
                                                        e.key.toString()] ??
                                                    0) >
                                                0
                                            ? Image.asset(e.value, width: 20)
                                            : Container(),
                                      )
                                      .toList(),
                                ),
                              )
                            : Container(),
                        numReactions > 0
                            ? Text(
                                numReactions.toString(),
                                style: theme.textTheme.bodySmall,
                              )
                            : Container(),
                      ]),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(
                              Icons.mode_comment_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: widget.onPressedComment ??
                                (widget.shouldTap && (communityPost.status == 1)
                                    ? () => CommunityPostPage.navigateWith(
                                        context,
                                        bloc.communityPostBloc,
                                        communityPost)
                                    : null),
                          ),
                          SizedBox(width: 3),
                          Text((communityPost.commentsCount ?? 0).toString(),
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    )
                  ],
                ),
                IconButton(
                    onPressed: () async {
                      await Share.share(
                          "Check this post: ${ShareURLMaker.getCommunityPostURL(communityPost)}");
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(
                      Icons.share_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ))
              ],
            ),
          ),
        );
      case CPType.PendingPosts:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Text("Disapprove"),
                  onPressed: () {
                    bloc.communityPostBloc
                        .updateCommunityPostStatus(communityPost.id!, 2);
                  },
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                flex: 1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primaryContainer,
                  ),
                  child: Text("Approve"),
                  onPressed: () {
                    bloc.communityPostBloc
                        .updateCommunityPostStatus(communityPost.id!, 1);
                  },
                ),
              ),
            ],
          ),
        );
      case CPType.ReportedContent:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Text("Ignore"),
                  onPressed: () {
                    bloc.communityPostBloc
                        .updateCommunityPostStatus(communityPost.id!, 1);
                  },
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                flex: 1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primaryContainer,
                  ),
                  child: Text("Delete"),
                  onPressed: () {
                    bloc.communityPostBloc
                        .updateCommunityPostStatus(communityPost.id!, 2);
                  },
                ),
              ),
            ],
          ),
        );

      default:
        return Container();
    }
  }
}

List<String> emojis = [
  "assets/communities/emojis/like.png",
  "assets/communities/emojis/love.png",
  "assets/communities/emojis/laugh.png",
  "assets/communities/emojis/surprise.png",
  "assets/communities/emojis/cry.png",
  "assets/communities/emojis/angry.png",
];

/// An arbitrary widget that lives in a popup menu
class PopupMenuWidget<T> extends PopupMenuEntry<T> {
  const PopupMenuWidget({
    Key? key,
    required this.height,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  final double height;

  @override
  _PopupMenuWidgetState createState() => _PopupMenuWidgetState();

  @override
  bool represents(T? value) => false;
}

class _PopupMenuWidgetState extends State<PopupMenuWidget> {
  @override
  Widget build(BuildContext context) => widget.child;
}

class DropdownMultiSelect<T> extends StatefulWidget {
  final void Function(List<T>?) update;
  final Future<List<T>>? load;
  final Future<List<T>> Function(String?)? onFind;
  final String singularObjectName;
  final String pluralObjectName;

  const DropdownMultiSelect({
    Key? key,
    required this.update,
    required this.load,
    required this.onFind,
    required this.singularObjectName,
    required this.pluralObjectName,
  }) : super(key: key);

  @override
  State<DropdownMultiSelect<T>> createState() => _DropdownMultiSelectState();
}

class _DropdownMultiSelectState<T> extends State<DropdownMultiSelect<T>> {
  List<T>? objects;

  void onObjectChange(T? body) async {
    if (body != null) {
      if (objects!.any((e) => e.toString() == body.toString())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("You already selected this ${widget.singularObjectName}"),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      setState(() {
        objects?.add(body);
        widget.update(objects);
      });
    }
  }

  Widget _buildChips(BuildContext context) {
    List<Widget> w = [];
    int length = objects?.length ?? 0;
    for (int i = 0; i < length; i++) {
      w.add(
        Chip(
          labelPadding: EdgeInsets.all(2.0),
          label: Text(
            objects?[i].toString() ?? "",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.primaries[i],
          elevation: 6.0,
          shadowColor: Colors.grey[60],
          padding: EdgeInsets.all(8.0),
          onDeleted: () async {
            objects?.removeAt(i);
            widget.update(objects);
            setState(() {});
          },
        ),
      );
    }
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0,
      children: w,
    );
  }

  Widget buildDropdownMenuItems(BuildContext context, T? body) {
    return Container(
      child: Text(
        "Search for an ${widget.singularObjectName}",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _customPopupItemBuilder(
      BuildContext context, T body, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(body.toString()),
      ),
    );
  }

  @override
  void initState() {
    if (widget.load != null) {
      widget.load!.then((value) {
        setState(() {
          objects = value;
        });
      });
    } else {
      objects = [];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      // width: double.infinity,
      margin: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          CustomDropdown<T>(
            emptyText:
                "No ${widget.pluralObjectName} found. Refine your search!",
            onChanged: onObjectChange,
            label: widget.pluralObjectName,
            itemBuilder: _customPopupItemBuilder,
            asyncItems: widget.onFind,
            dropdownBuilder: buildDropdownMenuItems,
            style: theme.textTheme.titleMedium,
            validator: (value) {
              // if (value == null) {
              //   return 'Please select a Skill';
              // }
              return null;
            },
          ),
          _buildChips(context),
        ],
      ),
    );
  }
}
