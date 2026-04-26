# Regras do Algarve Explorer

## Design
- Cor primária: #0066CC (azul oceano)
- Cor secundária: #FF6B35 (laranja pôr-do-sol)
- Fonte: Usar a fonte padrão do Flutter (não inventar fontes novas)
- Bordas arredondadas: 12px (borderRadius: 12)
- Espaçamento padrão: 16px

## Código Flutter
- Usar StatelessWidget sempre que possível
- Nunca hardcode cores diretamente nos widgets — usar AppColors do app_constants.dart
- Campos de input devem ter validação simples
- Botões devem usar o CustomButton já criado

## Navegação
- Login → Home (quando autenticado)
- Home → Mapa → Lista → Detalhes