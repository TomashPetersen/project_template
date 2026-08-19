# Планы реализации

Один plan описывает одну большую функцию или изменение архитектуры. Микроизменение без значимого риска может выполняться без plan. Имя файла: `YYYY-MM-DD-<slug>.md`.

## Контракт

Каноническая схема frontmatter и body находится в [`TEMPLATE.md`](TEMPLATE.md). Общие правила `knowledge_outcome`, candidate IDs, lifecycle и безопасных paths находятся в разделе [ADR, plans и retrospectives](../knowledge/INDEX.md#adr-plans-и-retrospectives) и проверяются semantic gate.

Для `planned` и `in-progress` допустим незавершенный knowledge outcome. `complete` и `blocked` требуют финальный outcome. Source-only history шаблона не переосмысливается задним числом.

## Обязательная структура body

- цель и границы;
- критерии приемки;
- риски, безопасность и откат;
- фазы со статусами `[ ]`, `[WIP]` или `[x]`;
- для каждой фазы: цель, deliverable, критерий готовности и задачи;
- итог: реализовано ли целиком, что осталось, какие проверки и commits относятся к работе.

Если plan уже существует, продолжай его и не создавай параллельный формат. Plan отражает ход реализации, но не заменяет `PROJECT.md`, предметный канон или accepted decisions.
