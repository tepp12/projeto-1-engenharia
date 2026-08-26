# Plano de tasks

## Objetivo

Evoluir o protótipo Godot para um jogo Web integrado a um site e a um backend Java autoritativo.

## Concluído no Godot

- [x] Criar os modelos `Cat`, `CatUpgrade` e `Upgrade`.
- [x] Criar o `GameState` independente da UI.
- [x] Adicionar `save_version`, `park_name`, `food`, `total_food_earned` e `click_power`.
- [x] Adicionar as coleções de gatos e upgrades.
- [x] Usar inteiros de 64 bits na economia.
- [x] Proteger as invariantes principais.
- [x] Implementar `to_dict()` e `from_dict()`.
- [x] Validar campos, tipos, versão, IDs e relacionamentos.
- [x] Integrar `GameState` ao `GlobalValues`, clique e UI.
- [x] Criar e executar o teste de round-trip JSON.
- [x] Executar a verificação headless do projeto.

O contrato mínimo validado é:

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

## Próximas etapas

### 1. Criar o backend Java

- [ ] Criar o projeto Spring Boot.
- [ ] Criar os DTOs do estado e das entidades aninhadas.
- [ ] Mapear `food`, `total_food_earned` e `click_power` para `long`.
- [ ] Criar o modelo persistente e o repositório de banco.
- [ ] Implementar o carregamento do estado oficial.
- [ ] Implementar a ação `rename_park`.
- [ ] Devolver o estado atualizado e sua `revision`.
- [ ] Testar os endpoints fora do Godot.

### 2. Preparar Godot Web e site

- [ ] Criar o preset de exportação Web.
- [ ] Confirmar que o jogo abre no navegador.
- [ ] Testar controles, tamanho e responsividade.
- [ ] Criar a página do site que incorpora o jogo.
- [ ] Preparar login e sessão.

### 3. Integrar Godot e Java

- [ ] Criar uma camada de rede separada do domínio e da UI.
- [ ] Carregar o estado oficial pela API.
- [ ] Reconstruir o estado com `GameState.from_dict()`.
- [ ] Enviar `rename_park` e aplicar a resposta confirmada.
- [ ] Tratar autenticação, CORS, timeout e indisponibilidade.

### 4. Integrar a economia

- [ ] Acumular cliques pendentes no Godot.
- [ ] Enviar cliques em lotes com `command_id`, `click_count` e `base_revision`.
- [ ] Mostrar previsão visual separada do estado confirmado.
- [ ] Validar limites e idempotência no backend.
- [ ] Implementar compra de gatos e upgrades como ações do servidor.
- [ ] Calcular produção passiva no backend com base no tempo.

### 5. Completar o sistema online

- [ ] Associar o progresso ao jogador autenticado.
- [ ] Tratar concorrência entre sessões ou dispositivos.
- [ ] Calcular pontuação e ranking no backend.
- [ ] Exibir perfil e ranking no site.

## Primeiro corte vertical

```text
login no site
→ abrir Godot Web
→ carregar estado oficial
→ enviar rename_park
→ Java validar e persistir
→ recarregar e confirmar o nome
```

Esse corte comprova autenticação, comunicação, reconstrução do estado e persistência antes da implementação das regras econômicas online.

## Fora do caminho crítico inicial

- minigames e batalhas;
- customização completa dos gatos;
- arte, música e interface finais;
- otimizações avançadas;
- funcionalidades adicionais de progressão.
