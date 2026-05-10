// lib/views/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:algarve_explorer/core/constants/app_constants.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _idioma = 'Português';

  final List<String> _idiomas = [
    'Português',
    'English',
    'Français',
    'Español',
    'Italiano',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Perfil',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Avatar + Nome
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF4A90D9)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Turista',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      'turista@algarve.pt',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // IDIOMA
              Text(
                'Idioma',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _idioma,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    items: _idiomas.map((idioma) {
                      return DropdownMenuItem(
                        value: idioma,
                        child: Text(idioma),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _idioma = value!);
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Estatísticas
              Text(
                'Estatísticas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatCard(Icons.favorite, 'Favoritos', '12 locais guardados'),
              const SizedBox(height: 8),
              _buildStatCard(Icons.route, 'Rotas', '3 rotas planeadas'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String titulo, String subtitulo) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitulo, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}