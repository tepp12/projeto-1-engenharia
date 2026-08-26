# Plano de tasks para preparação do Godot

## Objetivo

Fechar o contrato mínimo do lado Godot antes da integração com o backend Java.

Esta etapa não exige concluir o ciclo econômico do jogo. O objetivo é tornar o estado tipado, serializável, validável e independente da implementação de persistência.

No modo online, o backend Java será autoritativo. O Godot manterá uma cópia do estado para apresentação e enviará ações ao servidor; não enviará um `GameState` econômico completo para ser aceito como progresso oficial. O save local foi retirado do caminho planejado porque não existe requisito de modo offline ou cache.

## Decisões de modelagem

O contrato JSON usa chaves em `snake_case`.

O modelo `Cat` usa:

- `cat_id`;
- `cat_type`;
- `name`;
- `appearance_id`;
- `status`.

As chaves genéricas `id` e `type` não fazem parte do contrato JSON de `Cat`.

`CatUpgrade` é uma classe própria para representar melhorias vinculadas obrigatoriamente a um `cat_id`. Seu primeiro tipo é `AUTOMATION`, responsável por automatizar a produção passiva do gato associado. Outros tipos específicos, como sorte ou velocidade, poderão ser adicionados futuramente.

`Upgrade` é uma classe separada para representar melhorias gerais do jogador, como `click_power`, e não possui `cat_id`.

O contrato JSON implementado de `Upgrade` usa `upgrade_id`, `upgrade_type` e `upgrade_level`. O identificador e o nível oficial são controlados pelo backend Java; o Godot apenas reconstrói o objeto validado recebido do servidor.

Não será criado um `Upgrade` geral com `cat_id` opcional. Melhorias específicas de gato pertencem a `CatUpgrade`; a automação deixa de ser uma classe e passa a ser o tipo inicial dessa entidade.

## Sequência de implementação

### 1. Criar os modelos mínimos de CatUpgrade e Upgrade — concluído

- [x] Criar `CatUpgrade` como `RefCounted`.
- [x] Usar tipagem estática em propriedades, parâmetros e retornos.
- [x] Definir a associação obrigatória de `CatUpgrade` com `cat_id`.
- [x] Criar o tipo inicial `AUTOMATION`.
- [x] Implementar `to_dict()` e `from_dict()`.
- [x] Validar campos obrigatórios e tipos de `CatUpgrade`.
- [x] Criar `Upgrade` como `RefCounted`.
- [x] Manter `Upgrade` sem `cat_id`.
- [x] Implementar `to_dict()` e `from_dict()` para `Upgrade`.
- [x] Validar campos obrigatórios e tipos de `Upgrade`.

### 2. Criar GameState — concluído

- [x] Criar um estado agregado e independente da UI.
- [x] Adicionar `save_version`.
- [x] Adicionar `park_name`.
- [x] Adicionar `food`.
- [x] Adicionar `total_food_earned`.
- [x] Adicionar `click_power`.
- [x] Adicionar `cats`.
- [x] Adicionar `cat_upgrades`.
- [x] Adicionar `upgrades`.
- [x] Usar tipos estáticos sempre que declarativos no GDScript.
- [x] Proteger as invariantes principais e expor leitura controlada.

O estado mínimo esperado é:

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

### 3. Implementar a serialização completa de GameState — implementado, execução do teste pendente

- [x] Implementar `to_dict()`.
- [x] Implementar `from_dict()`.
- [x] Serializar os modelos aninhados.
- [x] Reconstruir os modelos aninhados.
- [x] Validar campos obrigatórios.
- [x] Validar os tipos recebidos.
- [x] Validar `save_version`.
- [x] Rejeitar estado incompatível ou inválido.
- [x] Confirmar que todo o JSON usa `snake_case`.
- [x] Criar teste de round-trip por JSON.
- [ ] Executar o teste com o CLI do Godot.

### 4. Validar o contrato JSON — implementação concluída, execução pendente

- [x] Criar um estado mínimo.
- [x] Converter o estado para JSON.
- [x] Interpretar novamente o JSON.
- [x] Reconstruir o `GameState`.
- [x] Comparar o estado reconstruído com o original.
- [ ] Executar o teste de round-trip no Godot.

A prova do contrato deve executar o fluxo:

```text
criar estado
→ converter para JSON
→ interpretar o JSON
→ reconstruir
→ validar
```

O teste não persiste progresso e não cria uma segunda fonte de verdade.

### 5. Preparar contratos de comunicação autoritativa

- [x] Remover os scripts experimentais `SaveRepository` e `LocalSaveRepository`.
- [ ] Manter requisições HTTP fora das entidades e regras do domínio.
- [ ] Definir resultados explícitos para ausência, dados inválidos e falhas de persistência.
- [ ] Definir `GameStateQuery` para carregar o estado oficial.
- [ ] Definir `GameActionClient` para enviar comandos assíncronos.
- [ ] Não criar `save_game(game_state)` para a API.

A dependência esperada é:

```text
Modo online autoritativo
   ├── GameStateQuery
   └── GameActionClient
       ├── rename_park
       ├── send_click_batch
       └── futuras compras e upgrades
```

Não deve existir uma implementação remota genérica de `save_game(game_state)` que permita ao cliente sobrescrever o progresso oficial.

### 6. Separar a regra de clique da UI e da cena — concluído no fluxo local

- [x] Remover a alteração direta de `GlobalValues.dinheiro` do fluxo de clique.
- [x] Criar `game_state.earn_food(amount)`.
- [x] Atualizar `food` nessa operação.
- [x] Atualizar `total_food_earned` nessa operação.
- [x] Fazer `clicker_gato.gd` solicitar a operação de domínio local.
- [x] Fazer a UI apenas apresentar o estado resultante.
- [ ] Criar um contador separado de cliques pendentes.
- [ ] Enviar cliques em lotes periódicos, e não uma requisição por clique.
- [ ] Incluir `command_id`, `click_count` e `base_revision` no comando.
- [ ] Manter cliques ocorridos durante uma requisição para o lote seguinte.
- [ ] Exibir uma previsão otimista sem alterar o estado confirmado.
- [ ] Reconciliar a previsão com a resposta oficial.
- [ ] Fazer o Java validar limites, aplicar o `click_power` oficial e garantir idempotência.

### 7. Validar exportação Web e HTTP

- [ ] Criar ou revisar a configuração de exportação Web.
- [ ] Confirmar que o jogo abre no navegador.
- [ ] Confirmar o funcionamento dos controles.
- [ ] Confirmar a adaptação ao espaço da página.
- [ ] Realizar uma requisição HTTP de teste.
- [ ] Interpretar uma resposta JSON.
- [ ] Tratar indisponibilidade e erro básico de rede.
- [ ] Tratar timeout, repetição idempotente e conflito de revisão.

## Critério para iniciar a integração Java

A preparação estará concluída quando os sete passos anteriores estiverem validados.

A primeira integração real não enviará o save local ao servidor. Ela carregará o estado oficial e enviará uma ação simples:

```text
Godot Web
→ carregar estado pela API
→ enviar `rename_park`
→ Java validar e persistir
→ recarregar
→ confirmar a persistência
```

`park_name` é adequado para essa primeira prova por não depender das regras econômicas ainda pendentes. Depois dela, clique, compras e upgrades deverão seguir o mesmo princípio: o Godot envia a intenção e o Java calcula o resultado oficial.

O clique será a segunda integração. O Godot agrupará cliques por intervalo ou limite de lote, enquanto o Java calculará a recompensa em uma única transação. `save_version` continuará indicando a versão do formato; `revision`, mantida no contrato da API, controlará concorrência do progresso.

## Fora do escopo desta sequência

As seguintes funcionalidades não bloqueiam o início do backend Java:

- compra de gato;
- compra e aplicação funcional de upgrades;
- ganho passivo funcional no cliente;
- ranking;
- minigames;
- customização e gerenciamento completo dos gatos;
- ganho offline;
- arte, música e interface finais.

Os modelos mínimos de `CatUpgrade` e `Upgrade` fazem parte desta sequência porque pertencem ao contrato persistente. A produção passiva funcional do tipo `AUTOMATION` será implementada posteriormente no backend, calculando o acumulado pela taxa oficial e pelo tempo desde a última atualização, sem gravações contínuas.
