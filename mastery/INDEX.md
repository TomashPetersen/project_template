# Project Mastery

Project-local mastery хранит только проверенные, переносимые методы, необходимые самому проекту. Это не копия внешней общей mastery-библиотеки и не место для данных конкретного исследования.

## Области

- [Researcher Mastery](researcher/INDEX.md) - методы исследования перспективности новых IT/web-возможностей до разработки и на ранней стадии проверки.
- [Analyst Mastery](analyst/INDEX.md) - методы бизнес- и системного анализа, requirements engineering, моделей, traceability и спецификаций.
- [Local Mastery](local/INDEX.md) - зарегистрированные project-local расширения, созданные только в generated project.

## Retrieval route

Для research выбери baseline только из [`researcher/INDEX.md`](researcher/INDEX.md), для analysis - только из [`analyst/INDEX.md`](analyst/INDEX.md). В каждом workflow выбери один основной и не более одного дополняющего profile. Затем прочитай реестр [`local/INDEX.md`](local/INDEX.md) и при необходимости открой максимум одно зарегистрированное active, непросроченное и релевантное local extension. Точные baseline refs, local `method_id` и local refs запиши в brief и decision запуска.

Пустой `mastery/local/` в template source и fresh generated copy является правильным состоянием.

## Границы

- Процедура запуска, схема evidence и актуальные правила доступа находятся в [startup-researcher](../.agents/skills/startup-researcher/SKILL.md).
- Процедура business/system analysis находится в [it-analysis](../.agents/skills/it-analysis/SKILL.md).
- Данные конкретных запусков находятся в [research](../research/INDEX.md).
- Подтвержденные знания об идее находятся в [idea](../idea/INDEX.md).
- Общая внешняя mastery-библиотека остается read-only и в проект не копируется.

## Shared mastery identifiers

Этот раздел регистрирует переносимые logical identifiers, но не задает полномочия. Правила owner и записи остаются в [`knowledge/INDEX.md`](../knowledge/INDEX.md).

| Logical identifier | Shared owner и внешний target | Доступ из проекта |
|---|---|---|
| `logical:shared-mastery/copywriting` | Глобальный `AGENTS.md` -> внешний `Модельный портфель` -> `mastery/INDEX.md` -> `mastery/copywriting/INDEX.md` | Только read-only source ref |

Для copywriting-задачи разрешай `logical:shared-mastery/copywriting` только через глобальный `AGENTS.md`. Identifier запрещен как project-local target, не разрешает local или external write и не создает локальный fallback. Попытка изменить shared mastery возвращает `blocked: shared-owner`. Произвольный неизвестный `logical:shared-mastery/*` блокируется.
