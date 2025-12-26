import 'package:flutter/material.dart';
import 'package:InstiApp/src/utils/responsive.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final bool top;
  final bool bottom;
  final VoidCallback onTap;

  const SettingsItem({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    this.top = false,
    this.bottom = false,
    this.onTap = _noop,
  });

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    final radius = RS.s(context, 14);

    return Container(
      height: RS.sh(context, 64),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(239, 239, 239, 1),
        borderRadius: BorderRadius.vertical(
          top: top ? Radius.circular(radius) : Radius.zero,
          bottom: bottom ? Radius.circular(radius) : Radius.zero,
        ),
        border: bottom
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color.fromRGBO(210, 213, 218, 0.5),
                  width: 1,
                ),
              ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: RS.sw(context, 16)),
          child: Row(
            children: [
              Icon(
                icon,
                size: RS.s(context, 24),
                color: color ?? const Color(0xFF1E293B),
              ),
              SizedBox(width: RS.sw(context, 16)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: RS.sp(context, 16),
                    fontWeight: FontWeight.w600,
                    color: color ?? const Color(0xFF1E293B),
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ToggleItem extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final bool top;
  final bool bottom;
  final IconData? icon;

  const ToggleItem({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.top = false,
    this.bottom = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final radius = RS.s(context, 14);

    return Container(
      height: RS.sh(context, 64),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(239, 239, 239, 1),
        borderRadius: BorderRadius.vertical(
          top: top ? Radius.circular(radius) : Radius.zero,
          bottom: bottom ? Radius.circular(radius) : Radius.zero,
        ),
        border: bottom
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color.fromRGBO(210, 213, 218, 0.5),
                  width: 1,
                ),
              ),
      ),
      child: Theme(
        data: ThemeData.light().copyWith(
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.all(Colors.white),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? const Color.fromRGBO(48, 111, 220, 1)
                  : const Color.fromRGBO(210, 213, 218, 1),
            ),
            trackOutlineColor:
                WidgetStateProperty.all(Colors.transparent),
          ),
        ),
        child: SwitchListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: RS.sw(context, 16),
          ),
          secondary: icon != null
              ? Icon(
                  icon,
                  size: RS.s(context, 24),
                  color: const Color(0xFF1E293B),
                )
              : null,
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w600,
              fontSize: RS.sp(context, 16),
            ),
          ),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class DecoratedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final String? backgroundImageAsset;

  final double borderRadius;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;

  const DecoratedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.white,
    this.backgroundImageAsset,
    this.borderRadius = 30,
    this.height = 48,
    this.fontSize = 20,
    this.fontWeight = FontWeight.w600,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    final scaledHeight = RS.sh(context, height);
    final scaledRadius = RS.s(context, borderRadius);

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(scaledRadius),
        child: Container(
          height: scaledHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(scaledRadius),
            image: backgroundImageAsset != null
                ? DecorationImage(
                    image: AssetImage(backgroundImageAsset!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: RS.sp(context, fontSize),
              fontWeight: fontWeight,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
      ),
    );
  }
}
