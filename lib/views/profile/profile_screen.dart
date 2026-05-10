// lib/views/profile/profile_screen.dart
import 'package:flutter/material.dart';

/// Página do Perfil do turista.
/// 
/// Placeholder por agora — a Laura e a Maria vão definir o conteúdo.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Perfil do Turista',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Em desenvolvimento...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}