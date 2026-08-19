---
artifact_kind: plan
status: complete
knowledge_outcome: existing
candidate_ids: []
affected_canon: []
blocked_reason: null
---

# План: маршрутизация и автонакопление знаний

- Дата: 2026-07-29
- Статус: complete
- Целевая версия шаблона: `1.2.0`

## Проблема и evidence

Шаблон уже разделяет канон, RAW, research runs, mastery, plans и retrospectives, но реальное автонакопление не замкнуто:

- обычный RAW может пройти в канон без единого candidate gate;
- `promotion-proposal.md` существует только внутри startup research;
- consent в RAW-шаблонах заранее выставлен как полученный;
- `PROJECT.md` и девять leaf-файлов `idea/` используют Wikilinks как единственный локальный маршрут;
- `new-project.ps1` и `verify-structure.ps1` дублируют portable allowlist;
- GeneratedProject запрещает проверенные project-local расширения mastery;
- structural verifier не проверяет candidate state, evidence IDs, provenance backlinks и root reachability.

`verify-structure.ps1 -Mode TemplateSource` до этой функции проходит, поэтому проблема находится в семантическом контракте, а не в существовании базовых папок.

## Цель

Добавить минимальный Git-ориентированный knowledge control plane:

1. Один owner-first маршрут от инструкций к точному артефакту.
2. Agent-driven knowledge closeout после задач с записью.
3. Один Markdown candidate для каждого устойчивого project-local вывода.
4. Явное разрешение для RAW, promotion, shared write и удаления.
5. Машинную проверку state, provenance, evidence и графа ссылок.
6. Версионированный immutable baseline Researcher Mastery и валидируемую `mastery/local/`.

## Границы

Входит:

- проектные инструкции, индексы, шаблоны RAW, research и истории;
- project-local `$knowledge-curator`;
- единый `.template-manifest.json`;
- два knowledge-скрипта;
- интеграция `$startup-researcher` с центральным candidate;
- точечное исправление Markdown-маршрутов;
- TemplateSource, GeneratedProject, Auto и fresh-copy проверки.

Не входит:

- база данных, vector store, daemon, hooks или внешняя служба памяти;
- автоматическое изменение внешнего `Модельный портфель`;
- автоматическое сохранение RAW, PII, секретов или стороннего verbatim-контента;
- автоматическое удаление;
- миграция старых проектов;
- массовое переименование README;
- commit, push и deploy.

## Архитектурное решение

```text
активные инструкции
-> обязательный сработавший SKILL.md
-> PROJECT.md
-> INDEX.md
-> knowledge/INDEX.md для write или closeout
-> тематический INDEX.md
-> источник, рабочий артефакт или канон
-> $knowledge-curator
-> verify-knowledge.ps1
```

Алгоритм:

```text
intent -> repository mode -> owner -> artifact kind -> domain -> authority -> target
```

`knowledge/INDEX.md` является единой политикой и таблицей маршрутов. Не создаются отдельные `POLICY.md`, `routes.json`, `QUEUE.md`, event ledger и JSON Schema.

### Рассмотренные варианты

| Вариант | Польза | Риск и стоимость | Решение |
|---|---|---|---|
| Только усилить инструкции | Минимальный diff | Нет исполняемой очереди и semantic gate | Отклонен |
| База данных или vector store | Сильный поиск | Второй канон, инфраструктура и синхронизация | Отклонен |
| Candidate из трех файлов и event log | Полный аудит переходов | Дублирует Git и раздувает шаблон | Отклонен |
| Один Markdown candidate и semantic verifier | Переносимость, Git diff, небольшая стоимость | Требует строгого frontmatter | Выбран |

## Исполняемые контракты

### PROJECT

```yaml
repository_kind: template-source | generated-project
project_status: template | initialized | active | archived
project_id:
knowledge_contract_version: 1
knowledge_capture_mode: disabled | report-only | safe-local
```

- TemplateSource: `template + disabled`.
- Новый проект: `initialized + report-only`.
- Active: `safe-local` по умолчанию, `report-only` как opt-out.
- Archived: `disabled`.

### Candidate

Путь:

```text
knowledge/candidates/YYYY/KC-YYYYMMDD-HHmmss-<8hex>.md
```

Состояния:

```text
ready -> applied
      -> dismissed
```

Обычная задача может создать не более одного автоматического candidate, research - не более трех. Candidate создается только для нового, устойчивого, атомарного, безопасного project-local claim с owner, source и target. Shared claim автоматически не записывается.

### Provenance

```text
source -> candidate -> canonical target
                     <- Markdown backlink
```

Source не переписывается. Applied candidate без существующего target и backlink является ошибкой.

## Критерии приемки

1. `PROJECT.md` имеет валидную пару repository status и capture mode.
2. Новый проект создается как `initialized + report-only`.
3. Answer, review и diagnose не создают knowledge-файлы.
4. Safe-local change с durable delta создает не более одного `ready` candidate.
5. Duplicate, transient, unsafe и shared выводы автоматически не записываются.
6. Applied candidate имеет существующие source, target и backlink.
7. RAW создается только по прямому capture-запросу и не имеет заранее полученного consent.
8. Research создает central candidate, но без разрешения не меняет `idea/`.
9. Evidence JSONL имеет валидный JSON, уникальные IDs и разрешимые decision refs.
10. Каждый статический канонический Markdown-файл достижим от корневого `INDEX.md`.
11. Динамические runs, RAW, plans, retrospectives и candidates не требуют ручного реестра.
12. `.template-manifest.json` является единственным portable allowlist.
13. Researcher Mastery baseline проверяется по SHA-256.
14. GeneratedProject допускает только зарегистрированные файлы `mastery/local/`.
15. Оба project-local skills проходят официальный `quick_validate.py`.
16. Fresh copy не содержит owner overlays, `.codex`, source history и заполненных runs/candidates.
17. `git diff --check`, PowerShell AST, TemplateSource, GeneratedProject, Auto, semantic self-tests и security review проходят.

## Риски, безопасность и откат

- Knowledge curator анализирует фактический diff, но не получает право на RAW, external write или delete.
- Candidate хранит нормализованный claim, а не пользовательское сообщение, transcript или полный diff.
- Относительные пути не могут выходить за корень или проходить через reparse point.
- Проверка не утверждает, что способна доказать отсутствие пропущенного knowledge delta; это semantic обязанность агента.
- Existing archive-каталоги сохраняются, но новые RAW физически не перемещаются.
- Откат выполняется только поименно по затронутым путям после проверки diff. Owner overlays не изменяются.

## Фаза 1 - [x] Контракт и маршрутизация

Цель: создать единый authority stack и portable manifest.

Deliverable: план, ADR, `AGENTS.md`, `PROJECT.md`, root/knowledge indexes и `.template-manifest.json`.

Сделано, когда: каждый контрольный intent имеет один owner, artifact и write gate.

Задачи:

- [x] Зафиксировать baseline status и structural evidence.
- [x] Сравнить тяжелый и минимальный control plane.
- [x] Создать ADR.
- [x] Добавить PROJECT frontmatter и режимы.
- [x] Переработать AGENTS и индексы.
- [x] Ввести единый portable manifest.

## Фаза 2 - [x] Candidate pipeline

Цель: реализовать безопасный closeout.

Deliverable: candidate template, `$knowledge-curator`, generator и semantic verifier.

Сделано, когда: валидный candidate создается атомарно, а invalid candidate не появляется на диске.

Задачи:

- [x] Инициализировать skill официальным `init_skill.py`.
- [x] Написать SKILL.md и согласованный `openai.yaml`.
- [x] Реализовать `new-knowledge-candidate.ps1`.
- [x] Реализовать candidate validation, report и self-tests.

## Фаза 3 - [x] RAW, research и mastery

Цель: свести все пути promotion к central candidate.

Deliverable: обновленные RAW templates, startup research decision flow и mastery extension contract.

Сделано, когда: ни RAW, ни research не обходят candidate gate, baseline и local mastery различаются.

Задачи:

- [x] Исправить consent и promotion в RAW.
- [x] Удалить run-local promotion proposal и обновить skill references/assets.
- [x] Добавить baseline hashes и `mastery/local/`.
- [x] Добавить логический маршрут к внешней Copywriting Mastery.

## Фаза 4 - [x] Ссылки, copy и semantic gate

Цель: обеспечить переносимость и графовую целостность.

Deliverable: manifest-driven copy/verify, обычные Markdown routes и semantic integration.

Сделано, когда: source и fresh copy проходят оба verifier-а, а отрицательные fixtures дают ожидаемый FAIL.

Задачи:

- [x] Перевести copy и structure verifier на manifest.
- [x] Исправить Wikilink-only маршруты.
- [x] Проверить reachability статического канона.
- [x] Проверить evidence, candidate, mastery и path security.

## Фаза 5 - [x] Review и выпуск

Цель: закрыть регрессию и выпустить шаблон 1.2.0.

Deliverable: green gates, forward-tests, independent review, security review, retrospective и changelog.

Сделано, когда: все критерии сопоставлены с evidence и нет открытых существенных findings.

Задачи:

- [x] Провести fresh-copy tests.
- [x] Forward-test оба skills свежими агентами.
- [x] Провести независимый review без передачи выводов реализации.
- [x] Исправить доказанные findings и повторить gates.
- [x] Обновить версию, changelog, план и ретроспективу.

## Проверки

- PowerShell AST пяти измененных скриптов - PASS.
- Официальный `quick_validate.py` для `$knowledge-curator` и `$startup-researcher` - PASS.
- `verify-knowledge.ps1 -SelfTest` - PASS для полного набора positive и negative fixtures.
- `verify-knowledge.ps1 -Report` - PASS, все пять отчетных счетчиков равны нулю.
- `verify-structure.ps1 -Mode TemplateSource` и `-Mode Auto` - PASS, 67 канонических Markdown-файлов.
- Fresh generated copy: `GeneratedProject`, `Auto` и knowledge report - PASS, 64 канонических Markdown-файла.
- Fresh-copy inventory в точности равен 75 portable-файлам manifest плюс `TEMPLATE-ORIGIN.md`: 76 файлов, 0 commits, пустой `research/runs/`, только candidate template и `mastery/local/INDEX.md`.
- Изолированный future bump `2.0.0` через manifest + `.template-version` проходит TemplateSource, создание проекта и GeneratedProject без изменения runtime-скриптов.
- Owner overlays, `.codex`, source-only plans/retrospectives и история исходного Git в fresh copy отсутствуют.
- Независимые correctness, security и forward reviews - CLEAN после исправления всех доказанных P2.
- `git diff --check` - PASS; остаются только информационные предупреждения Git о будущей нормализации LF/CRLF.

## Итог

- Реализовано целиком: да, все фазы и критерии версии 1.2.0 закрыты.
- Что осталось: функциональной работы в scope нет; старые проекты намеренно не мигрируются.
- Коммиты: не создаются без отдельной команды пользователя.
