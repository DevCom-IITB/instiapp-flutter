import 'package:flutter/material.dart';

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
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(239, 239, 239, 1),
        borderRadius: BorderRadius.vertical(
          top: top ? const Radius.circular(14) : Radius.zero,
          bottom: bottom ? const Radius.circular(14) : Radius.zero,
        ),
        border: bottom ? null :
          const Border(bottom: BorderSide(color: Color.fromRGBO(210, 213, 218, 0.5), width: 1)),
      ),
      child: Center(
        child: ListTile(
          leading: Icon(icon, color: color ?? const Color(0xFF1E293B)),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: color ?? const Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: onTap,
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
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(239, 239, 239, 1),
        borderRadius: BorderRadius.vertical(
          top: top ? const Radius.circular(14) : Radius.zero,
          bottom: bottom ? const Radius.circular(14) : Radius.zero,
        ),
        border: bottom ? null :
          const Border(bottom: BorderSide(color: Color.fromRGBO(210, 213, 218, 0.5), width: 1)),
      ),
      child: Center(
        child: Theme(
          data: ThemeData.light().copyWith(
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                return Colors.white;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? Color.fromRGBO(48, 111, 220, 1)
                    : Color.fromRGBO(210, 213, 218, 1);
              }),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
          child: Center(
            child: SwitchListTile(
              secondary: icon != null ? Icon(icon, color: const Color(0xFF1E293B)) : null,
              title: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(title, style: const TextStyle(fontFamily: "DM Sans", fontWeight: FontWeight.w600, fontSize: 16)),
              ),
              value: value,
              onChanged: onChanged,
            ),
          ),
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

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
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
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}
