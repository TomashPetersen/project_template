---
artifact_kind: retrospective
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

# Ретроспектива: обучаемая аналитическая система и knowledge graph

## Задача и связи

Завершен [план обучаемой аналитической системы](../plans/2026-08-16-assisted-learning-knowledge-graph.md) и реализовано [принятое архитектурное решение](../docs/decisions/2026-08-16-assisted-learning-knowledge-graph.md). Изменение выпускает template payload `1.4.0` для системного и бизнес-анализа без автоматического изменения канона.

## Что сделано

- Добавлен tracked deterministic `knowledge/graph/INDEX.md` с обычными ссылками, root-relative Wikilinks, outgoing links, backlinks, orphans, conflicts и evidence refs.
- Graph `Check` встроен первым trusted semantic child в structure gate; `Write`, `Report` и `SelfTest` используют bounded exact-case resolution.
- Минимальная обучаемость реализована через существующий candidate lifecycle: метод требует независимые evidence либо явную коррекцию оператора, direct authority, medium/high confidence и review due.
- Добавлен project-local шаблон метода и approval-only promotion в `mastery/local`; automatic promotion отсутствует.
- `$it-analysis` ограничивает параллельную read-only декомпозицию тремя специалистами, сохраняет Lead единственным writer и требует независимые review и red-team после synthesis.
- Knowledge closeout и graph check включены в portable workflow и fresh generated project.

## Что проверено и какими командами

- PowerShell AST parse всех `scripts/*.ps1` и `scripts/*.psm1`; `git diff --check`.
- `scripts/update-knowledge-graph.ps1 -Mode SelfTest`, `Check`, `Report`: 11 nodes, 17 edges, 1 orphan, 0 conflicts.
- `scripts/verify-analysis.ps1 -SelfTest`: 54 сценария.
- `scripts/verify-knowledge.ps1 -SelfTest`: все встроенные fixtures.
- Source-only harnesses: artifacts `15/15`, control plane `P0 PASS`, mastery `24/24`, privacy `37`, research `12`, semantics полный pass.
- Disposable fresh copy: source и generated gates прошли, graph fresh, exact eight-file analysis run создан, реальные candidates и local extensions отсутствуют.
- Manual skill validation: exact frontmatter, folder/name, непустой body и обязательные `agents/openai.yaml` поля прошли для `it-analysis` и `knowledge-curator`.

## Что не получилось или осталось

Официальный `quick_validate.py` не стартовал, потому что bundled Python не содержит модуль `yaml`. Новую зависимость не устанавливали; выполнена эквивалентная локальная проверка. Existing generated projects не мигрируются автоматически. Commit, push и deploy не выполнялись.

## Как было и как стало

Раньше шаблон имел knowledge lifecycle и аналитический control plane, но graph памяти почти отсутствовал, а улучшения методов не имели узкого автоматизируемого входа. Теперь fresh project получает детерминированную карту канона и backlinks, управляемый method-candidate closeout, проверяемую оркестрацию и fail-closed promotion. Человек по-прежнему утверждает канон и методы.

## Что выучено

Массив PowerShell-параметров нельзя надежно передавать через native `pwsh -File`: второй `SourceRefs` терялся и создавал ложный A76 fail. Harness переведен на типобезопасный parameter map через encoded child command с `-OutputFormat Text`. Security review также показал, что reparse chain следует проверять до любого `CreateDirectory`, даже если штатный portable layout уже содержит целевой каталог.

## Security review

- Персональные данные: новые fixtures используют только синтетические значения; privacy gate прошел 37 bounded checks.
- Контент третьих лиц: не сохранялся и не отправлялся; внешние ссылки остаются данными с provenance и quarantine contract.
- Внешние отправки: отсутствовали.
- Секреты: credential URL, signed URL, unsafe HTML/Markdown и известные PII patterns блокируются; diagnostics не выводят offending values.
- Trust boundary: executable и module разрешаются рядом с trusted `$PSScriptRoot`; внешний `-Root` остается данными. Graph writer теперь проверяет reparse chain до первого write и повторно после создания каталога.
- Destructive scope: удалялись только disposable temp roots с проверенным parent/prefix; project files, owner overlays и внешняя общая база не удалялись.
