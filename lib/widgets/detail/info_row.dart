// 🆕 lib/widgets/detail/info_row.dart
import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool isMultiLine;

  const InfoRow({
    super.key, required this.icon, required this.text,
    this.onTap, this.iconColor, this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon, color: iconColor), title: Text(text), onTap: onTap);
  }
}
