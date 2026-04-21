// Tela: Detalhes do ponto turístico + rota (Laura)

import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: const Center(child: Text('Página Detalhes do POI')),
    );
  }
}