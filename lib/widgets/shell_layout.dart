/// Layout "mãe" que tem o Header + IndexedStack. Quando clicas numa tab, muda o ecrã mas mantém o estado.
/// 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../views/home/home_screen.dart';
import '../views/map/poi_explorer_screen.dart';
import '../views/profile/profile_screen.dart';
import 'custom_app_bar.dart';

/// Layout principal da app.
/// 
/// Tem o Header fixo em cima e o conteúdo muda conforme a tab.
/// Usa IndexedStack para manter o estado de cada página.
class ShellLayout extends StatefulWidget {
  const ShellLayout({super.key});

  @override
  State<ShellLayout> createState() => _ShellLayoutState();
}

class _ShellLayoutState extends State<ShellLayout> {
  int _selectedIndex = 1; // Começa no Mapa (0=Início, 1=Mapa, 2=Perfil)

  /// Páginas que ficam dentro do IndexedStack
  final List<Widget> _pages = const [
    HomeScreen(),           // index 0 - Início
    PoiExplorerScreen(),    // index 1 - Mapa
    ProfileScreen(),        // index 2 - Perfil
  ];

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _onLogout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Header fixo em cima
      appBar: CustomAppBar(
        selectedIndex: _selectedIndex,
        onTabChanged: _onTabChanged,
        onLogout: _onLogout,
      ),
      // Corpo: IndexedStack mantém estado das 3 páginas
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}