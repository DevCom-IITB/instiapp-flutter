import 'package:InstiApp/src/utils/responsive.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onOther;
  final IconData other;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.onOther,
    this.other = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconBackground(context, Icons.arrow_back, RS.s(context, 52),
            onPressed: onBack ?? () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/feed');
              }
            },
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: RS.sp(context, 24),
              fontWeight: FontWeight.bold,
              fontFamily: "DM Sans",
              color: Color(0xFF0F1620),
            ),
          ),
          onOther != null 
          ? _buildIconBackground(context, other, RS.s(context, 52), onPressed: onOther)
          : SizedBox(width: RS.s(context, 52)),
        ],
      ),
    );
  }

  Widget _buildIconBackground(BuildContext context, IconData icon, double size, {VoidCallback? onPressed}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(235, 235, 235, 0.8),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(icon, size: RS.s(context, 24), color: const Color(0xFF0F1620)),
          onPressed: onPressed,
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }
}
