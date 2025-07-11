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
          _buildIconBackground(
            Icons.arrow_back,
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F1620),
            ),
          ),
          onOther != null 
          ? _buildIconBackground(other, onPressed: onOther)
          : SizedBox(width: 52), // Maintain spacing balance
        ],
      ),
    );
  }

  Widget _buildIconBackground(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(235, 235, 235, 0.8),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(icon, color: const Color(0xFF0F1620)),
          onPressed: onPressed,
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }
}
