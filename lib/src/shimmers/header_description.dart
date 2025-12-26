import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';

class HeaderDescriptionShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(0, 224, 224, 224)!,
      highlightColor: const Color.fromARGB(0, 245, 245, 245)!,
      child: Container(
        width: Responsive.width(240, context),
        height: Responsive.height(16, context),
        decoration: BoxDecoration(
          color: const Color.fromARGB(0, 255, 255, 255),
          borderRadius:
              BorderRadius.circular(Responsive.height(4, context)),
        ),
      ),
    );
  }
}
