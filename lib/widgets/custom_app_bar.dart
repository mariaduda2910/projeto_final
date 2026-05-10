import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// Header reutilizável do Algarve Explorer
/// 
/// Uso:
/// CustomAppBar(
///   selectedIndex: 0,           // 0=Início, 1=Mapa, 2=Perfil
///   onTabChanged: (index) {}, // avisa o ShellLayout
///   onLogout: () {},          // avisa para fazer logout
/// )
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onLogout;

  const CustomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF4A90D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x400066CC),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // 🌊 LOGO (igual do login)
              _buildLogo(),
              const SizedBox(width: 24),
              
              // 📑 TABS
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTab('Início', 0),
                    const SizedBox(width: 24),
                    _buildTab('Mapa', 1),
                    const SizedBox(width: 24),
                    _buildTab('Perfil', 2),
                  ],
                ),
              ),
              
              // 🔓 LOGOUT
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo: círculo com onda azul (igual login)
  Widget _buildLogo() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.waves,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  /// Tab: Início | Mapa | Perfil
  Widget _buildTab(String label, int index) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white 
                  : Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          // Underline animado quando selecionado
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 24 : 0,
            height: 2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  /// Botão logout: só ícone
  Widget _buildLogoutButton() {
    return IconButton(
      icon: Icon(
        Icons.logout,
        color: Colors.white.withOpacity(0.8),
        size: 22,
      ),
      onPressed: onLogout,
      tooltip: 'Sair',
    );
  }
}