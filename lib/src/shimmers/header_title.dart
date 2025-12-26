import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';

class HeaderTitleShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: Responsive.width(180, context),
        height: Responsive.width(36, context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(Responsive.width(6, context)),
        ),
      ),
    );
  }
}
