---
artifact_kind: decision
status: accepted
knowledge_outcome: none
candidate_ids: []
affected_canon:
  - .template-manifest.json
  - TEMPLATE-CHANGELOG.md
  - TEMPLATE.md
supersedes: []
blocked_reason: null
---

# Решение: privacy audit публичной истории и purge локальных pre-release refs

## Контекст и владелец

Первичная проверка через `git log --all` обнаружила персональные author, committer и tagger identities и историческую персонализированную copyright-строку. Дополнительная проверка показала, что `--all` смешал публичные refs с локальной private branch и локальными pre-release tags.

Публичная `source` имеет отдельный нейтральный root commit `v1.6.2`; публичные `main`, `source`, `v1.6.2` и `v2.0.0` не достигают прежнюю локальную историю. Владелец прямо потребовал обезличить все оставшиеся данные и допроверить результат. Работа выполняется по [tracked privacy plan](../../plans/2026-08-22-sanitize-public-history.md).

## Решение

- Не переписывать чистые публичные branches и tags: force rewrite не устраняет дополнительных данных и создает ненужный release risk.
- Удалить локальную private branch и локальные unpublished tags `v1.5.0`, `v1.6.0`, `v1.6.1`, затем истечь reflogs и выполнить local GC.
- Проверять public scope только по точным fetched remote refs и опубликованным tags, а local residue отдельно по `--all`, reflogs и known tainted object IDs.
- Опубликовать source-only audit evidence обычным fast-forward commit и дождаться Windows/macOS CI.
- Не перемещать опубликованные `v1.6.2` и `v2.0.0`; consumer `main` не пересобирать, поскольку portable payload не изменился.
- В future release gate всегда сканировать commit metadata, annotated tags, historical trees, remote refs и local-only refs раздельно.

## Рассмотренные альтернативы

- Force-rewrite `source` и published tags отклонен после точной ref-проверки: публичные objects уже нейтральны.
- Оставить local private refs отклонено: персональные данные продолжили бы храниться в локальной object database.
- Использовать mirror push отклонено: он может отправить private refs или удалить несвязанные remote refs.
- Создать новый repository отклонено: public repository не содержит найденных локальных данных.

## Последствия и риски

- Локальная pre-release история и ее tags перестают быть доступными после GC. Это намеренный privacy purge.
- GitHub caches и external clones в общем случае не контролируются локальной проверкой, но для этого repository публичные forks, pull requests и pull refs отсутствуют, а tainted commits никогда не были достижимы из опубликованных refs.
- Operational GitHub repository URL остается в distribution descriptor и документации как необходимая provenance, а не профиль владельца.

## Проверка

- Exact public ref scan подтверждает нейтральные author, committer и tagger identities.
- Historical public trees не содержат personal email, известного имени, локальных user paths или персонализированной copyright-строки.
- После local ref deletion и GC известные tainted commits недоступны через `git cat-file`.
- Source gates, Windows/macOS CI, public clone и GitHub Template contract остаются зелены.

## Откат или замена

Local purge не откатывается сохранением tainted backup. Если будущий аудит обнаружит реально публичный sensitive object, требуется отдельный incident plan и новый ADR до history rewrite.

## Связи

- План: [обезличивание и допроверка](../../plans/2026-08-22-sanitize-public-history.md).
- Release contract: [TEMPLATE.md](../../TEMPLATE.md).
- Distribution boundary: [GitHub Template ADR](2026-08-17-github-template-distribution.md).
