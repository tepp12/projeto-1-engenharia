# Plano de tasks para preparação do Godot

## Objetivo

Fechar o contrato mínimo do lado Godot antes da integração com o backend Java.

Esta etapa não exige concluir o ciclo econômico do jogo. O objetivo é tornar o estado tipado, serializável, validável e independente da implementação de persistência.

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

### 2. Criar GameState

Este é o próximo passo da preparação do Godot.

- [ ] Criar um estado agregado e independente da UI.
- [ ] Adicionar `save_version`.
- [ ] Adicionar `park_name`.
- [ ] Adicionar `food`.
- [ ] Adicionar `total_food_earned`.
- [ ] Adicionar `click_power`.
- [ ] Adicionar `cats`.
- [ ] Adicionar `cat_upgrades`.
- [ ] Adicionar `upgrades`.
- [ ] Usar tipos estáticos sempre que declarativos no GDScript.

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

### 3. Implementar a serialização completa de GameState

- [ ] Implementar `to_dict()`.
- [ ] Implementar `from_dict()`.
- [ ] Serializar os modelos aninhados.
- [ ] Reconstruir os modelos aninhados.
- [ ] Validar campos obrigatórios.
- [ ] Validar os tipos recebidos.
- [ ] Validar `save_version`.
- [ ] Rejeitar estado incompatível ou inválido.
- [ ] Confirmar que todo o JSON usa `snake_case`.

### 4. Implementar save local

- [ ] Criar um estado mínimo.
- [ ] Converter o estado para JSON.
- [ ] Salvar o JSON localmente.
- [ ] Ler o arquivo salvo.
- [ ] Reconstruir o `GameState`.
- [ ] Validar o estado reconstruído.
- [ ] Tratar arquivo ausente, inválido ou incompatível.

A prova do contrato deve executar o fluxo:

```text
criar estado
→ converter para JSON
→ salvar
→ recarregar
→ reconstruir
→ validar
```

### 5. Isolar a persistência

- [ ] Definir um contrato de persistência, como `SaveRepository`.
- [ ] Fazer o gameplay depender desse contrato.
- [ ] Criar `LocalSaveRepository`.
- [ ] Manter acesso a arquivos fora das regras de gameplay.
- [ ] Reservar `ApiSaveRepository` como implementação futura.
- [ ] Manter requisições HTTP fora das entidades e regras do domínio.

A dependência esperada é:

```text
Gameplay
   └── SaveRepository
       ├── LocalSaveRepository
       └── ApiSaveRepository
```

### 6. Separar a regra de clique da UI e da cena

- [ ] Remover a alteração direta de `GlobalValues.dinheiro` do fluxo de clique.
- [ ] Criar uma operação de domínio como `game_state.earn_food(amount)`.
- [ ] Atualizar `food` nessa operação.
- [ ] Atualizar `total_food_earned` nessa operação.
- [ ] Fazer `clicker_gato.gd` apenas solicitar a ação.
- [ ] Fazer a UI apenas apresentar o estado resultante.

### 7. Validar exportação Web e HTTP

- [ ] Criar ou revisar a configuração de exportação Web.
- [ ] Confirmar que o jogo abre no navegador.
- [ ] Confirmar o funcionamento dos controles.
- [ ] Confirmar a adaptação ao espaço da página.
- [ ] Realizar uma requisição HTTP de teste.
- [ ] Interpretar uma resposta JSON.
- [ ] Tratar indisponibilidade e erro básico de rede.

## Critério para iniciar a integração Java

A preparação estará concluída quando os sete passos anteriores estiverem validados.

A primeira integração real poderá então substituir a persistência local:

```text
Godot Web
→ carregar estado pela API
→ alterar um dado simples
→ salvar pela API
→ recarregar
→ confirmar a persistência
```

`park_name` é um dado adequado para essa primeira prova por não depender das regras econômicas ainda pendentes.

## Fora do escopo desta sequência

As seguintes funcionalidades não bloqueiam o início do backend Java:

- compra de gato;
- compra e aplicação funcional de upgrades;
- ganho passivo funcional;
- ranking;
- minigames;
- customização e gerenciamento completo dos gatos;
- ganho offline;
- arte, música e interface finais.

Os modelos mínimos de `CatUpgrade` e `Upgrade` fazem parte desta sequência porque pertencem ao contrato persistente. A produção passiva funcional do tipo `AUTOMATION` será implementada posteriormente.
