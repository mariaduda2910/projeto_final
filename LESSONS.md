# 🎓 Algarve Explorer — Aulas de Arquitetura e Dados

> Documento de referência criado durante a fase de planeamento.
> Resume as decisões tomadas para que possas voltar a consultar mais tarde.

---

## 📚 Aula 1 — Descrever a app

### Resposta às 4 perguntas

**1. O que a app faz, numa frase:**
> É uma app para o turista conseguir criar rotas e visualizar rotas já trilhadas de outros utilizadores.

**2. Atores:**
| Ator | Papel |
|------|-------|
| Turista (B2C) | Utilizador principal — cria conta, faz tudo |
| Hotel (B2B) | _Considerado mas excluído_ — fluxo de criação por hotéis não implementado |

**3. 5 ações principais:**
1. Selecionar lugares preferidos
2. Criar rotas
3. Visualizar rotas de outros turistas
4. Ver detalhes dos estabelecimentos
5. Logar

**4. O que a app NÃO é:**
- ❌ Não acompanha o turista em tempo real (não é Google Maps Navigation)
- ❌ Não faz recomendações
- ❌ Não conecta turistas entre si (sem chat, perfis públicos)
- ❌ Não mostra locais fora da zona atual do turista

### Decisões importantes

**Modelo de partilha de rotas: A — Anónimo agregado**
> Vês rotas mas não vês quem fez. Apresentadas como "Rota popular pelo Algarve". Sem perfis, sem nomes, sem interação social.

**Modelo de criação de contas: C — Só auto-registo**
> Qualquer pessoa cria a sua própria conta. O fluxo B2B do hotel foi excluído.

---

## 📚 Aula 2 — Entidades de dados

### Entidades descobertas a partir dos substantivos das ações

| # | Entidade | De onde veio | Onde vive |
|---|----------|--------------|-----------|
| 1 | **Utilizador** | "logar" | 🏠 nossa BD (`N`) |
| 2 | **Lugar / POI** | "lugares preferidos", "estabelecimentos" | 🌍 Geoapify (`E`) |
| 3 | **Favorito** | "lugares preferidos" (relação) | 🏠 nossa BD (`N`) |
| 4 | **Roteiro (plano)** | "criar rotas" | 🏠 nossa BD (`N`) |
| 5 | **Paragem** | implícito — parte do roteiro | 🏠 nossa BD (`N`) |
| 6 | **Rota partilhada** | "ver rotas de outros" | 🏠 nossa BD (`N`) |
| 7 | **Polyline (cálculo)** | derivado | 🌍 Geoapify Routing (`E`) |

### Insight chave

> "Rota" tem dois significados: o **plano** (decisão do utilizador, vive na nossa BD) vs a **polyline** (cálculo da Geoapify, on-demand, não persistimos).

### Decisões sobre Favoritos e Paragens

**Snapshot completo** (Opção 2) — guardamos uma cópia dos dados do POI (nome, lat, lng, categoria) em vez de só o ID.
- ✅ Funciona offline
- ✅ Não quebra se o POI desaparecer da Geoapify
- ❌ Pequena duplicação de dados (aceitável)

---

## 📚 Aula 3 — Especificar campos por entidade

### Entidade: `Utilizador`

| Campo | Tipo | Obrigatório? |
|-------|------|--------------|
| id | string | ✅ |
| email | string | ✅ |
| password | string | ✅ |
| nome | string | ✅ |
| dataRegisto | string (ISO date) | ✅ |
| dataExpiracao | string (ISO date) | ❌ |
| idiomaPreferido | string | ❌ (default "pt") |

### Entidade: `Favorito`

| Campo | Tipo | Obrigatório? |
|-------|------|--------------|
| id | string | ✅ |
| userId | string | ✅ |
| poiId | string | ✅ |
| nome | string | ✅ |
| latitude | number | ✅ |
| longitude | number | ✅ |
| endereco | string | ❌ |
| categoria | string | ❌ |
| adicionadoEm | string (ISO date) | ✅ |

### Entidade: `Roteiro` (com paragens embebidas)

| Campo | Tipo | Obrigatório? |
|-------|------|--------------|
| id | string | ✅ |
| userId | string | ✅ |
| titulo | string | ✅ |
| descricao | string | ❌ |
| dataInicio | string (ISO date) | ✅ |
| dataFim | string (ISO date) | ✅ |
| criadoEm | string (ISO date) | ✅ |
| ativo | boolean | ✅ |
| partilhado | boolean | ✅ |
| paragens | array | ✅ |

**Cada paragem dentro de `paragens`:**

| Campo | Tipo | Obrigatório? |
|-------|------|--------------|
| id | string | ✅ |
| poiId | string | ✅ |
| nome | string | ✅ |
| latitude | number | ✅ |
| longitude | number | ✅ |
| endereco | string | ❌ |
| categoria | string | ❌ |
| ordem | number | ✅ |
| periodo | string | ❌ ("manha"/"tarde"/"noite") |
| dataHora | string (ISO date) | ❌ |
| visitado | boolean | ✅ |
| notas | string | ❌ |

### Entidade: `RotaPartilhada` (anónima)

| Campo | Tipo | Obrigatório? |
|-------|------|--------------|
| id | string | ✅ |
| regiao | string | ✅ |
| centroLatitude | number | ✅ |
| centroLongitude | number | ✅ |
| titulo | string | ❌ |
| paragens | array (versão "magra") | ✅ |
| partilhadoEm | string (ISO date) | ✅ |

**Paragem na rota partilhada (sem dados pessoais):**

| Campo | Tipo | Obrigatório? |
|-------|------|--------------|
| poiId | string | ✅ |
| nome | string | ✅ |
| latitude | number | ✅ |
| longitude | number | ✅ |
| categoria | string | ❌ |
| ordem | number | ✅ |

---

## 🏗️ Arquitetura de persistência

### Camadas

```
┌──────────────────────────────────────────────────────────────┐
│                          UI (telas)                          │
└────────────────────────────┬─────────────────────────────────┘
                             │
              ┌──────────────┴──────────────┐
              ▼                             ▼
┌─────────────────────┐         ┌──────────────────────┐
│  Providers (estado) │         │  SyncProvider (UI)   │
│  Itinerary / Fav    │         │  online? pending?    │
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
3. **Snapshot denormalization** — favoritos e paragens guardam cópia dos dados do POI

---

## 🌐 JSON Server — onde fica o quê

### Estrutura do `db.json`

```json
{
  "users": [],
  "favoritos": [],
  "roteiros": [],
  "rotasPartilhadas": []
}
```

### Endpoints automáticos

| Endpoint | O que faz |
|----------|-----------|
| `GET /users` | Lista todos os utilizadores |
| `GET /users?email=x@y.pt` | Filtra por email |
| `POST /users` | Cria novo utilizador |
| `PUT /users/:id` | Atualiza utilizador |
| `DELETE /users/:id` | Apaga utilizador |
| _(mesmo padrão para `/favoritos`, `/roteiros`, `/rotasPartilhadas`)_ | |

---

## 🧠 Glossário (termos que apareceram)

| Termo | O que é |
|-------|---------|
| **Entidade** | "Coisa" do mundo real que tem identidade própria (Utilizador, Roteiro...) |
| **Atributo / Campo** | Característica de uma entidade (nome, email...) |
| **Snapshot** | Cópia dos dados de uma entidade num momento, guardada noutra para não depender da original |
| **Denormalização** | Duplicar dados intencionalmente para evitar joins/pedidos extra |
| **Normalização** | Guardar cada dado num único sítio (só ID, depois faz lookup) |
| **Embebido** | Dados aninhados dentro de outro (paragens dentro do roteiro) |
| **Offline-first** | A app funciona sempre, com ou sem internet; sincroniza quando puder |
| **Sync** | Sincronizar dados locais com servidor |
| **Pending queue** | Fila de operações por enviar ao servidor (quando estavas offline) |
| **REST** | Estilo de API onde cada recurso tem URL e ações via verbos HTTP |
| **JSON Server** | Ferramenta que transforma um ficheiro JSON num REST API automaticamente |
| **CORS** | Restrição de browser que impede chamadas a domínios diferentes (resolvido pelo JSON Server) |

---

## ✅ Estado atual da implementação

- [x] Plano de dados definido (Aulas 1-3)
- [x] `UserModel` alinhado com a entidade
- [x] `StorageService` regista com `id` e `dataRegisto`
- [x] **JSON Server configurado** (`server/db.json` + `server/README.md`)
- [x] **`ApiService`** — Dio wrapper para JSON Server
- [x] **`ConnectivityService`** — deteção online/offline
- [x] **`SyncService`** — orquestra sync local ↔ servidor
- [x] **`AuthService`** envia novos utilizadores ao servidor após registo

## 🔜 Próximos passos sugeridos

- [ ] Aula 4 — Alinhar `Favorito` e `Roteiro` com a entidade (rever campos)
- [ ] Aula 5 — Relações + queries (como pedir "roteiros do user X" ao servidor)
- [ ] Sincronizar Favoritos e Roteiros (atualmente só Users)
- [ ] Implementar "pull" do servidor ao arrancar (multi-dispositivo)
- [ ] UI: indicador visual de "online / a sincronizar / offline"
