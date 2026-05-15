// 🆕 lib/widgets/common/error_state.dart
// Estado de erro reutilizável
// RESPONSABILIDADE: Laura | USADO POR: Qualquer ecrã que possa falhar

import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final String? botaoTexto;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key, this.titulo = 'Algo correu mal',
    this.subtitulo, this.botaoTexto = 'Tentar novamente', this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            if (subtitulo != null) ...[const SizedBox(height: 8), Text(subtitulo!, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center)],
            if (onRetry != null) ...[const SizedBox(height: 24), ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(botaoTexto!))],
          ],
        ),
      ),
    );
  }
}
