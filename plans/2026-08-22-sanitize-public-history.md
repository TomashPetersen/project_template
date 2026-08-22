---
artifact_kind: plan
plan_contract_version: 2
plan_id: PLAN-20260822-sanitize-public-history
task_key: sanitize-public-history
prompt_ref: prompts/plan-and-deliver.md
status: in-progress
current_phase: P4
updated_at: 2026-08-22T17:42:36Z
completed_at: null
closeout_status: pending
knowledge_outcome: null
candidate_ids: []
result_refs: []
affected_canon: []
blocked_reason: null
---

# План: Privacy audit публичной Git-истории и local purge

## Цель

Доказать обезличенность всех публично достижимых Git objects, удалить персональные данные из локальных private refs и object database, сохранить работоспособность Codex-first template v2.0.0.

## Границы

Входит:

- раздельная проверка публичных и локальных refs, metadata и historical trees;
- удаление локальной private branch, unpublished pre-release tags, reflogs и unreachable objects с персональными данными;
- обычная fast-forward публикация source-only audit evidence;
- проверка публичных refs, forks, pull requests, CI, clone и GitHub Template initialization;
- удаление локальных refs и unreachable objects, сохраняющих старые персональные данные;
- фиксация точной public reachability и общего ограничения GitHub caches и внешних clones.

Не входит:

- переименование GitHub account или repository URL, используемого как operational provenance;
- отправка данных в GitHub Support без отдельной прямой команды;
- изменение функционального consumer contract v2.0.0;
- публикация локальной private branch;
- изменение пользовательских overlays `.agents/skills/bulletproof/**`, `.agents/skills/frontend-design/**` и `.codex/**`.

## Критерии приемки

- [x] AC-01 Все reachable commits и annotated tags в публичных refs имеют нейтральные author, committer и tagger identity.
- [x] AC-02 Исторические деревья не содержат персонализированных copyright-строк, личных email, известных персональных имен или абсолютных локальных user paths.
- [x] AC-03 Чистые public refs не переписаны; локальная private branch и unpublished tags не отправлены и удалены.
- [ ] AC-04 Финальный `source` проходит локальные gates и GitHub Actions на Windows и macOS.
- [x] AC-05 Существующие published `v1.6.2` и `v2.0.0` подтверждены нейтральными и не перемещены.
- [ ] AC-06 Производный `main` не содержит source-only audit files, а public clone/init smoke tests проходят.
- [ ] AC-07 Public forks, pull requests, refs и repository settings повторно проверены; cache/support limitation явно зафиксировано.
- [x] AC-08 Старые известные tainted objects недоступны через локальные refs и удалены локальным reflog expiry/GC.
- [ ] AC-09 Protected overlays не изменены, source worktree чист, plan и retrospective содержат финальные evidence.

## Риски, безопасность и откат

- Local purge необратимо удаляет private pre-release objects после GC; постоянный backup с персональными данными не создается.
- Public refs не переписываются без доказанного public taint. Разрешен только обычный fast-forward push нового source audit commit.
- Старые GitHub cached views и внешние clones в общем случае находятся вне локального контроля, но tainted commits не достигаются из exact опубликованных refs, forks и pull requests отсутствуют.
- `git push --all`, `git push --mirror`, force push и tag replacement запрещены для этого исправленного scope.

Отклонены: force-rewrite уже чистых public refs, использовать `git push --mirror`, создавать постоянный backup локальной tainted history или менять repository URL.

## Фаза P1 - [x] Контракт, drift repair и полный privacy inventory

Цель: подтвердить authority, исправить ранее возникший незавершенный marker terminal plan и получить точный список публичных и локальных refs.

Deliverable: зеленый Plan v2 contract, source-only регистрация текущего плана и исчерпывающий baseline.

Сделано, когда: old plan снова валиден, новый plan active, public refs/forks/PR и tainted-object inventory зафиксированы.

Задачи:

- [x] Исправить pre-existing `[WIP]` в terminal publish plan без изменения его смысла.
- [x] Зарегистрировать этот plan в source-only manifest и пересобрать index.
- [x] Проверить remote refs, forks, pull requests, tags, identities, copyright, email и local paths.
- [x] Зафиксировать exact old ref IDs и официальное GitHub cache limitation.

## Фаза P2 - [x] Source policy и release artifacts

Цель: зафиксировать исправленный privacy scope и запрет ненужной public rewrite.

Deliverable: privacy audit ADR, changelog note, обновленный source release contract и retrospective scaffold.

Сделано, когда: source-only artifacts зарегистрированы, published tag immutability сохранена и consumer behavior не меняется.

Задачи:

- [x] Добавить ADR о раздельном public/local audit и правилах future incident response.
- [x] Обновить `TEMPLATE.md` и `TEMPLATE-CHANGELOG.md`.
- [x] Создать release/privacy retrospective и зарегистрировать source-only paths.
- [x] Проверить manifest, plans и source structure.

## Фаза P3 - [x] Exact public proof и local object purge

Цель: доказать чистоту exact public refs и удалить только локальные refs/objects, где реально остались данные.

Deliverable: neutral public reachability report, удаленные local private refs и полный локальный gate.

Сделано, когда: public scan neutral, known tainted local objects недоступны после GC, все source gates зелены.

Задачи:

- [x] Подтвердить exact remote reachability, published taggers и historical content.
- [x] Удалить local private branch и unpublished pre-release tags без remote mutation.
- [x] Истечь reflogs, выполнить GC и проверить known tainted object IDs.
- [x] Запустить полный локальный source gate.

## Фаза P4 - [WIP] Финализация source audit и CI

Цель: закрыть tracked evidence, отправить обычный source fast-forward и дождаться CI.

Deliverable: финальный source audit commit и зеленый Windows/macOS CI.

Сделано, когда: plan/retrospective закрыты, source fast-forward опубликован, CI green.

Задачи:

- [ ] Завершить plan closeout и retrospective по фактическому audit/purge.
- [ ] Создать финальный neutral source commit без portable payload delta.
- [ ] Отправить финальный source commit и дождаться Windows/macOS CI.
- [ ] Доказать отсутствие force/tag/main mutations.

## Фаза P5 - [ ] Финальная public verification

Цель: подтвердить неизменность опубликованного release state и работоспособность GitHub Template.

Deliverable: exact refs/settings, public clone/init evidence и clean source worktree.

Сделано, когда: published tags/main не перемещены, clone/init green, remote audit neutral, forks/PR повторно проверены.

Задачи:

- [ ] Подтвердить неизменные neutral `v1.6.2`, `v2.0.0` и consumer `main`.
- [ ] Выполнить public clone и GitHub Template initialization smoke.
- [ ] Проверить refs, forks, PR, settings и остаточное GitHub cache limitation.
- [ ] Подтвердить clean source worktree и protected overlays.

## Проверки

- Pre-task snapshot: branch `source`; HEAD `7a16ede05d3f461c557bc13396a569f8bdffb4bb`; pre-existing drift только в terminal publish plan; новый plan и производный index еще untracked/modified.
- Public baseline: `source=7a16ede05d3f461c557bc13396a569f8bdffb4bb`; `main=7a3e424cd1d4feac02635e5886b29747aadd2fdb`; remote annotated tags `v1.6.2=9d3b31830eccc9942f00738246252a07c63748ab` и `v2.0.0=b88038e5b3f61ebb7febe502e8cb5dadd5e97bc3`.
- Local `--all` baseline: 14 commits; 5 commit identity records с personal Gmail; 3 local unpublished taggers с personal Gmail; 3 local commit trees с personal copyright; absolute local path matches отсутствуют.
- Exact public baseline after fetch: 8 unique commits; 0 bad commit identities; 0 bad published taggers; 0 personal copyright, Gmail content, known-name content или absolute local-path matches.
- GitHub baseline: public default `main`, Template Repository включен, forks 0, pull requests 0, releases 0, remote pull refs 0.
- Diagnostic correction: `git log --all` смешал public refs с local private refs; isolated rehearsal остановлен до remote mutation, когда local-only tag targets доказали ошибку scope.
- GitHub limitation: cached views и external clones в общем случае не контролируются локальной операцией; в этом repository tainted objects не public-reachable, forks/PR/pull refs отсутствуют.
- Full local regression: platform PASS; Plan v2 PASS; canon/graph PASS; consumer boundary PASS (`portable=117`, formal analysis absent); cross-platform bootstrap PASS; GitHub Template distribution 14/14; Mastery v2 PASS; knowledge self-test PASS; privacy/RAW 37/37; Mastery harness 24/24; artifacts 15/15; control-plane P0 PASS; research 12/12; TemplateSource PASS with 122 canonical Markdown files.
- Protected overlays: 0 diff lines. `git diff --check` PASS.
- Local purge attempt was rejected by the execution safety reviewer because branch/tag deletion plus reflog expiry/GC irreversibly destroys unpublished history. No partial ref deletion or GC occurred.
- После явного повторного подтверждения local purge выполнен: private branch и unpublished tags удалены; 7 private commit objects и 3 tag objects имели 0 пересечений с public reachability и недоступны после reflog expiry/GC.
- Post-purge local scan: 9 reachable commits; bad commit identities 0; bad taggers 0; personal copyright/Gmail/known-name/local-path matches 0; `git fsck --full --no-reflogs --unreachable` выдал 0 строк.
- Обязательные финальные проверки: plan/index/resume, structure, privacy, consumer boundary, GitHub distribution, platform, knowledge, mastery, `git diff --check`, reachable-object scan, Windows/macOS CI, public clone/init.

## Связанные решения

- Решения:

- [`Privacy audit публичной истории`](../docs/decisions/2026-08-22-public-history-privacy-audit.md).

## Resume checkpoint

- Текущая фаза: P4
- Уже выполнено: P1-P3 complete. With explicit confirmation, local private branch and unpublished tags were deleted; reflogs expired; GC pruned 10 known private commit/tag objects. Public refs were not mutated.
- Последние успешные проверки: Post-purge: 9 reachable commits, bad identities/taggers/copyright/Gmail/known-name/local-path matches all 0; fsck unreachable lines 0; v1.6.2 and v2.0.0 refs unchanged.
- Точные рабочие paths: plans/2026-08-22-sanitize-public-history.md; plans/INDEX.md; retrospectives/2026-08-22_public-history-privacy-audit.md; docs/decisions/2026-08-22-public-history-privacy-audit.md; .template-manifest.json; TEMPLATE.md; TEMPLATE-CHANGELOG.md
- Git checkpoint: v1:12de377718b72d32dcdd6d63cc996b00c961b4b33b6653a954a5f110281dd4ac
- Следующее действие: Run focused post-purge gates and public clone/init audit, complete plan closeout with outcome none, commit neutral source audit, push source once, await Windows/macOS CI, and perform final remote verification.
- Блокеры: none
- Обновлено: 2026-08-22T17:42:36Z

## Итог

- Реализовано целиком:
- Что осталось:
- Коммиты:

Перед `complete` закрой criteria и фазы, заполни проверки, итог, `result_refs`, closeout и финальный knowledge outcome. Не дублируй остальные machine fields в body.
