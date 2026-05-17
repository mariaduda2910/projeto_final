<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Status-Em%20Desenvolvimento-yellow?style=for-the-badge" />
  <img src="https://img.shields.io/badge/UAlg-2025%2F2026-blue?style=for-the-badge" />
</p>

<h1 align="center">🌊 Algarve Explorer</h1>
<p align="center"><i>O teu guia pessoal pelo Algarve, na palma da mão.</i></p>

---

## 📋 Índice

- [🎯 Visão Geral](#-visão-geral)
- [✨ Funcionalidades](#-funcionalidades)
- [🏗️ Arquitetura da Solução](#-arquitetura-da-solução)
- [🛠️ Tecnologias Utilizadas](#-tecnologias-utilizadas)
- [📦 Setup e Instalação](#-setup-e-instalação)
- [▶️ Como correr](#-como-correr)
- [🗄️ Persistência e Sincronização](#-persistência-e-sincronização)
- [📊 Modelo de Dados](#-modelo-de-dados)
- [📁 Estrutura do Projeto](#-estrutura-do-projeto)
- [👥 Equipa & Cronograma](#-equipa--cronograma)
- [📆 Prazos do Projeto](#-prazos-do-projeto)

---

## 🎯 Visão Geral

**Algarve Explorer** é uma aplicação móvel de apoio ao turismo local. Permite ao turista descobrir locais de interesse no Algarve, guardar favoritos e criar roteiros personalizados de viagem com cálculo automático de rotas reais.

### 💡 Ideia Central

O turista regista-se na app e tem acesso a três áreas principais:

| Área | Descrição |
|------|-----------|
| 🏠 **Início** | Resumo do roteiro ativo, favoritos rápidos, atalhos para criar roteiros |
| 🗺️ **Mapa** | Localização em tempo real, exploração de POIs por categoria, criação de rotas |
| 👤 **Perfil** | Dados do utilizador, estatísticas, definições e logout |

### 🎯 Foco do projeto

Esta primeira fase implementa o **módulo do turista** (B2C). Os módulos B2B (painel hoteleiro) e administrativo ficaram fora do âmbito.

---

## ✨ Funcionalidades

### 🔐 Autenticação
- Registo com email + password (validação ≥ 8 caracteres)
- Login com credenciais reais persistidas
- Logout com confirmação (em 3 sítios: AppBar, Perfil, Definições)
- Auto-login ao abrir a app (sessão de 7 dias)

### 🗺️ Mapa
- OpenStreetMap (gratuito, sem chave de API)
- GPS do utilizador com marcador próprio
- **10 categorias coloridas**: restaurantes, cafés, bares, hotéis, atrações, museus, supermercados, farmácias, praias, parques
- Pesquisa de POIs reais via **Geoapify Places API**
- Filtro "Aberto agora"
- Botão recentrar no utilizador

### ❤️ Favoritos
- Toggle ♥ em qualquer POI
- Sheet de favoritos no mapa
- Lista na Home com ícones por categoria
- Persistidos localmente + sincronizados com servidor

### 🛣️ Roteiros
- Modo de seleção múltipla de POIs no mapa
- Adicionar a roteiro existente ou criar novo
- Lista de roteiros + detalhe com paragens
- Marcar paragens como visitadas
- "Ver no Mapa" → traça rota seguindo **estradas reais** via Geoapify Routing
- Polyline numerada + cartão com distância e tempo estimado
- Ponto de partida = localização atual do utilizador

### 🔄 Sincronização
- **Offline-first** — tudo funciona sem internet
- Sincronização automática com JSON Server quando há rede
- Fila persistente de operações pendentes
- Retry automático ao detetar internet

---

## 🏗️ Arquitetura da Solução

A aplicação segue uma arquitetura em camadas:

```
┌──────────────────────────────────────────────────────────────┐
│                          UI (telas)                          │
└────────────────────────────┬─────────────────────────────────┘
                             │
              ┌──────────────┴──────────────┐
              ▼                             ▼
┌─────────────────────┐         ┌──────────────────────┐
│  Providers (estado) │         │   SyncProvider (UI)  │
│  Auth / Itinerary / │         │   online? pending?   │
│  Favorites / POI    │         │                      │
└──────────┬──────────┘         └──────────┬───────────┘
           │                               │
           ▼                               ▼
┌────────────────────┐         ┌──────────────────────┐
│  StorageService    │◀────────│   SyncService        │
│  SharedPreferences │  lê     │   (orquestrador)     │
│  (sempre primeiro) │  fila   │                      │
└────────────────────┘         └──────────┬───────────┘
                                          │
                          ┌───────────────┼───────────────┐
                          ▼                               ▼
              ┌────────────────────┐         ┌──────────────────────┐
              │   ApiService       │         │ ConnectivityService  │
              │   Dio → JSON Server│         │ connectivity_plus    │
              └────────────────────┘         └──────────────────────┘
```

### Princípios

1. **Offline-first** — a UI nunca espera pelo servidor; tudo é instantâneo via SharedPreferences
2. **Eventual consistency** — o servidor é uma cópia que se atualiza quando há rede
3. **Snapshot denormalization** — favoritos e paragens guardam cópia dos dados do POI (funciona offline)

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Finalidade |
|------------|------------|
| **Flutter + Dart** | Framework e linguagem base |
| **Provider** | Gestão de estado entre ecrãs |
| **Shared Preferences** | Persistência local (sessão, dados, fila offline) |
| **Geolocator** | Obtenção de latitude/longitude do dispositivo |
| **Flutter Map** | Renderização do mapa interativo |
| **OpenStreetMap** | Tiles do mapa (gratuito) |
| **Dio** | Cliente HTTP para Geoapify e JSON Server |
| **Connectivity Plus** | Deteção online/offline |
| **Flutter Dotenv** | Variáveis de ambiente (chaves de API) |
| **Url Launcher** | Abertura de links externos (Google Maps) |
| **Geoapify Places API** | Pesquisa de pontos de interesse reais |
| **Geoapify Routing API** | Cálculo de rotas reais por estrada |
| **JSON Server** | Backend "fake" local para sincronização |

---

## 📦 Setup e Instalação

### Pré-requisitos

- **Flutter SDK** ≥ 3.0 ([instalar](https://docs.flutter.dev/get-started/install))
- **Node.js** ≥ 18 ([instalar](https://nodejs.org)) — apenas para o JSON Server
- **Chave da Geoapify** (gratuita em [geoapify.com](https://geoapify.com))

### 1. Clonar o projeto

```bash
git clone <https://github.com/mariaduda2910/projeto_final.git>
cd projeto_final_flutter
```

### 2. Configurar variáveis de ambiente

Cria um ficheiro `.env` na raiz do projeto:

```env
GEOAPIFY_API_KEY=555f1e7ee9cb4908babba56e80d5c48e
API_BASE_URL=http://localhost:3000
```

> ⚠️ **Atenção ao `localhost` consoante onde corres a app:**
>
> | Onde corre a app | `API_BASE_URL` |
> |------------------|----------------|
> | Chrome no mesmo PC | `http://localhost:3000` |
> | Emulador Android | `http://10.0.2.2:3000` |
> | Telemóvel real (mesma WiFi) | `http://192.168.X.X:3000` |

### 3. Instalar dependências Flutter

```bash
flutter pub get
```

### 4. Instalar o JSON Server 

```bash
npm install -g json-server
```

---

## Como correr

### Arrancar o backend local (JSON Server)

Num terminal, a partir da raiz do projeto:

```bash
json-server --watch server/db.json --port 3000
```

Deves ver:

```
Resources
  http://localhost:3000/users
  http://localhost:3000/favoritos
  http://localhost:3000/roteiros
  http://localhost:3000/rotasPartilhadas
```

**Deixa este terminal aberto.**

### Arrancar a app Flutter

Noutro terminal:

```bash
# Web (Chrome)
flutter run -d chrome

# Android
flutter run -d <device-id>

# Listar dispositivos disponíveis
flutter devices
```

### Endpoints disponíveis

| Método | URL | O que faz |
|--------|-----|-----------|
| GET | `/users` | Lista todos os utilizadores |
| GET | `/users?email=x@y.pt` | Filtra por email |
| POST | `/users` | Cria utilizador novo |
| PATCH | `/users/:id` | Atualiza utilizador |
| DELETE | `/users/:id` | Apaga utilizador |
| _(mesmo padrão para `/favoritos`, `/roteiros`, `/rotasPartilhadas`)_ | | |

---

## 🗄️ Persistência e Sincronização

### Tecnologias usadas
_____________________________________________________________________________________________________________
| Camada               | Tecnologia                | Propósito                                              |
|----------------------|---------------------------|--------------------------------------------------------|
| **Local (rápida)**   | SharedPreferences         | Dados do utilizador, fila de sync, favoritos, roteiros |
| **Servidor "fake"**  | JSON Server (`db.json`)   | Simula sincronização cloud para partilha de dados      |
| **POIs externos**    | Geoapify Places + Routing | Pontos de interesse e rotas reais                      |
-------------------------------------------------------------------------------------------------------------

### Como funciona a sincronização

1. **Utilizador faz uma ação** (criar conta, favoritar, criar roteiro)
2. **Guarda imediatamente** no SharedPreferences (instantâneo)
3. **Enfileira operação** no `SyncService`
4. **Se há internet**: envia para o JSON Server logo
5. **Se está offline**: fica na fila persistente
6. Quando o `connectivity_plus` deteta volta de internet → processa fila


## 📊 Modelo de Dados

Quatro coleções no `db.json`:

```json
{
  "users": [],
  "favoritos": [],
  "roteiros": [],
  "rotasPartilhadas": []
}
```

### Entidade: `Utilizador`

| Campo | Tipo | Obrigatório |
|-------|------|-------------|
| id | string | ✅ |
| email | string | ✅ |
| password | string | ✅ |
| nome | string | ✅ |
| dataRegisto | ISO date | ✅ |
| dataExpiracao | ISO date | ❌ |
| idiomaPreferido | string | ❌ (default "pt") |

### Entidade: `Favorito`

| Campo | Tipo | Obrigatório |
|-------|------|-------------|
| id | string | ✅ |
| userId | string | ✅ |
| poiId | string | ✅ |
| nome, latitude, longitude | string/number | ✅ |
| endereco, categoria | string | ❌ |
| adicionadoEm | ISO date | ✅ |

### Entidade: `Roteiro` (com paragens embebidas)

| Campo | Tipo | Obrigatório |
|-------|------|-------------|
| id | string | ✅ |
| userId | string | ✅ |
| titulo | string | ✅ |
| dataInicio, dataFim | ISO date | ✅ |
| eventos (array de paragens) | array | ✅ |
| ativo, partilhado | boolean | ✅ |

**Cada paragem dentro de `eventos`:**

| Campo | Tipo | Obrigatório |
|-------|------|-------------|
| id, poiId, nome | string | ✅ |
| latitude, longitude | number | ✅ |
| ordem | number | ✅ |
| visitado | boolean | ✅ |
| periodo, notas, dataHora | string | ❌ |

---

## 📁 Estrutura do Projeto

```
projeto_final_flutter/
├── lib/
│   ├── main.dart                   # Arranque + init de serviços
│   ├── app.dart                    # MultiProvider + MaterialApp
│   ├── routes.dart                 # Rotas nomeadas
│   │
│   ├── core/
│   │   ├── constants/              # Cores, strings, espaçamentos
│   │   ├── theme/                  # AppTheme global
│   │   └── utils/                  # Helpers, validators, formatters
│   │
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── session_model.dart
│   │   ├── poi_model.dart
│   │   ├── favorite_poi_model.dart
│   │   ├── itinerary_model.dart    # com eventos embebidos
│   │   ├── itinerary_event_model.dart
│   │   ├── itinerary_attachment_model.dart
│   │   └── route_result_model.dart # resposta Geoapify Routing
│   │
│   ├── services/
│   │   ├── api_service.dart        # cliente Dio → JSON Server
│   │   ├── auth_service.dart       # login, registo, sessão
│   │   ├── storage_service.dart    # SharedPreferences wrapper
│   │   ├── sync_service.dart       # orquestrador offline-first
│   │   ├── connectivity_service.dart # online/offline detection
│   │   ├── geoapify_service.dart   # Places + Details + Routing
│   │   └── location_service.dart   # GPS
│   │
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── favorites_provider.dart
│   │   ├── itinerary_provider.dart
│   │   ├── location_provider.dart
│   │   ├── poi_provider.dart
│   │   └── sync_provider.dart
│   │
│   ├── views/
│   │   ├── login/                  # LoginScreen + RegisterModal
│   │   ├── home/                   # HomeScreen
│   │   ├── map/                    # PoiExplorerScreen (principal)
│   │   ├── detail/                 # DetailScreen
│   │   ├── itinerary/              # lista + detalhe de roteiros
│   │   ├── profile/                # ProfileScreen
│   │   └── settings/               # SettingsScreen
│   │
│   └── widgets/
│       ├── shell_layout.dart       # Layout com tabs Início/Mapa/Perfil
│       ├── custom_app_bar.dart
│       ├── poi_card.dart, poi_marker.dart
│       ├── map/                    # widgets do mapa (rota, info)
│       ├── itinerary/              # widgets de roteiros
│       ├── detail/                 # widgets de detalhe do POI
│       └── home/                   # widgets da home
│
├── server/
│   └── db.json                     # base de dados local (JSON Server)
│
├── licenses/                       # licenças de terceiros
├── proposta_inicial.md             # proposta original do projeto
├── pubspec.yaml
├── .env                            # chaves de API (não commitado)
└── README.md                       # este ficheiro
```

---

## 👥 Equipa & Cronograma

| Membro | Responsabilidade |
|--------|------------------|
| **Laura** — *Frontend & UX* | Ecrã de login, navegação, mapa, componentes visuais dos cartões |
| **Maria** — *Lógica & Dados* | Gestão de sessão, autenticação, geolocalização, persistência, sincronização com JSON Server |
| **Ambas** | Definição de requisitos, testes, documentação |

### Cronograma

| Semana | Entregável |
|--------|------------|
| **Semana 1** | Definição do conceito, personas, funcionalidades e divisão de tarefas |
| **Semana 2** | Protótipos visuais, wireframes e fluxo de navegação |
| **Semana 3** | Login, sessão do utilizador e persistência local |
| **Semana 4** | Geolocalização e mapa com pontos turísticos |
| **Semana 5** | Listagem por proximidade, criação de roteiros, sincronização com servidor |
| **Semana 6** | Testes, correções, melhorias visuais e finalização da documentação |

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

## 🚀 Roadmap Futuro

- [ ] Painel web de administração (B2B para hotéis)
- [ ] Módulo de cliente empresarial (white-label / branding personalizado)
- [ ] Hash de passwords (bcrypt/Argon2) — atualmente texto simples (académico)
- [ ] Modo escuro funcional
- [ ] Multi-idioma efetivo (5 línguas já preparadas)
- [ ] Notificações push geolocalizadas
- [ ] Rotas partilhadas anonimamente entre utilizadores
- [ ] Sistema de avaliações e comentários

---

<p align="center">
  <b>Desenvolvido com 💙 no Algarve</b><br>
  <i>Universidade do Algarve — 2025/2026</i>
</p>
