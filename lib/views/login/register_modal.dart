import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

/// Modal de Registro - "Criar Conta"
/// Design Figma: Junte-se à comunidade Algarve Explorer
/// Inclui: Email, Password, Confirmar Password, GitHub Login
class RegisterModal extends StatefulWidget {
  final VoidCallback onClose;

  const RegisterModal({
    super.key,
    required this.onClose,
  });

  @override
  State<RegisterModal> createState() => _RegisterModalState();
}

class _RegisterModalState extends State<RegisterModal>
    with SingleTickerProviderStateMixin {
  // Controladores de texto para os campos de input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Estado de foco dos campos para animação de sombra
  String? _focusedField;

  // Animação de entrada do modal
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animação de entrada (fade + slide)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Inicia animação
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Valida a senha (mínimo 8 caracteres)
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Introduz uma palavra-passe';
    }
    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    return null;
  }

  /// Valida se as senhas coincidem
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma a palavra-passe';
    }
    if (value != _passwordController.text) {
      return 'As palavras-passe não coincidem';
    }
    return null;
  }

  /// Cria conta via AuthProvider e faz login automático.
  Future<void> _handleCreateAccount() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    final sucesso = await auth.registar(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (sucesso) {
      Navigator.pop(context); // fecha o modal
      Navigator.pushReplacementNamed(context, '/shell');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Erro ao criar conta.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Função para GitHub login (a implementar)
  void _handleGitHubLogin() {
    // TODO: Implementar autenticação GitHub (Firebase, etc)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GitHub Login - Funcionalidade em desenvolvimento'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✖️ BOTÃO FECHAR (topo direito)
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.close,
                              size: 24,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 📋 TÍTULO
                      Text(
                        'Criar Conta',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),

                      const SizedBox(height: 8),

                      // 📝 SUBTÍTULO
                      Text(
                        'Junte-se à comunidade Algarve Explorer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),

                      const SizedBox(height: 32),

                      // 🔗 BOTÃO GITHUB
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _handleGitHubLogin,
                          icon: const Icon(Icons.code, size: 20),
                          label: const Text(
                            'Continuar com GitHub',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 📍 DIVISOR "ou"
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: Color(0xFFE5E7EB),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'ou',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: Color(0xFFE5E7EB),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 📧 CAMPO EMAIL
                      _buildInputField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'seu@email.com',
                        isFocused: _focusedField == 'email',
                        onFocusChange: (isFocused) {
                          setState(() {
                            _focusedField = isFocused ? 'email' : null;
                          });
                        },
                        keyboardType: TextInputType.emailAddress,
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

                      const SizedBox(height: 16),

                      // 🔒 CAMPO PASSWORD (Mínimo 8 caracteres)
                      _buildInputField(
                        controller: _passwordController,
                        label: 'Palavra-passe',
                        hint: 'Mínimo 8 caracteres',
                        isFocused: _focusedField == 'password',
                        onFocusChange: (isFocused) {
                          setState(() {
                            _focusedField = isFocused ? 'password' : null;
                          });
                        },
                        obscureText: true,
                        validator: _validatePassword,
                      ),

                      const SizedBox(height: 16),

                      // 🔒 CAMPO CONFIRMAR PASSWORD
                      _buildInputField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar palavra-passe',
                        hint: 'Confirme a palavra-passe',
                        isFocused: _focusedField == 'confirmPassword',
                        onFocusChange: (isFocused) {
                          setState(() {
                            _focusedField =
                                isFocused ? 'confirmPassword' : null;
                          });
                        },
                        obscureText: true,
                        validator: _validateConfirmPassword,
                      ),

                      const SizedBox(height: 32),

                      // 🚀 BOTÃO CRIAR CONTA
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: _buildGradientButton(
                          text: 'Criar Conta',
                          onPressed: () => _handleCreateAccount(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔗 LOGIN LINK
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Já tem conta? ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: 'Faça login',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                // TODO: Implementar navegação para login
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget reutilizável para campos de input
  /// Inclui animação de focus com sombra e border azul
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isFocused,
    required Function(bool) onFocusChange,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: onFocusChange,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Sombra sutil quando em foco
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
              ),
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }

  /// Botão com gradiente azul - Criar Conta
  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primary, // #0066CC
              Color(0xFF0052A3), // Azul mais escuro
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
