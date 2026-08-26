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

`Automation` e `Upgrade` permanecem classes distintas. `Automation` representa produção passiva associada obrigatoriamente a um `cat_id`. `Upgrade` representa melhorias gerais do jogador, como `click_power`, e não possui `cat_id`.

O contrato JSON atual de `Upgrade` é:

```json
{
  "upgrade_id": "click-power-basic",
  "upgrade_type": "CLICK_POWER",
  "upgrade_level": 1
}
```

O `upgrade_id` e o `upgrade_level` oficiais são controlados pelo backend Java. O Godot não incrementa o nível diretamente: ele envia a intenção de melhorar, e o backend valida custo e saldo antes de devolver o `Upgrade` atualizado.

Não será criado, neste momento, um modelo genérico de upgrade com `cat_id` opcional. Um campo que só se aplica a parte dos objetos indica responsabilidades diferentes. Caso surjam futuramente outras melhorias específicas de gato, como bônus de sorte ou velocidade, a necessidade de generalização será avaliada naquele momento.

O `cat_id` é gerado e controlado exclusivamente pelo backend Java. O cliente Godot não cria identificadores de gatos; um `Cat` oficial é reconstruído a partir dos dados validados recebidos do servidor.

## O mínimo necessário no Godot

### 1. Criar os modelos mínimos de Automation e Upgrade

Criar classes `RefCounted`, tipadas e independentes da interface, seguindo o padrão de `Cat`: validação, `to_dict()` e `from_dict()`. `Automation` deve exigir `cat_id`; `Upgrade` não deve possuir esse campo.

### 2. Criar GameState

Criar um estado agregado e independente da interface contendo:

- `save_version`;
- `park_name`;
- `food`;
- `total_food_earned`;
- `click_power`;
- `cats`;
- `automations`;
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
  "automations": [],
  "upgrades": []
}
```

O backend Java deve respeitar as chaves `snake_case` ao receber ou devolver os dados, mantendo o contrato consistente entre `GameState` e seus modelos aninhados.

## Critérios de conclusão

O desenvolvimento do backend pode começar quando:

- [ ] `Automation` e `Upgrade` possuírem modelos mínimos, tipados e validáveis;
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

Os modelos mínimos de `Automation` e `Upgrade` fazem parte da preparação porque pertencem ao contrato persistente. Suas regras funcionais serão implementadas posteriormente.

## Próximo passo após esta etapa

Com esses critérios atendidos, iniciar o primeiro corte integrado:

```text
Godot Web → carregar save remoto → alterar park_name → salvar → recarregar
```

Cadastro, login, sessão, banco e validação oficial serão implementados no site e no backend Java.
