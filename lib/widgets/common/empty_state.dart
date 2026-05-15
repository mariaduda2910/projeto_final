// 🆕 lib/widgets/common/empty_state.dart
// Estado vazio reutilizável
// RESPONSABILIDADE: Laura | USADO POR: Qualquer lista vazia

import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String? subtitulo;
  final String? botaoTexto;
  final VoidCallback? onBotaoTap;

  const EmptyState({
    super.key, required this.icon, required this.titulo,
    this.subtitulo, this.botaoTexto, this.onBotaoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]), textAlign: TextAlign.center),
            if (subtitulo != null) ...[const SizedBox(height: 8), Text(subtitulo!, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center)],
            if (botaoTexto != null && onBotaoTap != null) ...[const SizedBox(height: 24), ElevatedButton(onPressed: onBotaoTap, child: Text(botaoTexto!))],
          ],
        ),
      ),
    );
  }
}
