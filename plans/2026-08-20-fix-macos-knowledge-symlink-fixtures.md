---
artifact_kind: plan
plan_contract_version: 2
plan_id: PLAN-20260820-fix-macos-knowledge-symlink-fixtures
task_key: fix-macos-knowledge-symlink-fixtures
prompt_ref: prompts/feature-bugfix-delivery.md
status: complete
current_phase: null
updated_at: 2026-08-20T19:33:03Z
completed_at: 2026-08-20T19:33:03Z
closeout_status: complete
knowledge_outcome: none
candidate_ids: []
result_refs:
  - scripts/verify-knowledge.ps1
  - scripts/update-knowledge-graph.ps1
  - scripts/test-knowledge-semantics.ps1
  - plans/2026-08-20-fix-macos-knowledge-symlink-fixtures.md
affected_canon:
  - TEMPLATE-CHANGELOG.md
  - .template-manifest.json
blocked_reason: null
---

# План: Исправление macOS symlink fixtures knowledge CI

## Цель

Исправить кроссплатформенные symlink/reparse negative fixtures, из-за которых macOS CI v2 завершается ошибкой после успешного прохождения platform primitives.

## Границы

Входит:

- заменить Windows-only создание `Junction` в выполняемых на macOS fixtures на явный выбор `Junction` для Windows и `SymbolicLink` для Unix;
- сохранить строгую проверку, что link действительно создан и обнаруживается safety-контуром;
- проверить все аналогичные knowledge/graph fixtures, чтобы следующий macOS шаг не упал по той же причине;
- выполнить локальные gates, commit, точечный push `source:source` и дождаться Windows/macOS CI.

Не входит:

- изменение production policy запрета links в пользовательских путях;
- публикация `main`, создание `v2.0.0`, GitHub Release или deploy;
- изменение пользовательских overlays `.agents/skills/bulletproof/**`, `.agents/skills/frontend-design/**` и `.codex/**`.

## Критерии приемки

- [x] AC-01 Активные v2 knowledge/graph directory-link fixtures используют поддерживаемый тип link на текущей ОС и завершаются с `-ErrorAction Stop`.
- [x] AC-02 `verify-knowledge.ps1 -SelfTest`, semantic/graph tests и полный локальный release gate проходят на Windows.
- [x] AC-03 Внешний gate подготовлен: после terminal plan выполнить отдельный commit, точечный push `source:source` и дождаться `windows-latest` и `macos-latest` до финального ответа.
- [x] AC-04 Privacy/provenance и protected-overlay checks зелены; staging ограничен точными проверенными paths.

## Риски, безопасность и откат

- Риск: ослабить production link policy вместо исправления fixture. Мера: менять только test/self-test setup, сохранять прежние assertions.
- Риск: удалить target вместе с link. Мера: очищать только точный fixture-link, затем отдельный временный fixture root.
- Откат: отдельный обычный follow-up commit, без amend, force push и destructive reset.

## Фаза P1 - [x] Диагностика и полный охват fixtures

Цель: подтвердить первопричину из macOS job log и найти все Windows-only directory-link fixtures в portable CI.

Deliverable: минимальный список безопасных изменений и regression scope.

Сделано, когда: каждый релевантный `ItemType Junction` классифицирован как Windows-only или требует Unix fallback.

Задачи:

- [x] Получить точный failing step и безопасный фрагмент GitHub log.
- [x] Подтвердить, что `reparse-root` не создается перед verifier call.
- [x] Проверить все portable knowledge/graph fixtures с `Junction`.

## Фаза P2 - [x] Кроссплатформенное исправление

Цель: использовать `Junction` на Windows и `SymbolicLink` на Unix без изменения production policy.

Deliverable: обновленные fixtures и явная проверка созданного link.

Сделано, когда: AST и целевые локальные tests проходят, а Windows behavior сохранено.

Задачи:

- [x] Внести минимальные изменения во все релевантные fixtures.
- [x] Добавить/сохранить link-creation assertions и безопасный cleanup.
- [x] Обновить manifest/changelog/plan по release contract.

## Фаза P3 - [x] Release regression и внешний push gate

Цель: подтвердить исправление полным локальным и удаленным контуром.

Deliverable: terminal plan, exact staging/commit/refspec и процедура ожидания matrix CI.

Сделано, когда: локальные acceptance gates и knowledge closeout закрыты, а внешние commit/push/CI действия готовы к выполнению после terminal transition.

Задачи:

- [x] Выполнить локальные target и release gates.
- [x] Провести privacy, security и impact review.
- [x] Завершить plan и knowledge closeout без candidate/promotion.
- [x] Подготовить отдельный commit, `git push origin source:source` и ожидание обоих CI jobs после terminal plan.

## Проверки

- Pre-task HEAD: `6b5c43be5ea797a6a484cafb14afdd2bed761ac8`; worktree и index были чистыми.
- Failed workflow: run `32403057951`, macOS job `96535581891`, step `Verify semantic knowledge fixtures`.
- Exact failure: `reparse-root` отсутствовал после попытки создать Windows-only `Junction` на macOS.
- Target: PowerShell AST PASS; `verify-knowledge.ps1 -SelfTest` PASS; graph SelfTest PASS; semantic A30 PASS после forward-slash path normalization.
- Full local Windows CI equivalent: platform, TemplateSource 118, Plan lifecycle, canon/graph, Mastery v2, consumer boundary 117, bootstrap, distribution 14/14 и privacy 37/37 - PASS.
- Git hygiene: `git diff --check` PASS; personal identifier и absolute user-home scans PASS; protected overlays unchanged.
- Security/impact review: production link policy не изменена; fixture path/target изолированы в system temp; создание link fail-fast и проверяется до safety assertions; legacy v1 control-plane не изменен.
- Knowledge closeout: `none` - durable delta уже является source-of-truth test behavior и записана в changelog; candidate или promotion не нужны.
- External gate после terminal plan: exact commit, `git push origin source:source`, сверка remote ref и terminal conclusions Windows/macOS.

## Связанные решения

- Решения:

- [`Codex-first template v2`](../docs/decisions/2026-08-20-codex-first-template-v2.md).

## Resume checkpoint

- Текущая фаза: нет - план завершен
- Уже выполнено: P1-P3 complete: diagnosed macOS Junction failure, implemented OS-aware active v2 fixtures, ran full local Windows CI equivalent and finished knowledge closeout none.
- Последние успешные проверки: AST; diff-check; platform; TemplateSource 118; Plan; canon/graph; Mastery; consumer 117; bootstrap; distribution 14/14; knowledge SelfTest; semantic A30; privacy 37/37; PII and protected-overlay scans - PASS.
- Точные рабочие paths: .template-manifest.json; TEMPLATE-CHANGELOG.md; plans/2026-08-20-fix-macos-knowledge-symlink-fixtures.md; plans/INDEX.md; scripts/verify-knowledge.ps1; scripts/update-knowledge-graph.ps1; scripts/test-knowledge-semantics.ps1
- Git checkpoint: v1:88700d7b90398aaa15a55a28df1646e973d4c200ddfe019030ddf679ff972c85
- Следующее действие: нет - plan terminal; follow-up требует новый plan_id
- Блокеры: нет
- Обновлено: 2026-08-20T19:33:03Z

## Итог

- Реализовано целиком: да - активные v2 negative fixtures используют `Junction` на Windows и `SymbolicLink` на Unix, сохраняя одинаковый fail-closed oracle.
- Что осталось: внутри plan ничего; после terminal transition выполнить отдельно разрешенные commit, `source:source` push и CI verification.
- Коммиты: baseline `6b5c43be5ea797a6a484cafb14afdd2bed761ac8`; follow-up fix создается после terminal plan.

Перед `complete` закрой criteria и фазы, заполни проверки, итог, `result_refs`, closeout и финальный knowledge outcome. Не дублируй остальные machine fields в body.
