---
artifact_kind: retrospective
knowledge_outcome: none
candidate_ids: []
affected_canon:
  - .github/workflows/template-integrity.yml
  - .template-manifest.json
  - AGENTS.md
  - CODEX-INSTALL-PROMPT.md
  - INDEX.md
  - MODEL-PROJECT-OVERVIEW.md
  - README.md
  - TEMPLATE-CHANGELOG.md
  - TEMPLATE.md
  - docs/decisions/2026-08-20-codex-first-template-v2.md
  - knowledge/INDEX.md
  - mastery/INTENTS.json
  - scripts/initialize-project.ps1
  - scripts/lib/ModelProject.Platform.psm1
  - scripts/lib/ModelProject.Plan.psm1
blocked_reason: null
---

# Ретроспектива: Codex-first шаблон v2.0.0

## Задача и связи

Перестроить универсальный template вокруг Codex, предметного канона, сохраняемого Plan v2, реализации, проверки и выборочного knowledge closeout. Сохранить сильные safety, provenance, privacy, graph, Researcher Mastery и GitHub distribution механизмы, но убрать formal analysis из consumer.

- [Source plan](../plans/2026-08-20-codex-first-template-v2.md)
- [Breaking ADR](../docs/decisions/2026-08-20-codex-first-template-v2.md)
- [Template contract](../TEMPLATE.md)

## Что сделано

- Добавлены product, business architecture, technical architecture и codebase owners с canon contract и graph routing.
- Реализованы обязательный Plan v2, prompt policies, deterministic index, resume checkpoint, drift detection и `project-delivery`.
- Добавлены data-driven Local Mastery v2, расширяемый intent catalog, preview/promotion generator и rollback.
- Formal-analysis payload и специализированные scripts/prompts удалены из v2; универсальные parser, safety и negative-test primitives сохранены.
- Process, path, Git, null device, case, link, input и lock primitives сведены в cross-platform module для Windows и macOS.
- README начинается с отдельного Codex installation prompt; source release flow вынесен в `TEMPLATE.md`.
- Добавлен source-only CI matrix для `windows-latest` и `macos-latest`.

## Что проверено и какими командами

- `test-platform.ps1` - platform primitives PASS.
- `test-plan-lifecycle.ps1` - Plan v2, deduplication, prompt preflight, deterministic LF index и resume drift PASS.
- `test-canon-graph.ps1` - schema, discovery, graph boundary и stale detection PASS.
- `test-mastery-v2.ps1` - preview, authority, apply, intents, index и rollback PASS.
- `test-v2-consumer-boundary.ps1` - 117 portable files, formal-analysis absent, DistributionTemplate PASS.
- `test-cross-platform-bootstrap.ps1` - local copy, GitHub-style initialization, default owner и invalid input PASS.
- `test-github-template-distribution.ps1` - exact tag build, real commit/clone и 14 trust fixtures PASS.
- `verify-knowledge.ps1 -SelfTest` - все встроенные semantic и safety fixtures PASS.
- `test-knowledge-privacy.ps1` - 37 bounded public CLI cases PASS.
- `test-knowledge-mastery.ps1` - 24/24 PASS.
- `test-knowledge-artifacts.ps1` - 15/15 PASS.
- `test-knowledge-control-plane.ps1` - A01-A23 PASS по полному прогону и focused reruns после исправлений.
- `test-knowledge-research.ps1` - A43-A54 PASS по полному прогону и focused A53/A54 reruns.
- `verify-structure.ps1 -Mode TemplateSource` - PASS, 114 canonical Markdown files.
- PowerShell AST scan и `git diff --check` - PASS.

## Что не получилось или осталось

- macOS workflow подготовлен, но локально на Windows macOS runner не исполнялся. Его результат проверяется после отдельного разрешенного push ветки `source`.
- Commit, tag `v2.0.0`, push и публикация derived `main` не выполнялись. Это отдельные действия после проверки пользователем.
- Старые generated projects автоматически не мигрируются; точный `v1.6.2` остается воспроизводимым.

## Как было и как стало

Раньше consumer по умолчанию содержал formal business/system analysis и не мог надежно продолжить planning prompt после потери chat context. Теперь активная работа имеет один tracked plan и checkpoint, а знания разделены между idea, product, business, architecture, codebase, code/tests и explicit candidates.

## Что выучено

- Derived indexes должны использовать LF независимо от ОС. Иначе descriptor, созданный до Git normalization, расходится после clone.
- Cross-platform migration должна включать source regression harnesses: старый тест на Windows PowerShell 5.1 скрывал небезопасный public diagnostic и устаревший payload oracle.
- Новый общий intent catalog обязан сохранять granular researcher intents, иначе Local Mastery формально существует, но не подключается к startup research retrieval.
- При atomic initialization нельзя печатать промежуточный успешный child output до финального gate: поздний rollback иначе раскрывает локальный path или unsafe fixture content.

## Security review

- Персональные данные: известные имя, GitHub handle и абсолютные локальные paths не найдены; один исторический repository handle обезличен. `person@example.com` остается только синтетической negative fixture.
- Контент третьих лиц: новые сторонние материалы не добавлялись; existing notices сохранены.
- Внешние отправки: не выполнялись. Network, commit, tag, push и deploy отсутствуют.
- Секреты: реальные credentials не читались и не сохранялись; secret-like строки существуют только в bounded negative fixtures.
- Trust boundaries: traversal, case, symlink/reparse, Git environment, bounded output, PII/secret и rollback cases зеленые.

## Local pre-push report

- Рабочая ветка: `source`.
- Pre-task HEAD: `96f6c11d0b3b2e00147889619ba689c10042e287`.
- Release version в manifest: `2.0.0`.
- Existing tag `v1.6.2` разрешается в commit `c8639f22f0517ca7b6dbba5d96b1ff3ef5c8e326` и не изменялся.
- Index не staged; commit, tag и push не выполнялись.
- Knowledge closeout: `none`, потому что durable release решения уже выражены в ADR, contracts, scripts и tests, а `template-source + disabled` запрещает candidate creation.
