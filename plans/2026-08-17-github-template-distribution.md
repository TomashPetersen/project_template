---
artifact_kind: plan
status: complete
knowledge_outcome: existing
candidate_ids: []
affected_canon:
  - .gitignore
  - .template-manifest.json
  - AGENTS.md
  - PROJECT.md
  - README.md
  - TEMPLATE.md
  - ai-clone/CORE.md
  - ai-clone/INDEX.md
  - docs/decisions/2026-08-17-github-template-distribution.md
  - scripts/initialize-project.ps1
  - scripts/verify-knowledge.ps1
  - scripts/verify-structure.ps1
blocked_reason: null
---

# План: распространение через GitHub Template

## Цель

Подготовить template payload `1.5.0`, который можно безопасно опубликовать в GitHub, использовать для создания независимых репозиториев и передавать другим людям без личных оверлеев, секретов и зависимости от внешней базы владельца.

## Границы

Входит:

- каноническая source-ветка и производная consumer-сборка для default-ветки GitHub Template;
- отдельный copy-paste prompt для Codex и полный русскоязычный quick start в корневом `README.md`;
- инициализация уже существующего Git-репозитория после GitHub Template без `git init`, stage, commit или push;
- локальный пустой `ai-clone`, руководство по business-контексту и approval-only созданию Local Mastery;
- точный список переносимых skills, MCP и остальных компонентов;
- provenance descriptor, шаблонная лицензия, third-party notices и проверяемая граница между лицензией шаблона и лицензией продукта;
- structure, semantic, negative и fresh-copy проверки.

Не входит:

- автоматический push, изменение GitHub settings или включение GitHub Template через API;
- публикация приватного репозитория и приглашение внешнего тестировщика;
- миграция существующих generated projects;
- автоматическая установка Codex, Git, PowerShell, plugins или MCP;
- перенос личного AI-клона, `.codex`, global skills, секретов и истории портфеля.

## Критерии приемки

1. Корневой `README.md` объясняет установку, старт, `ai-clone`, business, Local Mastery, skills, MCP и базовые prompts.
2. Отдельный `CODEX-INSTALL-PROMPT.md` можно передать Codex для установки из нового репозитория, созданного через GitHub Template.
3. `build-github-template.ps1` строит consumer payload только из exact source tag/commit и формирует проверяемый `TEMPLATE-DISTRIBUTION.json` с SHA-256.
4. `verify-structure.ps1` различает `TemplateSource`, `DistributionTemplate` и `GeneratedProject` и блокирует неправильный inventory, provenance или лицензионную границу.
5. `initialize-project.ps1 -FromGitHubTemplate` требует чистый существующий Git-репозиторий, запрещает source refs и прямую инициализацию канонического template remote.
6. Локальный `new-project.ps1` продолжает создавать независимый репозиторий с нулем commits.
7. После инициализации root `LICENSE` шаблона заменен на `TEMPLATE-LICENSE.md`, а лицензия будущего продукта остается невыбранной.
8. `active + safe-local` принимает только HEAD с тем же generated `project_id` и тем же `TEMPLATE-ORIGIN.md`, поэтому исходный GitHub Template commit не считается baseline.
9. Consumer payload не содержит source-only history, owner overlays, `.codex`, заполненные runs/candidates или личные данные.
10. AST, self-tests, source gate, distribution gate, local fresh copy и GitHub-style fresh copy проходят на итоговом snapshot.

## Риски, безопасность и откат

- GitHub UI может скопировать source-ветку при включенном `Include all branches`; initializer обязан обнаружить source ref и остановиться.
- Прямой clone канонического template remote может привести к ошибочному push; descriptor и initializer сравнивают remote identity и блокируют этот путь.
- Descriptor хранит только безопасные provenance-поля, относительные пути и SHA-256, без токенов и персональных данных.
- Consumer builder работает через GUID-staging, не следует reparse points и публикует destination только атомарным rename.
- Откат удаляет distribution mode, builder, descriptor и GitHub parameter set, сохраняя существующий локальный `new-project.ps1`.

## Фаза 1 - [x] Контракт и решение

Цель: зафиксировать branch model, trust boundary и критерии приемки.

Deliverable: этот план и accepted ADR.

Сделано, когда:

- [x] Source и consumer responsibilities не смешаны.
- [x] GitHub Template limitations отражены в failure behavior.

## Фаза 2 - [x] Документация и переносимый контекст

Цель: сделать репозиторий понятным владельцу и получателю без устной инструкции.

Deliverable: README, install prompt, `ai-clone`, license и notices.

Сделано, когда:

- [x] Quick start и примеры prompts покрывают первый рабочий цикл.
- [x] Список skills, MCP и environment dependencies точен.

## Фаза 3 - [x] Distribution pipeline

Цель: получить детерминированный consumer payload из exact release source.

Deliverable: manifest `1.5.0`, descriptor, builder и distribution verification.

Сделано, когда:

- [x] Builder блокирует dirty, untagged, wrong-branch или mismatched source.
- [x] Payload inventory и hashes проверяются до публикации.

## Фаза 4 - [x] Dual initialization и baseline gate

Цель: поддержать локальную копию и GitHub Template без смешения Git semantics.

Deliverable: два взаимоисключающих parameter set и усиленный HEAD contract.

Сделано, когда:

- [x] Локальная и GitHub-style инициализация проходят.
- [x] Wrong remote, source refs, single-branch clone, dirty repo, descriptor drift и повторный запуск блокируются без мутации.

## Фаза 5 - [x] Release gate и handoff

Цель: дать проверяемый локальный change set, готовый к отдельному commit/tag/push.

Deliverable: tests, sequential independent review, security review, changelog и retrospective.

Сделано, когда:

- [x] Все применимые проверки зелены.
- [x] Ни stage, ни commit, ни push не выполнены.

## Проверки

- PowerShell AST для всех измененных `.ps1` и `.psm1`.
- `git diff --check`.
- `verify-knowledge.ps1 -SelfTest` и применимые source-only harnesses.
- `verify-structure.ps1 -Mode TemplateSource`.
- `verify-structure.ps1 -Mode DistributionTemplate` на disposable consumer build.
- Local fresh copy через `new-project.ps1`.
- GitHub-style disposable Git repository через `initialize-project.ps1 -FromGitHubTemplate`.
- Sequential independent review по spec, plan, diff и evidence, так как пользователь запретил subagents.

## Связанные решения

- Решения: [распространение через GitHub Template](../docs/decisions/2026-08-17-github-template-distribution.md).

## Итог

- Локальный change set реализован и проверен: документация, consumer builder, dual initialization, provenance, license boundary и negative trust gates готовы к отдельному release workflow.
- Retrospective: [распространение через GitHub Template](../retrospectives/2026-08-18_21-30_github-template-distribution.md).
- Внешний release остается отдельной задачей владельца: создать `source` commit и exact tag, построить derived `main`, затем по прямой команде выполнить push и включить GitHub Template settings.
- Stage, commit, tag, branch mutation, push и deploy в этой задаче не выполнялись.

## Финальная проверка 2026-08-18 21:30 +04:00

- Полный `verify-knowledge.ps1 -SelfTest`: все встроенные fixtures прошли.
- `verify-analysis.ps1 -SelfTest`: 54 сценария.
- `update-knowledge-graph.ps1 -Mode SelfTest`: write/check/determinism/stale/reparse gates прошли.
- PowerShell AST: 17 файлов без parser errors.
- Distribution harness: `13/13`, включая origin identity и ignored untracked manifest-file regressions.
- Sequential review выполнен соло по spec, plan, diff и evidence; доказанные release findings исправлены и повторно проверены.
- Финальные `TemplateSource`, local fresh-copy, GeneratedProject, graph check и `git diff --check` прошли после добавления retrospective в manifest; disposable temp-копия удалена.

## Подготовка к GitHub release 2026-08-18 22:50 +04:00

- Пользователь отдельно разрешил подготовить локальный Git release, но не выполнять push.
- Повторный полный pre-commit gate прошел на итоговом source snapshot: PowerShell AST `17/17`, `TemplateSource` - 135 канонических Markdown-файлов, knowledge self-test, analysis self-test `54/54`, knowledge graph self-test, distribution harness `13/13`.
- Отдельные public CLI harnesses также повторены: artifacts `15/15`, privacy `37/37`, Mastery `24/24`, research `12/12`, semantics и control plane `P0 PASS`.
- Все 102 измененных или новых file paths входят в `.template-manifest.json`; `.codex`, owner-only `bulletproof` и `frontend-design` остаются ignored и не входят в release.
- Privacy audit не обнаружил workspace path, рабочих credentials или иных личных данных в payload, кроме принятой владельцем строки copyright в `LICENSE`; Git author history также явно принят владельцем.
- Следующий локальный шаг - создать canonical ветку `source`, один release commit и exact tag `v1.5.0`. Производная `main` требует точный URL будущего GitHub repository, потому что URL входит в проверяемый provenance descriptor.

## Checkpoint 2026-08-18 00:20 +04:00

Уже подтверждено на текущем коде:

- distribution harness `11/11`, включая exact tag, ветку `source`, descriptor hashes, неизменность HEAD/remote и negative trust fixtures;
- local fresh copy: `local-copy`, usage-only README, template license rename и ноль commits;
- control plane A01-A23: все три группы `P0 PASS`;
- analysis self-test: 54 сценария; graph self-test: determinism и stale/reparse gates;
- artifacts `15/15`, Mastery `24/24`, privacy `37/37`;
- research A43-A54 и semantics A19-A30 прошли после исправления baseline staging и безопасного reparse diagnostic;
- pre-task snapshot сохранен, staged changes отсутствуют, knowledge closeout имеет outcome `existing` через accepted ADR.

Последний повторный `verify-knowledge.ps1 -SelfTest` был прерван по просьбе пользователя до вывода результата. Более ранний полный прогон проходил, но после финальных точечных review-правок этот gate нужно запустить заново. Retrospective еще не создана, plan остается `in-progress`, stage/commit/push не выполнялись.
