---
artifact_kind: decision
status: accepted
knowledge_outcome: existing
candidate_ids: []
affected_canon: []
supersedes: []
blocked_reason: null
---

# Решение: минимальный knowledge control plane

- Дата: 2026-07-29
- Статус: accepted
- Владелец решения: шаблон проекта

## Контекст

Markdown-структура уже разделяет канон, RAW, research, mastery и историю, но promotion использует разные правила. Дополнительная база данных создала бы второй источник истины, а один набор инструкций не дал бы машинных гарантий.

## Решение

Сохранить распределенный Markdown-канон и добавить:

- единый маршрут и lifecycle в `knowledge/INDEX.md`;
- один Markdown-файл на candidate;
- project-local `$knowledge-curator`;
- generator с атомарной записью;
- semantic verifier, вызываемый structural gate;
- единый portable manifest с Researcher Mastery baseline.

Автоматически создается только безопасный project-local candidate в режиме `safe-local`. RAW, promotion, shared write и delete требуют прямого разрешения.

## Уточнение hardening 1.2.1

Версия 1.2.1 усиливает проверку связности, конкурентную запись и защиту приватности, не меняя принятое решение о распределенном Markdown-каноне и едином candidate gate.

Promotion выполняется как проверяемый и восстанавливаемый change set с явной проверкой и способом отката. Это не обещание межфайловой транзакции: частичный сбой должен обнаруживаться и восстанавливаться по зафиксированному набору изменений.

## Trust boundary

- Проверяемый `-Root` всегда считается данными. Structural gate исполняет semantic verifier только рядом с собственным доверенным `$PSScriptRoot`.
- Git-команды для tracked overlay допустимы только когда проверяемый root совпадает с root доверенного verifier-а. Git executable и PowerShell subprocess host разрешаются по точному внешнему application path без reparse chain.
- Git subprocess очищает управляющие `GIT_*`, отключает system/global config, ограничивает читаемый вывод и привязывается к проверенному `.git`. Linked worktree marker требует безопасный административный каталог и точный backlink на текущий marker.
- Candidate публикуется только после полной проверки отрендеренного документа; invalid input не оставляет final или draft.
- JSONL, frontmatter и Markdown читаются с лимитами размера и количества, а evidence использует закрытую scalar-схему.
- Относительные пути не выходят за root и не проходят через reparse point.
- Новый проект полностью собирается и проверяется в случайном sibling staging, затем появляется в final destination одним rename.

## Рассмотренные альтернативы

1. Только расширить `AGENTS.md` - отклонено из-за отсутствия semantic gate.
2. Добавить database или vector store - отклонено как второй канон и инфраструктурная зависимость.
3. Хранить candidate как `record.json + proposal.md + events.jsonl` - отклонено, потому что Git уже хранит историю.
4. Создать отдельные policy, routes и queue - отклонено из-за риска дрейфа нескольких карт.

## Последствия и риски

- Система является agent-driven, а не фоновой.
- Verifier доказывает корректность существующих записей, но не полноту семантического closeout.
- Strict frontmatter ограничивает свободу формата candidate.
- Secret и PII scanner является эвристическим denylist, а не доказательством отсутствия любой утечки.
- `authority_ref` и snapshot текущего capture mode не доказывают исторический режим создания artifact; write-time режим проверяет generator.
- В owner-only каталоге остается узкое локальное TOCTOU-окно между path check и filesystem operation; shared writable parent не поддерживается.
- Existing archive-каталоги остаются совместимостью, но новые RAW не перемещаются.
- Внешняя общая база остается read-only.

## Проверка

- Candidate generator не создает неполные файлы.
- Applied candidate требует target и backlink.
- TemplateSource, GeneratedProject и fresh copy проходят оба verifier-а.
- Оба project-local skills проходят официальный validator и forward-тесты.

## Откат или замена

Откат выполняется поименно: удалить новые knowledge и skill paths, вернуть PROJECT, routing и script contracts. Database migration и автоматический перенос данных отсутствуют.

## Связи

- Политика: [`knowledge/INDEX.md`](../../knowledge/INDEX.md)
- Заменяет решение: нет
