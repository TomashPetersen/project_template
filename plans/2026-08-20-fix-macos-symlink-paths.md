---
artifact_kind: plan
plan_contract_version: 2
plan_id: PLAN-20260820-fix-macos-symlink-paths
task_key: fix-macos-symlink-paths
prompt_ref: prompts/feature-bugfix-delivery.md
status: complete
current_phase: null
updated_at: 2026-08-20T18:22:29Z
completed_at: 2026-08-20T18:22:29Z
closeout_status: complete
knowledge_outcome: none
candidate_ids: []
result_refs:
  - scripts/lib/ModelProject.Platform.psm1
  - scripts/test-platform.ps1
  - scripts/test-cross-platform-bootstrap.ps1
  - scripts/test-github-template-distribution.ps1
  - scripts/verify-knowledge.ps1
  - .github/workflows/template-integrity.yml
  - plans/2026-08-20-fix-macos-symlink-paths.md
affected_canon:
  - TEMPLATE-CHANGELOG.md
  - .template-manifest.json
blocked_reason: null
---

# План: Исправление macOS trusted symlink paths для CI

## Цель

Исправить доказанный macOS CI failure, сохранив fail-closed запрет на недоверенные symlink/reparse paths: штатные executable и system temp сначала разрешаются в физический final path, затем проходят повторную trust-проверку.

## Границы

Входит:

- physical path resolver для существующих symlink/reparse segments;
- безопасное разрешение trusted `pwsh`, `git` и system temp;
- перенос CI fixtures на физический system temp;
- positive/negative tests, Windows regression, follow-up commit и `source` push;
- ожидание нового Windows/macOS workflow до terminal conclusion.

Не входит:

- ослабление запрета symlink для пользовательских project paths;
- force push, amend опубликованного commit, tag `v2.0.0`, `main` или deploy;
- изменение API предметного canon и consumer структуры вне platform helper.

## Критерии приемки

- [x] AC-01 Доказанный job `96517159529` воспроизводимо объяснен: macOS trusted/system paths проходят через штатные links и текущий helper fail-closed их отвергает.
- [x] AC-02 Resolver обрабатывает существующие link segments, возвращает физический path и блокирует unresolved/broken/cyclic или небезопасный результат.
- [x] AC-03 Trusted executable проверяет original и resolved paths, allowed leaf, file type, controlled roots и отсутствие links после resolution.
- [x] AC-04 System temp возвращается физическим существующим directory без link chain; lock и source-only fixtures используют его.
- [x] AC-05 Platform, Plan, bootstrap, distribution, consumer, privacy, knowledge и structure regressions зеленые на Windows.
- [x] AC-06 Внешний release gate готов: после terminal `complete` разрешены один follow-up commit и `source:source` push; новый workflow, tag и `main` проверяются до финального ответа вне terminal plan.

## Риски, безопасность и откат

- Resolution только после проверки original controlled-root boundary, чтобы symlink из управляемого root не обходил trust gate.
- Final target повторно проверяется на allowed leaf, type, controlled roots и остаточные links.
- Пользовательские destination/source paths не physicalize автоматически и сохраняют строгий no-link contract.
- При CI failure опубликованная история не переписывается; создается отдельный follow-up fix.

## Фаза P1 - [x] Contract и failing evidence

Цель: зафиксировать точную failure boundary и минимальный безопасный контракт.

Deliverable: job evidence, threat analysis и focused test matrix.

Сделано, когда: AC-01, AC-02 и AC-03 покрыты конкретными assertions.

Задачи:

- [x] Зафиксировать macOS log и все вызовы `GetTempPath`/trusted executable в CI path.
- [x] Спроектировать original-path и final-path validation без blanket symlink allowance.
- [x] Добавить focused resolver/executable/temp fixtures.

## Фаза P2 - [x] Реализация и impacted regressions

Цель: внедрить physical resolution в общий platform layer и минимально обновить CI fixtures.

Deliverable: platform helper, migrated temp roots и зеленые impacted Windows tests.

Сделано, когда: AC-02-AC-05 подтверждены.

Задачи:

- [x] Реализовать resolver, trusted executable resolution и physical system temp.
- [x] Обновить CI harnesses и embedded selftests, которые создают trust-sensitive temp roots.
- [x] Запустить AST, platform, Plan, bootstrap, distribution, consumer, privacy, knowledge и structure gates.
- [x] Провести security review original/final path и TOCTOU boundary.

## Фаза P3 - [x] Closeout и follow-up release gate

Цель: подготовить terminal plan и отдельный non-force fix commit.

Deliverable: exact staged diff, `knowledge_outcome: none`, commit/refspec и CI wait procedure.

Сделано, когда: local gates зеленые, exact paths staged, plan complete и внешний release gate готов.

Задачи:

- [x] Выполнить exact staging, staged check и privacy scan.
- [x] Закрыть plan и knowledge closeout без candidate/promotion.
- [x] Подготовить exact fix commit, `source:source` refspec и ожидание обоих CI jobs после terminal plan.

## Проверки

- Pre-task HEAD: `d85e80082a1683753655576b8490b40984bb9c7e`; worktree и index чистые.
- Pre-task snapshot: четыре обязательные Git-команды выполнены до первой записи.
- Failed workflow: run `32397349365`, macOS job `96517159529`, step `Verify platform primitives`.
- Exact log: `Exception: Путь не может проходить через symlink или reparse point.`
- Red fixture: обновленный `test-platform.ps1` до реализации завершился с `Get-ModelProjectSystemTempRoot is not recognized`.
- Focused green: physical resolver/temp/executable assertions проходят на Windows; `test-platform.ps1` PASS.
- Static integration: TemplateSource PASS, 117 canonical Markdown files; Plan v2 PASS после нового source-only follow-up plan.
- Focused regression: PowerShell AST, `git diff --check`, platform, Plan lifecycle, canon graph, Mastery v2 и TemplateSource PASS.
- Integration regression: cross-platform bootstrap PASS; distribution 14/14; consumer portable=117 и formal-analysis absent; privacy exit=0; knowledge SelfTest PASS.
- Security review: original executable path проверяется до resolution, final target повторно проверяется по leaf/type/controlled roots/no-link; broken or missing target fail-closed; пользовательские project paths не physicalize.
- TOCTOU: execution и lock используют returned physical path, поэтому последующее изменение исходной link alias не меняет выбранный target; общий filesystem replacement race остается ограничением существующего agent-driven contract.
- Final staged gate: 16 exact manifest-declared paths; cached check PASS; unstaged=0; untracked=0; AST, platform, Plan, bootstrap, consumer, distribution 14/14, privacy 37/37, knowledge SelfTest и TemplateSource PASS.
- Commit: `git commit -m "fix: resolve trusted macOS symlink paths"`; push: только `git push origin source:source`.
- Remote/CI: сравнить exact HEAD с `origin/source`, убедиться в неизменности `main` и `v1.6.2`, дождаться terminal conclusions `windows-latest` и `macos-latest`.
- Knowledge closeout: `none` - устойчивое исправление уже выражено в platform contract, tests, changelog и plan; template-source имеет disabled capture и не создает candidate.

## Связанные решения

- Решения:

- [`Codex-first template v2`](../docs/decisions/2026-08-20-codex-first-template-v2.md).

## Resume checkpoint

- Текущая фаза: нет - план завершен
- Уже выполнено: P1-P2 завершены: macOS link failure доказан; physical resolver/trusted executable/system temp реализованы; impacted Windows regressions green.
- Последние успешные проверки: AST; diff-check; platform; Plan; canon; Mastery; TemplateSource 117; bootstrap; distribution 14/14; consumer 117; privacy; knowledge SelfTest - PASS.
- Точные рабочие paths: .template-manifest.json; TEMPLATE-CHANGELOG.md; scripts/lib/ModelProject.Platform.psm1; 10 impacted CI/test scripts; active plan; plans/INDEX.md.
- Git checkpoint: v1:e395d758b38f1933c1ead6d6be2d4f3ee0b5c07c1e747309949f335585ff8c25
- Следующее действие: нет - plan terminal; follow-up требует новый plan_id
- Блокеры: нет
- Обновлено: 2026-08-20T18:22:29Z

## Итог

- Реализовано целиком: да - local macOS trust-path fix и release gate готовы.
- Что осталось: внутри plan ничего; после terminal transition выполнить отдельно разрешенные fix commit, `source:source` push и CI verification.
- Коммиты: baseline `d85e80082a1683753655576b8490b40984bb9c7e`; follow-up fix создается после terminal plan.

Перед `complete` закрой criteria и фазы, заполни проверки, итог, `result_refs`, closeout и финальный knowledge outcome. Не дублируй остальные machine fields в body.
