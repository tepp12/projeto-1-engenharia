# Arquitetura e mapa de features

## Propósito

Este documento orienta a arquitetura central do Cat Clicker: preparar o domínio do jogo no Godot e construir sua integração com site, backend Java, save remoto e ranking.

Ele complementa os documentos de requisitos e casos de uso presentes nesta pasta. O relatório inicial está desatualizado quanto aos sistemas online: embora os registre como fora do escopo original, a decisão atual do projeto é tratá-los como parte essencial e como principal eixo de desenvolvimento.

## Escopo e direção do projeto

O Cat Clicker é um jogo de gerenciamento de parque de gatos. Seu ciclo principal documentado é:

```text
Clicar no gato
  → ganhar ração
  → investir em gato, automação ou upgrade
  → aumentar a produção
  → repetir o ciclo
```

Os três casos de uso centrais são:

1. clicar no gato para ganhar ração;
2. gastar ração em gatos ou upgrades;
3. automatizar gatos para gerar ração passivamente.

O projeto atual não termina no cliente Godot. Login, persistência remota e ranking fazem parte do sistema pretendido. O núcleo local continua necessário porque define o que será salvo e validado, mas deve ser desenvolvido pensando no contrato com o backend desde o início.

## Objetivo arquitetural principal

O jogador deverá entrar pelo site, autenticar-se e abrir o jogo no navegador. O Godot carregará o progresso associado à sessão, enviará ações do gameplay ao backend e receberá o estado atualizado. O site consultará o mesmo backend para apresentar perfil e ranking.

```text
Login no site
  → sessão autenticada
  → abertura do Godot Web
  → carregamento do progresso
  → ações do jogo validadas no backend
  → persistência no banco
  → atualização do perfil e ranking
```

Essa integração é uma feature transversal: ela afeta o modelo de dados, as regras econômicas, a persistência, a segurança, a exportação Web e a forma de calcular a progressão.

## Estado atual na branch `main`

O projeto Godot válido está em `jogo/`, com configuração em `jogo/project.godot`.

Já existe:

- clique no gato para gerar ração;
- contador visual de ração;
- poder de clique no estado global;
- resposta visual do gato ao mouse e ao clique;
- overlay básico de FPS e versão.
- modelo `Cat` com validação, `to_dict()` e `from_dict()`;
- contrato JSON de `Cat` padronizado com `cat_id` e `cat_type`.
- modelo `Upgrade` com tipagem, validação, `to_dict()` e `from_dict()`;
- contrato JSON de `Upgrade` padronizado com `upgrade_id`, `upgrade_type` e `upgrade_level`.

Ainda faltam o modelo de `CatUpgrade`, o `GameState`, a serialização do estado agregado, a persistência local isolada, a separação da regra de clique, a preparação Web/HTTP e o restante do ciclo econômico.

## Separação de responsabilidades

### Godot

- executar as mecânicas do jogo;
- representar ração, gatos, upgrades específicos de gato e upgrades gerais;
- exibir a interface interna do jogo;
- transformar o estado do jogo em dados serializáveis;
- consumir a API do backend para carregar e atualizar o progresso.

### Site

- cadastro, login e logout;
- perfil e navegação;
- página do ranking;
- incorporação do jogo exportado para Web.

### Backend Java

- autenticar e identificar o jogador;
- armazenar e recuperar o progresso;
- validar ações que alteram a economia;
- calcular a pontuação oficial e o ranking;
- fornecer a API usada pelo site e pelo Godot.

### Banco de dados

- contas de usuário;
- progresso do jogo;
- dados necessários para o ranking.

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

Login, senha, perfil e ranking não pertencem ao Godot. O jogo deve receber apenas a sessão e os dados necessários ao gameplay.

## Preparação necessária no Godot

A sequência abaixo deve ser seguida na ordem definida. O detalhamento operacional está em `docs/PLANO_DE_TASKS.md`.

### 1. Criar os modelos mínimos de CatUpgrade e Upgrade

Criar classes `RefCounted`, tipadas e independentes da interface, com validação, `to_dict()` e `from_dict()`.

`CatUpgrade` é uma classe própria para melhorias vinculadas obrigatoriamente a um `cat_id`. `AUTOMATION` é seu primeiro tipo e representa a automatização da produção passiva de um gato específico. Outros tipos, como sorte ou velocidade, poderão ser adicionados futuramente sem misturar essas melhorias com os upgrades gerais.

O contrato JSON inicial de `CatUpgrade` será:

```json
{
  "cat_upgrade_id": "cat-upgrade-123",
  "cat_id": "cat-123",
  "cat_upgrade_type": "AUTOMATION",
  "cat_upgrade_level": 1
}
```

`Upgrade` representa melhorias gerais do jogador, como aumento de `click_power` ou de produção global, e não possui `cat_id`.

O contrato JSON atual de `Upgrade` é:

```json
{
  "upgrade_id": "click-power-basic",
  "upgrade_type": "CLICK_POWER",
  "upgrade_level": 1
}
```

O `upgrade_id` e o `upgrade_level` oficiais são controlados pelo backend Java. Para melhorar um upgrade, o Godot deverá enviar apenas a intenção da ação. O backend validará custo e saldo, atualizará o nível e devolverá o objeto atualizado para reconstrução por `from_dict()`.

Essa separação é intencional: `Upgrade` não possui `cat_id`, enquanto todo `CatUpgrade` pertence a um gato específico. A automação deixa de ser uma classe e passa a ser o tipo inicial de `CatUpgrade`.

O contrato JSON de `Cat` usa `cat_id`, `cat_type`, `name`, `appearance_id` e `status`, sempre em `snake_case`. As formas genéricas `id` e `type` não fazem parte desse contrato. O `cat_id` é gerado e controlado exclusivamente pelo backend Java.

### 2. Criar GameState

Substituir o estado global mínimo por um modelo tipado que concentre `save_version`, `park_name`, `food`, `total_food_earned`, `click_power`, `cats`, `cat_upgrades` e `upgrades`. O estado não deve conter senha, e-mail ou permissões do usuário.

### 3. Implementar a serialização completa de GameState

Implementar `to_dict()` e `from_dict()`, incluindo os modelos aninhados, validação de campos, tipos e `save_version`.

### 4. Implementar save local

Provar o contrato pelo fluxo: criar estado, converter para JSON, salvar, recarregar, reconstruir e validar. Arquivos ausentes, inválidos ou incompatíveis devem ser tratados.

### 5. Isolar a persistência

Definir um contrato como `SaveRepository`, com `LocalSaveRepository` nesta etapa e `ApiSaveRepository` durante a integração Java. Gameplay e entidades não devem acessar arquivo ou rede diretamente.

```text
Gameplay
   └── SaveRepository
       ├── LocalSaveRepository
       └── ApiSaveRepository
```

### 6. Separar a regra de clique da UI e da cena

O clique deve chamar uma operação de domínio como `game_state.earn_food(amount)`, que atualiza `food` e `total_food_earned`. `clicker_gato.gd` deve apenas solicitar a ação, enquanto a UI deve apenas apresentar o estado.

### 7. Validar Web e comunicação HTTP

No início da integração Java, deve existir uma exportação de teste que confirme:

- inicialização no navegador;
- funcionamento dos controles;
- adaptação à página;
- desempenho aceitável em máquinas de menor capacidade;
- possibilidade de realizar requisições HTTP;
- tratamento de indisponibilidade da API.

## Organização sugerida do código

```text
jogo/src/
├── gameplay/
│   ├── estado do jogo
│   ├── dados dos gatos
│   ├── regras de compra
│   └── regras de produção e progressão
├── persistence/
│   ├── contrato de persistência
│   └── save local
├── network/
│   └── cliente da API
├── principal/
└── debug/
```

Essa estrutura é uma direção, não uma obrigação de criar todos os arquivos antecipadamente. Os scripts devem permanecer pequenos, tipados e com responsabilidade clara.

## Ponto de partida do backend Java

Não é necessário terminar o núcleo inteiro do jogo para começar o Java. O backend pode ser iniciado quando houver base suficiente para um primeiro contrato:

- [ ] um estado mínimo e versionado estiver definido;
- [ ] salvar e carregar JSON funcionar;
- [ ] as regras econômicas estiverem separadas da UI;
- [ ] a exportação Web abrir corretamente;
- [ ] houver um rascunho dos dados que a API receberá e devolverá.

Compra de gato, compra e aplicação funcional de upgrades, ganho passivo funcional e fórmula de progressão podem evoluir depois, desde que qualquer mudança no contrato seja controlada por versão. Ranking, minigames, batalhas, customização, arte final e música também não bloqueiam o início do Java. Os modelos mínimos de `CatUpgrade` e `Upgrade` pertencem à preparação porque fazem parte do estado persistente, mesmo que suas regras funcionais ainda não existam.

## Primeira integração com Java

Após os critérios anteriores, a primeira integração deve ser pequena e atravessar todo o sistema:

```text
Login no site
  → abrir o Godot Web
  → carregar um estado do backend
  → alterar um dado simples do jogo
  → salvar
  → recarregar e confirmar a persistência
```

Depois dessa prova, a API pode evoluir para receber ações como compra de gato, aquisição de `CatUpgrade` do tipo `AUTOMATION` e upgrade geral. O backend deve identificar o jogador pela sessão e nunca confiar em uma pontuação pronta enviada pelo cliente.

## Mapa de features

| Ordem | Feature | Situação na `dev` | Relação com o sistema online |
|---:|---|---|---|
| 1 | Estado e contrato de save | Pendente | Base da integração |
| 2 | Exportação Web e cliente HTTP | Pendente | Canal de integração |
| 3 | Backend, banco e autenticação | Pendente | Identidade e persistência oficial |
| 4 | Save remoto por jogador | Pendente | Primeiro corte completo |
| 5 | Clique e ganho de ração | Implementação básica | Ação a ser sincronizada e validada |
| 6 | Modelo de CatUpgrade | Pendente | Inclui `AUTOMATION` e exige `cat_id` |
| 7 | Modelo de Upgrade | Implementado | Contrato inicial estabilizado |
| 8 | Compra de gatos, upgrades e ganho passivo | Pendente, posterior | Não bloqueia o início do Java |
| 9 | Progressão e ranking | Pendente | Calculados oficialmente no backend |
| 10 | Nomear parque | Apenas representação visual | Bom dado simples para testar sincronização |
| 11 | Gerenciar e customizar gatos | Pendente | Evolução posterior do save |
| 12 | Minigames | Pendente | Não bloqueia a integração inicial |
| 13 | Arte e música originais | Pendente | Não afeta a arquitetura online |
| 14 | Batalhas | Fora do núcleo atual | Exigiria arquitetura própria no futuro |

## Organização resumida no Trello

Para manter o quadro legível, a integração online deve ser tratada como o épico central, dividido em seis cartões:

1. **Definir estado e contrato do jogo:** JSON, versionamento e regras que o servidor validará.
2. **Preparar Godot Web:** exportação, cliente HTTP, carregamento e tratamento de erros.
3. **Criar backend Java:** Spring Boot, banco, autenticação e API do jogo.
4. **Criar site autenticado:** cadastro, login, sessão, perfil e abertura do jogo.
5. **Implementar save remoto:** associar o progresso à sessão e sincronizar Godot e backend.
6. **Criar ranking:** definir os dados de progressão, calcular no backend e exibir no site.

## Próximo marco

O próximo marco da `dev` é provar a arquitetura online com um corte vertical mínimo:

```text
Estado mínimo em JSON
  → exportação Godot Web
  → login no site
  → carregar save remoto
  → alterar um dado do jogo
  → salvar e recuperar o mesmo dado
```

Depois dessa prova, compra de gatos, `CatUpgrade` do tipo `AUTOMATION`, upgrades gerais e ranking devem ser incorporados ao mesmo fluxo. Assim, cada nova mecânica já nasce integrada ao modelo persistente, em vez de exigir uma adaptação online tardia.
