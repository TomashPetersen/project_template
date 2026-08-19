---
artifact_kind: retrospective
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

# Ретроспектива: portable analysis control plane

## Задача и связи

Реализован план [portable analysis control plane](../plans/2026-08-14-portable-analysis-control-plane.md) и принято связанное [архитектурное решение](../docs/decisions/2026-08-14-portable-analysis-control-plane.md). Изменение выпускает переносимый аналитический контур как часть template payload `1.3.0`.

## Что сделано

- Добавлены разделенные working и canonical зоны для бизнес- и системного анализа.
- Введены закрытые ID, artifact kinds, owner paths, lifecycle, authority, provenance и traceability invariants.
- Добавлены baseline-профили аналитика и skill `it-analysis` с exact eight-file run assets.
- Реализованы атомарный генератор run и fail-closed analysis verifier.
- Analysis gate встроен перед knowledge gate, а knowledge lifecycle учитывает handoff из `analysis/runs` без потери первичного provenance.
- Обновлены manifest, mastery hashes, навигация, version и migration notes.

## Что проверено и какими командами

- PowerShell AST parse для измененных scripts.
- `scripts/verify-analysis.ps1 -SelfTest` - 53 сценария.
- `scripts/verify-analysis.ps1 -Report`.
- `scripts/verify-knowledge.ps1 -SelfTest` и `-Report`.
- `scripts/verify-structure.ps1 -Mode TemplateSource` в Windows PowerShell и текущем PowerShell.
- Source-only harnesses для artifacts, control plane, mastery, privacy, research и semantics: `15/15`, focused control-plane `A02`, `24/24`, `37/37`, `12/12` и полный pass соответственно.
- Fresh-copy bootstrap подтвердил отсутствие source-only paths, dynamic runs/candidates и Git `HEAD`.
- В финальной fresh copy `SystemAnalysisWorkspace-Smoke-20260815-2` создан `RUN-20260815-153854-smoke-system-requirements-eef345`: ровно восемь файлов, staging отсутствует, analysis report имеет `canon=0, runs=1, issues=0`, knowledge report и GeneratedProject structure gate прошли, Git commits отсутствуют.

## Что не получилось или осталось

Официальный `quick_validate.py` для skill нельзя было запустить в bundled Python: в runtime отсутствует модуль `yaml`. Структура и metadata skill проверены эквивалентными локальными правилами, без установки новой зависимости. Промежуточная fresh copy `SystemAnalysisWorkspace-Smoke-20260815` выявила locale-dependent coercion quoted RFC3339 timestamp через `ConvertFrom-Json`; run и staging не опубликовались. Парсер заменен детерминированным разбором JSON-строки, после чего новая fresh copy прошла полный сценарий. Существовавшие до работы каталоги `SystemAnalysisWorkspace-Smoke` и `SystemAnalysisWorkspace-Smoke-2` не изменялись. Existing generated projects остаются на своей версии и не мигрируются автоматически.

## Как было и как стало

Раньше шаблон имел research и knowledge control plane, но не имел нормативного разделения рабочих аналитических материалов, требований, моделей и ТЗ. Теперь fresh project получает пустую working-зону, канонические owner paths, методику, генератор и проверяемую цепочку analysis -> knowledge -> structure.

## Что выучено

Reusable safety primitives должны экспортироваться общим модулем, но integrity проверки этого модуля обязаны выполняться до его импорта минимальным bootstrap-кодом. Streaming UTF-8 reader должен удалять BOM после strict decode: regression research gate поймал этот дефект по anchor первого heading. Scriptblock fixtures должны явно захватывать helper functions, иначе `.GetNewClosure()` теряет команды и создает ложные privacy failures. Вывод дочерних Windows PowerShell процессов следует нормализовать по окончаниям строк в regression harness, иначе корректный gate дает ложный fail на CRLF.

## Security review

- Независимый checklist-review не выявил незакрытых P0/P1 findings; working/canon ownership, derived view zones и user-only approval не имеют конкурирующих источников истины.
- Trusted scripts и module разрешаются рядом с `$PSScriptRoot`, проходят exact-case и full-chain reparse checks; проверяемый `-Root` остается только данными.
- Run публикуется через уникальный owned staging directory и атомарный directory move; при ошибке удаляется только проверенный staging path.
- Персональные данные: новые fixtures используют только синтетические значения; существующие privacy gates не ослаблены.
- Контент третьих лиц: не сохранялся и не отправлялся.
- Внешние отправки: отсутствовали.
- Секреты: secret, credential URL и известные PII patterns блокируются до handoff; diagnostics не выводят offending value.
