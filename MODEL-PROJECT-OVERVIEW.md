# Смысл Codex-first шаблона

## Рабочий цикл

```text
Идея и evidence
      |
      v
Продукт и бизнес
      |
      v
Tracked Plan v2 -> реализация -> проверки
      |                              |
      +-------- Resume checkpoint ---+
                                     |
                                     v
                         knowledge closeout
                            |             |
                          none       ready candidate
                                            |
                                   решение владельца
                                            v
                                    канон или Mastery
```

Текущий план, канон и результаты проверок находятся в репозитории. Чат, локальная память Codex и retrospective не являются источником текущего состояния.

## Структура

```text
Модельный проект/
|-- PROJECT.md          # паспорт, границы и статус
|-- ai-clone/           # обезличиваемый профиль сотрудничества
|-- idea/               # гипотезы, evidence, PoV, MVP и риски
|-- product/            # пользователи, опыт и capabilities
|-- business/           # бизнес-архитектура, экономика и метрики
|-- docs/architecture/  # технический контекст и границы
|-- docs/codebase/      # фактическая карта реализации
|-- docs/decisions/     # устойчивые архитектурные решения
|-- plans/              # возобновляемые планы реализации
|-- research/           # evidence runs
|-- knowledge/          # candidates, graph и promotion
|-- mastery/            # Researcher и Local Mastery
|-- inbox/raw/          # единственная RAW-зона
|-- prompts/            # компактные entrypoints Codex
`-- scripts/            # bootstrap, generators и gates
```

`src/`, `app/`, `tests/`, `infra/` и конфиги стека появляются только после технического выбора. Код и тесты являются источником истины о поведении, а `docs/codebase/` описывает фактическую структуру.

## Границы знания

1. `PROJECT.md` задает паспорт, `idea/` хранит проверяемые гипотезы, `product/` и `business/` отвечают за предметный канон.
2. `plans/` хранит состояние значимой работы. `plans/INDEX.md` позволяет найти один active plan, а checkpoint задает точный следующий шаг.
3. `docs/architecture/`, `docs/codebase/` и accepted ADR объясняют систему без дублирования кода.
4. `knowledge-curator` сравнивает фактический diff с владельцами канона и создает только разрешенный durable candidate. Promotion всегда подтверждает человек.
5. `mastery/local/` хранит повторяемые методы проекта. Новые intent-категории добавляются данными в `mastery/INTENTS.json`, без изменения PowerShell-кода.

Wikilinks можно использовать дополнительно, но переносимые Markdown-ссылки остаются обязательным маршрутом. MCP, plugins и credentials не встроены.
