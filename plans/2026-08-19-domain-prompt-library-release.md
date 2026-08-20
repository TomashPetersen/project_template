---
artifact_kind: plan
status: complete
knowledge_outcome: none
candidate_ids: []
affected_canon:
  - .gitattributes
  - .template-manifest.json
  - INDEX.md
  - LICENSE
  - PROJECT.md
  - README.md
  - scripts/test-github-template-distribution.ps1
  - scripts/verify-analysis.ps1
  - scripts/verify-structure.ps1
  - TEMPLATE-DISTRIBUTION.json
  - TEMPLATE-CHANGELOG.md
  - TEMPLATE.md
  - prompts/README.md
blocked_reason: null
---

# План: доменная библиотека промтов и GitHub release

## Цель

Добавить в переносимый шаблон короткие готовые промты для заполнения ключевых зон проекта, связать их из README и выпустить проверяемый GitHub Template release `1.6.2` в канонический template repository.

## Границы

Входит:

- индекс `prompts/` и отдельные промты для AI Clone, паспорта, идеи, business, research, analysis, delivery и knowledge/mastery;
- ссылки из README, PROJECT и корневого INDEX;
- обновление manifest, descriptor placeholder, changelog и template contract;
- source commit/tag, derived consumer `main`, проверки и push обеих веток.

Не входит:

- заполнение шаблона данными конкретного продукта или владельца;
- автоматическая настройка MCP, plugins или secrets;
- изменение GitHub repository settings кроме отправки Git refs;
- создание продукта из шаблона.

## Критерии приемки

1. README ведет к компактному индексу и каждому доменному промту.
2. AI Clone и business имеют интервью-формат, который не собирает лишние персональные данные и не выдумывает факты.
3. Остальные промты соблюдают project mode, owner, authority и canonical handoff contracts.
4. Все новые файлы входят в portable manifest версии `1.6.2` и fresh consumer payload.
5. Source, distribution, links, privacy и Git release gates проходят.
6. Remote содержит derived `main`, canonical `source` и exact tag `v1.6.2` без локальной персонализированной Git-истории.

## Риски, безопасность и откат

- Prompt может ошибочно выглядеть как authority. Каждый файл явно запрещает скрытый commit, push, promotion и canonical handoff.
- Интервью может собрать PII. AI Clone prompt ограничивает вопросы рабочими предпочтениями и запрещает контакты, адреса, документы, секреты и приватную переписку.
- Git checkout может менять line endings и нарушать descriptor hashes. Все text paths фиксируются как LF и проходят настоящий commit/clone regression.
- Ручное развитие `main` запрещено. Consumer branch строится только из exact tagged `source` через builder.
- Откат GitHub release выполняется новым исправляющим source release, а не ручной правкой derived `main`.

## Фаза 1 - [x] Библиотека промтов

Цель: дать готовые короткие entrypoints для значимых зон.

Deliverable: `prompts/` и README-навигация.

Сделано, когда:

- [x] каждый промт указывает owner artifacts и stop conditions;
- [x] root onboarding остается компактным и ведет к деталям.

## Фаза 2 - [x] Portable contract

Цель: включить библиотеку только в новые consumer copies.

Deliverable: manifest и release metadata `1.6.2`.

Сделано, когда:

- [x] source inventory точен;
- [x] distribution descriptor строится из exact tag в harness;
- [x] настоящий Git commit/clone сохраняет обязательные run roots и descriptor hashes.

## Фаза 3 - [x] Проверка и публикация

Цель: выпустить source и derived consumer без ручного drift.

Deliverable: зеленые gates, source tag, consumer commit и GitHub refs.

Сделано, когда:

- [x] local release checks зелены;
- [x] remote refs проверены после push.

## Проверки

- `git diff --check` и Markdown-link/structure gate.
- `verify-knowledge.ps1`, knowledge graph check и privacy scan.
- `verify-structure.ps1 -Mode TemplateSource`.
- `test-github-template-distribution.ps1`.
- Actual tagged consumer build и `DistributionTemplate` verification.
- Remote ref verification после push.

## Связанные решения

- Решения: [распространение через GitHub Template](../docs/decisions/2026-08-17-github-template-distribution.md).

## Итог

- Реализовано целиком: библиотека, portable contract, обезличенная public history и GitHub publication.
- Что осталось: обязательных действий нет; признак GitHub `Template repository` включается отдельно в настройках repository.
- Public source/tag commit: `c8639f22f0517ca7b6dbba5d96b1ff3ef5c8e326`.
- Public consumer `main` commit: `31927e05f5f94442c3ddf3eeeda26f4642a411fa`.

## Pre-push evidence 2026-08-19

- Prompt review: 9 файлов, 226 строк, PII/secret/path findings `0`.
- PowerShell AST измененных scripts: parser errors `0`.
- Analysis self-test: `54/54`.
- TemplateSource: 146 канонических Markdown-файлов.
- Distribution harness: `14/14`, включая настоящий commit/clone, `.gitkeep` roots и descriptor hashes после checkout.
- GitHub target и authentication проверены через `ls-remote` и `push --dry-run` без изменения remote.
- Full-tree privacy review выявил и удалил личное имя из `LICENSE`; публичная история собирается с нейтральной служебной подписью.
- Actual `v1.6.2` payload: 141 файл, 140 SHA-256 entries, 9 prompt-файлов, hash mismatches `0`.
- Fresh consumer clone: `DistributionTemplate` PASS, 122 канонических Markdown-файла, clean worktree, 1 neutral-author commit.
- Atomic push создал только `main`, `source` и `v1.6.2`; remote `HEAD` указывает на `main`, unpublished tags отсутствуют.
