---
artifact_kind: plan
plan_contract_version: 2
plan_id: PLAN-20260820-release-v2-source-push
task_key: release-v2-source-push
prompt_ref: prompts/plan-and-deliver.md
status: complete
current_phase: null
updated_at: 2026-08-20T17:21:07Z
completed_at: 2026-08-20T17:21:07Z
closeout_status: complete
knowledge_outcome: none
candidate_ids: []
result_refs:
  - README.md
  - .template-manifest.json
  - .github/workflows/template-integrity.yml
  - docs/decisions/2026-08-20-codex-first-template-v2.md
  - scripts/lib/ModelProject.Plan.psm1
  - plans/2026-08-20-release-v2-source-push.md
affected_canon:
  - .template-manifest.json
  - TEMPLATE.md
  - TEMPLATE-CHANGELOG.md
blocked_reason: null
---

# План: Проверочный commit и push ветки source для v2.0.0

## Цель

Повторно доказать live-состояние Codex-first шаблона v2.0.0, сформировать точный release commit в ветке `source` и, после terminal plan closeout, отправить только эту ветку в `origin` по прямой команде пользователя.

## Границы

Входит:

- повторный полный local pre-push gate на фактическом worktree;
- проверка privacy, secrets, абсолютных путей, protected overlays и immutable `v1.6.2`;
- поименный staging только проверенных путей;
- один source release commit и push только `source`;
- проверка совпадения локального и удаленного `source`, затем ожидание source CI.

Не входит:

- tag `v2.0.0`;
- сборка или публикация производной ветки `main`;
- deploy, GitHub Release и изменение настроек repository;
- `git push --all`, force push и изменение пользовательских overlays.

## Критерии приемки

- [x] AC-01 Полный набор local pre-push gates проходит на текущем worktree, а все неисполненные проверки явно названы.
- [x] AC-02 Privacy и secret scan не находят реальных персональных данных, секретов и абсолютных локальных путей; synthetic negative fixtures остаются ограниченными тестами.
- [x] AC-03 Exact staged inventory соответствует v2.0.0 и source-only release artifacts, не содержит protected overlays и посторонних файлов.
- [x] AC-04 `v1.6.2` разрешается в прежний commit, branch `source` и `origin` подтверждены, tag и `main` не изменяются.
- [x] AC-05 Plan closeout завершен до release commit; exact commit message и push refspec зафиксированы, tag и `main` исключены.
- [x] AC-06 Внешний release gate разрешает после terminal `complete` создать один commit и отправить только `source`; фактический remote ref и CI проверяются до финального ответа вне terminal plan.

## Риски, безопасность и откат

- Главный риск - случайно включить чужие или чувствительные изменения. Снижение риска: baseline snapshot, exact inventory, поименный staging и staged diff review.
- Сетевой push является внешней записью, но прямо разрешен текущей командой. Force push, tag и `main` запрещены.
- Если любой gate падает, staging очищается только поименно для путей текущей задачи или plan переводится в `blocked`; чужие изменения не откатываются.
- Если push отклонен, локальный commit сохраняется, причина фиксируется без force push.

## Фаза P1 - [x] Live pre-push verification

Цель: заменить прежнее checkpoint-evidence актуальным доказательством на текущем worktree.

Deliverable: полный журнал зеленых gates, privacy review и проверенные branch, remote и immutable tag.

Сделано, когда: AC-01, AC-02 и AC-04 подтверждены фактическими командами.

Задачи:

- [x] Запустить минимальный release-набор из `TEMPLATE.md` и дополнительные AST, plan, canon, regression и privacy gates.
- [x] Проверить exact worktree inventory, overlay invariants, remote identity и `v1.6.2`.
- [x] Провести correctness, security и release impact review фактического diff.

## Фаза P2 - [x] Exact staging и closeout

Цель: подготовить один воспроизводимый source release commit без расширения scope.

Deliverable: exact staged inventory, staged diff review и terminal Plan v2.

Сделано, когда: AC-03 и AC-05 подтверждены, plan closeout имеет `knowledge_outcome: none`.

Задачи:

- [x] Добавить новый source-only plan в manifest и пересобрать производные индексы.
- [x] Выполнить поименный staging всех и только проверенных v2 paths.
- [x] Проверить staged inventory, staged diff, overlays и отсутствие незапланированного unstaged delta.
- [x] Исправить выявленные EOF issues, повторить impacted gates и restage только исправленные paths.

## Фаза P3 - [x] Release gate handoff

Цель: подготовить точный и безопасный handoff для отдельно разрешенных commit и push после terminal plan closeout.

Deliverable: exact commit message, explicit `source:source` refspec, rollback и remote-verification команды.

Сделано, когда: AC-05 и AC-06 подтверждают готовность внешнего release gate; сам push выполняется только после terminal plan.

Задачи:

- [x] Зафиксировать commit message и команды commit, explicit push refspec, remote verification и CI wait.
- [x] Подтвердить отсутствие tag, `main`, force push, `--all` и deploy в разрешенном scope.
- [x] Выполнить knowledge closeout и подготовить terminal transition; только затем исполнить внешний release gate.

## Проверки

- Pre-task HEAD: `96f6c11d0b3b2e00147889619ba689c10042e287`.
- Pre-task branch: `source`; index пуст; implementation v2 находится в ожидаемом tracked, deleted и untracked worktree state.
- Pre-task snapshot: `git status --porcelain=v1 -z`, `git diff HEAD`, `git diff --cached`, `git ls-files --others --exclude-standard` выполнены до первой записи.
- Static: PowerShell AST PASS; `git diff --check` PASS; Plan v2 PASS; canon 12/12; knowledge report 0 candidates/conflicts/drift; TemplateSource PASS, 116 canonical Markdown files.
- Focused: platform, plan lifecycle, canon graph, Mastery v2 и consumer boundary PASS; portable=117; formal-analysis absent.
- Integration: cross-platform bootstrap PASS; GitHub Template distribution 14/14; privacy 37/37; knowledge SelfTest PASS.
- Extended regression: artifacts 15/15; Mastery 24/24; control-plane A01-A23 PASS; research A43-A54 PASS.
- Live privacy search: known identifiers, Windows/macOS absolute user paths и secret assignments вне bounded test fixtures - совпадений нет.
- Protected overlays: `git diff -- .agents/skills/bulletproof .agents/skills/frontend-design .codex` пуст.
- Remote preflight: `origin/source` = `96f6c11d0b3b2e00147889619ba689c10042e287`; `v1.6.2` tag object = `9d3b31830eccc9942f00738246252a07c63748ab`, commit = `c8639f22f0517ca7b6dbba5d96b1ff3ef5c8e326`.
- Review: удаление formal-analysis, добавление v2 control planes и 117-file payload согласованы с ADR и manifest; незапланированных file modes, overlay delta и temp artifacts нет; actionable correctness/security findings отсутствуют.
- Exact staging: 167 named paths; cached protected-overlay diff пуст; unstaged=0; untracked=0.
- Staged quality: первый cached check выявил 25 лишних EOF blank lines; 24 explicit files нормализованы, `plans/INDEX.md` исправлен через generator; повторные Plan lifecycle, AST, TemplateSource, consumer 117 и distribution 14/14 PASS.
- Final cached check P2: `git diff --cached --check` PASS; `git diff --check` PASS.
- Commit: `git commit -m "feat!: release Codex-first project template v2.0.0"` с neutral repository-local metadata `Model Project Release <release@example.invalid>`.
- Push: только `git push origin source:source`; `--all`, force, tag, `main`, deploy и GitHub Release не выполняются.
- Remote verification: сравнить `git rev-parse HEAD` с `git ls-remote origin refs/heads/source`; CI найти по exact `head_sha` через public GitHub Actions API и дождаться terminal conclusion.
- Failure path: при rejected push сохранить локальный commit без force; при CI failure не переписывать опубликованную историю, создать отдельный follow-up plan и fix commit.
- Knowledge closeout: `none` - template-source имеет `knowledge_capture_mode: disabled`, release delta уже выражена в ADR, manifest, plan, scripts и tests; candidate и promotion не создаются.

## Связанные решения

- Решения:

- [`Codex-first template v2`](../docs/decisions/2026-08-20-codex-first-template-v2.md).
- [`GitHub Template distribution`](../docs/decisions/2026-08-17-github-template-distribution.md).

## Resume checkpoint

- Текущая фаза: нет - план завершен
- Уже выполнено: P1-P2 завершены: full gates green; 167 exact paths staged; EOF findings fixed; impacted gates and cached checks green.
- Последние успешные проверки: STAGED=167; UNSTAGED=0 до plan update; UNTRACKED=0; cached and worktree diff-check PASS; Plan lifecycle, AST, structure, consumer 117, distribution 14/14 PASS after fix.
- Точные рабочие paths: plans/2026-08-20-release-v2-source-push.md; plans/INDEX.md; exact staged v2 release tree.
- Git checkpoint: v1:72d95d0d3706749be571f70f7f67a4e36fdd8f89fd7eb7c660d3a9b610365a05
- Следующее действие: нет - plan terminal; follow-up требует новый plan_id
- Блокеры: нет
- Обновлено: 2026-08-20T17:21:07Z

## Итог

- Реализовано целиком: да - local release gate и exact staged state готовы.
- Что осталось: внутри plan ничего; после terminal transition выполнить отдельно разрешенные commit, `source:source` push, remote и CI verification.
- Коммиты: exact release commit создается после terminal plan; message `feat!: release Codex-first project template v2.0.0`.

Перед `complete` закрой criteria и фазы, заполни проверки, итог, `result_refs`, closeout и финальный knowledge outcome. Не дублируй остальные machine fields в body.
