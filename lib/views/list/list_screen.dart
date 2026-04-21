// Tela: Listagem de pontos turísticos (Laura)

import 'package:flutter/material.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista')),
      body: const Center(child: Text('Página Lista de POIs')),
    );
  }
}
