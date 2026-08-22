---
artifact_kind: retrospective
knowledge_outcome: none
candidate_ids: []
affected_canon:
  - .template-manifest.json
  - TEMPLATE-CHANGELOG.md
  - TEMPLATE.md
blocked_reason: null
---

# Ретроспектива: privacy audit Git-истории

## Задача и связи

Проверить все public и local Git refs, удалить реально оставшиеся локальные персональные данные и не менять уже чистую публичную историю без доказанной необходимости.

- [План](../plans/2026-08-22-sanitize-public-history.md)
- [ADR](../docs/decisions/2026-08-22-public-history-privacy-audit.md)
- [Release contract](../TEMPLATE.md)

## Что сделано

- Исправлен ложный вывод первичного `git log --all` audit: local-only history отделена от exact remote reachability.
- Подтверждено, что public `main`, `source`, `v1.6.2` и `v2.0.0` уже обезличены и не требуют force rewrite.
- Подготовлены source-only ADR, changelog и release-contract correction без consumer payload delta.
- Изолированный rewrite rehearsal остановлен до любых remote mutations после обнаружения ошибочного scope; точный temp clone удален.
- Выполнен полный локальный regression. После отдельного явного подтверждения удалены local private branch, три unpublished tags, reflogs и unreachable objects.

## Что проверено и какими командами

- Exact public scan: 8 unique commits, 0 bad commit identities, 0 bad published taggers, 0 personal copyright, Gmail, known-name и absolute local-path matches.
- `test-platform.ps1`, `test-plan-lifecycle.ps1`, `test-canon-graph.ps1`, `test-v2-consumer-boundary.ps1` и `test-cross-platform-bootstrap.ps1` - PASS.
- `test-github-template-distribution.ps1` - 14/14 PASS; exact tagged build, real clone/init и trust failures проверены.
- `test-mastery-v2.ps1`, `verify-knowledge.ps1 -SelfTest`, `test-knowledge-privacy.ps1`, `test-knowledge-mastery.ps1` и `test-knowledge-artifacts.ps1` - PASS; privacy 37/37, Mastery 24/24, artifacts 15/15.
- `test-knowledge-control-plane.ps1` - P0 PASS; `test-knowledge-research.ps1` - 12/12 PASS.
- `verify-structure.ps1 -Mode TemplateSource` - PASS, 122 canonical Markdown files; protected overlays 0 diff lines; `git diff --check` PASS.

## Что не получилось или осталось

- Source push, Windows/macOS CI и финальная public clone/init verification выполняются после terminal source closeout.

## Как было и как стало

Первичный `--all` отчет ошибочно назвал локальные pre-release refs публичной историей. Exact remote ref audit отделил чистые public objects от локальной private истории, которая подлежит удалению.

## Что выучено

Privacy-аудит обязан разделять remote reachability, local branches, local-only tags и reflogs. `git log --all` достаточен для поиска локального residue, но не доказывает публикацию объекта.

## Security review

- Персональные данные: public refs чисты; local-only private refs удалены; 10 известных private commit/tag objects недоступны после reflog expiry и GC; post-purge scan не находит personal identity/content matches.
- Контент третьих лиц: новый сторонний контент не добавлялся.
- Внешние отправки: выполнены только read-only fetch/API audit; push, force push, tag replacement и main mutation отсутствуют.
- Секреты: реальные credentials не читались и не сохранялись.
