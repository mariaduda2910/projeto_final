// lib/widgets/app_header.dart
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// Header estilo Airbnb — fixo no topo da página do mapa
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final int selectedTab; // 0=Mapa, 1=Lista, 2=Desejos
  final Function(int) onTabChanged;
  final VoidCallback onProfileTap;

  const AppHeader({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // 🌊 LOGO (igual login)
              _buildLogo(),

              const Spacer(),

              // 🗺️ [Mapa] [Lista] [Desejos]
              _buildNavTabs(),

              const SizedBox(width: 16),

              // 👤 PERFIL
              _buildProfileButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF4A90D9)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.waves, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 10),
        const Text(
          'Algarve',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildNavTabs() {
    final tabs = [
      _NavTab(icon: Icons.map_outlined, label: 'Mapa', index: 0),
      _NavTab(icon: Icons.list_outlined, label: 'Lista', index: 1),
      _NavTab(icon: Icons.favorite_outline, label: 'Desejos', index: 2),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = selectedTab == tab.index;
          return GestureDetector(
            onTap: () => onTabChanged(tab.index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    tab.icon,
                    size: 16,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: onProfileTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.person_outline,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _NavTab {
  final IconData icon;
  final String label;
  final int index;
  const _NavTab({required this.icon, required this.label, required this.index});
}
