// 🆕 lib/views/settings/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Definições')),
      body: ListView(
        children: [
          const ListTile(leading: Icon(Icons.palette), title: Text('Modo Escuro'), trailing: Switch(value: false, onChanged: null)),
          const ListTile(leading: Icon(Icons.language), title: Text('Idioma'), trailing: Text('Português')),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Terminar Sessão', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
