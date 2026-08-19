---
method_id: project-method-id
owner_scope: project
applies_to:
  - functional-requirements
status: active
source_refs:
  - knowledge/candidates/YYYY/KC-YYYYMMDD-HHmmss-8hex.md
verified_at: YYYY-MM-DD
review_due: YYYY-MM-DD
supersedes: null
---

# Название локального метода

## Purpose

Какую повторяемую аналитическую задачу упрощает метод и какой результат дает оператору.

## Applies to

Когда применять метод, когда не применять и какой intent из закрытого списка он обслуживает.

## Inputs

Минимальные входные артефакты, источники и ограничения.

## Workflow

Короткая воспроизводимая последовательность действий без автоматического изменения канона.

## Outputs

Какие working или canonical артефакты ожидаются после разрешенного handoff.

## Quality gate

Проверяемые условия достаточности, traceability и независимого review.

## Failure modes

Типичные ошибки, условия остановки и безопасный fallback.

## Learning evidence

Почему метод устойчив: два независимых task/run source либо явная коррекция оператора с user authority и project source.

## Provenance

Ссылка на applied candidate из `knowledge/candidates/`. Candidate остается владельцем истории обучения.

## Review dates

Проверить `verified_at` и `review_due`. По умолчанию review назначается через 180 дней после применения candidate.

## Navigation

- [Local Mastery registry](INDEX.md)
- [Knowledge lifecycle](../../knowledge/INDEX.md)
- [Knowledge graph](../../knowledge/graph/INDEX.md)
