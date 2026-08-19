---
artifact_kind: plan
status: complete
knowledge_outcome: none
candidate_ids: []
affected_canon:
  - .template-manifest.json
  - analysis/CONTRACT.md
  - knowledge/INDEX.md
  - knowledge/graph/INDEX.md
  - mastery/local/INDEX.md
  - scripts/update-knowledge-graph.ps1
  - scripts/verify-structure.ps1
blocked_reason: null
---

# План: обучаемая аналитическая система и Wikilink-граф

## Цель

Выпустить template payload `1.4.0`, в котором системный или бизнес-аналитик запускает один управляемый workflow, получает проверяемые аналитические артефакты, deterministic перекрестный граф знаний и минимальную обучаемость методов без автоматического promotion.

## Границы

Входит:

- tracked derived-граф `knowledge/graph/INDEX.md` из canonical refs;
- automatic durable-delta closeout для всех write-задач в разрешенном режиме;
- method candidates и approval-only promotion в `mastery/local`;
- single-writer orchestration внутри `$it-analysis`;
- manifest, verifiers, tests, fresh-copy smoke и release notes.

Не входит:

- daemon, watcher, внешний multi-agent runtime или отдельная база данных;
- обучение весов модели;
- automatic promotion, commit, push, deploy или delete;
- автоматическая миграция существующих generated projects.

## Критерии приемки

1. Graph `Write` детерминированно строит один tracked INDEX, а `Check` блокирует stale и ручной drift.
2. Wikilinks и обычные Markdown-ссылки разрешаются в exact case без traversal, unsafe URI и reparse points.
3. Граф включает project canon, analysis canon, accepted ADR, active local mastery и candidates; runs и RAW остаются evidence refs.
4. Knowledge closeout применяется ко всем write-задачам и создает максимум один automatic candidate только в `active + safe-local` с Git HEAD.
5. Method candidate требует два независимых task/run evidence либо explicit operator correction, medium/high confidence и review due.
6. Promotion метода остается user-approved и создает зарегистрированный `mastery/local` artifact с backlink.
7. `$it-analysis` фиксирует assignments, findings, conflict resolution, Lead synthesis, independent review и red-team verdict без изменения exact eight-file inventory.
8. `verify-structure.ps1` запускает trusted graph gate раньше analysis и knowledge gates.
9. Fresh project содержит актуальный граф, пустые runs/candidates/local extensions и полный portable workflow.
10. Source self-tests, regression harnesses и fresh-copy smoke проходят на финальном snapshot.

## Риски, безопасность и откат

- Graph output считается derived view и никогда не становится владельцем нормативного текста.
- Внешний `-Root` остается данными; executable и module загружаются только рядом с trusted `$PSScriptRoot`.
- Graph report не выводит claim bodies, credential URLs, PII или небезопасные locators.
- Ошибка refresh возвращает `blocked: stale-knowledge-graph` без автоматического отката canonical change set.
- Откат удаляет graph view/generator и возвращает прежний closeout, не меняя canonical artifacts и candidates.

## Фаза 1 - [x] Contract и fixtures

Цель: зафиксировать единственную архитектуру graph, learning и orchestration.

Deliverable: plan, accepted ADR, failing graph/method/orchestration fixtures.

Сделано, когда:

- [x] Новые contracts не создают второй источник истины.
- [x] Negative fixtures воспроизводят stale graph и invalid method evidence.

Задачи:

- [x] Зафиксировать graph input/output и failure codes.
- [x] Зафиксировать method candidate threshold и approval lifecycle.

## Фаза 2 - [x] Deterministic knowledge graph

Цель: реализовать безопасный generator/checker и tracked view.

Deliverable: `scripts/update-knowledge-graph.ps1`, graph INDEX и structure integration.

Сделано, когда:

- [x] Check, Write, Report и SelfTest работают детерминированно.
- [x] Structure gate fail-closed проверяет trusted graph child.

Задачи:

- [x] Реализовать bounded discovery, node/edge extraction и atomic write.
- [x] Добавить exact Wikilinks, backlinks, orphans, conflicts и evidence refs.

## Фаза 3 - [x] Learning и orchestration

Цель: дать оператору один полный цикл analysis -> closeout -> graph.

Deliverable: обновленные knowledge, mastery и it-analysis contracts/assets.

Сделано, когда:

- [x] Все write-задачи имеют явный closeout и graph check.
- [x] Method candidate и promotion проверяются fail-closed.
- [x] Run хранит single-writer orchestration evidence.

Задачи:

- [x] Добавить `mastery/local/TEMPLATE.md` и method validation.
- [x] Расширить skill, orchestration reference и run headings.

## Фаза 4 - [x] Packaging и release gate

Цель: доказать переносимость в fresh generated project.

Deliverable: manifest `1.4.0`, changelog, regression evidence, smoke и retrospective.

Сделано, когда:

- [x] Source gates и все применимые harnesses зелены.
- [x] Fresh-copy graph, run, closeout и GeneratedProject gate проходят.

Задачи:

- [x] Обновить portable/source-only inventories и навигацию.
- [x] Провести independent и security review.

## Проверки

- PowerShell AST и `git diff --check`.
- Graph `-Mode SelfTest`, `Check` и `Report`.
- Analysis и knowledge self-tests.
- Artifacts, control-plane, mastery, privacy, research и semantics harnesses.
- TemplateSource и GeneratedProject structure gates.
- Fresh-copy smoke без source commit, stage, push или deploy.

## Связанные решения

- Решения: [Обучаемая аналитическая система и derived knowledge graph](../docs/decisions/2026-08-16-assisted-learning-knowledge-graph.md).

## Итог

- Реализовано целиком: да, локальный template payload `1.4.0` готов к handoff без публикации.
- Что осталось: только отдельное решение пользователя о commit/push; existing generated projects автоматически не мигрируются.
- Коммиты: не создаются без отдельной прямой команды.

## Финальное evidence 2026-08-16

- Graph `SelfTest`, `Check` и `Report` прошли: 11 nodes, 17 edges, 1 orphan, 0 conflicts; self-test покрывает determinism, stale drift и блокировку reparse до первого write.
- `verify-analysis.ps1 -SelfTest` прошел 54 сценария; `verify-knowledge.ps1 -SelfTest` прошел все встроенные fixtures.
- Source-only harnesses: artifacts `15/15`, control plane `P0 PASS`, mastery `24/24`, privacy `37`, research `12`, semantics полный pass.
- Fresh public copy прошла TemplateSource и GeneratedProject gates, сохранила свежий graph, создала exact eight-file analysis run и осталась с 0 реальных candidates и 0 local extensions.
- Independent review подтвердил single-writer, closed ownership и отсутствие automatic promotion. Security review нашел и закрыл порядок pre-write reparse check в graph writer.
- Официальный skill validator не стартовал из-за отсутствующего `yaml` в bundled Python; эквивалентная проверка frontmatter, folder/name, body и `agents/openai.yaml` прошла для `it-analysis` и `knowledge-curator`.
- Ретроспектива: [assisted learning knowledge graph](../retrospectives/2026-08-16_22-41_assisted-learning-knowledge-graph.md).

## Checkpoint 2026-08-16

- Реализованы contracts, generator/checker графа, structure child gate, method-candidate validation, local method template и single-writer orchestration assets.
- Последний успешный graph self-test: write/check/determinism/stale detection; report текущего снимка: 11 nodes, 17 edges, 1 orphan, 0 conflicts.
- Analysis self-test прошел 54 сценария. Knowledge self-test проходил полностью до добавления последнего generator-negative fixture; его нужно повторить на текущем snapshot.
- TemplateSource gate проходил до последних документационных и test-fixture правок; его нужно повторить.
- Artifact harness завершен: 15/15. Совмещенный mastery/semantics запуск остановлен по просьбе пользователя после успешного `A74 one-way local replacement chain`; оставшиеся mastery cases и semantics нужно запустить заново целиком.
- Не запускались текущий privacy, research, control-plane full harness, final fresh-copy smoke, quick skill validation, retrospective и финальный review.
- Stage, commit, push и deploy не выполнялись. Pre-existing owner overlays не изменялись.

## Checkpoint 2026-08-16 - повторная пауза

- Полный `verify-knowledge.ps1 -SelfTest` прошел на текущем production snapshot, включая generator-negative и три method-candidate fixtures.
- `test-knowledge-semantics.ps1` прошел.
- `test-knowledge-privacy.ps1` прошел: 37 bounded checks.
- `test-knowledge-research.ps1` прошел: 12 requested cases.
- `test-knowledge-control-plane.ps1` прошел: `KNOWLEDGE CONTROL PLANE P0 PASS`, включая trusted knowledge-graph child, fresh initialized/report-only project, zero commits, race, Git и rollback gates.
- Artifact harness из предыдущего checkpoint остается зеленым: 15/15.
- Mastery harness сейчас имеет один blocker: `A76 canonical shared mastery logical source passes`; остальные 23 cases проходят. Fixture уже переведен на exact local mastery target, добавлен `PROJECT.md` как project source и `method.*` claim key, но public generator все еще возвращает generic rejection.
- Следующий шаг при возобновлении: не запускать весь mastery harness сразу. Сначала создать узкое A76-воспроизведение или безопасно получить internal stable failure code, проверить фактическую передачу двух `SourceRefs` через `ProcessStartInfo.ArgumentList`, затем исправить только доказанную причину и повторить полный mastery harness.
- После A76 остаются final graph/analysis/structure gates, skill validation, independent/security review, fresh-copy smoke, retrospective и финальный closeout.
- Stage, commit, push и deploy не выполнялись. Owner overlays не изменялись.
