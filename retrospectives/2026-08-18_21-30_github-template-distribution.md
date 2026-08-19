---
artifact_kind: retrospective
knowledge_outcome: existing
candidate_ids: []
affected_canon:
  - .gitignore
  - .template-manifest.json
  - AGENTS.md
  - CODEX-INSTALL-PROMPT.md
  - PROJECT.md
  - README.md
  - TEMPLATE-DISTRIBUTION.json
  - TEMPLATE-CHANGELOG.md
  - TEMPLATE.md
  - ai-clone/CORE.md
  - ai-clone/INDEX.md
  - docs/decisions/2026-08-17-github-template-distribution.md
  - scripts/build-github-template.ps1
  - scripts/initialize-project.ps1
  - scripts/new-project.ps1
  - scripts/test-github-template-distribution.ps1
  - scripts/verify-knowledge.ps1
  - scripts/verify-structure.ps1
blocked_reason: null
---

# Ретроспектива: распространение через GitHub Template

## Задача и связи

Нужно было превратить исходный модельный проект в передаваемый шаблон, который можно безопасно развернуть в независимом repository через GitHub Template или локальную копию, а также дать человеку и Codex понятный onboarding.

- [План](../plans/2026-08-17-github-template-distribution.md)
- [Принятое решение](../docs/decisions/2026-08-17-github-template-distribution.md)
- [Контракт шаблона](../TEMPLATE.md)

## Что сделано

- Разделены каноническая `source` и производная default-ветка `main` с consumer payload.
- Добавлены root README, отдельный install prompt, пустой project-local `ai-clone`, инструкции по business и Local Mastery, точный inventory skills, MCP и остальных компонентов.
- Реализован source-only builder exact tagged payload с SHA-256 descriptor, atomic staging и `DistributionTemplate` gate.
- Добавлен GitHub setup mode, который сохраняет существующие HEAD и remote, не выполняет stage/commit/push и блокирует direct template clone, source refs, single-branch fetch, dirty state, повторный запуск и descriptor drift.
- Разделены MIT license шаблона и намеренно невыбранная лицензия продукта.
- Усилен release trust boundary: builder сверяет declared repository с source `origin` и требует, чтобы каждый manifest-файл находился в tagged commit с обычным tracked index state.
- Install prompt требует считать скачанные файлы недоверенными и проверить исполняемые скрипты до запуска.

## Что проверено и какими командами

- `pwsh -NoProfile -File .\scripts\verify-knowledge.ps1 -SelfTest` - все встроенные fixtures прошли.
- `pwsh -NoProfile -File .\scripts\verify-analysis.ps1 -SelfTest` - 54 сценария.
- `pwsh -NoProfile -File .\scripts\update-knowledge-graph.ps1 -Mode SelfTest` - write, check, determinism, stale и reparse gates прошли.
- PowerShell AST всех 17 `.ps1` и `.psm1` - parser errors отсутствуют.
- `pwsh -NoProfile -File .\scripts\test-github-template-distribution.ps1` - 13 проверок, включая новые regressions для wrong origin и ignored untracked manifest-файла.
- Ранее на том же кодовом baseline прошли control plane A01-A23, artifacts 15/15, Mastery 24/24, privacy 37/37, research A43-A54 и semantics A19-A30.
- Финальный source gate, local fresh-copy smoke, GeneratedProject gate, graph check и `git diff --check` выполнены после регистрации этой retrospective в manifest.

## Что не получилось или осталось

Первый повтор distribution harness был ошибочно запущен через Windows PowerShell, который не входит в заявленную среду и неверно прочитал UTF-8 без BOM. Тесты не начали исполняться. Повтор через документированный `pwsh` 7.6+ завершился успешно.

Публикация намеренно не выполнялась. Для выпуска владелец отдельно создает проверенный `source` commit и exact tag, строит derived `main`, разрешает push и включает Template repository в GitHub. Private GitHub flow для внешнего знакомого остается реальным post-push smoke, потому что локальный harness не доказывает permissions конкретного аккаунта.

## Как было и как стало

Раньше шаблон поддерживал только локальное создание и зависел от устного объяснения владельца. Теперь получатель создает независимый GitHub repository из default consumer branch, передает Codex отдельный prompt, проходит проверяемую инициализацию и получает usage-only проект без source-maintenance истории и личных оверлеев.

## Что выучено

- Exact tag недостаточен, если builder копирует рабочее дерево и не доказывает, что каждый manifest-файл существует в commit.
- Repository URL в provenance является частью security boundary и должен совпадать с реальным source `origin`, а не оставаться свободным операторским текстом.
- GitHub Template создает независимую историю из default branch; отказ от `Include all branches` является обязательной частью branch isolation.
- Downloaded repository должен проходить audit до исполнения собственных setup-скриптов, даже если внутри него есть self-verifier.

Устойчивое архитектурное решение уже находится в accepted ADR, поэтому отдельный knowledge candidate не создавался.

## Security review

- Персональные данные: owner-specific AI clone и общая база не включены; portable `ai-clone` остается пустым scaffold.
- Контент третьих лиц: включены MIT license, notices и собственные краткие operating summaries; полные сторонние произведения не копируются.
- Внешние отправки: scripts не используют сеть; во время review открывались только официальные общие страницы OpenAI и GitHub без передачи содержимого repository.
- Секреты: `.env`, credentials, `.codex`, MCP configuration и токены не читались и не включались; Git URL с credentials блокируется.

## Pre-commit release checkpoint 2026-08-18 22:50 +04:00

По отдельной команде владельца выполнена подготовка к GitHub push без самого push. Полный release gate повторен на текущем source snapshot: AST `17/17`, `TemplateSource`, knowledge и analysis self-tests, graph self-test, distribution `13/13`, artifacts `15/15`, privacy `37/37`, Mastery `24/24`, research `12/12`, semantics и control plane `P0 PASS`. Inventory review подтвердил, что все 102 измененных или новых file paths входят в manifest, а восемь ignored owner files не входят в release. Для сборки derived `main` остается получить точный GitHub repository URL, используемый одновременно как `origin` identity и provenance descriptor.
