---
artifact_kind: plan
status: complete
knowledge_outcome: existing
candidate_ids: []
affected_canon:
  - .template-manifest.json
  - analysis/CONTRACT.md
  - mastery/analyst/INDEX.md
  - scripts/verify-analysis.ps1
  - TEMPLATE.md
blocked_reason: null
---

# План: portable analysis control plane

## Цель

Превратить исходный шаблон в переносимое рабочее пространство бизнес- и системного анализа. Решение должно отделять рабочие прогоны от канона, поддерживать закрытый namespace аналитических артефактов, обеспечивать проверяемую трассируемость и безопасно входить в каждую новую копию проекта.

## Границы

Входит:

- portable analysis IA в `analysis/`, `business/analysis/` и `docs/analysis/`;
- восемь baseline-профилей аналитика и расширение project-local mastery intents;
- project-local skill `it-analysis` с trusted run assets;
- атомарный генератор analytical run и отдельный fail-closed verifier;
- интеграция analysis gate перед knowledge gate;
- manifest, навигация, release notes и fresh-copy smoke.

Не входит:

- автоматическая миграция существующих generated projects;
- создание реального канона в исходном шаблоне;
- автоматическое одобрение или promotion артефактов;
- deploy, push, commit или staging;
- изменение owner overlays `.codex/**`, `.agents/skills/bulletproof/**` и `.agents/skills/frontend-design/**`.

## Критерии приемки

1. Fresh generated project получает статический analysis-контур и пустой `analysis/runs`.
2. Canon использует только закрытые ID, kinds, ownership paths и exact-case filenames.
3. Canonical frontmatter принимает только объявленные поля и статусы.
4. `approved` требует прямую `user-request:<safe-ref>` authority и полную доказательную цепочку.
5. Working run содержит ровно восемь файлов, единый UTC run ID и не может сам одобрять канон.
6. Machine refs безопасны, root-relative, exact-case и проверяют anchors; Markdown links остаются file-relative.
7. Traceability invariants для FR, NFR, INT, SPEC, supersedes и orphan artifacts проверяются fail-closed.
8. Provenance различает repo-derived, explicit-user-capture и research-derived без потери первичного источника.
9. Reparse points, traversal, absolute/unsafe URI, secrets, credential URLs, PII и prompt-injection material блокируются.
10. Проверки ограничивают размер файла, corpus bytes и количество файлов.
11. `verify-analysis.ps1 -SelfTest` покрывает положительные и отрицательные fixtures из запроса.
12. `verify-structure.ps1` запускает trusted analysis child раньше trusted knowledge child и агрегирует оба результата.
13. `verify-knowledge.ps1` запрещает `analysis/runs` как canonical target и принимает analyst baseline/intents.
14. `.template-manifest.json` перечисляет весь portable static payload и отдельные generated extension zones.
15. Mastery baseline содержит researcher и analyst profiles с актуальными hashes.
16. Root navigation достигает все portable canonical и workflow документы без ссылок на source-only материалы.
17. Source gates проходят после всех изменений.
18. Fresh-copy smoke подтверждает отсутствие source-only файлов, overlays, prefilled runs и Git commits.
19. Smoke run создается штатным генератором и проходит повторные analysis/structure gates.
20. Финальный отчет содержит version, пути, run ID, результаты gates, review findings и rollback.

## Архитектурные варианты

1. Добавить analysis как внешний add-on после bootstrap. Отклонено: generated project перестает быть самодостаточным, а versioned payload не контролирует runtime и skill.
2. Создать отдельный JSON/SQLite ledger. Отклонено: появляется второй источник истины, усложняется ручной review и нарушается Markdown-first контракт.
3. Расширить текущие manifest, Markdown IA и verifier chain. Выбрано: решение совместимо с существующей control plane, переносимо и проверяемо штатными gate-командами.

## Риски, безопасность и откат

- Главный regression-риск связан с крупными PowerShell verifiers. Изменения разделяются на reusable primitives, самостоятельный analysis verifier и узкие интеграционные точки.
- Внешний `-Root` считается недоверенными данными. Исполняемый код и assets разрешены только рядом с trusted `$PSScriptRoot`.
- Любая неоднозначность namespace закрывается fail-closed. `docs/analysis/context` и `docs/analysis/traceability` остаются view-зонами без новых неявных artifact kinds.
- Откат выполняется поименным возвратом файлов этого плана, manifest/version и новых portable paths. Существующие проекты не очищаются и не мигрируются автоматически.
- Smoke destination проверяется непосредственно перед bootstrap. Существующий каталог не удаляется и не перезаписывается.

## Фаза 1 - [x] Инвентаризация и contracts

Цель: отделить baseline пользователя и проверить live-состояние шаблона.

Deliverable: baseline HEAD, полный список owner overlays, прочитанные manifest, lifecycle, scripts и skills.

Сделано, когда:

- [x] Git baseline зафиксирован до первой записи.
- [x] Исторический checkpoint сопоставлен с live HEAD.
- [x] Обязательные файлы и текущие trust boundaries прочитаны.

## Фаза 2 - [x] Architecture record и static IA

Цель: зафиксировать единственный контракт working/canon, namespace, authority и provenance.

Deliverable: accepted ADR, `analysis/CONTRACT.md`, indexes и templates.

Сделано, когда:

- [x] ADR связан с этим планом и существующими control-plane решениями.
- [x] Все новые portable Markdown paths достижимы из корневой навигации.

## Фаза 3 - [x] Mastery и it-analysis skill

Цель: дать агенту маршрутизацию аналитических задач без автономного одобрения.

Deliverable: analyst baseline, local intents, skill metadata, references и exact eight-file assets.

Сделано, когда:

- [x] Skill проходит project-local validation.
- [x] Mastery baseline hashes согласованы с manifest.

## Фаза 4 - [x] Generator и verifier

Цель: реализовать безопасное создание run и строгую проверку working/canon.

Deliverable: `new-analysis-run.ps1`, `verify-analysis.ps1`, common primitives и regression fixtures.

Сделано, когда:

- [x] Генератор атомарен и не оставляет partial artifacts.
- [x] Все обязательные self-tests дают ожидаемый pass/fail.

## Фаза 5 - [x] Интеграция knowledge и structure gates

Цель: встроить analysis в существующий release control plane без ослабления старых контрактов.

Deliverable: обновленные `verify-knowledge.ps1`, `verify-structure.ps1` и manuals.

Сделано, когда:

- [x] Analysis child запускается первым из trusted source.
- [x] Старые regression harnesses остаются зелеными.

## Фаза 6 - [x] Manifest, version и migration notes

Цель: объявить portable payload и backward-compatible minor release.

Deliverable: manifest `1.3.0`, mastery bundle, changelog и обновленная навигация.

Сделано, когда:

- [x] Exact inventory и hashes согласованы.
- [x] Existing generated projects явно не считаются автоматически мигрированными.

## Фаза 7 - [x] Source verification

Цель: получить evidence по source tree после всех изменений.

Deliverable: AST/skill checks, self-tests, report и TemplateSource gate.

Сделано, когда:

- [x] `git diff --check` и все обязательные source gates успешны.

## Фаза 8 - [x] Fresh-copy smoke и closeout

Цель: доказать переносимость на отдельной свежей копии.

Deliverable: smoke project, один open analysis run, reviews, retrospective и финальный gate log.

Сделано, когда:

- [x] Smoke inventory, zero-commit state и empty-before-run contract подтверждены на финальном snapshot.
- [x] После run analysis и structure gates проходят повторно.
- [x] Независимое и security review закрыты без незавершенных P0/P1 findings.

## Проверки

- PowerShell AST parse для измененных `.ps1` и `.psm1`.
- Project-local skill validation.
- `git diff --check`.
- `scripts/verify-analysis.ps1 -SelfTest`.
- `scripts/verify-knowledge.ps1 -SelfTest`.
- `scripts/verify-knowledge.ps1 -Report`.
- `scripts/verify-structure.ps1 -Mode TemplateSource`.
- Existing regression harnesses, применимые к manifest, links, knowledge, bootstrap и security.
- Fresh generated-project gates до и после создания smoke run.

## Связанные решения

- [Portable analysis control plane](../docs/decisions/2026-08-14-portable-analysis-control-plane.md)
- [Knowledge control plane](../docs/decisions/2026-07-29-knowledge-control-plane.md)
- [Generated payload boundary](../docs/decisions/2026-08-01-generated-payload-boundary.md)

## Итог

Portable analysis control plane выпущен как template payload `1.3.0`. Fresh-copy smoke `SystemAnalysisWorkspace-Smoke-20260815-2` подтвердил пустой `analysis/runs` до штатной генерации, zero-commit state и успешные analysis, knowledge и GeneratedProject gates после создания `RUN-20260815-153854-smoke-system-requirements-eef345`. Knowledge closeout: `existing`, отдельный candidate не требуется, потому что durable-решение уже представлено принятым ADR и каноническими contracts этого изменения.
