# Preparação do game para o backend Java

## Objetivo

Definir a fronteira entre o Godot e o backend Java para que ambos usem o mesmo contrato de estado e de ações.

O backend mantém o progresso oficial. O Godot carrega esse estado, envia ações do jogador e atualiza a interface com os resultados confirmados.

## Situação do Godot

A preparação do modelo está concluída:

- `GameState` agregado, tipado e independente da UI;
- `Cat`, `CatUpgrade` e `Upgrade` serializáveis;
- contrato JSON em `snake_case`;
- invariantes e relacionamentos validados;
- economia baseada em inteiros de 64 bits;
- round-trip JSON e carregamento headless aprovados no Godot 4.7.2.

O backend Java pode ser iniciado com esse contrato. Exportação Web, site e cliente HTTP serão necessários para a primeira integração completa.

## Estado mínimo

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

## Mapeamento para Java

| JSON | Java | Regra |
|---|---|---|
| `save_version` | `int` | versão do formato |
| `park_name` | `String` | não vazio após normalização |
| `food` | `long` | maior ou igual a zero |
| `total_food_earned` | `long` | maior ou igual a `food` |
| `click_power` | `long` | maior que zero |
| `cats` | `List<CatDto>` | IDs únicos |
| `cat_upgrades` | `List<CatUpgradeDto>` | IDs únicos e `cat_id` existente |
| `upgrades` | `List<UpgradeDto>` | IDs únicos |

Modelos aninhados:

```json
{
  "cat_id": "cat-123",
  "cat_type": "default",
  "name": "Mingau",
  "appearance_id": "default",
  "status": "ATIVO"
}
```

```json
{
  "cat_upgrade_id": "cat-upgrade-123",
  "cat_id": "cat-123",
  "cat_upgrade_type": "AUTOMATION",
  "cat_upgrade_level": 1
}
```

```json
{
  "upgrade_id": "click-power-basic",
  "upgrade_type": "CLICK_POWER",
  "upgrade_level": 1
}
```

## Contrato HTTP inicial

O primeiro fluxo deve carregar o estado e alterar somente o nome do parque.

```http
GET /api/game-state
```

Resposta sugerida:

```json
{
  "revision": 1,
  "game_state": {
    "save_version": 1,
    "park_name": "Parque do Jogador",
    "food": 0,
    "total_food_earned": 0,
    "click_power": 1,
    "cats": [],
    "cat_upgrades": [],
    "upgrades": []
  }
}
```

```http
PATCH /api/game-state/park-name
Content-Type: application/json
```

```json
{
  "park_name": "Parque dos Gatos"
}
```

O backend identifica o jogador pela sessão, valida o nome, persiste a alteração, incrementa `revision` e devolve o estado atualizado.

## Próximas ações da API

Depois do primeiro fluxo, a API poderá receber:

- lotes de cliques;
- compra de gatos;
- aquisição de `CatUpgrade`;
- compra de `Upgrade`;
- alterações permitidas em gatos e parque.

Para cliques, o Godot enviará `command_id`, `click_count` e `base_revision`. O backend aplicará o `click_power` oficial e garantirá idempotência.

A produção passiva será calculada pelo backend usando a taxa oficial e o tempo desde a última atualização.

## Primeira integração completa

- [ ] backend com os endpoints iniciais;
- [ ] exportação Godot Web funcionando;
- [ ] site incorporando o jogo;
- [ ] sessão compartilhada com a API;
- [ ] CORS configurado;
- [ ] Godot carregando e reconstruindo o estado;
- [ ] `rename_park` persistido e confirmado após recarregar.

Compras, cliques em lote, produção passiva e ranking não bloqueiam esse primeiro corte.
