Vou explicar o código como se estivéssemos a lê-lo ficheiro por ficheiro, linha a linha, primeiro o GeoapifyService e depois o PoiModel. Assim consegues perceber não só o que faz, mas também a sintaxe Dart usada em cada parte.


Claro. Vou explicar linha a linha, começando pelo ficheiro do serviço:

lib/services/geoapify_service.dart

Este ficheiro é responsável por falar com a API da Geoapify.

1. GeoapifyService explicado linha a linha

Código:

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/poi_model.dart';
Linha 1
import 'package:dio/dio.dart';

Esta linha importa a biblioteca Dio.

O Dio é usado para fazer pedidos HTTP, ou seja, para a tua app comunicar com APIs externas.

Neste caso, usamos o Dio para fazer pedidos à Geoapify.

Exemplo de pedido HTTP:

_dio.get(...)
Linha 2
import 'package:flutter_dotenv/flutter_dotenv.dart';

Esta linha importa a biblioteca flutter_dotenv.

Ela serve para ler variáveis guardadas no ficheiro .env.

No teu caso, a chave da Geoapify fica guardada assim:

GEOAPIFY_API_KEY=sua_chave_aqui

Assim evitas escrever a chave directamente no código.

Linha 4
import '../models/poi_model.dart';

Esta linha importa o modelo PoiModel.

O PoiModel é a classe que representa cada local encontrado pela Geoapify.

Por exemplo:

PoiModel(
  nome: 'Restaurante Exemplo',
  latitude: 37.0892,
  longitude: -8.2503,
)

Sem este import, o ficheiro GeoapifyService não saberia o que é um PoiModel.

Classe principal
class GeoapifyService {

Esta linha cria uma classe chamada GeoapifyService.

Em Dart, uma classe é como um molde. Neste caso, é o molde do serviço que vai comunicar com a Geoapify.

A ideia é poderes fazer:

final geoapifyService = GeoapifyService();

E depois chamar métodos como:

geoapifyService.buscarLocaisProximos(...)
  final Dio _dio;

Aqui estamos a declarar uma variável chamada _dio.

Ela é do tipo Dio.

A palavra final significa que, depois de receber um valor, essa variável não será substituída.

O nome começa com _:

_dio

Em Dart, quando uma variável começa com _, significa que ela é privada dentro daquele ficheiro.

Ou seja, só pode ser usada dentro de geoapify_service.dart.

  GeoapifyService({Dio? dio}) : _dio = dio ?? Dio();

Esta linha é o construtor da classe.

O construtor é executado quando fazes:

GeoapifyService()

Vamos dividir:

GeoapifyService({Dio? dio})

Aqui estamos a dizer que o construtor pode receber opcionalmente um objecto Dio.

O ponto de interrogação em:

Dio?

significa que o valor pode ser nulo.

Ou seja, podes criar o serviço assim:

GeoapifyService()

ou assim:

GeoapifyService(dio: Dio())

Agora esta parte:

: _dio = dio ?? Dio();

Isto é a lista de inicialização do construtor.

Significa:

“Antes de executar o corpo da classe, define _dio com o valor recebido em dio. Se dio vier nulo, cria um novo Dio().”

O operador ?? significa:

“se o valor da esquerda for nulo, usa o valor da direita”.

Então isto:

dio ?? Dio()

quer dizer:

se dio existir, usa dio;
se dio for null, usa Dio().

Na prática:

_dio = dio ?? Dio();

é equivalente a dizer:

if (dio != null) {
  _dio = dio;
} else {
  _dio = Dio();
}
  final String _apiKey = dotenv.env['GEOAPIFY_API_KEY'] ?? '';

Esta linha cria uma variável privada chamada _apiKey.

Ela vai buscar a chave da Geoapify ao ficheiro .env.

Vamos por partes:

final String _apiKey

Cria uma variável do tipo String.

dotenv.env['GEOAPIFY_API_KEY']

Vai procurar no ficheiro .env uma variável chamada GEOAPIFY_API_KEY.

?? ''

Se essa variável não existir, usa uma string vazia.

Ou seja:

_apiKey = chave encontrada no .env

ou, se não encontrar:

_apiKey = ''

Depois, mais abaixo, temos uma função que valida se a chave está vazia.

  static const String _placesUrl = 'https://api.geoapify.com/v2/places';

Esta linha define o endereço da API de pesquisa de locais.

Vamos por partes:

static

Significa que esta variável pertence à classe, e não a uma instância específica.

const

Significa que o valor é constante, ou seja, nunca muda.

String

É texto.

_placesUrl

Nome privado da variável.

'https://api.geoapify.com/v2/places'

É o endpoint usado para procurar locais.

  static const String _detailsUrl = 'https://api.geoapify.com/v2/place-details';

Esta linha define o endpoint usado para buscar detalhes de um local específico.

A diferença entre os dois endpoints é:

/v2/places

procura vários locais.

/v2/place-details

procura detalhes de um local específico.

Método buscarLocaisProximos
  Future<List<PoiModel>> buscarLocaisProximos({

Aqui começa a função principal.

Ela chama-se:

buscarLocaisProximos

Esta função devolve:

Future<List<PoiModel>>

Vamos explicar:

List<PoiModel>

Significa uma lista de objectos PoiModel.

Exemplo:

[
  PoiModel(nome: 'Restaurante A', ...),
  PoiModel(nome: 'Restaurante B', ...),
]
Future

Significa que o resultado não vem imediatamente.

Como a função faz pedidos à internet, ela demora algum tempo. Por isso, em Dart, usamos Future.

Ou seja:

Future<List<PoiModel>>

significa:

“Esta função vai devolver uma lista de POIs no futuro, depois de terminar o pedido à API.”

    required double latitude,

Este parâmetro é obrigatório.

A palavra required significa que quem chamar a função tem de informar esse valor.

double

Significa número decimal.

Exemplo:

latitude: 37.0892
    required double longitude,

Também é obrigatório.

Representa a longitude.

Exemplo:

longitude: -8.2503
    required List<String> categories,

Este parâmetro também é obrigatório.

Ele espera uma lista de textos.

List<String>

Exemplo:

categories: ['catering.restaurant']

ou:

categories: [
  'catering.restaurant',
  'catering.cafe',
]

Estas categorias são as categorias da Geoapify.

    int radius = 1000,

Este parâmetro é opcional.

Se não for informado, o valor padrão será 1000.

int

Significa número inteiro.

Neste caso, o radius é o raio de pesquisa em metros.

Exemplo:

radius: 3000

procura num raio de 3 km.

    int limit = 20,

Também é opcional.

Se não for informado, o valor padrão será 20.

Este campo define o número máximo de resultados.

Exemplo:

limit: 20

quer dizer:

“devolve no máximo 20 locais.”

    bool incluirDetalhes = true,

Este campo é booleano.

bool

significa que só pode ser:

true

ou:

false

Se for true, depois de pesquisar os locais, a função vai buscar detalhes de cada local.

Se for false, devolve apenas os dados básicos da pesquisa.

    List<String> detalhesFeatures = const ['details'],

Este parâmetro define que tipo de detalhes queremos pedir à API de detalhes.

Por padrão, ele manda:

['details']

O const aqui indica que a lista padrão é constante.

  }) async {

Aqui termina a lista de parâmetros e começa o corpo da função.

A palavra async significa que esta função é assíncrona.

Ou seja, dentro dela podemos usar await.

O await serve para esperar uma resposta de uma função que demora, como um pedido HTTP.

    _validarApiKey();

Esta linha chama uma função privada chamada _validarApiKey.

Ela verifica se a API key existe.

Se a chave estiver vazia, ela lança um erro.

Isto evita fazer pedidos à Geoapify sem chave.

    if (categories.isEmpty) {

Aqui começa uma validação.

if

significa “se”.

categories.isEmpty

verifica se a lista de categorias está vazia.

Ou seja, se alguém chamou assim:

categories: []
      throw Exception('Deve informar pelo menos uma categoria Geoapify.');

Se a lista estiver vazia, esta linha lança uma excepção.

throw Exception(...)

significa:

“interrompe a execução e devolve este erro.”

    }

Fecha o bloco do if.

    if (radius <= 0) {

Aqui verifica se o raio é menor ou igual a zero.

Não faria sentido procurar locais num raio de 0 metros ou negativo.

      throw Exception('O raio de pesquisa deve ser maior que zero.');

Se o raio for inválido, lança um erro.

    }

Fecha o bloco.

    if (limit <= 0) {

Aqui verifica se o limite de resultados é menor ou igual a zero.

Também não faria sentido pedir 0 resultados.

      throw Exception('O limite de resultados deve ser maior que zero.');

Se o limite for inválido, lança erro.

    }

Fecha o bloco.

    try {

Aqui começa um bloco try.

Usamos try quando vamos executar algo que pode dar erro.

Neste caso, os pedidos HTTP podem falhar por vários motivos:

sem internet;
API key errada;
limite da Geoapify atingido;
erro no servidor;
parâmetros inválidos.
      final response = await _dio.get(

Aqui fazemos um pedido GET usando o Dio.

final response

guarda a resposta da API.

await

espera o pedido terminar.

_dio.get(...)

faz um pedido HTTP do tipo GET.

        _placesUrl,

Aqui dizemos que o pedido será feito para o endpoint de pesquisa de locais:

https://api.geoapify.com/v2/places
        queryParameters: {

Aqui começamos a montar os parâmetros que vão na URL.

Num pedido GET, os parâmetros vão normalmente depois de ?.

Por exemplo:

/v2/places?categories=catering.restaurant&limit=20

O Dio monta isto automaticamente a partir do mapa queryParameters.

          'categories': categories.join(','),

Esta linha envia as categorias.

categories

é uma lista.

Exemplo:

[
  'catering.restaurant',
  'catering.cafe',
]

Mas a Geoapify espera uma string separada por vírgulas.

Por isso usamos:

categories.join(',')

Resultado:

'catering.restaurant,catering.cafe'

Então o parâmetro enviado fica:

categories=catering.restaurant,catering.cafe
          'filter': 'circle:$longitude,$latitude,$radius',

Esta linha define o filtro geográfico.

A Geoapify usa este formato:

circle:longitude,latitude,raio

Exemplo:

filter: circle:-8.2503,37.0892,1000

Isto quer dizer:

“procura dentro de um círculo com centro nestas coordenadas e raio de 1000 metros.”

Repara que aqui vem primeiro a longitude e depois a latitude.

Isto é importante:

$longitude,$latitude

não é:

$latitude,$longitude
          'bias': 'proximity:$longitude,$latitude',

Esta linha diz à Geoapify para dar prioridade aos resultados mais próximos da localização.

O filter limita a área.

O bias ajuda a ordenar ou favorecer resultados próximos.

Exemplo:

bias: proximity:-8.2503,37.0892
          'limit': limit,

Esta linha manda o limite máximo de resultados.

Se limit for 20, a API tenta devolver no máximo 20 locais.

          'apiKey': _apiKey,

Esta linha envia a tua chave da Geoapify.

Sem isto, a API não autoriza o pedido.

        },

Fecha o mapa de parâmetros.

      );

Fecha o pedido _dio.get.

Neste momento, se tudo correr bem, response contém a resposta da Geoapify.

      final List features = response.data['features'] ?? [];

A Geoapify devolve os resultados dentro de uma chave chamada features.

A estrutura costuma ser assim:

{
  "features": [
    {
      "properties": {
        "name": "Restaurante Exemplo"
      },
      "geometry": {
        "coordinates": [-8.2503, 37.0892]
      }
    }
  ]
}

Então esta linha faz:

response.data['features']

para buscar a lista de resultados.

O ?? [] significa:

“se features não existir ou vier nulo, usa uma lista vazia.”

Ou seja, evita erro caso a API não devolva resultados.

      final pois = features

Aqui começa a transformação dos dados da Geoapify para uma lista de PoiModel.

pois será uma lista de locais já convertidos para o formato da tua app.

          .map((item) => PoiModel.fromGeoapify(Map<String, dynamic>.from(item)))

Esta linha percorre cada item da lista features.

O .map(...) transforma cada item em outra coisa.

Neste caso, transforma cada item da Geoapify em PoiModel.

Vamos dividir:

(item) => ...

Isto é uma função curta, chamada arrow function.

Significa:

“para cada item, faz isto”.

Map<String, dynamic>.from(item)

Garante que o item é tratado como um mapa Dart.

Um Map<String, dynamic> é uma estrutura do tipo:

{
  'name': 'Restaurante Exemplo',
  'distance': 250,
}

O String é o tipo das chaves.

O dynamic significa que os valores podem ser de qualquer tipo: texto, número, lista, outro mapa, etc.

Depois:

PoiModel.fromGeoapify(...)

chama o construtor especial do model para converter o JSON da Geoapify num objecto PoiModel.

          .toList();

O .map(...) devolve uma sequência, mas nós queremos uma lista.

Por isso usamos:

.toList()

No fim, temos:

final pois = [...]

com vários PoiModel.

      if (!incluirDetalhes) {

Aqui verificamos se o utilizador não quer detalhes.

O ponto de exclamação ! antes de uma variável booleana significa negação.

Ou seja:

!incluirDetalhes

quer dizer:

“se incluirDetalhes for falso”.

        return pois;

Se não quiser detalhes, a função termina aqui e devolve a lista básica.

      }

Fecha o if.

      final List<PoiModel> poisComDetalhes = [];

Aqui criamos uma nova lista vazia.

Esta lista vai guardar os POIs já enriquecidos com detalhes.

List<PoiModel>

quer dizer que a lista só deve conter objectos PoiModel.

      for (final poi in pois) {

Aqui começa um ciclo for.

Este ciclo percorre todos os POIs encontrados.

Para cada POI da lista pois, ele executa o bloco de código.

Exemplo:

for (final poi in pois)

significa:

“para cada poi dentro da lista pois”.

        final poiDetalhado = await _buscarDetalhesDoPoi(

Aqui chamamos uma função privada que vai buscar os detalhes daquele POI específico.

Usamos await porque ela também faz um pedido HTTP.

O resultado fica guardado em:

poiDetalhado
          poi: poi,

Estamos a passar o POI actual para a função.

          features: detalhesFeatures,

Estamos a passar o tipo de detalhes que queremos pedir.

Por padrão:

['details']
        );

Fecha a chamada da função _buscarDetalhesDoPoi.

        poisComDetalhes.add(poiDetalhado);

Esta linha adiciona o POI detalhado à lista poisComDetalhes.

      }

Fecha o ciclo for.

      return poisComDetalhes;

Depois de buscar detalhes de todos os POIs, a função devolve a lista final.

    } on DioException catch (e) {

Aqui começa o tratamento de erros específicos do Dio.

Se algum erro acontecer no pedido HTTP principal, ele entra aqui.

DioException

é o tipo de erro lançado pelo Dio.

catch (e)

guarda o erro na variável e.

      throw Exception(_formatarErroDio(e));

Aqui transformamos o erro técnico do Dio numa mensagem mais compreensível.

A função _formatarErroDio(e) cria uma mensagem personalizada.

Depois lançamos essa mensagem com:

throw Exception(...)
    } catch (e) {

Este catch apanha qualquer outro erro que não seja DioException.

      throw Exception('Erro ao procurar locais próximos: $e');

Aqui devolvemos um erro genérico, incluindo o erro original.

O $e dentro da string insere o valor da variável e.

Exemplo:

'Erro ao procurar locais próximos: qualquer erro'
    }

Fecha o bloco try/catch.

  }

Fecha a função buscarLocaisProximos.

Método privado _buscarDetalhesDoPoi

Agora este método:

  Future<PoiModel> _buscarDetalhesDoPoi({

Este método devolve um PoiModel.

Também devolve um Future, porque faz pedido à API.

O nome começa com _, por isso é privado.

Ou seja, só é usado dentro do próprio ficheiro.

    required PoiModel poi,

Este parâmetro é obrigatório.

Recebe o POI que queremos enriquecer com detalhes.

    required List<String> features,

Também é obrigatório.

Recebe a lista de detalhes que queremos pedir à Geoapify.

  }) async {

Fecha os parâmetros e começa o corpo da função.

O async permite usar await.

    if (poi.placeId == null || poi.placeId!.isEmpty) {

Aqui verificamos se o POI tem placeId.

O placeId é necessário para chamar a API de detalhes.

Vamos dividir:

poi.placeId == null

verifica se é nulo.

||

significa “ou”.

poi.placeId!.isEmpty

verifica se está vazio.

O ! depois de placeId diz ao Dart:

“eu sei que aqui o valor já não é nulo.”

Como antes verificámos poi.placeId == null, depois podemos usar poi.placeId!.

      return poi;

Se não houver placeId, não dá para buscar detalhes.

Então devolvemos o POI original, sem alterações.

    }

Fecha o if.

    try {

Começa o bloco de tentativa para fazer o pedido de detalhes.

      final response = await _dio.get(

Faz um pedido GET para a API.

Guarda a resposta em response.

        _detailsUrl,

O pedido vai para:

https://api.geoapify.com/v2/place-details
        queryParameters: {

Começa o mapa de parâmetros.

          'id': poi.placeId,

Envia o ID do local.

Este ID veio da primeira pesquisa feita em /v2/places.

          'features': features.join(','),

Envia os detalhes pretendidos.

Como features é uma lista, usamos:

features.join(',')

Exemplo:

['details']

vira:

'details'

Se no futuro tiveres:

['details', 'walk_20']

vira:

'details,walk_20'
          'apiKey': _apiKey,

Envia a chave da API.

        },

Fecha os parâmetros.

      );

Fecha o _dio.get.

      final List detalhesFeatures = response.data['features'] ?? [];

A resposta da API de detalhes também vem dentro de features.

Esta linha guarda essa lista.

Se não vier nada, guarda uma lista vazia.

      if (detalhesFeatures.isEmpty) {

Verifica se a lista de detalhes está vazia.

        return poi;

Se não houver detalhes, devolve o POI original.

      }

Fecha o if.

      final detalhesFeature = Map<String, dynamic>.from(detalhesFeatures.first);

Aqui pegamos no primeiro detalhe da lista.

detalhesFeatures.first

pega no primeiro item.

Depois convertemos para:

Map<String, dynamic>

Assim garantimos que conseguimos ler campos como:

detalhesFeature['properties']
      return poi.copyWithDetalhes(detalhesFeature);

Aqui está uma parte muito importante.

Em vez de criar um POI totalmente novo manualmente, chamamos:

copyWithDetalhes

Esse método está no PoiModel.

Ele pega no POI original e cria uma nova versão dele, agora com os detalhes adicionados.

    } on DioException {

Se a chamada de detalhes der erro, entra aqui.

Repara que aqui não usamos catch (e), porque não precisamos da variável do erro.

      return poi;

Se falhar a busca de detalhes, devolvemos o POI original.

Isto é uma decisão boa para a experiência do utilizador.

Assim, se um local falhar nos detalhes, a lista inteira não quebra.

    } catch (_) {

Este bloco apanha qualquer outro erro.

O _ significa:

“apanha o erro, mas não preciso de usar a variável.”

      return poi;

Também devolve o POI original.

    }

Fecha o try/catch.

  }

Fecha o método _buscarDetalhesDoPoi.

Método buscarDetalhesPorPlaceId
  Future<PoiModel?> buscarDetalhesPorPlaceId({

Este método permite buscar detalhes directamente pelo placeId.

Ele devolve:

Future<PoiModel?>

O ? em PoiModel? significa que pode devolver:

PoiModel

ou:

null

Ou seja, se não encontrar detalhes, pode devolver null.

    required String placeId,

Este parâmetro é obrigatório.

Recebe o ID do local.

    List<String> features = const ['details'],

Este parâmetro é opcional.

Por padrão, pede:

['details']
  }) async {

Fecha os parâmetros e começa o corpo assíncrono.

    _validarApiKey();

Valida se a chave da Geoapify existe.

    if (placeId.trim().isEmpty) {

Verifica se o placeId está vazio.

trim()

remove espaços antes e depois do texto.

Exemplo:

'   '.trim()

vira:

''

Então:

placeId.trim().isEmpty

apanha tanto uma string vazia como uma string só com espaços.

      throw Exception('O placeId não pode estar vazio.');

Se estiver vazio, lança erro.

    }

Fecha o if.

    try {

Começa a tentativa de chamar a API.

      final response = await _dio.get(

Faz o pedido GET.

        _detailsUrl,

Usa o endpoint de detalhes.

        queryParameters: {

Começa os parâmetros.

          'id': placeId,

Envia o ID do local.

          'features': features.join(','),

Envia os tipos de detalhes pretendidos.

          'apiKey': _apiKey,

Envia a API key.

        },

Fecha os parâmetros.

      );

Fecha o pedido.

      final List detalhesFeatures = response.data['features'] ?? [];

Guarda a lista de resultados devolvidos pela API.

      if (detalhesFeatures.isEmpty) {

Verifica se veio vazia.

        return null;

Se não veio nenhum detalhe, devolve null.

      }

Fecha o if.

      final detalhe = Map<String, dynamic>.from(detalhesFeatures.first);

Pega no primeiro detalhe e converte para Map<String, dynamic>.

      return PoiModel.fromGeoapify(detalhe).copyWithDetalhes(detalhe);

Aqui fazemos duas coisas:

Primeiro:

PoiModel.fromGeoapify(detalhe)

Cria um PoiModel a partir da resposta da Geoapify.

Depois:

.copyWithDetalhes(detalhe)

Enriquece o mesmo POI com os detalhes adicionais.

    } on DioException catch (e) {

Se houver erro do Dio, apanha o erro na variável e.

      throw Exception(_formatarErroDio(e));

Formata o erro e lança uma excepção mais legível.

    } catch (e) {

Apanha qualquer outro erro.

      throw Exception('Erro ao procurar detalhes do local: $e');

Lança erro genérico.

    }

Fecha o try/catch.

  }

Fecha o método buscarDetalhesPorPlaceId.

Método _validarApiKey
  void _validarApiKey() {

Este método não devolve nada.

Por isso o tipo dele é:

void

O nome começa por _, então é privado.

    if (_apiKey.isEmpty) {

Verifica se a API key está vazia.

      throw Exception(

Se estiver vazia, lança uma excepção.

        'GEOAPIFY_API_KEY não foi encontrada no ficheiro .env.',

Mensagem do erro.

      );

Fecha o Exception.

    }

Fecha o if.

  }

Fecha o método.

Método _formatarErroDio
  String _formatarErroDio(DioException e) {

Este método recebe um erro do Dio e devolve uma String.

Ou seja, recebe isto:

DioException e

e devolve uma mensagem de erro.

    final statusCode = e.response?.statusCode;

Aqui tentamos buscar o código HTTP da resposta.

Exemplos de códigos:

400 - pedido inválido
401 - não autorizado
403 - proibido
429 - limite atingido
500 - erro do servidor

O ?. é chamado operador de acesso seguro.

e.response?.statusCode

significa:

“se response existir, acede a statusCode; se response for nulo, devolve null.”

Evita erro quando não há resposta do servidor.

    final data = e.response?.data;

Aqui buscamos o corpo da resposta de erro.

Pode conter detalhes técnicos devolvidos pela Geoapify.

Também usa ?. para evitar erro se response for nulo.

    if (statusCode == 401 || statusCode == 403) {

Verifica se o erro é de autenticação ou permissão.

||

significa “ou”.

Então:

statusCode == 401 || statusCode == 403

significa:

“se for 401 ou 403”.

      return 'Erro de autenticação na Geoapify. Verifica a API key.';

Devolve uma mensagem amigável para esse erro.

    }

Fecha o if.

    if (statusCode == 400) {

Verifica se o erro foi pedido inválido.

Geralmente acontece quando os parâmetros foram mal enviados.

      return 'Pedido inválido enviado para a Geoapify: $data';

Devolve mensagem com os detalhes da resposta.

    }

Fecha o if.

    if (statusCode == 429) {

Verifica se a app atingiu o limite de pedidos da API.

      return 'Limite de pedidos da Geoapify atingido. Tenta novamente mais tarde.';

Mensagem amigável para limite atingido.

    }

Fecha o if.

    if (statusCode != null) {

Aqui verifica se existe algum código de erro diferente dos anteriores.

      return 'Erro Geoapify [$statusCode]: $data';

Devolve uma mensagem genérica com o código e os dados recebidos.

    }

Fecha o if.

    return 'Erro de ligação à Geoapify: ${e.message}';

Se não houve sequer resposta HTTP, pode ser erro de ligação.

Exemplo:

sem internet;
timeout;
DNS;
ligação interrompida.

${e.message} insere a mensagem do erro dentro da string.

  }

Fecha o método _formatarErroDio.

}

Fecha a classe GeoapifyService.

2. PoiModel explicado linha a linha

Agora vamos ao ficheiro:

lib/models/poi_model.dart

Este ficheiro representa os dados de cada local.

class PoiModel {

Cria uma classe chamada PoiModel.

POI significa:

Point of Interest

Em português: ponto de interesse.

Um POI pode ser:

restaurante;
café;
hotel;
museu;
praia;
farmácia;
supermercado;
atracção turística.
  final String? id;

Cria o campo id.

String?

significa que é texto, mas pode ser nulo.

O ? permite que o campo não exista.

  final String? placeId;

Cria o campo placeId.

Este campo é muito importante porque permite buscar os detalhes do local na Geoapify.

Também pode ser nulo.

  final String nome;

Cria o campo nome.

Aqui não há ?, então o nome é obrigatório.

Todo PoiModel precisa de ter um nome.

Mesmo que a Geoapify não devolva nome, o nosso model coloca:

'Local sem nome'
  final String? descricao;

Descrição opcional do local.

Pode existir ou não.

  final String? categoriaPrincipal;

Guarda uma categoria principal do local.

Por exemplo:

catering.restaurant

Pode ser nulo.

  final List<String> categorias;

Guarda a lista completa de categorias.

Exemplo:

[
  'catering',
  'catering.restaurant'
]

Aqui não é opcional, mas no construtor damos um valor padrão de lista vazia.

  final String? endereco;

Guarda a morada formatada.

Pode ser nulo.

  final String? cidade;

Guarda a cidade, concelho ou zona.

Pode ser nulo.

  final String? pais;

Guarda o país.

Pode ser nulo.

  final String? codigoPostal;

Guarda o código postal.

Pode ser nulo.

  final double latitude;

Guarda a latitude.

É obrigatória.

double

é número decimal.

  final double longitude;

Guarda a longitude.

Também é obrigatória.

  final double? distancia;

Guarda a distância entre o utilizador e o local.

É opcional.

Normalmente vem em metros.

Exemplo:

350.0
  final String? telefone;

Telefone do local, se existir.

  final String? email;

Email do local, se existir.

  final String? website;

Website do local, se existir.

  final String? horario;

Horário de funcionamento, se existir.

Normalmente pode vir em formato técnico, por exemplo:

Mo-Su 12:00-23:00
  final String? cozinha;

Tipo de cozinha, quando for restaurante.

Exemplos:

portuguese
italian
seafood
  final String? tipo;

Tipo de local, se a API devolver essa informação.

  final Map<String, dynamic>? detalhesRaw;

Guarda a resposta original da API de detalhes.

Map<String, dynamic>

é uma estrutura chave/valor.

Exemplo:

{
  'properties': {
    'name': 'Restaurante Exemplo'
  }
}

Este campo é útil para debug ou para aceder a dados que ainda não foram mapeados no model.

  final Map<String, dynamic>? raw;

Guarda a resposta original da primeira pesquisa /v2/places.

Também é útil para debug.

Construtor do PoiModel
  PoiModel({

Aqui começa o construtor da classe.

É usado para criar um objecto PoiModel.

Exemplo:

PoiModel(
  nome: 'Restaurante Exemplo',
  latitude: 37.0892,
  longitude: -8.2503,
)
    this.id,

Este campo é opcional.

Quando usamos this.id, estamos a dizer:

“o valor recebido no construtor vai para o campo id da classe.”

    this.placeId,

Também opcional.

    required this.nome,

Este campo é obrigatório.

Quem criar um PoiModel tem de passar o nome.

    this.descricao,

Campo opcional.

    this.categoriaPrincipal,

Campo opcional.

    this.categorias = const [],

Campo opcional com valor padrão.

Se ninguém passar categorias, fica uma lista vazia.

const []

é uma lista vazia constante.

    this.endereco,

Campo opcional.

    this.cidade,

Campo opcional.

    this.pais,

Campo opcional.

    this.codigoPostal,

Campo opcional.

    required this.latitude,

Latitude obrigatória.

    required this.longitude,

Longitude obrigatória.

    this.distancia,

Distância opcional.

    this.telefone,

Telefone opcional.

    this.email,

Email opcional.

    this.website,

Website opcional.

    this.horario,

Horário opcional.

    this.cozinha,

Cozinha opcional.

    this.tipo,

Tipo opcional.

    this.detalhesRaw,

Resposta original dos detalhes, opcional.

    this.raw,

Resposta original da pesquisa, opcional.

  });

Fecha o construtor.

Factory fromGeoapify
  factory PoiModel.fromGeoapify(Map<String, dynamic> feature) {

Aqui criamos um construtor especial chamado fromGeoapify.

A palavra factory significa que este construtor pode fazer alguma lógica antes de devolver o objecto.

Neste caso, ele recebe um Map<String, dynamic> vindo da Geoapify e transforma-o num PoiModel.

Exemplo de uso:

PoiModel.fromGeoapify(item)
    final properties = Map<String, dynamic>.from(feature['properties'] ?? {});

A resposta da Geoapify tem muitos dados dentro de properties.

Esta linha tenta ir buscar:

feature['properties']

Se não existir, usa:

{}

Depois converte para:

Map<String, dynamic>

O resultado fica guardado em properties.

    final geometry = Map<String, dynamic>.from(feature['geometry'] ?? {});

Aqui fazemos o mesmo com geometry.

A parte geometry normalmente guarda as coordenadas.

Exemplo:

"geometry": {
  "coordinates": [-8.2503, 37.0892]
}
    final coordinates = geometry['coordinates'];

Aqui guardamos as coordenadas numa variável.

Podem vir assim:

[-8.2503, 37.0892]
    double longitude = 0;

Criamos a variável longitude com valor inicial 0.

    double latitude = 0;

Criamos a variável latitude com valor inicial 0.

Fazemos isto porque, se a API não devolver coordenadas, o objecto ainda terá um valor numérico.

    if (coordinates is List && coordinates.length >= 2) {

Aqui verificamos duas coisas:

coordinates is List

confirma que coordinates é uma lista.

coordinates.length >= 2

confirma que tem pelo menos dois valores.

Precisamos de dois valores:

[longitude, latitude]
      longitude = _toDouble(coordinates[0]);

Se as coordenadas forem válidas, o primeiro valor é a longitude.

Usamos _toDouble para converter com segurança.

      latitude = _toDouble(coordinates[1]);

O segundo valor é a latitude.

Também usamos _toDouble.

    } else {

Se as coordenadas não vierem em geometry.coordinates, tentamos outro caminho.

      longitude = _toDouble(properties['lon']);

Tenta buscar a longitude em:

properties['lon']
      latitude = _toDouble(properties['lat']);

Tenta buscar a latitude em:

properties['lat']
    }

Fecha o if/else.

    final categoriesRaw = properties['categories'];

Guarda as categorias brutas vindas da API.

Podem vir como lista.

    final categorias = categoriesRaw is List

Aqui começa uma condição curta.

Estamos a verificar se categoriesRaw é uma lista.

        ? categoriesRaw.map((e) => e.toString()).toList()

Se for lista, transforma cada item em texto.

Vamos por partes:

categoriesRaw.map(...)

percorre cada item da lista.

(e) => e.toString()

transforma cada item em String.

.toList()

converte o resultado final numa lista.

        : <String>[];

Se categoriesRaw não for lista, usamos uma lista vazia de strings.

O operador usado aqui é o ternário:

condição ? valorSeVerdadeiro : valorSeFalso

Neste caso:

categoriesRaw is List
  ? converte lista
  : lista vazia
    return PoiModel(

Agora começamos a devolver um novo objecto PoiModel.

      id: properties['id']?.toString(),

Define o campo id.

properties['id']

busca o ID.

?.toString()

se existir, converte para texto.

Se não existir, fica null.

      placeId: properties['place_id']?.toString(),

Define o placeId.

Este é o ID usado para chamar a API de detalhes.

      nome: _valorNaoVazio(properties['name']) ??
          _valorNaoVazio(properties['formatted']) ??
          'Local sem nome',

Define o nome.

Aqui usamos vários fallbacks.

Primeiro tenta:

properties['name']

Se não existir ou estiver vazio, tenta:

properties['formatted']

Se também não existir, usa:

'Local sem nome'

O operador ?? significa:

“se o valor da esquerda for nulo, usa o da direita.”

      descricao: _valorNaoVazio(properties['description']),

Define a descrição, se existir.

A função _valorNaoVazio evita guardar strings vazias.

      categoriaPrincipal:
          categorias.isNotEmpty ? categorias.first : _valorNaoVazio(properties['category']),

Define a categoria principal.

Se a lista categorias não estiver vazia:

categorias.first

usa a primeira categoria.

Caso contrário, tenta usar:

properties['category']
      categorias: categorias,

Guarda a lista completa de categorias.

      endereco: _valorNaoVazio(properties['formatted']),

Guarda a morada formatada.

      cidade: _valorNaoVazio(properties['city']) ??
          _valorNaoVazio(properties['county']),

Define a cidade.

Primeiro tenta:

properties['city']

Se não houver, tenta:

properties['county']
      pais: _valorNaoVazio(properties['country']),

Guarda o país.

      codigoPostal: _valorNaoVazio(properties['postcode']),

Guarda o código postal.

      latitude: latitude,

Guarda a latitude já calculada acima.

      longitude: longitude,

Guarda a longitude já calculada acima.

      distancia: _toNullableDouble(properties['distance']),

Guarda a distância.

Usa _toNullableDouble, porque a distância pode não existir.

Se não existir, fica null.

      telefone: _valorNaoVazio(properties['phone']),

Guarda o telefone, se existir.

      email: _valorNaoVazio(properties['email']),

Guarda o email, se existir.

      website: _valorNaoVazio(properties['website']),

Guarda o website, se existir.

      horario: _valorNaoVazio(properties['opening_hours']),

Guarda o horário, se existir.

      cozinha: _valorNaoVazio(properties['cuisine']),

Guarda o tipo de cozinha, se existir.

      tipo: _valorNaoVazio(properties['type']),

Guarda o tipo do local, se existir.

      raw: feature,

Guarda a resposta original completa.

Isto é útil para debug.

    );

Fecha a criação do PoiModel.

  }

Fecha o factory fromGeoapify.

Método copyWithDetalhes
  PoiModel copyWithDetalhes(Map<String, dynamic> detalhesFeature) {

Este método cria uma nova versão do mesmo PoiModel, mas com dados adicionais vindos da API de detalhes.

Ele recebe:

Map<String, dynamic> detalhesFeature

e devolve:

PoiModel
    final properties = Map<String, dynamic>.from(
      detalhesFeature['properties'] ?? {},
    );

Busca os properties da resposta de detalhes.

Se não existir, usa mapa vazio.

    final contact = properties['contact'] is Map
        ? Map<String, dynamic>.from(properties['contact'])
        : <String, dynamic>{};

Aqui tentamos buscar os contactos.

Algumas respostas podem trazer dados dentro de:

properties['contact']

A linha usa novamente o operador ternário.

Se properties['contact'] for um Map, converte para Map<String, dynamic>.

Se não for, usa mapa vazio.

    final datasource = properties['datasource'] is Map
        ? Map<String, dynamic>.from(properties['datasource'])
        : <String, dynamic>{};

Aqui tentamos buscar o datasource.

O datasource pode conter dados brutos vindos de fontes como OpenStreetMap.

    final rawData = datasource['raw'] is Map
        ? Map<String, dynamic>.from(datasource['raw'])
        : <String, dynamic>{};

Aqui tentamos buscar dados brutos dentro de:

datasource['raw']

Isto pode conter campos como:

opening_hours
cuisine
    return PoiModel(

Agora devolvemos um novo PoiModel.

      id: id,

Mantém o id original.

      placeId: placeId,

Mantém o placeId original.

      nome: _valorNaoVazio(properties['name']) ?? nome,

Tenta actualizar o nome com o valor vindo dos detalhes.

Se não vier nome nos detalhes, mantém o nome antigo.

      descricao: _valorNaoVazio(properties['description']) ?? descricao,

Tenta actualizar a descrição.

Se não existir, mantém a descrição anterior.

      categoriaPrincipal: categoriaPrincipal,

Mantém a categoria principal anterior.

      categorias: categorias,

Mantém a lista de categorias anterior.

      endereco: _valorNaoVazio(properties['formatted']) ?? endereco,

Tenta actualizar a morada.

Se não vier nova morada, mantém a antiga.

      cidade: _valorNaoVazio(properties['city']) ?? cidade,

Tenta actualizar a cidade.

      pais: _valorNaoVazio(properties['country']) ?? pais,

Tenta actualizar o país.

      codigoPostal: _valorNaoVazio(properties['postcode']) ?? codigoPostal,

Tenta actualizar o código postal.

      latitude: latitude,

Mantém a latitude original.

      longitude: longitude,

Mantém a longitude original.

      distancia: distancia,

Mantém a distância original.

      telefone: _valorNaoVazio(properties['phone']) ??
          _valorNaoVazio(contact['phone']) ??
          telefone,

Aqui tenta preencher o telefone por prioridade.

Primeiro tenta:

properties['phone']

Se não existir, tenta:

contact['phone']

Se também não existir, mantém:

telefone

Ou seja, mantém o valor antigo.

      email: _valorNaoVazio(properties['email']) ??
          _valorNaoVazio(contact['email']) ??
          email,

Mesma lógica para o email.

Prioridade:

properties['email']
contact['email']
email antigo
      website: _valorNaoVazio(properties['website']) ??
          _valorNaoVazio(contact['website']) ??
          website,

Mesma lógica para website.

      horario: _valorNaoVazio(properties['opening_hours']) ??
          _valorNaoVazio(rawData['opening_hours']) ??
          horario,

Aqui tenta preencher o horário.

Prioridade:

properties['opening_hours']
rawData['opening_hours']
horário antigo
      cozinha: _valorNaoVazio(properties['cuisine']) ??
          _valorNaoVazio(rawData['cuisine']) ??
          cozinha,

Aqui tenta preencher o tipo de cozinha.

Prioridade:

properties['cuisine']
rawData['cuisine']
cozinha antiga
      tipo: _valorNaoVazio(properties['type']) ?? tipo,

Tenta actualizar o tipo.

Se não vier, mantém o antigo.

      detalhesRaw: detalhesFeature,

Guarda a resposta completa da API de detalhes.

      raw: raw,

Mantém a resposta original da pesquisa.

    );

Fecha o novo PoiModel.

  }

Fecha o método copyWithDetalhes.

Funções auxiliares

Agora temos funções privadas usadas dentro do model.

  static String? _valorNaoVazio(dynamic value) {

Esta função recebe qualquer valor:

dynamic value

e devolve:

String?

Ou seja, pode devolver texto ou null.

Ela serve para evitar guardar strings vazias.

O static significa que a função pertence à classe, e não a um objecto específico.

    if (value == null) return null;

Se o valor vier nulo, devolve null.

    final texto = value.toString().trim();

Converte o valor para texto.

Depois aplica:

trim()

que remove espaços no início e no fim.

Exemplo:

'  Restaurante  '.trim()

fica:

'Restaurante'
    if (texto.isEmpty) return null;

Se depois de limpar os espaços o texto ficar vazio, devolve null.

    return texto;

Se tiver texto válido, devolve o texto.

  }

Fecha a função.

  static double _toDouble(dynamic value) {

Esta função converte um valor qualquer para double.

Devolve sempre um número.

Se não conseguir converter, devolve 0.

    if (value == null) return 0;

Se o valor for nulo, devolve 0.

    if (value is num) return value.toDouble();

Se o valor já for numérico, converte para double.

Em Dart, num pode ser:

int

ou:

double

Então:

10

vira:

10.0
    return double.tryParse(value.toString()) ?? 0;

Se o valor não for número, tenta converter de texto para double.

Exemplo:

double.tryParse('37.0892')

vira:

37.0892

Se não conseguir converter, devolve null.

Por isso usamos:

?? 0

Ou seja, se a conversão falhar, devolve 0.

  }

Fecha a função.

  static double? _toNullableDouble(dynamic value) {

Esta função também converte para double, mas pode devolver null.

A diferença para _toDouble é:

_toDouble

devolve sempre um número.

_toNullableDouble

pode devolver null.

Usamos esta para campos opcionais, como distância.

    if (value == null) return null;

Se o valor for nulo, devolve null.

    if (value is num) return value.toDouble();

Se já for número, converte para double.

    return double.tryParse(value.toString());

Tenta converter para double.

Se não conseguir, o próprio tryParse devolve null.

  }

Fecha a função.

}

Fecha a classe PoiModel.

3. Resumo da lógica completa

Quando chamas isto:

final locais = await geoapifyService.buscarLocaisProximos(
  latitude: 37.0892,
  longitude: -8.2503,
  categories: ['catering.restaurant'],
  radius: 1000,
  limit: 20,
  incluirDetalhes: true,
);

Acontece isto:

O serviço valida se existe API key.
Valida se há categorias.
Valida se o raio e o limite são válidos.
Faz pedido à Geoapify em /v2/places.
Recebe uma lista chamada features.
Transforma cada item em PoiModel.
Se incluirDetalhes for false, devolve logo a lista.
Se incluirDetalhes for true, percorre cada POI.
Para cada POI com placeId, chama /v2/place-details.
Junta os detalhes ao PoiModel.
Devolve uma lista final de PoiModel.

No fim, a app recebe algo fácil de usar:

locais[0].nome
locais[0].endereco
locais[0].latitude
locais[0].longitude
locais[0].telefone
locais[0].website
locais[0].horario

Em vez de teres de andar sempre a escrever:

response.data['features'][0]['properties']['name']

ou:

response.data['features'][0]['geometry']['coordinates'][1]

O PoiModel organiza tudo para ti.