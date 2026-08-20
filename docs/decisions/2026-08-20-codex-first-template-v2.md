---
artifact_kind: decision
status: accepted
knowledge_outcome: existing
candidate_ids: []
affected_canon:
  - .template-manifest.json
  - AGENTS.md
  - INDEX.md
  - PROJECT.md
  - README.md
  - TEMPLATE.md
  - business/INDEX.md
  - docs/INDEX.md
  - knowledge/INDEX.md
  - mastery/INDEX.md
  - product/INDEX.md
supersedes:
  - docs/decisions/2026-08-14-portable-analysis-control-plane.md
  - docs/decisions/2026-08-16-assisted-learning-knowledge-graph.md
blocked_reason: null
---

# Решение: Codex-first шаблон v2

## Контекст и владелец

Версия 1.6.2 надежно распространяла consumer payload и защищала knowledge lifecycle, но делала formal business/system analysis центральной частью любого нового проекта. Для универсального вайбкодинга с Codex важнее устойчивый контекст проекта, предметный канон, сохраняемый план, реализация, проверка и выборочное обучение.

Решение принято владельцем шаблона в рамках [source plan v2](../../plans/2026-08-20-codex-first-template-v2.md). Это breaking release без автоматической миграции существующих проектов.

## Решение

- Основные владельцы знаний: `PROJECT.md`, `idea/`, `product/`, `business/`, `docs/architecture/`, `docs/codebase/`, accepted ADR, код и тесты.
- Любой planning prompt сначала создает или находит один tracked Plan v2. `plans/INDEX.md` и `Resume checkpoint` обеспечивают возобновление после нового чата или потери контекста.
- Formal-analysis payload, Analyst Mastery и `it-analysis` удаляются из v2. Универсальные parser, provenance, privacy, reference, process, path и negative-test primitives сохраняются в общем knowledge/platform слое.
- `project-delivery`, `knowledge-curator` и `startup-researcher` являются единственными переносимыми project-local skills.
- Local Mastery остается проверяемым knowledge artifact и создается через method candidate, preview и отдельное одобрение. Автоматического преобразования Mastery в Skill нет.
- Plan closeout переносит только устойчивый результат и при достаточном evidence повторяемый метод. Полный план, diff, код, тесты, логи, секреты и PII не копируются в knowledge.
- PowerShell 7 остается единым runtime на Windows и macOS. Platform helpers централизуют process invocation, Git environment, null device, case semantics, path containment, links, input bounds и lock-files.
- Stack-native каталоги не создаются заранее и разрешены вне template-controlled roots.
- MCP, plugins, credentials, hooks, automations и `.codex/config.toml` остаются opt-in настройками пользователя.
- Consumer `main` по-прежнему строится только из exact tag ветки `source`. Тег `v1.6.2` остается неизменяемой воспроизводимой реализацией v1.

## Рассмотренные альтернативы

- Оставить formal analysis в default payload отклонено: это перегружает большинство новых проектов и дублирует product, business, architecture и codebase owners.
- Сделать analysis optional pack v2 отклонено до появления подтвержденного спроса и отдельного lifecycle пакетов.
- Хранить текущую работу только в чате отклонено: model memory и compaction не дают repository-level resumability.
- Перемещать планы по status-папкам отклонено: ссылки становятся нестабильными.
- Автоматически применять candidates отклонено: promotion меняет канон и требует отдельного authority.
- Предсоздавать универсальные `src/`, `tests/` и `infra/` отклонено: структура должна следовать выбранному стеку.

## Последствия и риски

- v2 consumer проще и универсальнее, но пользователю v1 с formal analysis нужен отдельный осознанный migration plan либо сохранение на `v1.6.2`.
- Plan contract и checkpoints добавляют дисциплину и небольшую стоимость записи, зато работа восстанавливается из репозитория.
- macOS parity подтверждается source CI; локальный pre-push на Windows не заменяет результат macOS runner.
- Расширение Mastery становится data-driven через `mastery/INTENTS.json`, но создание нового executable Skill остается отдельной задачей.

## Проверка

- Generated consumer содержит v2 domains, skills и prompts и не содержит formal-analysis paths.
- Required prompt без Plan v2, stale index, worktree drift или незаконный status transition блокируется.
- Canon graph, Mastery registry и plan index детерминированы.
- Local copy и GitHub-style initialization проходят на Windows; source workflow выполняет тот же контракт на Windows и macOS.
- Privacy и provenance fixtures блокируют PII, secrets, unsafe paths и automatic promotion.

## Откат или замена

Не переписывать v2 и не мигрировать проекты автоматически. Для прежнего formal-analysis workflow создать новый проект из точного `v1.6.2` либо разработать отдельный versioned extension после нового ADR. Выпуск v2 можно остановить до tag/push, не затрагивая опубликованный v1.

## Связи

- План: [Codex-first шаблон v2](../../plans/2026-08-20-codex-first-template-v2.md).
- Контракт: [TEMPLATE.md](../../TEMPLATE.md).
- Распространение: [GitHub Template ADR](2026-08-17-github-template-distribution.md).
- Knowledge: [knowledge contract](../../knowledge/INDEX.md).
- Обратные ссылки на примененные candidates: нет, решение принято прямой командой владельца.
