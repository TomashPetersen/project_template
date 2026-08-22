---
artifact_kind: plan
plan_contract_version: 2
plan_id: PLAN-20260822-publish-v2-github-template
task_key: publish-v2-github-template
prompt_ref: prompts/plan-and-deliver.md
status: complete
current_phase: null
updated_at: 2026-08-22T09:49:46Z
completed_at: 2026-08-22T09:49:46Z
closeout_status: complete
knowledge_outcome: none
candidate_ids: []
result_refs:
  - .template-manifest.json
  - plans/2026-08-22-publish-v2-github-template.md
  - plans/INDEX.md
  - scripts/build-github-template.ps1
  - retrospectives/2026-08-20_14-01_codex-first-template-v2.md
affected_canon:
  - .template-manifest.json
blocked_reason: null
---

# План: Публикация GitHub Template v2.0.0 в main

## Цель

Опубликовать проверенный Codex-first template v2.0.0 как производный consumer в default-ветке `main`, чтобы GitHub `Use this template` создавал проект с актуальным README и `CODEX-INSTALL-PROMPT.md`.

## Границы

Входит:

- terminal source release plan и точный pre-release gate;
- отдельный annotated tag `v2.0.0` на проверенном `source` commit;
- сборка consumer только через `scripts/build-github-template.ps1`;
- отдельный consumer commit в `main` без source-only истории и файлов;
- точечные push `source`, `v2.0.0` и `main`, без `--all` и force;
- проверка remote refs, descriptor, публичного clone/main initialization и GitHub Template settings;
- нейтральное описание и релевантные GitHub topics, если live metadata требует улучшения.

Не входит:

- изменение или перенос тега `v1.6.2`;
- ручная правка consumer payload вне builder output;
- создание или удаление внешнего тестового repository;
- GitHub Release assets, deploy, MCP/plugins, credentials или migration существующих проектов;
- изменение пользовательских overlays `.agents/skills/bulletproof/**`, `.agents/skills/frontend-design/**` и `.codex/**`.

## Критерии приемки

- [x] AC-01 Live repository audit подтверждает public repository, default `main`, `is_template: true`, clean `source` и version `2.0.0`.
- [x] AC-02 Source release commit ограничен terminal plan, manifest registration и производным plan index; consumer/product contracts не меняются.
- [x] AC-03 Полный local source gate зелен; exact source push и обязательное ожидание нового Windows/macOS CI зафиксированы как pre-tag gate.
- [x] AC-04 External runbook создает annotated `v2.0.0` только на exact CI-green source commit и собирает DistributionTemplate только trusted builder.
- [x] AC-05 Main publication protocol допускает только exact consumer payload, актуальные README/install prompt и отдельный consumer commit без source-only paths/history.
- [x] AC-06 Remote verification protocol покрывает `source`, `main`, `v2.0.0`, неизменный `v1.6.2`, public main clone и GitHub-style initialization.
- [x] AC-07 GitHub metadata target, cleanup и финальная проверка clean source worktree определены до внешних изменений.

## Риски, безопасность и откат

- Immutable tag создается только после source CI. Если последующий main publish блокируется, тег не перемещается, а публикация повторяется из того же verified payload.
- `main` обновляется обычным consumer commit поверх existing main history. Откат выполняется новым проверенным consumer commit, без force push.
- Staging и publish clone создаются только в новых проверенных каталогах системного temp; cleanup не следует по symlink/reparse.
- Перед main push exact inventory и descriptor hashes сверяются с builder output; source-only файлы блокируют публикацию.
- GitHub metadata обратима и не содержит персональных данных, секретов или локальных путей.

## Фаза P1 - [x] Release contract и live audit

Цель: подтвердить точную release boundary и текущее состояние source/main/GitHub settings.

Deliverable: один tracked plan, pre-task snapshot и доказанный publication flow.

Сделано, когда: AC-01 закрыт, manifest version/tag/main gap подтверждены, realistic alternatives сравнены.

Задачи:

- [x] Прочитать source release contract, builder, ADR, retrospective и skills.
- [x] Зафиксировать clean pre-task Git snapshot на `source` HEAD `fcdc8d9c...`.
- [x] Проверить live GitHub settings и подтвердить, что актуальный prompt есть в `source`, но default `main` содержит старый payload.
- [x] Зафиксировать рекомендуемый путь и rejected alternatives.

Рекомендуемый путь: terminal source plan -> source commit/push/CI -> annotated tag -> trusted builder -> изолированный clone существующего `main` -> exact payload consumer commit -> public verification. Он сохраняет source/main boundary, rollback и builder provenance.

Отклонены:

- checkout и ручная замена `main` в source worktree - смешивает release state и повышает риск перенести source-only файлы;
- force push нового orphan `main` - без необходимости уничтожает существующую consumer history и ухудшает откат;
- загрузка файлов через GitHub UI - не дает детерминированной inventory/hash проверки;
- создание `main` напрямую из source tree - нарушает ADR и переносит maintenance history.

## Фаза P2 - [x] Source pre-release gates

Цель: сделать source release commit воспроизводимой и безопасной базой для immutable tag.

Deliverable: terminal plan, manifest registration, полный локальный gate и exact source commit/push/CI procedure.

Сделано, когда: AC-02-AC-03 закрыты локально, knowledge closeout выполнен, external gate готов.

Задачи:

- [x] Зарегистрировать source-only plan в manifest и проверить deterministic indexes.
- [x] Выполнить полный local pre-push gate, privacy и protected-overlay review.
- [x] Завершить plan с `knowledge_outcome: none` и подготовить exact source commit/refspec.

## Фаза P3 - [x] External publication gate

Цель: выполнить только после terminal source plan точные tag/build/main/GitHub действия.

Deliverable: точный и проверенный runbook для remote tag `v2.0.0`, derived `main`, public template и metadata.

Сделано, когда: AC-04-AC-07 закрыты как безопасные post-terminal gates; live evidence собирается при их выполнении до финального ответа пользователю.

Задачи:

- [x] Зафиксировать запрет tag до source commit/push и зеленого matrix CI, затем exact annotated tag.
- [x] Зафиксировать сборку и проверку consumer staging только через trusted builder.
- [x] Зафиксировать отдельный consumer commit в изолированном publish clone и точечный push `main:main`.
- [x] Зафиксировать public main clone, GitHub-style initialization, refs, template flag, описание и topics как обязательные финальные проверки.

## Проверки

- Pre-task snapshot: status/diff/cached/untracked пусты; branch `source`; HEAD `fcdc8d9c4f9b27ff03a9b3d21a71b732a24bf1cd`.
- Manifest: `template_version: 2.0.0`; remote `v2.0.0` отсутствует; `v1.6.2` не изменяется.
- GitHub API: public, default `main`, `is_template: true`, repository active.
- Existing release evidence: source workflow `32409524515` успешно прошел Windows и macOS на текущем pre-task HEAD.
- Platform gate: `scripts/test-platform.ps1` - PASS.
- Structure gate: `scripts/verify-structure.ps1 -Root . -Mode TemplateSource` - PASS, 119 canonical Markdown artifacts.
- Plan lifecycle, canon graph, consumer boundary, cross-platform bootstrap, GitHub Template distribution и Mastery v2 - PASS.
- Knowledge self-test - PASS.
- Privacy/RAW public CLI harness - PASS, 37 bounded checks.
- `git diff --check`, manifest JSON, protected overlays и plan/index/resume checks - PASS.

## Связанные решения

- Решения:

- [`GitHub Template distribution`](../docs/decisions/2026-08-17-github-template-distribution.md).
- [`Codex-first template v2`](../docs/decisions/2026-08-20-codex-first-template-v2.md).

## Resume checkpoint

- Текущая фаза: нет - план завершен
- Уже выполнено: P1-P3: release contract, local gates, terminal closeout and exact external publication runbook prepared.
- Последние успешные проверки: Platform, structure, plan lifecycle, canon graph, consumer boundary, bootstrap, GitHub distribution, Mastery, knowledge and privacy harness PASS.
- Точные рабочие paths: .template-manifest.json; plans/2026-08-22-publish-v2-github-template.md; plans/INDEX.md; scripts/build-github-template.ps1
- Git checkpoint: v1:1888445872a6d82c3d9857662d9bd67c1d56d1bed9cd74d0a9b05c05a8129bf1
- Следующее действие: нет - plan terminal; follow-up требует новый plan_id
- Блокеры: нет
- Обновлено: 2026-08-22T09:49:46Z

## Итог

- Реализовано целиком: создан terminal source release plan, он зарегистрирован как source-only; полный локальный pre-release gate зелен; точные refspec, builder boundary, main publication protocol, metadata target и финальные live checks подготовлены.
- Knowledge closeout: `none` - изменение является release control artifact в `template-source`, durable product или method delta отсутствует.
- Что осталось вне terminal plan: под текущей прямой командой пользователя выполнить exact source commit/push, дождаться нового зеленого Windows/macOS CI, затем tag/build/main/metadata и public verification без дополнительных repository writes в source.
- Коммиты: source release commit и consumer main commit создаются после terminal plan; их exact IDs сообщаются пользователю после публикации.
