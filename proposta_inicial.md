# TITULO :
- Algarve Explorer

# PUBLICO ALVO :  
A aplicação será uma solução móvel orientada ao turismo no Algarve, pensada para ajudar turistas a descobrir pontos de interesse próximos da sua localização actual. Embora o produto completo tenha três níveis de utilizador — administradores ou gestores de conteúdo, clientes empresariais como hotéis, cafés e empresas de animação turística, e utilizadores finais turistas — o desenvolvimento desta fase ficará focado apenas na experiência do turista. Essa decisão é justificada pela limitação de tempo e recursos, mantendo, ainda assim, uma visão de produto escalável e realista.

# EXPLICANDO A IDÉIA CENTRAL:

O turista entra na app com credenciais próprias, que terão uma validade temporal de utilização. Depois do login, pode navegar em três áreas principais: uma página inicial com identidade visual e promoção da marca parceira que lhe forneceu acesso à app, uma página de mapa com a sua localização e os pontos turísticos próximos, e uma página de listagem que organiza esses pontos por proximidade e por estado de abertura.

Isto encaixa muito bem nos requisitos do trabalho porque permite ter autenticação, geolocalização, persistência local, navegação entre páginas e integração com dados estruturados.

Trata-se de uma aplicação móvel de apoio ao turismo local, pensada como solução B2B2C. A plataforma é comercializada a empresas do sector turístico, que a disponibilizam aos seus clientes finais, os turistas. Nesta primeira fase, o projecto implementa apenas o módulo do utilizador final, permitindo autenticação temporária, geolocalização, consulta de pontos turísticos próximos e visualização de conteúdo promocional associado ao parceiro comercial.

# ENTENDENDO OS UTILIZADORES DA APP:
O primeiro nível seria o administrador da plataforma. Este utilizador seria responsável por inserir e manter os pontos turísticos, horários, descrições, categorias, imagens e parcerias comerciais. Numa versão futura, poderia usar um painel web ou backend em Python para gerir a base de dados.

O segundo nível seria o cliente empresarial. Aqui entram hotéis, restaurantes, guias ou empresas de turismo. Estes parceiros comprariam ou licenciariam a solução e poderiam personalizar a experiência do turista com branding próprio, publicidade, destaques comerciais ou sugestões recomendadas. Em marketing seria uma white label, o cliente final(turista) não sabe que app foi criada por X, pensa que é uma app do local que a vendeu. 

O terceiro nível é o turista, que é o utilizador final da app e também o único módulo implementado nesta fase. Ele recebe acesso, faz login e usa a aplicação para explorar o Algarve com base na sua localização.

# FUNCIONAMENTO DA APP DA VISÃO DO TURISTA:
Funcionamento da app do ponto de vista do turista

### ecrã de autenticação
O turista entra com email e password. Também existirá uma opção “esqueci-me da palavra-passe”, mas essa funcionalidade ficará apenas representada na interface, para desenvolvimento futuro.
### ecrã de merchandising / boas-vindas
Depois do login, o utilizador entra numa página inicial com identidade da marca parceira. Por exemplo, se o acesso foi vendido por um hotel, esta página pode mostrar o logótipo, uma mensagem de boas-vindas, promoções locais, parcerias recomendadas e sugestões patrocinadas.
### ecrã de mapa
Nesta área, a aplicação obtém a localização actual do turista e mostra num mapa os pontos turísticos próximos. Cada ponto pode ter nome, categoria, distância aproximada, estado “aberto/fechado” e botão para ver detalhes.
### ecrã de listagem
A terceira página mostra os mesmos pontos turísticos em formato de lista. Aqui eles podem ser organizados por proximidade e por estado de funcionamento, por exemplo “abertos agora” e “outros próximos”. Também poderá ter um menu dropdown que mostra a rota.

### ecrã para ver detalhes
O quarto ecrã seria quando o turista seleciona algum ponto turistico para ver os detalhes, endereço escrito, nome, avaliação, categoria, imagens e pode selecionar varios pontos para fazer uma rota, a rota pode ser ordenada pelo turista ou ordenada pela app, por pontos proximos.

# FUNCIONALIDADES : 

### Geolocalização:
Para geolocalização, geolocator fornece acesso multiplataforma à localização.

### Persistencia de dados local:
Para persistência de dados simples, shared_preferences ira ser utilizado para guardar sessão, dados básicos e configurações locais.

### Vizualização do mapa:
Temos 3 opções -> Flutter_map , dio (configuração global, intrceptors e cancelamento de pedidos) e pacote http com chamadas REST básicas. 

### Navegação entre páginas:

### Gestão de estado:
Provider -> uma opção adequada e bastante usada para expor estado e lógica sem complicar a arquitectura.  

### Autenticação com OAuth2
Em Flutter existe o pacote oauth2_client, que suporta interacção com servidores OAuth2, armazenamento seguro de tokens e renovação automática. No entanto caso não dê tempo iremos implementar um login simplificado e deixaremos o fluxo OAuth2 descrito como evolução futura.

### Shared_preferences
Para a parte offline, optamos por guardar localmente a sessão do utilizador, a última localização conhecida, preferências e talvez uma cópia simples dos pontos turísticos mais recentes. Shared_preferences é suficiente para dados muito simples. 


# Arquitectura simples da solução

Camada de interface
Responsável pelos ecrãs, widgets, navegação e interacção com o utilizador.

Camada lógica
Responsável pela autenticação, obtenção de localização, filtragem de pontos turísticos, ordenação por distância e controlo do estado da aplicação.

Camada de dados
Responsável pela leitura de dados de uma API REST e pelo armazenamento local de sessão, preferências e cache.

# Modelo funcional do sistema

Entrada:

email e password do turista

Processamento:

validação da sessão
verificação do prazo de utilização
leitura da localização actual
carregamento dos pontos turísticos
cálculo da proximidade
classificação por aberto/fechado

Saída:

mapa com pontos próximos
lista ordenada de locais
página inicial com conteúdo promocional do parceiro

# Validade temporal da conta

O login do turista não representa uma conta permanente, mas sim um acesso temporário associado a uma experiência turística, estadia ou pacote adquirido. Por exemplo, um hotel ou guia pode vender o acesso por 3 dias, 7 dias ou pela duração da estadia. Quando o prazo termina, o utilizador deixa de ter acesso à app. 

Para execução desta parte teremos uma API, que devolve:

data de activação
data de expiração
estado da conta

# Apresentação da Página da APP:

#### Página 1 — Boas-vindas / Merchandising
Serve para reforçar a identidade visual do parceiro que fornece a app. Pode mostrar logótipo, imagem de destaque, mensagem de boas-vindas e promoções recomendadas.

#### Página 2 — Mapa
Mostra a localização do turista e os pontos turísticos à volta, com ícones e marcadores.

#### Página 3 — Lista de pontos turísticos
Mostra os locais ordenados por distância , separados entre “abertos agora” e “outros locais próximos”, orderna os pontos para mostrar no mapa, o turista pode selecionar varios pontos que o mapa fará por proximidade. 


# Como o projeto cumpre os requisitos que foram solicitados

#### Interface de utilizador básica
Cumpre facilmente, porque tera login e mais três páginas navegáveis.

#### Persistência de dados básica
Irá feita com shared_preferences para sessão, dados simples e pequenas preferências locais.

#### Funcionalidades diferenciadoras

geolocalização com geolocator
integração com API REST com http ou dio
funcionamento offline básico com cache local

# TECNOLOGIAS UTILIZADAS :
#### Provider (gestão de estado)

Utilização:

Armazenar dados do utilizador (sessão/login)
Partilhar estado entre ecrãs
Controlar lista de pontos turísticos
Actualizar UI quando os dados mudam


#### shared_preferences (persistência local)

Armazenamento local simples de dados.

Utilização:

Guardar sessão do utilizador (login)
Guardar data de validade do acesso
Guardar preferências básicas
Manter dados entre sessões da app

#### Geolocator (geolocalização)

Plugin para obter a localização do utilizador.

Utilização:

Obter latitude e longitude do turista
Atualizar posição no mapa
Calcular proximidade aos pontos turísticos
Base para ordenação por distância

#### Flutter Map (ou Google Maps Flutter)

Biblioteca para apresentação de mapas.

Utilização:

Mostrar mapa interactivo
Apresentar localização do utilizador
Marcar pontos turísticos no mapa
Interação com marcadores (pins)

#### HTTP (API REST)

Pacotes para comunicação com APIs externas.

Utilização:

Obter lista de pontos turísticos
Enviar e validar dados de login
Carregar dados actualizados (quando houver internet)

Diferença:

#### Base de dados local leve.

Utilização:

Guardar pontos turísticos localmente (cache)
Permitir funcionamento offline
Armazenar listas estruturadas de dados
Melhor alternativa ao shared_preferences para dados complexos

#### Flutter Local Notifications (opcional)

Sistema de notificações locais.

Utilização:

Notificar utilizador sobre pontos turísticos próximos
Alertar sobre fim do acesso (expiração)
Enviar recomendações
Python (backend – conceitual)


# Páginas e 'ferramentas':
Login do utilizador
→ Flutter + Dart + shared_preferences + (API com http)

Validade do acesso
→ Dart + shared_preferences

Página de merchandising
→ Flutter (UI)

Mapa com localização
→ Geolocator + Flutter Map

Lista de pontos turísticos
→ Dart + Provider + ListView

Ordenação por proximidade
→ Dart (cálculos com base em latitude/longitude)

Dados dos pontos turísticos
→ API REST (http/dio) ou dados locais

Funcionamento offline
→ shared_preferences

Arquitectura futura 
→ Python + FastAPI + OAuth2


# CRONOGRAMA SIMPLIFICADO : 
Divisão do trabalho entre duas pessoas

Laura — frontend e experiência do utilizador
Fica responsável por:

ecrã de login
página de merchandising
navegação entre ecrãs
layout do mapa e da lista
componente visual dos cartões dos pontos turísticos

Maria — lógica e dados
Fica responsável por:

gestão de sessão
validação de acesso por prazo
integração da geolocalização
obtenção e tratamento dos pontos turísticos
persistência local
simulação ou integração de API

Ambos

definição de requisitos
testes
escrita do README
preparação da apresentação


Agenda simples de desenvolvimento

Semana 1
Definição do conceito final da app, personas, funcionalidades principais e divisão de tarefas.

Semana 2
Desenho dos ecrãs, protótipo visual e implementação do fluxo de navegação.

Semana 3
Implementação do login, sessão do utilizador e persistência local.

Semana 4
Integração da geolocalização e criação do mapa com pontos turísticos.

Semana 5
Criação da listagem por proximidade e estado de abertura.

Semana 6
Testes, correcções, melhorias visuais e finalização do README.


# DESAFIOS TÉCNICOS PREVISTOS :
# PRAZOS:
# Apresentação da Proposta
#### 17/04/2026 (Abril)
## Check point 1
#### 24/04/2026 (Abril) 06:00:00
## Check point 2
#### 11/05/2026 (Maio) 06:00:00
## Entrega Final 
#### 18/05/2026 (Maio) 06:00:00
## Apresentação Final 
#### 29/05/2026 16:00:00
