---
artifact_kind: retrospective
knowledge_outcome: existing
candidate_ids: []
affected_canon: []
blocked_reason: null
---

# Ретроспектива: knowledge lifecycle routing 1.2.0

- Дата и время: 2026-07-31 11:58
- Задача: реализовать маршрутизацию агентов и реальное agent-driven автонакопление project-local знаний
- Связанный план или решение: [план](../plans/2026-07-29-knowledge-lifecycle-routing.md), [ADR](../docs/decisions/2026-07-29-knowledge-control-plane.md)

## Что сделано

- Введен единый authority stack: `AGENTS.md` -> `PROJECT.md` -> root/domain indexes -> `knowledge/INDEX.md` -> точный артефакт.
- Добавлен исполняемый project mode и closeout-контракт с результатами `none | existing | ready | applied | blocked`.
- Реализован central Markdown candidate pipeline с атомарным генератором и semantic verifier.
- RAW, research, decisions, plans и retrospectives переведены на единый candidate gate без скрытого promotion.
- Portable состав, source-only history, extension zones и immutable Researcher Mastery сведены в `.template-manifest.json`.
- Copy и initialize scripts переведены на manifest, безопасную staging-copy и режим `initialized + report-only`.
- Исправлены Markdown-only маршруты, root reachability и backlinks.
- Удален run-local `promotion-proposal.md`; startup research возвращает central candidate ID.
- Добавлены встроенные positive и negative fixtures для state, provenance, evidence, RAW, mastery, ссылок, reparse points, traversal, resource limits и редактирования диагностик.
- Forward audit уточнил точный research source: candidate обязан ссылаться на конкретный `decision.md`, а не каталог run, и не получает скрытых delete-полномочий.
- Forward audit устранил два lifecycle-дефекта: исторический `ready:<id>` остается валидным после promotion в `applied`, а версия шаблона больше не зашита в runtime-скрипты.
- Semantic gate проверяет exact machine fields `decision.md`, primary ID, linked set, состояния, лимит трех, orphan candidates, current-run evidence и sibling-пару `evidence.jsonl` + `decision.md`.
- Resource gate ограничивает размер, число decision-файлов и token budget без материализации неограниченных коллекций.

## Что проверено и какими командами

- PowerShell AST пяти измененных скриптов - PASS.
- `scripts/verify-knowledge.ps1 -SelfTest` - PASS, включая child-process CLI redaction, CommonMark-границы, research state/provenance и отсутствие незавершенных artifacts.
- `scripts/verify-knowledge.ps1 -Report` - PASS: pending, dismissed, overdue, conflicts и mastery drift равны нулю.
- `scripts/verify-structure.ps1 -Mode TemplateSource` - PASS.
- `scripts/verify-structure.ps1 -Mode Auto` - PASS.
- Официальный `quick_validate.py` для `$knowledge-curator` и `$startup-researcher` - PASS.
- `git diff --check` - PASS, кроме информационных предупреждений Git о будущей нормализации LF/CRLF.
- Fresh generated copy: `GeneratedProject`, `Auto` и knowledge report - PASS; exact inventory 76 файлов, 0 commits, пустые runs и candidates без owner overlays.
- Изолированный future version bump до `2.0.0` через manifest + mirror - PASS для TemplateSource, copy и GeneratedProject.
- Независимый correctness review - CLEAN.
- Независимый security rereview - CLEAN.
- Forward audit skills, copy и manifest - CLEAN.

## Что не получилось или осталось

- Функциональной работы в заявленном scope не осталось.
- Фоновая память намеренно не создавалась. Система остается agent-driven и использует Git как историю.
- Семантический durable delta нельзя доказать одним скриптом. Его определяет `$knowledge-curator`, а скрипты проверяют форму, ссылки и безопасные границы.
- Остаточные низкие риски: локальная гонка с другим writer между отдельными filesystem checks, неполнота эвристик секретов/PII и доверие локальному PowerShell/Git executable.
- Автоматическое удаление, миграция старых проектов и запись во внешний `Модельный портфель` остаются вне scope.

## Как было и как стало

Раньше правила знаний были распределены между RAW, research proposal, retrospectives и hardcoded copy allowlists. После изменения существует один Markdown-канон маршрутизации, один candidate type, одна state machine, один portable manifest и один обязательный semantic gate.

## Что выучено

- Пустой YAML key и явное `[]` должны иметь разные типы, иначе nullable scalars и списки становятся неразличимыми.
- Редактировать только `Exception.Message` недостаточно: внешний PowerShell CLI добавляет `InvocationInfo`, поэтому безопасный reject должен проверяться отдельным child-process fixture.
- `\s` в .NET regex захватывает переводы строк, а обычный `-match` нечувствителен к регистру; machine fields требуют `[ \t]` и case-sensitive checks.
- Проверка Markdown должна учитывать block-level CommonMark-границы, но не маскировать same-line inline code так, чтобы из него синтезировались machine fields.
- Evidence-only research candidate обязан быть связан с точным `decision.md`, иначе симметрично пустой список в decision скрывает orphan и обходит noise budget.
- Ограничения размера недостаточно, если parser материализует сотни тысяч matches или split-items; нужны bounded grammar, streaming scan и отдельные token budgets.
- Версия должна иметь один канонический источник. Manifest хранит значение, `.template-version` служит проверяемым зеркалом, а runtime не содержит release-specific hardcode.
- Research outcome является историей closeout: `ready:<id>` совместим с последующим `applied`, но не с `dismissed`; `applied:<id>` по-прежнему требует applied-state.
- Динамические коллекции лучше обнаруживать сканированием, а статический канон - графом обычных Markdown-ссылок.
- Baseline и local mastery требуют разных правил: hash-lock для первого и source/review registration для второго.

## Исторический охват closeout

Результат был зафиксирован как уже отраженный в project-local каноне без создания central или shared-owner candidates. Изменение охватывало инструкции, паспорт и индексы, knowledge policy, ADR, portable manifest, оба project-local skill, scripts и mastery.

## Security review

- Персональные данные: в knowledge artifacts не добавлялись; synthetic sentinel использовался только во временных fixtures.
- Контент третьих лиц: новые verbatim-копии не сохранялись.
- Внешние отправки: отсутствуют.
- Секреты: не читались и не сохранялись; signed URLs, credential-like tokens и metadata проверялись только synthetic значениями.
