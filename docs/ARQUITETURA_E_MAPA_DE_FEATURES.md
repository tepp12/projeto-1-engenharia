# Arquitetura e mapa de features

## Visão do projeto

Cat Clicker é um jogo de gerenciamento de parque de gatos. Seu ciclo principal é:

```text
clicar no gato
→ ganhar ração
→ comprar gatos ou melhorias
→ aumentar a produção
→ repetir o ciclo
```

O produto será executado no navegador dentro de um site autenticado. O Godot apresenta o jogo, enquanto o backend Java mantém o progresso oficial e fornece dados também usados pelo perfil e pelo ranking.

```text
Site + Godot Web
       │
       │ HTTPS / JSON
       ▼
Backend Java / Spring Boot
       │
       ▼
PostgreSQL
```

## Princípios arquiteturais

- O backend Java é a fonte oficial do progresso.
- O Godot mantém uma representação do estado para gameplay e interface.
- O cliente envia ações; o backend valida, calcula, persiste e devolve o resultado.
- Login, credenciais, perfil e ranking ficam fora do `GameState`.
- O contrato JSON usa chaves em `snake_case`.
- `food`, `total_food_earned` e `click_power` são inteiros de 64 bits no Godot e correspondem a `long` no Java.
- `save_version` identifica a versão do formato persistente; uma futura `revision` controlará concorrência na API.

## Responsabilidades

### Godot

- executar e apresentar as mecânicas do jogo;
- reconstruir o estado devolvido pela API;
- enviar ações do jogador;
- manter dados transitórios de interface separados do estado confirmado;
- ser exportado para Web e incorporado ao site.

### Site

- cadastro, login e logout;
- perfil e navegação;
- página do ranking;
- página que incorpora o jogo exportado.

### Backend Java

- autenticar e identificar o jogador;
- validar e processar ações;
- armazenar e recuperar o progresso;
- calcular produção passiva, pontuação e ranking;
- controlar concorrência e idempotência;
- fornecer a API usada pelo site e pelo Godot.

### Banco de dados

- contas e sessões;
- progresso oficial do jogo;
- dados necessários para perfil e ranking.

## Estado atual do Godot

O projeto está em `jogo/` e sua configuração está em `jogo/project.godot`.

Implementado:

- clique no gato e resposta visual;
- contador de ração;
- `GlobalValues` com uma instância de `GameState`;
- `GameState` tipado com invariantes e valores iniciais;
- `Cat`, `CatUpgrade` e `Upgrade` tipados e serializáveis;
- `to_dict()` e `from_dict()` para o estado completo;
- validação de campos, tipos, versão, IDs e relacionamentos;
- economia baseada em inteiros;
- teste de round-trip `GameState → JSON → GameState`.

Validação concluída com Godot 4.7.2:

- round-trip JSON com código `0`;
- carregamento headless do projeto com código `0`.

Ainda não implementado:

- exportação Web;
- página do site para incorporar o jogo;
- cliente HTTP no Godot;
- backend Java, autenticação e banco;
- persistência remota por jogador;
- compras, produção passiva e ranking funcionais.

## Contrato de estado

O estado mínimo é:

```json
{
  "save_version": 1,
  "park_name": "Parque do Jogador",
  "food": 0,
  "total_food_earned": 0,
  "click_power": 1,
  "cats": [],
  "cat_upgrades": [],
  "upgrades": []
}
```

Entidades aninhadas:

| Modelo | Campos principais |
|---|---|
| `Cat` | `cat_id`, `cat_type`, `name`, `appearance_id`, `status` |
| `CatUpgrade` | `cat_upgrade_id`, `cat_id`, `cat_upgrade_type`, `cat_upgrade_level` |
| `Upgrade` | `upgrade_id`, `upgrade_type`, `upgrade_level` |

Todo `CatUpgrade` referencia um `Cat` existente. `Upgrade` representa melhorias gerais e não possui `cat_id`.

## Integração planejada

O primeiro corte vertical usará `park_name`, pois permite validar todo o fluxo sem depender da economia:

```text
login no site
→ abrir o Godot Web
→ carregar o estado oficial
→ enviar rename_park
→ Java validar e persistir
→ Godot aplicar o estado confirmado
```

### Cliques

O Godot acumulará cliques pendentes e os enviará em lotes. A interface poderá mostrar uma previsão imediata, mas o Java calculará a recompensa usando o `click_power` oficial.

O comando de lote deverá incluir:

- `command_id`, para idempotência;
- `click_count`, com a quantidade de cliques;
- `base_revision`, para controle de concorrência.

### Produção passiva

O backend calculará o acumulado usando a taxa oficial e o tempo desde a última atualização. O cálculo ocorrerá ao carregar o estado ou processar uma ação, evitando gravações contínuas.

## Mapa de features

| Feature | Situação | Próximo passo |
|---|---|---|
| Estado e contrato JSON | Implementado e validado | Manter compatibilidade por versão |
| Exportação Godot Web | Pendente | Criar preset e testar no navegador |
| Site | Pendente | Incorporar o build Web e preparar autenticação |
| Backend Java | Pendente | Criar DTOs e primeiro fluxo com `rename_park` |
| Cliente HTTP Godot | Pendente | Carregar estado e enviar ações |
| Clique e ração | Protótipo local implementado | Integrar lotes ao backend |
| Gatos e upgrades | Modelos implementados | Implementar compra e progressão |
| Produção passiva | Modelo inicial definido | Calcular oficialmente no backend |
| Ranking | Pendente | Calcular e consultar pelo backend |
| Customização e minigames | Pendente | Desenvolver após o ciclo principal |

## Próximo marco

O backend já pode ser iniciado com o contrato atual. A primeira integração completa exigirá:

1. backend Java com carregamento do estado e `rename_park`;
2. exportação Godot Web;
3. página do site incorporando o jogo;
4. comunicação HTTP autenticada entre Godot e Java.

O plano operacional está em `docs/PLANO_DE_TASKS.md` e o contrato de preparação para o backend em `docs/PREPARACAO_DO_GAME_PARA_JAVA.md`.
