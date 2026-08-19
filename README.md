# Модельный проект

Проверяемый шаблон для запуска независимого IT-продукта вместе с Codex. Он объединяет паспорт проекта, исследование идеи, business-контекст, системный и бизнес-анализ, project-local Mastery, knowledge lifecycle и безопасные PowerShell-проверки.

Шаблон поддерживает два способа старта:

- GitHub Template - основной способ для нового репозитория и передачи знакомым;
- локальная копия через `scripts/new-project.ps1` - способ владельца source template.

## Самый быстрый старт через GitHub

Поддерживаемая среда первого релиза: Windows 10/11, локальный NTFS-диск, PowerShell 7.6 или новее, Git 2.28 или новее и Codex.

1. На странице template repository нажми `Use this template` -> `Create a new repository`.
2. Не включай `Include all branches`. Новый repository должен получить только default consumer branch.
3. Создай отдельный private repository для своего продукта.
4. Открой [готовый prompt установки для Codex](CODEX-INSTALL-PROMPT.md), замени значения в угловых скобках и передай prompt Codex.
5. После setup проверь результат:

```powershell
pwsh -NoProfile -File .\scripts\verify-structure.ps1 -Mode GeneratedProject
```

Не клонируй канонический template repository как продукт и не меняй его remote. Сначала создай новый repository через GitHub Template, затем клонируй именно новый repository.

## Ручная установка из нового GitHub repository

```powershell
git clone <URL_НОВОГО_REPOSITORY> <ПАПКА_ПРОЕКТА>
Set-Location <ПАПКА_ПРОЕКТА>
pwsh -NoProfile -File .\scripts\initialize-project.ps1 `
  -FromGitHubTemplate `
  -ProjectName "Название продукта" `
  -ProjectSlug "product-slug" `
  -Description "Одно предложение о продукте" `
  -Owner "Имя владельца"
pwsh -NoProfile -File .\scripts\verify-structure.ps1 -Mode GeneratedProject
```

Инициализатор требует чистый Git worktree, сохраняет существующий `.git`, не выполняет stage, commit или push и блокирует прямой clone канонического template remote. Повторный запуск запрещен.

## Локальное создание из source template

Этот путь нужен только владельцу канонической source-копии:

```powershell
pwsh -NoProfile -File .\scripts\new-project.ps1 `
  -Destination "..\Название продукта" `
  -ProjectName "Название продукта" `
  -ProjectSlug "product-slug" `
  -Description "Одно предложение о продукте" `
  -Owner "Имя владельца"
```

Скрипт создает отдельную папку и независимый Git repository на ветке `main`, но оставляет его без commits. Он копирует только allowlist из [`.template-manifest.json`](.template-manifest.json) и не переносит `.git` source template, `.codex`, owner overlays, заполненные runs, candidates или личные данные.

## Как владельцу выпустить GitHub Template

Каноническая история шаблона хранится в ветке `source`, а default-ветка `main` содержит только собранный consumer payload. `main` не редактируется вручную и всегда строится из exact tag ветки `source`.

Минимальный release flow:

1. В `source` закончить изменения, проверить фактический diff и пройти все release gates.
2. Создать проверенный commit и tag вида `v<template_version>`, совпадающий с `.template-manifest.json`.
3. Из clean tagged `source` собрать payload в новый несуществующий destination path внутри существующей локальной родительской папки:

```powershell
pwsh -NoProfile -File .\scripts\build-github-template.ps1 `
  -SourceTag "v1.6.2" `
  -TemplateRepositoryUrl "https://github.com/<OWNER>/<TEMPLATE_REPOSITORY>" `
  -Destination "<ABSOLUTE_NEW_STAGING_PATH>"
```

4. Проверить staging в режиме `DistributionTemplate`, затем заменить содержимое derived-ветки `main` только этим payload и создать отдельный release commit.
5. После явного разрешения владельца отправить `source`, `main` и exact tag в remote. В GitHub выбрать `main` как default branch, включить признак Template repository и не использовать `Include all branches` при создании продукта.

Builder требует ветку `source`, clean tracked HEAD, exact tag, обычный tracked state всех manifest-файлов и HTTPS URL, совпадающий с GitHub identity `origin`. Он копирует только manifest allowlist, формирует SHA-256 descriptor и проверяет payload до atomic публикации. Destination заранее существовать не должен. Builder не выполняет commit, push и не меняет ветки. Публиковать source repository рекомендуется сначала как private и проверить установку в отдельном тестовом repository.

## Что сделать после установки

Новая копия начинает в режиме `generated-project + initialized + report-only`. В этом режиме можно заполнять паспорт, планировать, проводить research и сохранять RAW только по прямой просьбе, но нельзя начинать продуктовую реализацию до заполнения activation gate.

Рекомендуемый порядок:

1. Заполнить [`ai-clone/CORE.md`](ai-clone/CORE.md) минимальным рабочим профилем владельца.
2. Заполнить паспорт и границы в [`PROJECT.md`](PROJECT.md).
3. Зафиксировать идею и критерии проверки через [`idea/INDEX.md`](idea/INDEX.md).
4. Заполнить business-контекст через [`business/INDEX.md`](business/INDEX.md).
5. При необходимости провести evidence-based research через `$startup-researcher`.
6. При необходимости создать требования, процессы, модели или ТЗ через `$it-analysis`.
7. Только после заполнения обязательных полей попросить Codex перевести проект в `active + report-only`.
8. Отдельно проверить diff и дать прямую команду на baseline commit. Лишь после такого commit можно осознанно включать `safe-local`.

Базовый prompt:

```text
Прочитай AGENTS.md, ai-clone/CORE.md, PROJECT.md и INDEX.md. Проверь текущий режим
репозитория. Задай только вопросы, без которых нельзя заполнить паспорт проекта.
Не придумывай факты. Затем предложи минимальные изменения PROJECT.md, idea/ и
business/, но ничего не коммить и не отправляй в remote.
```

## Библиотека доменных промтов

В [`prompts/`](prompts/README.md) лежат короткие copy-paste prompts для значимых зон. Корневой README дает маршрут, а доменный файл содержит вопросы интервью, границы записи и критерий готовности.

| Нужно сделать | Готовый prompt | Целевой домен |
|---|---|---|
| Заполнить рабочий профиль владельца | [`AI Clone interview`](prompts/ai-clone-interview.md) | [`ai-clone/`](ai-clone/INDEX.md) |
| Заполнить паспорт и activation gate | [`Project passport`](prompts/project-passport.md) | [`PROJECT.md`](PROJECT.md) |
| Ограничить и проверить идею | [`Idea validation`](prompts/idea-validation.md) | [`idea/`](idea/INDEX.md) |
| Собрать business baseline через интервью | [`Business baseline`](prompts/business-baseline.md) | [`business/`](business/INDEX.md) |
| Запустить доказательное исследование | [`Research run`](prompts/research-run.md) | [`research/`](research/INDEX.md) |
| Создать требования, процессы или модели | [`Analysis run`](prompts/analysis-run.md) | [`analysis/`](analysis/INDEX.md) |
| Спланировать значимое изменение | [`Decision and delivery`](prompts/decision-and-delivery.md) | [`plans/`](plans/README.md), [`docs/`](docs/INDEX.md) |
| Завершить diff или предложить Local Mastery | [`Knowledge and Mastery`](prompts/knowledge-and-mastery.md) | [`knowledge/`](knowledge/INDEX.md), [`mastery/local/`](mastery/local/INDEX.md) |

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

## Как заполнить business

Папка [`business/`](business/INDEX.md) содержит канон одного продукта:

- `products/` - предложение, результат, тарифы и границы;
- `audience/` - сегменты, боли, поведение, возражения и путь пользователя;
- `economics/` - модель доходов, затрат и unit economics;
- `marketing/` - позиционирование, каналы и воронка;
- `goals/` - критерии успеха, провала и решения о продолжении;
- `analysis/` - stakeholders, capabilities, процессы, правила и business requirements;
- `raw/` - разрешенный исходный материал с provenance, но не подтвержденная истина.

Сначала заполняй только то, что влияет на ближайшую проверку гипотезы. Для каждого утверждения помечай тип: факт, наблюдение, гипотеза, мнение или цитата.

Пример prompt:

```text
На основе PROJECT.md и подтвержденных источников подготовь минимальный business
baseline. Раздели факты, наблюдения и гипотезы. Заполни только релевантные файлы
business/, добавь критерии проверки и provenance. Не создавай цены, метрики или
сегменты без evidence. Перед записью покажи предполагаемые target paths.
```

Для интервью по продукту, аудитории, экономике, маркетингу и целям используй готовый [`Business baseline prompt`](prompts/business-baseline.md).

## Как создавать Local Mastery

Baseline Mastery в [`mastery/researcher/`](mastery/researcher/INDEX.md) и [`mastery/analyst/`](mastery/analyst/INDEX.md) переносится вместе с шаблоном и не редактируется в продукте. Повторяемый project-specific метод создается только в [`mastery/local/`](mastery/local/INDEX.md).

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
| [`it-analysis`](.agents/skills/it-analysis/SKILL.md) | Business/system analysis, требования, процессы, модели, API и ТЗ | Да |
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
- `scripts/verify-analysis.ps1` - analysis runs и canonical handoff;
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

Сформировать требования:

```text
Используй $it-analysis. Создай bounded analysis run для функции <ФУНКЦИЯ>.
Построй stakeholders, as-is/to-be, требования, NFR, traceability и независимый
review. Canonical handoff не выполняй без моего отдельного подтверждения.
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
pwsh -NoProfile -File .\scripts\verify-structure.ps1 -Mode Auto
pwsh -NoProfile -File .\scripts\verify-knowledge.ps1 -Report
pwsh -NoProfile -File .\scripts\verify-analysis.ps1 -Report
pwsh -NoProfile -File .\scripts\update-knowledge-graph.ps1 -Mode Check
```

Template materials распространяются по [MIT License](LICENSE) и сопровождаются [third-party notices](THIRD-PARTY-NOTICES.md) до инициализации. После setup эти файлы хранятся как `TEMPLATE-LICENSE.md` и `TEMPLATE-THIRD-PARTY-NOTICES.md`. Лицензия кода и материалов нового продукта намеренно не выбирается автоматически.

Полная карта репозитория находится в [`INDEX.md`](INDEX.md).
