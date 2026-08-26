# Preparação do game para o backend Java

## Objetivo

Preparar o Godot para integração com o backend sem exigir que todas as features do jogo estejam concluídas.

O resultado desta etapa deve ser um jogo Web capaz de representar e reconstruir um estado mínimo, carregar o progresso oficial e enviar ações ao backend Java.

O backend Java é autoritativo: autentica o jogador, valida ações, calcula seus efeitos e persiste o estado oficial. O Godot mantém uma cópia para apresentação e não pode sobrescrever a economia enviando um `GameState` completo. Como não existe requisito de modo offline ou cache, o save local não faz parte da arquitetura planejada.

## Decisões de modelagem

O contrato JSON usa chaves em `snake_case`. O modelo `Cat` usa `cat_id`, `cat_type`, `name`, `appearance_id` e `status`; as chaves genéricas `id` e `type` não fazem parte desse contrato.

```json
{
  "cat_id": "cat-123",
  "cat_type": "default",
  "name": "Mingau",
  "appearance_id": "default",
  "status": "ATIVO"
}
```

`CatUpgrade` e `Upgrade` são classes distintas. `CatUpgrade` representa melhorias vinculadas obrigatoriamente a um `cat_id`; seu primeiro tipo é `AUTOMATION`, que automatiza a produção passiva do gato associado. `Upgrade` representa melhorias gerais do jogador, como `click_power`, e não possui `cat_id`.

O contrato JSON inicial de `CatUpgrade` será:

```json
{
  "cat_upgrade_id": "cat-upgrade-123",
  "cat_id": "cat-123",
  "cat_upgrade_type": "AUTOMATION",
  "cat_upgrade_level": 1
}
```

O contrato JSON atual de `Upgrade` é:

```json
{
  "upgrade_id": "click-power-basic",
  "upgrade_type": "CLICK_POWER",
  "upgrade_level": 1
}
```

O `upgrade_id` e o `upgrade_level` oficiais são controlados pelo backend Java. O Godot não incrementa o nível diretamente: ele envia a intenção de melhorar, e o backend valida custo e saldo antes de devolver o `Upgrade` atualizado.

Não será criado um `Upgrade` geral com `cat_id` opcional. Melhorias específicas, incluindo futuras opções como bônus de sorte ou velocidade, pertencem a `CatUpgrade`. A automação não é mais uma classe independente: ela é o tipo inicial `AUTOMATION`.

O `cat_id` é gerado e controlado exclusivamente pelo backend Java. O cliente Godot não cria identificadores de gatos; um `Cat` oficial é reconstruído a partir dos dados validados recebidos do servidor.

## O mínimo necessário no Godot

### 1. Modelos mínimos de CatUpgrade e Upgrade (concluído)

As classes `CatUpgrade` e `Upgrade` foram criadas como `RefCounted`, tipadas e independentes da interface, seguindo o padrão de `Cat`: validação, `to_dict()` e `from_dict()`. `CatUpgrade` exige `cat_id` e começa com o tipo `AUTOMATION`; `Upgrade` não possui `cat_id`.

### 2. Criar GameState (concluído)

Foi criado um estado agregado e independente da interface contendo:

- `save_version`;
- `park_name`;
- `food`;
- `total_food_earned`;
- `click_power`;
- `cats`;
- `cat_upgrades`;
- `upgrades`.

Somente dados do jogo pertencem a esse estado. Login, senha, e-mail, perfil e posição no ranking ficam fora do Godot.

### 3. Implementar a serialização completa de GameState (concluído; execução do teste pendente)

O estado implementa `to_dict()` e `from_dict()`, serializa e reconstrói seus modelos aninhados e valida campos obrigatórios, tipos, `save_version`, IDs duplicados e relacionamentos. Existe um teste de round-trip por JSON, ainda não executado neste ambiente por indisponibilidade do CLI do Godot.

### 4. Validar o contrato JSON (execução pendente)

O teste existente converte o estado para JSON, interpreta o conteúdo, reconstrói o `GameState` e compara o resultado com o original. Ele precisa ser executado em ambiente com o CLI do Godot.

Os scripts experimentais `SaveRepository` e `LocalSaveRepository` foram removidos. Eles modelavam escrita de estado completo pelo cliente, responsabilidade incompatível com a API autoritativa.

### 5. Isolar comunicação remota

O gameplay não deve acessar `HTTPRequest` diretamente. A camada de rede deve consultar o estado oficial e enviar ações assíncronas por contratos separados.

```text
Modo online
   ├── GameStateQuery
   └── GameActionClient
```

Não deve ser criado um `ApiSaveRepository.save_game(game_state)` que aceite o estado completo como origem do progresso. A API deverá receber comandos como `rename_park`, `click`, `buy_cat` e `buy_upgrade`; o Java calcula e devolve o resultado confirmado.

### 6. Separar a regra de clique da interface e da cena (fluxo local concluído; fluxo online pendente)

O `clicker_gato.gd` chama `game_state.earn_food(click_power)`, e a UI lê `game_state.food`. Isso separa a interface do estado no protótipo atual.

Na integração online, não será feita uma requisição por clique. O Godot manterá cliques pendentes, mostrará uma previsão visual e enviará lotes periódicos contendo `command_id`, `click_count` e `base_revision`. O Java validará limites, usará o `click_power` oficial, persistirá uma única atualização e devolverá o estado confirmado. `command_id` impedirá recompensa duplicada em repetições, enquanto `revision` tratará concorrência e permanecerá distinta de `save_version`.

Cliques realizados durante uma requisição permanecerão pendentes para o lote seguinte. A previsão visual nunca será considerada saldo oficial.

Produção passiva será calculada no Java pela taxa oficial e pelo tempo desde a última atualização, ao carregar o estado ou processar uma ação, evitando requisições e gravações contínuas.

### 7. Testar a exportação Web e HTTP

Gerar uma exportação de teste e confirmar:

- abertura no navegador;
- funcionamento dos controles;
- adaptação ao espaço da página;
- desempenho aceitável;
- capacidade de realizar uma requisição HTTP;
- interpretação da resposta JSON;
- tratamento básico de erro e indisponibilidade.

## Estado mínimo sugerido

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

O backend Java deve respeitar as chaves `snake_case` ao devolver o estado e ao receber comandos, mantendo o contrato consistente. A presença de `to_dict()` no Godot não autoriza o envio do estado econômico completo para persistência oficial.

## Critérios de conclusão

O desenvolvimento do backend pode começar quando:

- [x] `CatUpgrade` e `Upgrade` possuírem modelos mínimos, tipados e validáveis;
- [x] `GameState` agregar todo o estado persistente;
- [x] `GameState` puder ser convertido para JSON e reconstruído;
- [x] tipos, campos obrigatórios e `save_version` forem validados;
- [ ] o teste de round-trip for executado no Godot;
- [x] os scripts experimentais de save local forem removidos;
- [x] o clique alterar o estado por uma regra de gameplay, sem modificar o saldo diretamente na UI ou na cena;
- [ ] o contrato HTTP separar consulta de estado e envio de ações;
- [ ] o contrato de lote de cliques definir idempotência e revisão;
- [ ] a exportação Web abrir corretamente;
- [ ] uma requisição HTTP de teste funcionar no navegador.

## O que não bloqueia o Java

Não é necessário concluir antes do backend:

- compra de gato;
- compra e aplicação funcional de upgrades;
- ganho passivo funcional;
- ranking;
- minigames e batalhas;
- customização e gerenciamento completo dos gatos;
- ganho offline;
- arte, música e interface finais.

Os modelos mínimos de `CatUpgrade` e `Upgrade` fazem parte da preparação porque pertencem ao contrato persistente. A produção passiva funcional do tipo `AUTOMATION` será implementada posteriormente.

## Próximo passo após esta etapa

Com esses critérios atendidos, iniciar o primeiro corte integrado:

```text
Godot Web
→ carregar estado oficial
→ enviar `rename_park`
→ Java validar e persistir
→ recarregar e confirmar o nome
```

Cadastro, login, sessão, banco e validação oficial serão implementados no site e no backend Java. Ações econômicas posteriores seguirão o mesmo princípio: o cliente envia intenção, e o servidor calcula e confirma o resultado. Para cliques, as intenções serão agrupadas; para produção passiva, o servidor calculará o acumulado pelo tempo.
