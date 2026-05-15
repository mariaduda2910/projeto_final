// 🆕 lib/widgets/detail/mini_map.dart
import 'package:flutter/material.dart';

class MiniMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? nome;

  const MiniMap({super.key, required this.latitude, required this.longitude, this.nome});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.grey[200]),
      child: const Center(child: Text('MiniMap — TODO Laura')),
    );
  }
}
