# Карта нового проекта

## Начало

- [`README.md`](README.md) - быстрый старт и навигация.
- [`CODEX-INSTALL-PROMPT.md`](CODEX-INSTALL-PROMPT.md) - copy-paste установка нового GitHub repository через Codex.
- [`PROJECT.md`](PROJECT.md) - паспорт, границы, статус и критерии проекта.
- [`AGENTS.md`](AGENTS.md) - локальные инструкции Codex.
- [`ai-clone/INDEX.md`](ai-clone/INDEX.md) - минимальный project-local профиль владельца и правила сотрудничества.
- [`prompts/README.md`](prompts/README.md) - короткие интервью и copy-paste промты для значимых доменов.

## Предметные зоны

- [`idea/INDEX.md`](idea/INDEX.md) - путь от сигнала проблемы к проверяемой идее и MVP.
- [`business/INDEX.md`](business/INDEX.md) - продукт, аудитория, экономика, маркетинг и живые метрики.
- [`analysis/INDEX.md`](analysis/INDEX.md) - рабочие прогоны, аналитический контракт и handoff в предметный канон.
- [`inbox/README.md`](inbox/README.md) - RAW неизвестного или смешанного домена.
- [`docs/INDEX.md`](docs/INDEX.md) - архитектурные решения и долговечная документация.
- [`plans/README.md`](plans/README.md) - планы больших функций.
- [`retrospectives/README.md`](retrospectives/README.md) - история значимых рабочих сессий.
- [`knowledge/INDEX.md`](knowledge/INDEX.md) - маршрутизация, candidates, RAW, provenance и promotion.
- [`knowledge/graph/INDEX.md`](knowledge/graph/INDEX.md) - производная карта канона, backlinks, orphans и conflicts с Wikilinks.
- [`mastery/INDEX.md`](mastery/INDEX.md) - project-local методы, переносимые вместе с проектом.
- [`research/INDEX.md`](research/INDEX.md) - рабочие доказательные запуски конкретного проекта.
- [`.agents/skills/startup-researcher/SKILL.md`](.agents/skills/startup-researcher/SKILL.md) - исполняемый процесс исследования.
- [`.agents/skills/knowledge-curator/SKILL.md`](.agents/skills/knowledge-curator/SKILL.md) - knowledge closeout и promotion.
- [`.agents/skills/it-analysis/SKILL.md`](.agents/skills/it-analysis/SKILL.md) - бизнес- и системный анализ, требования, модели, ТЗ и review.
- [`scripts/README.md`](scripts/README.md) - инициализация и проверка структуры.

## Минимальные маршруты

| Задача | Читать |
|---|---|
| Понять проект | `PROJECT.md` |
| Понять предпочтения владельца | `ai-clone/CORE.md`, только если профиль активирован |
| Заполнить значимую зону через интервью | `prompts/README.md`, затем выбранный доменный prompt |
| Прочитать текущие выводы об идее | `idea/INDEX.md` и нужный канонический файл |
| Собрать новое evidence об идее | `research/INDEX.md`, затем `$startup-researcher` |
| Понять аудиторию или предложение | `business/INDEX.md` и тематический README |
| Выполнить бизнес- или системный анализ | `analysis/INDEX.md`, `analysis/CONTRACT.md`, затем `$it-analysis` |
| Найти утвержденные требования и модели | `business/analysis/INDEX.md` или `docs/analysis/INDEX.md` |
| Сохранить разрешенный project-local RAW | `knowledge/INDEX.md`, затем `inbox/raw/` или `business/raw/` |
| Продвинуть проверенный вывод | `knowledge/INDEX.md`, затем `$knowledge-curator` |
| Найти связанные артефакты и backlinks | `knowledge/graph/INDEX.md`, затем owner artifact |
| Найти принятое решение | accepted-файл в `docs/decisions/` |
| Найти состояние большой работы | активный файл в `plans/` |
| Понять историю | `retrospectives/` |
| Исследовать нишу или идею | `mastery/researcher/INDEX.md`, затем `$startup-researcher` |
| Выбрать метод анализа | `mastery/analyst/INDEX.md`, затем `$it-analysis` |
| Найти evidence и решение запуска | `research/INDEX.md` и нужный каталог в `research/runs/` |
