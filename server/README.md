# 🗄️ JSON Server — Backend local da Algarve Explorer

Esta pasta contém o "servidor" da app. É só um **ficheiro JSON** (`db.json`) que o `json-server` expõe como uma REST API.

---

## 📦 Instalação (só na primeira vez)

Precisas de **Node.js** instalado. Verifica com:

```bash
node --version
npm --version
```

Se não tiveres, instala em [nodejs.org](https://nodejs.org).

Depois instala o `json-server` globalmente:

```bash
npm install -g json-server
```

---

## ▶️ Como correr

A partir desta pasta (`server/`):

```bash
json-server --watch db.json --port 3000
```

Se preferires correr da raiz do projeto:

```bash
json-server --watch server/db.json --port 3000
```

Vais ver algo tipo:

```
\{^_^}/ hi!

Loading db.json
Done

Resources
  http://localhost:3000/users
  http://localhost:3000/favoritos
  http://localhost:3000/roteiros
  http://localhost:3000/rotasPartilhadas

Home
  http://localhost:3000
```

**Deixa este terminal aberto** enquanto desenvolves. O servidor está a correr.

---

## 🔗 Configurar a app Flutter

A app lê a URL do servidor do ficheiro `.env` na raiz do projeto. Adiciona esta linha:

```env
GEOAPIFY_API_KEY=a_tua_chave
API_BASE_URL=http://localhost:3000
```

**⚠️ Atenção ao "localhost" consoante onde corres a app:**

| Onde corre a app | `API_BASE_URL` |
|------------------|----------------|
| Chrome no mesmo PC | `http://localhost:3000` |
| Emulador Android | `http://10.0.2.2:3000` |
| Telemóvel real (mesma WiFi) | `http://192.168.X.X:3000` (vê o IP do PC com `ipconfig`) |

---

## 🧪 Testar manualmente

Com o servidor a correr, abre no browser:

- `http://localhost:3000/users` → vê todos os utilizadores
- `http://localhost:3000/users?email=maria@brasfone.pt` → filtrar por campo

Ou com `curl`:

```bash
# Criar um utilizador manualmente
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"id":"user_999","email":"teste@x.pt","nome":"Teste","password":"12345"}'

# Apagar um utilizador
curl -X DELETE http://localhost:3000/users/user_999
```

---

## 📋 Endpoints disponíveis

| Método | URL | O que faz |
|--------|-----|-----------|
| GET | `/users` | Lista todos os utilizadores |
| GET | `/users?email=x@y.pt` | Filtra por email |
| GET | `/users/:id` | Vê um utilizador |
| POST | `/users` | Cria utilizador novo |
| PUT | `/users/:id` | Substitui utilizador |
| PATCH | `/users/:id` | Atualiza parcialmente |
| DELETE | `/users/:id` | Apaga utilizador |
| _(mesmo padrão para `/favoritos`, `/roteiros`, `/rotasPartilhadas`)_ | | |

Filtros úteis: `?_sort=criadoEm&_order=desc&_limit=10`

---

## 🗂️ Estrutura do `db.json`

Quatro coleções, como definido nas aulas:

```json
{
  "users": [],
  "favoritos": [],
  "roteiros": [],
  "rotasPartilhadas": []
}
```

Cada vez que a app fizer `POST`, o `json-server` **escreve o ficheiro `db.json`** automaticamente. Podes abri-lo num editor para veres os dados a aparecerem em tempo real.

---

## 🛟 Resolução de problemas

**"Port 3000 already in use"** — outro processo está a usar a porta. Tenta outra:
```bash
json-server --watch db.json --port 3001
```
(e atualiza o `API_BASE_URL` no `.env`)

**"CORS error" no Chrome** — não deveria acontecer (o `json-server` aceita CORS por defeito). Se acontecer, atualiza para a versão mais recente:
```bash
npm update -g json-server
```

**"Cannot connect from Android"** — usaste `localhost`. Em Android tens de usar `10.0.2.2` (emulador) ou o IP local do PC (real).
