# Project Mastery

Project-local mastery хранит только проверенные, переносимые методы, необходимые самому проекту. Это не копия внешней общей mastery-библиотеки и не место для данных конкретного исследования.

## Области

- [Researcher Mastery](researcher/INDEX.md) - методы исследования перспективности новых IT/web-возможностей до разработки и на ранней стадии проверки.
- [`INTENTS.json`](INTENTS.json) - расширяемый каталог категорий методов; новые intent IDs добавляются без изменения PowerShell-кода.
- [Local Mastery](local/INDEX.md) - производный реестр примененных project-local методов, созданных только в generated project.

## Retrieval route

Для research выбери baseline только из [`researcher/INDEX.md`](researcher/INDEX.md). Для остальных типов работы используй зарегистрированный intent и при необходимости открой максимум одно active, непросроченное и релевантное расширение из [`local/INDEX.md`](local/INDEX.md). Точные baseline refs, local `method_id` и local refs запиши в рабочий plan или run.

Пустой `mastery/local/`, кроме `INDEX.md` и `TEMPLATE.md`, в template source и fresh generated copy является правильным состоянием. Реестр пересобирается `scripts/update-mastery-index.ps1`.

## Границы

- Процедура запуска, схема evidence и актуальные правила доступа находятся в [startup-researcher](../.agents/skills/startup-researcher/SKILL.md).
- Delivery workflow находится в [project-delivery](../.agents/skills/project-delivery/SKILL.md).
- Быстрое создание метода начинается с [`prompts/create-mastery.md`](../prompts/create-mastery.md), затем проходит method candidate, `new-mastery.ps1 -WhatIf` и отдельное approval.
- Данные конкретных запусков находятся в [research](../research/INDEX.md).
- Подтвержденные знания об идее находятся в [idea](../idea/INDEX.md).
- Общая внешняя mastery-библиотека остается read-only и в проект не копируется.

## Shared mastery identifiers

Этот раздел регистрирует переносимые logical identifiers, но не задает полномочия. Правила owner и записи остаются в [`knowledge/INDEX.md`](../knowledge/INDEX.md).

| Logical identifier | Shared owner и внешний target | Доступ из проекта |
|---|---|---|
| `logical:shared-mastery/copywriting` | Глобальный `AGENTS.md` -> внешний `Модельный портфель` -> `mastery/INDEX.md` -> `mastery/copywriting/INDEX.md` | Только read-only source ref |

Для copywriting-задачи разрешай `logical:shared-mastery/copywriting` только через глобальный `AGENTS.md`. Identifier запрещен как project-local target, не разрешает local или external write и не создает локальный fallback. Попытка изменить shared mastery возвращает `blocked: shared-owner`. Произвольный неизвестный `logical:shared-mastery/*` блокируется.
