# Модельный проект

Проверяемый шаблон для создания проектов вместе с Codex. В нем уже связаны паспорт проекта, AI Clone, идея, продукт, бизнес, архитектура, карта кодовой базы, сохраняемые планы, исследования, Mastery и управляемая база знаний.

## Установка через Codex

1. На странице этого template repository нажми `Use this template` -> `Create a new repository`.
2. Не включай `Include all branches`: новый проект должен получить только default consumer branch.
3. Открой [готовый prompt установки через Codex](CODEX-INSTALL-PROMPT.md), замени значения `<...>` и целиком передай его Codex.

Prompt поручает Codex клонировать именно новый repository, проверить trust gates, выполнить однократную инициализацию и вернуть результат без `commit` и `push`. Канонический template repository нельзя клонировать как продукт.

Поддерживаемая среда: Windows 10/11 или актуальная macOS, PowerShell 7 (`pwsh`), Git 2.28+ и обычная локальная файловая система.

## Ручная установка

Сначала создай новый repository через `Use this template` без `Include all branches`, затем выполни одинаковые команды в PowerShell 7 на Windows или macOS:

```powershell
git clone <URL_НОВОГО_REPOSITORY> <ПАПКА_ПРОЕКТА>
Set-Location <ПАПКА_ПРОЕКТА>
pwsh -NoProfile -File ./scripts/initialize-project.ps1 -FromGitHubTemplate -ProjectName "Название продукта" -ProjectSlug "product-slug" -Description "Одно предложение о продукте" -Owner "project-owner"
pwsh -NoProfile -File ./scripts/verify-structure.ps1 -Mode GeneratedProject
```

`-Owner` принимает роль или псевдоним, поэтому настоящее имя не требуется. Инициализатор требует чистый Git worktree, сохраняет существующий `.git` и `origin`, не выполняет stage, commit или push и блокирует прямой clone канонического template remote. Повторный запуск запрещен.

Инструкции владельца по локальной сборке, выпуску веток `source`/`main` и release tag находятся только в source-only `TEMPLATE.md`; в созданный продукт они не переносятся.

## Что сделать после установки

Новая копия начинает в режиме `generated-project + initialized + report-only`. В этом режиме можно заполнять паспорт, планировать, проводить research и сохранять RAW только по прямой просьбе, но нельзя начинать продуктовую реализацию до заполнения activation gate.

Рекомендуемый порядок:

1. Заполнить [`ai-clone/CORE.md`](ai-clone/CORE.md) минимальным рабочим профилем владельца.
2. Заполнить паспорт и границы в [`PROJECT.md`](PROJECT.md).
3. Зафиксировать идею и критерии проверки через [`idea/INDEX.md`](idea/INDEX.md).
4. Заполнить product- и business-контекст через [`product/INDEX.md`](product/INDEX.md) и [`business/INDEX.md`](business/INDEX.md).
5. При необходимости провести evidence-based research через `$startup-researcher`.
6. Для любого значимого изменения создать или продолжить Plan v2 через `$project-delivery`.
7. Только после заполнения обязательных полей попросить Codex перевести проект в `active + report-only`.
8. Отдельно проверить diff и дать прямую команду на baseline commit. Лишь после такого commit можно осознанно включать `safe-local`.

Базовый prompt:

```text
Прочитай AGENTS.md, ai-clone/CORE.md, PROJECT.md и INDEX.md. Проверь текущий режим
репозитория. Задай только вопросы, без которых нельзя заполнить паспорт проекта.
Не придумывай факты. Затем предложи минимальные изменения PROJECT.md, idea/,
product/ и business/, но ничего не коммить и не отправляй в remote.
```

## Библиотека доменных промтов

В [`prompts/`](prompts/README.md) лежат короткие copy-paste prompts для значимых зон. Корневой README дает маршрут, а доменный файл содержит вопросы интервью, границы записи и критерий готовности.

| Нужно сделать | Готовый prompt | Целевой домен |
|---|---|---|
| Заполнить рабочий профиль владельца | [`AI Clone interview`](prompts/ai-clone-interview.md) | [`ai-clone/`](ai-clone/INDEX.md) |
| Заполнить паспорт и activation gate | [`Project passport`](prompts/project-passport.md) | [`PROJECT.md`](PROJECT.md) |
| Ограничить и проверить идею | [`Idea validation`](prompts/idea-validation.md) | [`idea/`](idea/INDEX.md) |
| Собрать знания о продукте | [`Product interview`](prompts/product-interview.md) | [`product/`](product/INDEX.md) |
| Описать бизнес и его архитектуру | [`Business architecture interview`](prompts/business-architecture-interview.md) | [`business/`](business/INDEX.md) |
| Зафиксировать фактические architecture/codebase | [`Architecture and codebase inventory`](prompts/architecture-codebase-inventory.md) | [`docs/`](docs/INDEX.md) |
| Запустить доказательное исследование | [`Research run`](prompts/research-run.md) | [`research/`](research/INDEX.md) |
| Спланировать значимое изменение | [`Plan and deliver`](prompts/plan-and-deliver.md) | [`plans/`](plans/README.md), код и [`docs/`](docs/INDEX.md) |
| Продолжить ранее начатую работу | [`Continue plan`](prompts/continue-plan.md) | точный `<PLAN_REF>` |
| Предложить Local Mastery | [`Create Mastery`](prompts/create-mastery.md) | [`knowledge/`](knowledge/INDEX.md), затем [`mastery/local/`](mastery/local/INDEX.md) |

Prompt помогает собрать и маршрутизировать данные, но не дает разрешения на commit, push, promotion, external write или canonical handoff. Перед запуском замени `<ЗНАЧЕНИЯ>` и удали неприменимые пункты.

## Как заполнить ai-clone

`ai-clone` хранит минимальный контекст о том, как Codex должен работать с владельцем проекта. Это не биография и не место для секретов, документов, адресов, контактов или приватной переписки.

В [`ai-clone/CORE.md`](ai-clone/CORE.md) достаточно заполнить:

- роль и текущий контекст;
- цели и критерии хорошего результата;
- принципы принятия решений;
- предпочтительный стиль совместной работы и текста;
- запреты и ситуации, когда Codex обязан остановиться;
- повторяющиеся коррекции, которые уже доказали полезность.

После заполнения поменяй `profile_status: template` на `profile_status: active` и поставь дату проверки. Если repository станет public, сначала удали или обобщи персональные сведения.

Пример prompt:

```text
Помоги заполнить ai-clone/CORE.md. Сначала проведи короткое интервью по разделам
этого файла. Отделяй мои прямые ответы от своих гипотез, не добавляй чувствительные
данные и не меняй другие файлы. В конце покажи diff и список мест, где осталась
неопределенность.
```

Для пошагового интервью используй готовый [`AI Clone interview prompt`](prompts/ai-clone-interview.md).

## Как заполнить PROJECT и idea

[`PROJECT.md`](PROJECT.md) хранит только паспорт: проблему, проверяемую гипотезу, границы, критерии успеха и текущий статус. Не копируй в него подробности продукта, бизнеса или реализации.

[`idea/`](idea/INDEX.md) разворачивает гипотезу: почему сейчас, vision, proof of value, MVP, риски, принципы, источники и результаты deep research. Начинай с ближайшего проверяемого предположения, а не с полного описания будущего продукта.

```text
Проведи короткое интервью для PROJECT.md и idea/. Отдели подтвержденные факты от
гипотез, зафиксируй один ближайший proof of value, критерий провала и главные
риски. Не выбирай стек и не придумывай рынок. Перед записью покажи target paths.
```

Готовые маршруты: [`Project passport`](prompts/project-passport.md) и [`Idea validation`](prompts/idea-validation.md).

## Как заполнить product и business

Папка [`product/`](product/INDEX.md) хранит подтвержденные знания о пользователях, опыте и возможностях продукта:

- `overview.md` - назначение, ценность и границы;
- `users-and-jobs.md` - сегменты, контекст, боли и jobs-to-be-done;
- `experience.md` и `capabilities.md` - ожидаемый путь и способности без привязки к реализации;
- `glossary.md` - единый язык проекта.

Папка [`business/`](business/INDEX.md) хранит бизнес-механизм:

- `overview.md` и `architecture.md` - предложение, роли, capabilities и потоки ценности;
- `model-and-economics.md` - доход, затраты, unit economics и допущения;
- `go-to-market.md` - позиционирование, каналы и путь к ценности;
- `goals-and-metrics.md` - критерии решений и безопасные способы получить живые метрики;
- `assets/` - разрешенные бренд- и доказательные материалы.

Исходники всех доменов сохраняются только по прямой просьбе в [`inbox/raw/`](inbox/raw/README.md).

Сначала заполняй только то, что влияет на ближайшую проверку гипотезы. Для каждого утверждения помечай тип: факт, наблюдение, гипотеза, мнение или цитата.

Пример prompt:

```text
На основе PROJECT.md и подтвержденных источников подготовь минимальный product и
business baseline. Раздели факты, наблюдения и гипотезы. Заполни только нужные
файлы product/ и business/, добавь критерии проверки и source_refs. Не создавай
сегменты, цены или метрики без evidence. Перед записью покажи target paths.
```

Используй два коротких маршрута: [`Product interview`](prompts/product-interview.md) и [`Business architecture interview`](prompts/business-architecture-interview.md).

## Как работать с plans

Значимая реализация, bugfix, миграция, архитектурное изменение или release всегда ведется через один tracked Plan v2 в [`plans/`](plans/README.md). Планирующий prompt обязан создать или найти план до первой предметной записи. Файл не перемещается между папками и проходит состояния `planned` -> `in-progress` -> `complete`; `blocked` сохраняет причину и следующий шаг.

- [`plans/INDEX.md`](plans/INDEX.md) показывает группы «Новый», «В работе», «Сделано» и «Заблокирован».
- `Resume checkpoint` хранит текущую фазу, выполненное, проверки, рабочие paths и следующее действие.
- Перед продолжением Codex сверяет checkpoint с Git state через `scripts/assert-plan-resume.ps1`.
- После каждой фазы Codex обновляет план и детерминированный индекс.
- Завершение требует закрытых критериев, проверок, `result_refs` и knowledge closeout. Completed plan не открывается повторно.

```text
Используй $project-delivery для задачи <ЗАДАЧА> с task key <TASK_KEY>. До любых
изменений создай или найди ровно один active Plan v2, покажи его ID и путь. Веди
реализацию по фазам и после каждой обновляй Resume checkpoint и проверки.
```

Для новой работы используй [`Plan and deliver`](prompts/plan-and-deliver.md), для возобновления - [`Continue plan`](prompts/continue-plan.md) с точным `<PLAN_REF>`.

## Как начинать работу с кодом

Шаблон намеренно не создает заранее `src/`, `app/`, `tests/`, `infra/` и конфиги конкретного стека. После выбора технологии Codex создает только нужные stack-native каталоги, а затем фиксирует фактическую картину:

- [`docs/architecture/`](docs/architecture/INDEX.md) - контекст системы, границы, компоненты, данные, интеграции, trust boundaries и deployment;
- [`docs/codebase/`](docs/codebase/INDEX.md) - entrypoints, модули, команды run/build/test, conventions и технический долг;
- [`docs/decisions/`](docs/decisions/README.md) - только устойчивые труднообратимые решения;
- код и тесты - источник истины о текущем поведении.

Read-only инвентаризацию запускай через [`Architecture and codebase inventory`](prompts/architecture-codebase-inventory.md). Реализацию feature или bugfix начинай через [`Feature/bugfix delivery`](prompts/feature-bugfix-delivery.md), который обязательно связывает работу с планом.

## Как создавать Local Mastery

Baseline Researcher Mastery в [`mastery/researcher/`](mastery/researcher/INDEX.md) переносится вместе с шаблоном и не редактируется в продукте. Повторяемый project-specific метод создается только в [`mastery/local/`](mastery/local/INDEX.md).

Безопасный lifecycle:

1. Метод подтвержден двумя независимыми завершенными task/run sources или прямой коррекцией владельца с project source.
2. Codex предлагает один `type: method` knowledge candidate с точным `claim_key`, evidence, target и `review_due`.
3. Владелец отдельно одобряет promotion.
4. Codex создает `mastery/local/<method-id>.md` из шаблона, регистрирует его в `mastery/local/INDEX.md`, добавляет backlink и обновляет knowledge graph.
5. Verifier проверяет provenance, даты, status и ссылки. Автоматического promotion нет.

Пример prompt для предложения метода:

```text
Проанализируй завершенные задачи <ССЫЛКА_1> и <ССЫЛКА_2>. Проверь, есть ли новый
повторяемый project-local метод, которого еще нет в mastery. Если durable delta
доказан, предложи ровно один knowledge candidate типа method. Не применяй его и
не меняй mastery/local без моего отдельного одобрения.
```

Пример prompt для разрешенного promotion:

```text
Одобряю promotion candidate <KC-ID> в mastery/local. Проверь authority, sources,
duplicates, conflicts и review_due. Создай метод из TEMPLATE.md, зарегистрируй
его, добавь backlink, обнови knowledge graph и запусти полный structure gate.
Не выполняй commit или push.
```

## Что встроено

### Project-local skills

| Skill | Назначение | Входит в новый проект |
|---|---|---|
| [`startup-researcher`](.agents/skills/startup-researcher/SKILL.md) | Исследование ниш, идей, перспективности и evidence | Да |
| [`project-delivery`](.agents/skills/project-delivery/SKILL.md) | Обязательный Plan v2, реализация по фазам, проверки и closeout | Да |
| [`knowledge-curator`](.agents/skills/knowledge-curator/SKILL.md) | Diff closeout, candidates, review и разрешенный promotion | Да |

`bulletproof`, `frontend-design` и другие пользовательские/global skills могут быть доступны владельцу source template, но в consumer payload не входят.

### MCP, plugins и внешние подключения

В шаблон не зашит ни один MCP server, plugin, connector, hook или automation. Это намеренно: такие подключения имеют отдельные permissions, credentials и lifecycle и настраиваются в среде конкретного пользователя. `.codex` и `config.toml` также не копируются.

Если проекту нужен MCP, сначала опиши минимальный read/write scope и проверь официальный [MCP guide Codex](https://developers.openai.com/codex/mcp). Для устройства project instructions смотри официальный [AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md), для создания новых workflows - [Skills guide](https://developers.openai.com/codex/skills).

### Остальные компоненты

- `AGENTS.md` - обязательные project instructions Codex;
- `.template-manifest.json` - переносимый allowlist и release contract;
- `TEMPLATE-DISTRIBUTION.json` - provenance consumer payload;
- `scripts/verify-structure.ps1` - структура, ссылки и semantic gates;
- `scripts/verify-knowledge.ps1` - режимы, RAW, candidates, Mastery и history gates;
- `scripts/verify-plans.ps1` - обязательные планы, prompt policy и resume checkpoints;
- `scripts/verify-canon.ps1` - product, business, architecture и codebase canon;
- `scripts/update-knowledge-graph.ps1` - deterministic derived graph;
- PowerShell scripts для локального bootstrap и инициализации GitHub Template;
- Git как история состояний. Сеть, database и background daemon не требуются.

## Полезные prompts

Исследовать идею:

```text
Используй $startup-researcher. Проведи bounded deep dive по идее из PROJECT.md.
Сначала зафиксируй критерии решения, затем собери независимое evidence и red-team.
Не меняй idea/ без отдельного разрешения. Верни decision и candidate IDs.
```

Спланировать и реализовать изменение:

```text
Используй $project-delivery для задачи <ЗАДАЧА>. До первой предметной записи найди
active plan с task key <TASK_KEY> или создай его через scripts/new-plan.ps1.
Выполняй работу по фазам, после каждой обновляй Resume checkpoint и проверки.
Не выполняй commit, push или promotion без отдельного разрешения.
```

Проверить состояние:

```text
Выполни read-only аудит проекта: режим, заполненность PROJECT.md, stale knowledge
graph, незавершенные plans/runs, overdue mastery и результаты verifiers. Ничего не
исправляй и не создавай knowledge files. Верни приоритетный список проблем.
```

Подготовить локальный commit:

```text
Проверь фактический diff относительно pre-task snapshot, выполни knowledge
closeout и все применимые gates. Покажи точные paths для stage и предложи commit
message. Не выполняй stage, commit или push до моей отдельной команды.
```

## Проверки и лицензирование

Основные read-only проверки:

```powershell
pwsh -NoProfile -File ./scripts/verify-structure.ps1 -Mode Auto
pwsh -NoProfile -File ./scripts/verify-plans.ps1
pwsh -NoProfile -File ./scripts/verify-canon.ps1 -Report
pwsh -NoProfile -File ./scripts/verify-knowledge.ps1 -Report
pwsh -NoProfile -File ./scripts/update-knowledge-graph.ps1 -Mode Check
```

Template materials распространяются по [MIT License](LICENSE) и сопровождаются [third-party notices](THIRD-PARTY-NOTICES.md) до инициализации. После setup эти файлы хранятся как `TEMPLATE-LICENSE.md` и `TEMPLATE-THIRD-PARTY-NOTICES.md`. Лицензия кода и материалов нового продукта намеренно не выбирается автоматически.

Полная карта репозитория находится в [`INDEX.md`](INDEX.md).
