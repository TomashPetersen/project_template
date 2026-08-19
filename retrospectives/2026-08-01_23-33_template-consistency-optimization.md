---
artifact_kind: retrospective
knowledge_outcome: existing
candidate_ids: []
affected_canon:
  - .template-manifest.json
  - AGENTS.md
  - INDEX.md
  - PROJECT.md
  - TEMPLATE.md
  - docs/decisions/2026-08-01-generated-payload-boundary.md
  - knowledge/INDEX.md
blocked_reason: null
---

# Ретроспектива: консистентность и эффективность модельного шаблона

## Задача и связи

Задача - оптимизировать шаблон по владельцам и жизненным циклам, не сокращая полезный функциональный объем. Работа выполнена по [`plan`](../plans/2026-08-01-template-consistency-optimization.md) и зафиксирована в [`generated payload ADR`](../docs/decisions/2026-08-01-generated-payload-boundary.md).

## Что сделано

- Manifest оставлен единственным источником версии; legacy `.template-version` и его потребители удалены.
- Source maintenance отделен от generated payload. Bootstrap, release history, owner ADR и regression harnesses остаются source-only; research, mastery, knowledge и два project-local skill остаются portable.
- Portable `INDEX.md` и source-only `TEMPLATE.md` стали независимыми navigation roots.
- `AGENTS.md` сделан mode-aware, чтобы generated project не наследовал ложный запрет продуктовой работы и маршрут к отсутствующему bootstrap.
- Удалены пустые archive-заглушки и незаполненный brand guide. Повторяющиеся RAW, plan, retrospective, research и decision правила заменены ссылками на канонические contracts.
- GeneratedProject verifier теперь отклоняет любой exact source-only path. Staging cleanup повторно проверяет reparse chain перед рекурсивным удалением.

## Что проверено и какими командами

- PowerShell AST: PASS для всех 12 `.ps1` и `.psm1`.
- `verify-knowledge.ps1 -SelfTest`: PASS, включая изоляцию portable и maintenance graph.
- `verify-knowledge.ps1` и `-Report`: PASS, candidates/conflicts/mastery drift равны нулю.
- `verify-structure.ps1 -Mode TemplateSource` и `-Mode Auto`: PASS.
- Public fresh copy: GeneratedProject и Auto PASS; 68 manifest-файлов exact; source-only и owner overlays отсутствуют; dynamic zones чистые; Git commits 0; повторный initializer возвращает только `ERROR: initialization-rejected` и не меняет SHA-дерево.
- `test-knowledge-mastery.ps1`: 20 PASS, 0 FAIL, включая A74 negative diagnostics.
- `test-knowledge-control-plane.ps1 -CaseId 1,2,21`: PASS. После review A02 дополнительно подтвердил controlled failure при возврате `scripts/new-project.ps1` в generated project.
- `git diff --check`: PASS.

## Что не получилось или осталось

- Полные privacy, research, semantics и artifacts harnesses повторно не запускались: затронутые contracts покрыты self-test, mastery, A01/A02/A21 и fresh gate; ранее полученное release evidence сохранено.
- Handle-based защита от конкурентной замены filesystem path не реализована. Перед cleanup добавлены повторные reparse checks; остаточное окно между проверкой и системным вызовом ограничено, но полностью устраняется только другой filesystem API.
- Старые generated projects не мигрируются и не очищаются автоматически.

## Как было и как стало

Было три смешанных lifecycle в одном payload, два источника версии и README с повторяющимися нормативными правилами. Стало два явно разделенных владельца: project root `INDEX.md` для переносимого канона и maintenance root `TEMPLATE.md` для сопровождения source. Generated copy содержит полный рабочий процесс, но не историю и bootstrap владельца шаблона.

## Что выучено

Эффективность шаблона определяется не числом файлов, а однозначным владельцем каждого контракта, независимой навигацией и проверяемой границей payload. Research и knowledge слои полезнее сохранять целиком, а дрейф устранять через single source и negative oracles.

## Security review

- Персональные данные: не добавлялись; RAW payload не создавался и не читался.
- Контент третьих лиц: не добавлялся и наружу не отправлялся.
- Внешние отправки: сеть, push и deploy не использовались.
- Секреты: `.env` и secret-файлы не читались; diagnostics проверены на безопасный код без локальных путей.
