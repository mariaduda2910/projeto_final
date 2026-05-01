import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import 'register_modal.dart';

/// Tela de Login - Algarve Explorer
/// 
/// Design baseado em Figma com as seguintes características:
/// - Logo original: onda em círculo com gradiente azul
/// - Campos com focus animados (border azul + sombra)
/// - Botão com gradiente linear
/// - Animações de entrada (fade + slide)
/// - Pontos decorativos pulsantes na base
/// - Link para criar conta (abre RegisterModal)
/// 
/// Integração:
/// - Provider para autenticação (AuthProvider)
/// - Validação de email e password
/// - Navegação automática para /home ao fazer login com sucesso
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  
  // ============ CONTROLADORES ============
  /// GlobalKey para validação do formulário
  final _formKey = GlobalKey<FormState>();
  
  /// Controlador para o campo de email
  final _emailController = TextEditingController();
  
  /// Controlador para o campo de password
  final _passwordController = TextEditingController();

  // ============ ANIMAÇÕES ============
  /// Controlador para animação de entrada da tela (fade + slide)
  late AnimationController _fadeController;
  
  /// Animation: Fade da tela (0 -> 1)
  late Animation<double> _fadeAnimation;
  
  /// Estado do campo focado (email | password | null)
  /// Usado para animar a sombra azul no field
  String? _focusedField;

  @override
  void initState() {
    super.initState();
    
    // Animação de entrada: fade suave (800ms) com curva easeOut
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    // Inicia a animação
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Função para fazer login
  /// - Valida o formulário
  /// - Chama AuthProvider.login() com email e password
  /// - Se sucesso: navega para /home
  /// - Se erro: exibe erro no AuthProvider
  Future<void> _fazerLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final sucesso = await context.read<AuthProvider>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      
      if (sucesso && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_fadeAnimation),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      
                      // 🌊 ONDA ANIMADA COM GRADIENTE (logo original)
                      _buildWaveIcon(),
                      
                      const SizedBox(height: 48),
                      
                      // 🏷️ TÍTULO
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // ✨ SUBTÍTULO
                      Text(
                        'Descubra o paraíso costeiro',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 0.3,
                            ),
                      ),
                      
                      const SizedBox(height: 48),
                      
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
                      
                      const SizedBox(height: 24),
                      
                      // 🔒 CAMPO PASSWORD
                      _buildInputField(
                        controller: _passwordController,
                        label: 'Palavra-passe',
                        hint: '••••••••',
                        isFocused: _focusedField == 'password',
                        onFocusChange: (isFocused) {
                          setState(() {
                            _focusedField = isFocused ? 'password' : null;
                          });
                        },
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 4) {
                            return 'Mínimo 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // 🔗 ESQUECI-ME DA PASSWORD
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Funcionalidade em desenvolvimento'),
                              ),
                            );
                          },
                          child: Text(
                            'Esqueci-me da palavra-passe',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // ⚠️ MENSAGEM DE ERRO
                      if (auth.error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.error!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // 🚀 BOTÃO ENTRAR
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: _buildGradientButton(
                          text: 'Entrar',
                          isLoading: auth.isLoading,
                          onPressed: _fazerLogin,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 🔗 CRIAR CONTA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ainda não tem conta? ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Abre o modal de registro
                              showDialog(
                                context: context,
                                builder: (context) => RegisterModal(
                                  onClose: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                            child: Text(
                              'Criar conta',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 🌊 DECORAÇÃO INFERIOR
                      _buildDecorativeDots(),
                      
                      const SizedBox(height: 24),
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

  // 🌊 ONDA ANIMADA COM GRADIENTE (logo original)
  /// Logo animado: Círculo com ícone de onda
  /// 
  /// Features:
  /// - Tamanho: 100x100 pixels
  /// - Gradiente diagonal: azul oceano (#0066CC) -> azul mais claro (#4A90D9)
  /// - Sombra drop: 20px blur com offset (0, 8)
  /// - Ícone: Icons.waves (branco, tamanho 48)
  /// - Shape: CircleShape
  Widget _buildWaveIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF4A90D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.waves,
        color: Colors.white,
        size: 48,
      ),
    );
  }

  // 📧 CAMPO DE INPUT COM ANIMAÇÃO DE FOCUS
  /// Widget reutilizável para campos de input (email, password, etc)
  /// 
  /// Features:
  /// - Focus animado com sombra azul sutil
  /// - Border 2px que muda de cor ao fazer focus
  /// - Validação em tempo real (através do validator)
  /// - Suporte a campos obscurecidos (password)
  /// - BorderRadius: 16px (arredondado)
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

  // 🚀 BOTÃO COM GRADIENTE
  /// Botão customizado com gradiente linear azul
  /// 
  /// Features:
  /// - Gradiente: #0066CC -> #0052A3 (diagonal)
  /// - Sombra drop: cor primária com 40% opacidade
  /// - BorderRadius: 16px
  /// - Loader circular quando isLoading=true
  /// - Efeito ripple ao clicar
  Widget _buildGradientButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              Color(0xFF0052A3),
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
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
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

  // 🔵 PONTOS DECORATIVOS ANIMADOS
  /// Linha de 3 pontos na base da tela
  /// Cada ponto tem:
  /// - Animação de scale (1.0 -> 1.2 -> 1.0)
  /// - Animação de opacity (0.3 -> 0.6 -> 0.3)
  /// - Delay incremental para efeito "onda"
  /// - Duração total: 2 segundos
  Widget _buildDecorativeDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => _AnimatedDot(delay: index * 300),
      ),
    );
  }
}

// 🔵 WIDGET PONTO ANIMADO
/// Ponto decorativo inferior que pulsa com animação suave
/// 
/// Propósito:
/// - Criar efeito visual decorativo na base da login screen
/// - Indicar que há conteúdo/movimento na página
/// - Delay permite sincronizar múltiplos pontos com efeito "onda"
/// 
/// Animação:
/// - Scale: 1.0 -> 1.2 -> 1.0 (usando sin)
/// - Opacity: 0.3 -> 0.6 -> 0.3 (usando sin)
/// - Duração: 2 segundos por ciclo
/// - Repeat: infinito
class _AnimatedDot extends StatefulWidget {
  final int delay;

  const _AnimatedDot({required this.delay});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

/// Estado para o widget _AnimatedDot
/// Gerencia a animação de pulsação contínua com delay
/// 
/// Lifecycle:
/// 1. initState: Cria AnimationController
/// 2. Future.delayed: Aguarda `widget.delay` milissegundos
/// 3. _animationController.repeat(): Inicia animação infinita
/// 4. dispose: Limpa o controller
class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Delay antes de iniciar a animação (para efeito de onda)
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _animationController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Calcula scale e opacity usando função sin para movimento suave
        final scale = 1 + (sin(_animationController.value * 2 * 3.14159) * 0.2);
        final opacity = 0.3 + (sin(_animationController.value * 2 * 3.14159) * 0.3);
        
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
