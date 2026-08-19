---
artifact_kind: decision
status: accepted
knowledge_outcome: existing
candidate_ids: []
affected_canon:
  - .template-manifest.json
  - analysis/CONTRACT.md
  - knowledge/INDEX.md
  - mastery/local/INDEX.md
  - scripts/verify-structure.ps1
supersedes: []
blocked_reason: null
---

# Решение: обучаемая аналитическая система и derived knowledge graph

## Контекст и владелец

Оператор проекта является системным и бизнес-аналитиком. Ему нужен один переносимый workflow для создания требований, моделей, ТЗ, review и повторного применения проверенного опыта. Владельцами нормативного текста остаются существующие project canon paths.

## Решение

- Frontmatter refs и canonical Markdown остаются источниками истины.
- `knowledge/graph/INDEX.md` является tracked deterministic derived view с обычными ссылками и Wikilinks.
- Graph refresh выполняется в closeout write-задачи, а stale view блокирует structure gate.
- `$it-analysis` остается единственным верхнеуровневым analysis skill; Lead является единственным writer, specialist agents работают read-only.
- Automatic candidate допустим только по существующему `active + safe-local + HEAD` контракту.
- Повторяемый опыт предлагается как `type: method`, `domain: mastery`; promotion в `mastery/local` выполняется только после прямого approval.

## Рассмотренные альтернативы

- Reciprocal Wikilinks внутри каждого canonical artifact отклонены из-за multi-file churn и второго навигационного состояния.
- Фоновый watcher/daemon отклонен из-за скрытых side effects, шума и нового runtime state.
- Внешняя graph database отклонена как второй источник истины.
- Automatic method promotion отклонен, потому что формальная schema validation не доказывает смысловую полезность метода.

## Последствия и риски

- Человек получает готовый индекс связей и backlinks без ручного дублирования.
- Graph должен обновляться после любого изменения его входов; незавершенный refresh блокирует сдачу задачи.
- Derived view может быть удален и восстановлен без потери канона.
- Semantic relevance, consent и реальная полезность learning signal остаются human-in-the-loop решениями.

## Проверка

Generator обязан иметь Check, Write, Report и SelfTest. Full structure gate запускает trusted graph child раньше analysis и knowledge gates. Fresh-copy smoke проверяет пустое динамическое состояние, deterministic graph и один управляемый analysis run.

## Откат или замена

Вернуть manifest и navigation, удалить graph generator/view и снять graph child gate. Canonical refs, candidates и local mastery artifacts не переписывать.

## Связи

- План: [обучаемая аналитическая система и Wikilink-граф](../../plans/2026-08-16-assisted-learning-knowledge-graph.md).
- Предметный документ: [Knowledge](../../knowledge/INDEX.md), [Analysis contract](../../analysis/CONTRACT.md).
- Обратные ссылки на примененные candidates: нет, решение уже зафиксировано этим ADR.
