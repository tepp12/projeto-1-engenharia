# Preparação do game para o backend Java

## Objetivo

Preparar o Godot para integração com o backend sem exigir que todas as features do jogo estejam concluídas.

O resultado desta etapa deve ser um jogo Web capaz de representar, salvar e carregar um estado mínimo por meio de uma camada de persistência substituível por API.

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

### 1. Criar os modelos mínimos de CatUpgrade e Upgrade

Criar classes `RefCounted`, tipadas e independentes da interface, seguindo o padrão de `Cat`: validação, `to_dict()` e `from_dict()`. `CatUpgrade` deve exigir `cat_id` e começar com o tipo `AUTOMATION`; `Upgrade` não deve possuir `cat_id`.

### 2. Criar GameState

Criar um estado agregado e independente da interface contendo:

- `save_version`;
- `park_name`;
- `food`;
- `total_food_earned`;
- `click_power`;
- `cats`;
- `cat_upgrades`;
- `upgrades`.

Somente dados do jogo pertencem a esse estado. Login, senha, e-mail, perfil e posição no ranking ficam fora do Godot.

### 3. Implementar a serialização completa de GameState

O estado deve implementar `to_dict()` e `from_dict()`, serializar e reconstruir seus modelos aninhados e validar campos obrigatórios, tipos e `save_version`.

### 4. Implementar save local

O estado deve ser convertido para JSON, salvo localmente, recarregado, reconstruído e validado. O save local prova o contrato de dados antes da API e deve tratar arquivo ausente, inválido ou incompatível.

### 5. Isolar a persistência

O gameplay não deve acessar arquivos ou `HTTPRequest` diretamente. Ele deve depender de um contrato como `SaveRepository`, usando `LocalSaveRepository` agora e permitindo uma futura `ApiSaveRepository`.

```text
Gameplay
   └── SaveRepository
       ├── LocalSaveRepository
       └── ApiSaveRepository
```

### 6. Separar a regra de clique da interface e da cena

A UI deve apenas solicitar ações e exibir resultados. O clique deve chamar uma operação como `game_state.earn_food(amount)`, responsável por atualizar `food` e `total_food_earned`. `clicker_gato.gd` apenas solicita a ação, e a UI apenas apresenta o resultado.

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

O backend Java deve respeitar as chaves `snake_case` ao receber ou devolver os dados, mantendo o contrato consistente entre `GameState` e seus modelos aninhados.

## Critérios de conclusão

O desenvolvimento do backend pode começar quando:

- [ ] `CatUpgrade` e `Upgrade` possuírem modelos mínimos, tipados e validáveis;
- [ ] `GameState` agregar todo o estado persistente;
- [ ] `GameState` puder ser convertido para JSON e reconstruído;
- [ ] tipos, campos obrigatórios e `save_version` forem validados;
- [ ] salvar e carregar localmente funcionar;
- [ ] a persistência estiver isolada por um contrato como `SaveRepository`;
- [ ] o clique alterar o estado por uma regra de gameplay, sem modificar o saldo diretamente na UI ou na cena;
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
Godot Web → carregar save remoto → alterar park_name → salvar → recarregar
```

Cadastro, login, sessão, banco e validação oficial serão implementados no site e no backend Java.
