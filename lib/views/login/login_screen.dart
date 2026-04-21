// Tela: Login do turista
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';

/// Ecrã de login do turista.
/// Aqui o utilizador introduz email e password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final sucesso = await context.read<AuthProvider>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      
      if (sucesso && mounted) {
        // Navega para a home se login for bem-sucedido
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ou ícone
                  const Icon(
                    Icons.waves,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Título
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'O teu guia pelo Algarve',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Campo Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduz o teu email';
                      }
                      if (!value.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Campo Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Palavra-passe',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 4) {
                        return 'Mínimo 4 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Esqueci-me da password (apenas visual)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Futuro: recuperação de password
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funcionalidade em desenvolvimento'),
                          ),
                        );
                      },
                      child: const Text('Esqueci-me da palavra-passe'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Mensagem de erro
                  if (auth.error != null)
                    Text(
                      auth.error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Botão Entrar (reutilizável!)
                  CustomButton(
                    text: 'Entrar',
                    isLoading: auth.isLoading,
                    onPressed: _fazerLogin,
                    icon: Icons.login,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}