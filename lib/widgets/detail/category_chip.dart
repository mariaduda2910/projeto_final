// 🆕 lib/widgets/detail/category_chip.dart
import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String categoria;
  final bool isSmall;

  const CategoryChip({super.key, required this.categoria, this.isSmall = false});

  Color get _cor {
    final map = {
      'praia': Colors.amber, 'restaurante': Colors.red, 'monumento': Colors.teal,
      'museu': Colors.purple, 'natureza': Colors.green, 'comercial': Colors.orange,
    };
    return map[categoria.toLowerCase()] ?? Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(categoria),
      backgroundColor: _cor.withOpacity(0.2),
      labelStyle: TextStyle(color: _cor, fontSize: isSmall ? 12 : 14),
      padding: isSmall ? EdgeInsets.zero : null,
    );
  }
}
