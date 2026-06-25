import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:algarve_explorer/l10n/app_localizations.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/itinerary_provider.dart';
import '../itinerary/itinerary_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Map<String, String>> _idiomas = [
    {'code': 'pt', 'label': 'Português'},
    {'code': 'en', 'label': 'English'},
    {'code': 'fr', 'label': 'Français'},
    {'code': 'es', 'label': 'Español'},
  ];

  Future<void> _confirmarLogout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terminar sessão'),
        content: const Text('Queres mesmo sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profile,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 32),

              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final user = auth.user;
                  return Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, Color(0xFF4A90D9)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.nome ?? 'Convidado',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              Text(
                l10n.language,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Consumer<AppSettingsProvider>(
                builder: (context, settings, _) {
                  final selectedValue = _idiomas.any((item) => item['code'] == settings.localeCode)
                      ? settings.localeCode
                      : 'pt';

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedValue,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        items: _idiomas.map((idioma) {
                          return DropdownMenuItem(
                            value: idioma['code'],
                            child: Text(idioma['label'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          if (value == null) return;
                          await context.read<AppSettingsProvider>().setLocale(value);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${l10n.languageChanged}: ${_idiomas.firstWhere((item) => item['code'] == value)['label']}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              Text(
                'Estatísticas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),

              Consumer<FavoritesProvider>(
                builder: (context, fav, _) => _buildStatCard(
                  icon: Icons.favorite,
                  iconColor: Colors.red,
                  titulo: l10n.favorites,
                  subtitulo: fav.count == 0
                      ? l10n.noFavoritesYet
                      : '${fav.count} ${fav.count == 1 ? l10n.oneSavedPlace : l10n.savedPlaces}',
                  onTap: fav.count == 0
                      ? null
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.openMapToSeeFavorites),
                              duration: const Duration(seconds: 3),
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 8),
              Consumer<ItineraryProvider>(
                builder: (context, it, _) => _buildStatCard(
                  icon: Icons.route,
                  titulo: l10n.itineraries,
                  subtitulo: it.roteiros.isEmpty
                      ? l10n.createFirstItinerary
                      : '${it.roteiros.length} ${it.roteiros.length == 1 ? l10n.oneItinerary : l10n.itinerariesCount} ${it.roteiros.length == 1 ? '' : l10n.planned}',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ItineraryListScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmarLogout,
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text(
                    l10n.logout,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    Color? iconColor,
    required String titulo,
    required String subtitulo,
    VoidCallback? onTap,
  }) {
    final color = iconColor ?? AppColors.primary;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitulo, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
