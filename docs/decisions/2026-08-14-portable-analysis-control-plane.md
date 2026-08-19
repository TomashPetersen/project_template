---
artifact_kind: decision
status: accepted
knowledge_outcome: existing
candidate_ids: []
affected_canon:
  - .template-manifest.json
  - analysis/CONTRACT.md
  - mastery/analyst/INDEX.md
  - scripts/verify-analysis.ps1
  - TEMPLATE.md
supersedes: []
blocked_reason: null
---

# Решение: portable analysis control plane

## Контекст и владелец

Шаблон уже переносит research, mastery и knowledge control plane, но не содержит самостоятельного контура бизнес- и системного анализа. Без общего контракта рабочие заметки, требования, модели и решения смешиваются, трассируемость становится соглашением на словах, а fresh project не может проверить полноту или authority.

Владелец решения - template source. Прямое основание - текущий запрос пользователя `user-request:portable-analysis-control-plane-20260814`. Это основание разрешает изменить архитектуру шаблона, но не является blanket-одобрением будущих аналитических артефактов.

## Решение

Добавить portable analysis control plane из трех слоев:

1. `analysis/runs/<RUN-ID>/` - рабочие, непубликуемые прогоны с exact eight-file inventory.
2. `business/analysis/**` и `docs/analysis/**` - Markdown-first canon с закрытым namespace, strict schema, ownership и traceability invariants.
3. `mastery/analyst/**`, project-local `it-analysis` и scripts - переносимая методика, генератор и enforcement.

Canonical ID имеет exact uppercase prefix и четыре цифры. Filename имеет exact lowercase ID и slug. ID глобально уникален без учета регистра. Artifact kind и owner path определяются закрытой таблицей в `analysis/CONTRACT.md`.

Canonical approval разрешен только при прямой root authority `user-request:<safe-ref>`, заполненных provenance и verification refs, а также согласованных `approved_at` и `approved_by`. Accepted ADR может давать дополнительную трассу, но не заменяет согласие пользователя. ADR, созданный в том же run, не может сам одобрить результаты этого run.

Working run никогда не является каноном. Он может ссылаться на исходные repository/user/research sources, но не может быть `target_ref`, `affected_canon` или единственным первичным provenance после promotion.

`docs/analysis/context` и `docs/analysis/traceability` являются derived view-зонами. До отдельного изменения namespace там разрешены только служебные `README.md` и `TEMPLATE.md`; нормативные сущности остаются в перечисленных owner paths.

`verify-analysis.ps1` становится самостоятельным fail-closed gate. `verify-structure.ps1` вызывает его из trusted `$PSScriptRoot` раньше `verify-knowledge.ps1`, передает external `-Root` только как данные и агрегирует оба exit code. Общие path, UTF-8, anchor и safety primitives живут в `scripts/lib/ModelProject.Knowledge.psm1`.

Portable payload объявляется только manifest allowlist. Новая версия является backward-compatible minor release `1.3.0`. Существующие generated projects не изменяются автоматически.

## Рассмотренные альтернативы

1. Внешний analysis add-on. Отклонено: контрольный контур не попадает в fresh project и не связан с template version.
2. Отдельный structured ledger или база. Отклонено: создает второй источник истины и ухудшает reviewable Markdown workflow.
3. Свободные frontmatter kinds и пользовательские prefixes. Отклонено: verifier не может fail-closed определить ownership, обязательные связи и filename contract.
4. Единый verifier для knowledge и analysis. Отклонено: увеличивает связность двух доменных контрактов и усложняет независимые self-tests.

## Последствия и риски

- Все изменения namespace, схемы или approval semantics требуют отдельного решения и regression fixtures.
- Manifest, навигация, baseline hashes и gate-chain должны изменяться атомарно.
- Strict exact-case contract может выявлять ошибки, незаметные на case-insensitive filesystem.
- Heuristic data-safety checks дают консервативные блокировки. Подозрительные материалы остаются в quarantine и не используются как доверенный источник.
- Working artifacts не получают implicit canonical authority через близость к repository root.
- Старые проекты сохраняют прежний контракт до осознанного обновления.

## Проверка

- Positive fixtures: пустой template source, пустой generated project, open/completed run, draft и approved canon.
- Negative fixtures: inventory, schema, path/kind/ID, refs/anchors, graph invariants, authority, provenance, reparse/traversal, unsafe data и resource budgets.
- Source release gates и fresh-copy smoke по manifest payload.
- Independent и security review после реализации.

## Откат или замена

Откат выполняется поименным удалением только добавленных analysis paths и возвратом измененных manifest, navigation, mastery и verifier integration files к предыдущей версии. Owner overlays, существующие generated projects и внешняя общая база знаний не затрагиваются. Замена контракта требует нового ADR и новой version boundary.

## Связи

- [План реализации](../../plans/2026-08-14-portable-analysis-control-plane.md)
- [Knowledge control plane](2026-07-29-knowledge-control-plane.md)
- [Generated payload boundary](2026-08-01-generated-payload-boundary.md)
- [Контракт исходного шаблона](../../TEMPLATE.md)
