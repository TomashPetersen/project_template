# Контракт шаблона

Каноническая версия находится только в поле `template_version` файла [`.template-manifest.json`](.template-manifest.json). История изменений - [`TEMPLATE-CHANGELOG.md`](TEMPLATE-CHANGELOG.md). Каноническая ветка `source` хранит развитие шаблона, а default-ветка `main` является производной consumer-сборкой exact release tag.

`TEMPLATE.md`, `TEMPLATE-CHANGELOG.md` и accepted ADR, описывающие устройство исходного шаблона, являются source-only материалами владельца шаблона. Они не входят в consumer payload или generated project: consumer получает `TEMPLATE-DISTRIBUTION.json`, а initialized copy дополнительно получает `TEMPLATE-ORIGIN.md`.

Research, analysis, mastery и knowledge control plane остаются переносимой частью шаблона, потому что обеспечивают рабочий процесс и проверку конкретного проекта, а не сопровождение template source.

## Навигация владельца шаблона

- [`MODEL-PROJECT-OVERVIEW.md`](MODEL-PROJECT-OVERVIEW.md) - краткая карта назначения и memory flow шаблона.
- [`TEMPLATE-CHANGELOG.md`](TEMPLATE-CHANGELOG.md) - история версий и release provenance.
- [`docs/decisions/2026-07-29-knowledge-control-plane.md`](docs/decisions/2026-07-29-knowledge-control-plane.md) - границы knowledge control plane.
- [`docs/decisions/2026-08-01-generated-payload-boundary.md`](docs/decisions/2026-08-01-generated-payload-boundary.md) - разделение source maintenance и generated payload.
- [`docs/decisions/2026-08-14-portable-analysis-control-plane.md`](docs/decisions/2026-08-14-portable-analysis-control-plane.md) - переносимый контур бизнес- и системного анализа.
- [`docs/decisions/2026-08-16-assisted-learning-knowledge-graph.md`](docs/decisions/2026-08-16-assisted-learning-knowledge-graph.md) - обязательный closeout, обучаемые методы и derived knowledge graph.
- [`docs/decisions/2026-08-17-github-template-distribution.md`](docs/decisions/2026-08-17-github-template-distribution.md) - source/consumer branch model, provenance и GitHub setup gates.

## Что копируется в новый проект

- проектный `AGENTS.md`;
- пустой переносимый `ai-clone/` без данных владельца source template;
- root onboarding, отдельный Codex install prompt и provenance descriptor;
- компактная библиотека доменных интервью и copy-paste prompts в `prompts/`;
- паспорт и корневой индекс;
- каркас идеи и бизнеса;
- гибридный RAW-процесс;
- чистые зоны plans, retrospectives и проектных решений с их шаблонами, без source-maintenance истории;
- единый knowledge contract, candidate template, derived graph и semantic verifier;
- project-local `mastery/INDEX.md`, immutable `mastery/researcher/`, immutable `mastery/analyst/`, шаблон и зона `mastery/local/`;
- project-local skills `.agents/skills/startup-researcher/`, `.agents/skills/it-analysis/` и `.agents/skills/knowledge-curator/`;
- чистый каркас `research/` без предметных запусков;
- чистый `analysis/runs/`, canonical templates в `business/analysis/` и `docs/analysis/` без предметных артефактов;
- безопасные скрипты инициализации, генерации графа и проверки.
- MIT license и notices шаблона; после setup они сохраняются под именами `TEMPLATE-LICENSE.md` и `TEMPLATE-THIRD-PARTY-NOTICES.md`, не выбирая лицензию продукта.

## Что намеренно не копируется

- заполненный личный AI-клон владельца source template;
- общая внешняя mastery-библиотека;
- общая история портфеля;
- глобальный `config.toml` Codex;
- пользовательские и global skills, кроме трех контрактных project-local skills;
- данные и код других продуктов;
- локальная память Codex.

Эти слои общие для пользователя и подключаются глобальными настройками Codex.

## Обязательные зоны

`PROJECT.md`, `INDEX.md`, `AGENTS.md`, `ai-clone/`, `idea/`, `business/analysis/`, `analysis/`, `inbox/`, `docs/analysis/`, `plans/`, `retrospectives/`, `scripts/`, `knowledge/`, `mastery/researcher/`, `mastery/analyst/`, `mastery/local/`, `.agents/skills/startup-researcher/`, `.agents/skills/it-analysis/`, `.agents/skills/knowledge-curator/`, `research/`.

## Опциональные зоны

Код, тесты, инфраструктура, дизайн и продуктовые ассеты создаются только когда определен стек и реальная потребность. Не добавлять пустую универсальную архитектуру заранее.

## Создание локальной копии

Поддерживаемый путь - `scripts/new-project.ps1`. Единственный allowlist находится в `.template-manifest.json`; тот же manifest читает `verify-structure.ps1`. В копию входят только контрактные project-local skills, baseline mastery, пустые extension zones и переносимые документы. `.git` исходника, `.codex`, owner overlays, общая mastery, заполненные runs и candidates, staging и maintenance-история не переносятся.

Ручное копирование всей директории запрещено: скрытая `.git` превратит новый продукт в продолжение репозитория шаблона.

## GitHub consumer payload

Source-only `scripts/build-github-template.ps1` принимает exact `v<template_version>` tag и URL канонического template repository. Он требует clean source HEAD, копирует portable allowlist в GUID-staging, переводит `PROJECT.md` во временный `distribution-template`, заполняет SHA-256 descriptor и проверяет `DistributionTemplate` до atomic publication.

Consumer payload публикуется как содержимое default-ветки `main`. Пользователь создает новый repository через `Use this template` без `Include all branches`, клонирует новый repository и запускает `scripts/initialize-project.ps1 -FromGitHubTemplate`. Инициализатор не меняет remote и Git history, не выполняет stage/commit/push и блокирует source refs, canonical template remote и descriptor drift.

## Обновление шаблона

1. Изменить только исходную папку `Модельный проект`.
2. Обновить `template_version` в `.template-manifest.json` и `TEMPLATE-CHANGELOG.md`.
3. Запустить `scripts/verify-structure.ps1 -Mode TemplateSource`.
4. Создать временный проект через `new-project.ps1` и повторить проверку.
5. После отдельного commit и tag собрать consumer payload через `build-github-template.ps1`, проверить его и только затем обновить derived `main`.
6. Не применять миграцию автоматически к старым проектам.

Проекты, созданные раньше, не мигрируются автоматически. Они обновляются отдельным осознанным планом после сравнения версий.
