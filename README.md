&lt;p align="center"&gt;
  &lt;img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" /&gt;
  &lt;img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" /&gt;
  &lt;img src="https://img.shields.io/badge/Status-Em%20Desenvolvimento-yellow?style=for-the-badge" /&gt;
  &lt;img src="https://img.shields.io/badge/UAlg-2025%2F2026-blue?style=for-the-badge" /&gt;
&lt;/p&gt;

&lt;h1 align="center"&gt;🌊 Algarve Explorer&lt;/h1&gt;
&lt;p align="center"&gt;&lt;i&gt;O teu guia pessoal pelo Algarve, na palma da mão.&lt;/i&gt;&lt;/p&gt;

---

## 📋 Índice

- [🎯 Visão Geral](#-visão-geral)
- [🏗️ Arquitetura da Solução](#-arquitetura-da-solução)
- [✨ Funcionalidades](#-funcionalidades)
- [🛠️ Tecnologias Utilizadas](#-tecnologias-utilizadas)
- [📁 Estrutura do Projeto](#-estrutura-do-projeto)
- [👥 Equipa & Divisão de Tarefas](#-equipa--divisão-de-tarefas)
- [📅 Cronograma](#-cronograma)
- [⚠️ Desafios Técnicos Previstos](#-desafios-técnicos-previstos)
- [🚀 Roadmap Futuro](#-roadmap-futuro)
- [📆 Prazos do Projeto](#-prazos-do-projeto)

---

## 🎯 Visão Geral

**Algarve Explorer** é uma aplicação móvel de apoio ao turismo local, concebida como solução **B2B2C**. A plataforma é comercializada a empresas do setor turístico (hotéis, restaurantes, guias, empresas de animação), que a disponibilizam aos seus clientes finais — os turistas.

&gt; **Nota:** Nesta primeira fase, o desenvolvimento foca-se exclusivamente no **módulo do turista**, mantendo uma visão escalável para integração futura dos painéis de administração e cliente empresarial.

### 💡 Ideia Central

O turista acede à app com credenciais temporárias fornecidas pelo parceiro comercial. Após o login, explora três áreas principais:

| Área | Descrição |
|------|-----------|
| 🏠 **Home / Merchandising** | Identidade visual do parceiro, boas-vindas e promoções |
| 🗺️ **Mapa** | Localização em tempo real e pontos turísticos próximos |
| 📋 **Listagem** | Locais ordenados por proximidade e estado de funcionamento |

---

## 🏗️ Arquitetura da Solução

A aplicação segue uma arquitetura em três camadas simples e desacoplada:
┌─────────────────────────────────────┐
│      🎨 Camada de Interface         │
│   Ecrãs, widgets, navegação, UI     │
├─────────────────────────────────────┤
│      🧠 Camada Lógica               │
│   Auth, geolocalização, filtragem,  │
│   ordenação, gestão de estado       │
├─────────────────────────────────────┤
│      💾 Camada de Dados             │
│   API REST, cache local, sessão     │
└─────────────────────────────────────┘

### Modelo Funcional
Entrada:        email + password do turista
↓
Processamento:  validação da sessão
verificação do prazo de utilização
leitura da localização atual
carregamento e ordenação dos pontos turísticos
↓
Saída:          mapa interativo com pontos próximos
lista ordenada de locais
página promocional do parceiro
plain


---

## ✨ Funcionalidades

| Funcionalidade | Descrição | Estado |
|----------------|-----------|--------|
| 🔐 **Autenticação Temporária** | Login com validade temporal (ex: 3 dias, 1 semana) | ✅ Implementar |
| 📍 **Geolocalização** | Localização em tempo real do turista | ✅ Implementar |
| 🗺️ **Mapa Interativo** | Visualização de pontos turísticos com marcadores | ✅ Implementar |
| 📋 **Listagem Inteligente** | Ordenação por proximidade e estado (aberto/fechado) | ✅ Implementar |
| 🛣️ **Roteiro Personalizado** | Seleção múltipla de pontos com ordenação por proximidade | ✅ Implementar |
| 💾 **Persistência Local** | Cache de sessão, preferências e dados offline | ✅ Implementar |
| 🔔 **Notificações Locais** | Alertas de proximidade e expiração de acesso | 🔮 Futuro |
| 🔗 **Integração OAuth2** | Autenticação segura com renovação automática de tokens | 🔮 Futuro |

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Finalidade |
|------------|------------|
| **Flutter + Dart** | Framework e linguagem base |
| **Provider** | Gestão de estado entre ecrãs |
| **Shared Preferences** | Persistência local simples (sessão, configurações) |
| **Geolocator** | Obtenção de latitude/longitude do dispositivo |
| **Flutter Map** | Renderização de mapas interativos |
| **HTTP / Dio** | Comunicação com API REST |
| **Flutter Local Notifications** | Notificações locais (opcional) |

> **Backend (conceitual/futuro):** Python + FastAPI + OAuth2

---

## 📁 Estrutura do Projeto

Aqui está a árvore de arquivos proposta para manter o projeto organizado e escalável:

algarve_explorer/
├── android/                    # Configurações Android
├── ios/                        # Configurações iOS
├── lib/
│   ├── main.dart               # Ponto de entrada da aplicação
│   │
│   ├── app.dart                # MaterialApp, rotas e tema
│   │
│   ├── core/                   # Núcleo da aplicação
│   │   ├── constants/          # Cores, strings, endpoints
│   │   ├── theme/              # Tema global (light/dark)
│   │   └── utils/              # Helpers, formatadores, cálculos de distância
│   │
│   ├── models/                 # Classes de dados (POJOs)
│   │   ├── user_model.dart
│   │   ├── poi_model.dart      # Point of Interest
│   │   ├── partner_model.dart
│   │   └── session_model.dart
│   │
│   ├── services/               # Camada de dados e APIs
│   │   ├── api_service.dart    # HTTP/Dio client
│   │   ├── auth_service.dart   # Login, logout, validação
│   │   ├── location_service.dart
│   │   └── storage_service.dart # SharedPreferences wrapper
│   │
│   ├── providers/              # Gestão de estado (Provider)
│   │   ├── auth_provider.dart
│   │   ├── location_provider.dart
│   │   └── poi_provider.dart
│   │
│   ├── views/                  # Ecrãs / Páginas
│   │   ├── login/
│   │   │   └── login_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── map/
│   │   │   └── map_screen.dart
│   │   ├── list/
│   │   │   └── list_screen.dart
│   │   └── detail/
│   │       └── detail_screen.dart
│   │
│   ├── widgets/                # Componentes reutilizáveis
│   │   ├── poi_card.dart
│   │   ├── poi_marker.dart
│   │   ├── custom_button.dart
│   │   └── loading_indicator.dart
│   │
│   └── routes.dart             # Definição centralizada de rotas
│
├── assets/
│   ├── images/                 # Logótipos, imagens de parceiros
│   └── fonts/                  # Tipografias personalizadas
│
├── test/                       # Testes unitários e widgets
├── pubspec.yaml
└── README.md


---

## 👥 Equipa & Divisão de Tarefas

| Membro | Responsabilidade |
|--------|------------------|
| **Laura** — *Frontend & UX* | Ecrã de login, página de merchandising, navegação, layout do mapa/lista, componentes visuais dos cartões |
| **Maria** — *Lógica & Dados* | Gestão de sessão, validação de acesso, geolocalização, obtenção de POIs, persistência local, integração/simulação de API |
| **Ambas** | Definição de requisitos, testes, documentação, apresentação |

---

## 📅 Cronograma

| Semana | Entregável |
|--------|------------|
| **Semana 1** | Definição do conceito, personas, funcionalidades e divisão de tarefas |
| **Semana 2** | Protótipos visuais, wireframes e fluxo de navegação |
| **Semana 3** | Implementação do login, sessão do utilizador e persistência local |
| **Semana 4** | Integração da geolocalização e mapa com pontos turísticos |
| **Semana 5** | Listagem por proximidade, estado de abertura e roteiro |
| **Semana 6** | Testes, correções, melhorias visuais e finalização da documentação |

---

## ⚠️ Desafios Técnicos Previstos

- **Precisão da geolocalização** em zonas com fraca cobertura GPS
- **Cálculo de distância** em tempo real sem sobrecarregar a UI
- **Sincronização offline/online** dos pontos turísticos
- **Validação temporal robusta** da sessão do utilizador
- **Performance do mapa** com muitos marcadores simultâneos

---

## 🚀 Roadmap Futuro

- [ ] Painel web de administração (Python + FastAPI)
- [ ] Módulo de cliente empresarial (white-label / branding personalizado)
- [ ] Fluxo completo OAuth2 com renovação automática de tokens
- [ ] Sistema de avaliações e comentários dos pontos turísticos
- [ ] Notificações push geolocalizadas ("Estás perto da Praia da Marinha!")
- [ ] Suporte a múltiplos idiomas

---

## 📆 Prazos do Projeto

| Marco | Data |
|-------|------|
| 📋 Apresentação da Proposta | 17/04/2026 |
| ✅ Check Point 1 | 24/04/2026 |
| ✅ Check Point 2 | 11/05/2026 |
| 🏁 **Entrega Final** | **18/05/2026** |
| 🎤 **Apresentação Final** | **29/05/2026** |

---

<p align="center">
  <b>Desenvolvido com 💙 no Algarve</b><br>
  <i>Universidade do Algarve — 2025/2026</i>
</p>