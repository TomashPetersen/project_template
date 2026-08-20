# Контракт и выпуск шаблона

Этот файл предназначен только для владельца `template-source` и не входит в consumer payload. Каноническая версия находится в поле `template_version` файла [`.template-manifest.json`](.template-manifest.json), история версий - в [`TEMPLATE-CHANGELOG.md`](TEMPLATE-CHANGELOG.md).

Ветка `source` хранит развитие шаблона. Default-ветка `main` является производной consumer-сборкой exact release tag и вручную не редактируется. Публичный проект создается из `main` через GitHub `Use this template` без `Include all branches`.

## Инвариант v2

Шаблон дает Codex repository-level контекст и возобновляемую работу:

```text
идея -> продукт и бизнес -> tracked plan -> реализация и проверки
     -> выборочный knowledge closeout -> отдельное подтверждение promotion
```

Текущий план хранится в `plans/`, а не в чате или локальной памяти. Product, business, architecture и codebase имеют отдельных владельцев канона. Код и тесты остаются источником истины о поведении. MCP, plugins, credentials, hooks, automations и `.codex/config.toml` не встраиваются.

## Навигация владельца шаблона

- [`MODEL-PROJECT-OVERVIEW.md`](MODEL-PROJECT-OVERVIEW.md) - компактная модель проекта.
- [`docs/decisions/2026-08-20-codex-first-template-v2.md`](docs/decisions/2026-08-20-codex-first-template-v2.md) - актуальное breaking-решение v2.
- [`docs/decisions/2026-08-17-github-template-distribution.md`](docs/decisions/2026-08-17-github-template-distribution.md) - source/consumer branch model и provenance.
- [`docs/decisions/2026-08-01-generated-payload-boundary.md`](docs/decisions/2026-08-01-generated-payload-boundary.md) - разделение source maintenance и generated payload.
- [`docs/decisions/2026-07-29-knowledge-control-plane.md`](docs/decisions/2026-07-29-knowledge-control-plane.md) - границы knowledge lifecycle.
- [`docs/decisions/2026-08-14-portable-analysis-control-plane.md`](docs/decisions/2026-08-14-portable-analysis-control-plane.md) и [`2026-08-16-assisted-learning-knowledge-graph.md`](docs/decisions/2026-08-16-assisted-learning-knowledge-graph.md) - исторические решения v1, частично superseded в v2.

## Что копируется в новый проект

- root onboarding: `README.md`, `CODEX-INSTALL-PROMPT.md`, `AGENTS.md`, `PROJECT.md`, `INDEX.md`, manifest, provenance и template legal files;
- обезличиваемый `ai-clone/` без данных владельца source template;
- `idea/`, `product/`, `business/`, `docs/architecture/`, `docs/codebase/` и шаблоны ADR;
- tracked Plan v2: `plans/README.md`, `plans/TEMPLATE.md` и пустой производный `plans/INDEX.md`;
- `knowledge/` с candidates, graph, backlinks, provenance и ручным promotion;
- immutable `mastery/researcher/`, расширяемые `mastery/INTENTS.json` и `mastery/local/`;
- `research/`, единая RAW-зона `inbox/raw/` и необязательные retrospectives;
- компактная библиотека `prompts/` с machine-readable `plan_policy`;
- project-local skills `project-delivery`, `knowledge-curator` и `startup-researcher`;
- portable PowerShell 7 scripts и общие platform, plan, mastery и knowledge modules.

После инициализации `LICENSE` и `THIRD-PARTY-NOTICES.md` переименовываются в `TEMPLATE-LICENSE.md` и `TEMPLATE-THIRD-PARTY-NOTICES.md`. Лицензия конкретного продукта автоматически не выбирается.

## Что намеренно не копируется

- `.git` исходника, source branch, release staging и source-only CI;
- `TEMPLATE.md`, changelog, owner ADR, source plans, release retrospectives, builder и regression harnesses;
- пользовательские overlays `.agents/skills/bulletproof/**`, `.agents/skills/frontend-design/**` и `.codex/**`;
- заполненные runs, RAW, candidates, Local Mastery и личные данные владельца шаблона;
- formal-analysis v1: `analysis/`, `business/analysis/`, `docs/analysis/`, `mastery/analyst/`, `it-analysis` и специализированные scripts/prompts;
- общая база знаний, портфель, глобальные skills, MCP, plugins и credentials.

Полная прежняя реализация formal analysis остается воспроизводимой в неизменяемом теге `v1.6.2`. Автоматической миграции старых generated projects нет.

## Обязательные зоны v2

`PROJECT.md`, `INDEX.md`, `AGENTS.md`, `ai-clone/`, `idea/`, `product/`, `business/`, `docs/architecture/`, `docs/codebase/`, `docs/decisions/`, `plans/`, `knowledge/`, `mastery/researcher/`, `mastery/local/`, `research/`, `inbox/raw/`, `retrospectives/`, `prompts/` и три контрактных project-local skills.

Кодовые каталоги `src/`, `app/`, `tests/`, `infra/`, platform configs и design assets не создаются заранее. Выбранный стек может свободно добавлять их вне template-controlled roots; фактическая карта затем фиксируется в `docs/codebase/`.

## Локальная копия владельца

Ручное копирование всей source-директории запрещено: скрытая `.git` превратит продукт в продолжение шаблона. Используй source-only generator:

```powershell
pwsh -NoProfile -File ./scripts/new-project.ps1 -Destination "<ABSOLUTE_NEW_PATH>" -ProjectName "<PROJECT_NAME>" -ProjectSlug "<project-slug>" -Description "<ONE_SENTENCE_DESCRIPTION>" -Owner "project-owner"
```

Destination заранее не должна существовать. Скрипт копирует только manifest allowlist, инициализирует независимый Git repository без commits, выполняет rollback при ошибке и не делает stage, commit или push.

## Выпуск GitHub consumer

1. На ветке `source` заверши tracked plan, knowledge closeout, retrospective и полный local gate. Проверь фактический diff и отсутствие PII, секретов и абсолютных локальных путей.
2. Только по отдельной команде создай точный release commit и signed или annotated tag `v<template_version>`. Тег `v1.6.2` не изменяй.
3. Из clean tagged `source` собери payload в новый несуществующий локальный path:

```powershell
pwsh -NoProfile -File ./scripts/build-github-template.ps1 -SourceTag "v2.0.0" -TemplateRepositoryUrl "https://github.com/<OWNER>/<TEMPLATE_REPOSITORY>" -Destination "<ABSOLUTE_NEW_STAGING_PATH>"
```

4. Проверь staging в режиме `DistributionTemplate`, exact inventory, descriptor hashes и настоящий Git clone/initialization roundtrip.
5. После отдельного подтверждения замени производную `main` только собранным payload и создай отдельный consumer commit. Не переносить source-only history.
6. После явного разрешения отправь только ожидаемые refs: `source`, `main` и exact tag. `git push --all` запрещен.
7. Дождись зеленого CI на `windows-latest` и `macos-latest`. Затем проверь внешний `Use this template` flow без `Include all branches`.

Builder требует ветку `source`, clean tracked HEAD, exact tag, обычный tracked state manifest-файлов и GitHub URL, совпадающий с identity `origin`. Он не меняет branches/remotes, не выполняет commit или push и публикует destination атомарно только после зеленого gate.

## Local pre-push gate

Минимальный release-набор:

```powershell
pwsh -NoProfile -File ./scripts/test-platform.ps1
pwsh -NoProfile -File ./scripts/test-plan-lifecycle.ps1
pwsh -NoProfile -File ./scripts/test-canon-graph.ps1
pwsh -NoProfile -File ./scripts/test-mastery-v2.ps1
pwsh -NoProfile -File ./scripts/test-v2-consumer-boundary.ps1
pwsh -NoProfile -File ./scripts/test-cross-platform-bootstrap.ps1
pwsh -NoProfile -File ./scripts/test-github-template-distribution.ps1
pwsh -NoProfile -File ./scripts/test-knowledge-privacy.ps1
pwsh -NoProfile -File ./scripts/verify-knowledge.ps1 -SelfTest
pwsh -NoProfile -File ./scripts/verify-structure.ps1 -Mode TemplateSource
git diff --check
```

Source-only workflow `.github/workflows/template-integrity.yml` повторяет ключевые проверки на Windows и macOS и не входит в создаваемый проект.

## Обновление шаблона

1. Создать или продолжить один source plan и зафиксировать pre-task Git snapshot.
2. Изменить source, portable allowlist и negative fixtures согласованно.
3. Обновить `template_version`, changelog, ADR при смене базового решения и release retrospective.
4. Проверить TemplateSource, DistributionTemplate, fresh local copy и GitHub-style initialization.
5. Не мигрировать и не очищать существующие проекты автоматически.
