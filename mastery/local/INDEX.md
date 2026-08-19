# Local Mastery

Зона расширений, специфичных для одного generated project. В исходном template source и fresh copy она остается пустой, кроме этого индекса. Baseline из [`../researcher/`](../researcher/INDEX.md) и [`../analyst/`](../analyst/INDEX.md) здесь не копируется и не переопределяется.

## Контракт расширения

Каждый Markdown-файл расширения создается из [`TEMPLATE.md`](TEMPLATE.md) и имеет strict frontmatter:

```yaml
---
method_id: unique-project-method-id
owner_scope: project
applies_to:
  - niche-discovery
status: active
source_refs:
  - relative/source.md
verified_at: YYYY-MM-DD
review_due: YYYY-MM-DD
supersedes: null
---
```

Закрытый список `applies_to`:

| Intent ID | Тип research |
|---|---|
| `niche-discovery` | поиск ниш |
| `idea-comparison` | сравнение идей |
| `deep-dive` | deep dive |
| `project-assessment` | оценка существующего проекта |
| `refresh` | обновление исследования |
| `external-research-audit` | аудит чужого исследования |
| `stakeholder-analysis` | stakeholders, интересы, влияние и конфликты |
| `requirements-elicitation` | выявление источников, потребностей и ограничений |
| `business-process-analysis` | бизнес-процессы, участники, исключения и метрики |
| `as-is-to-be` | сравнение текущего и целевого состояния |
| `gap-analysis` | разрывы, причины, зависимости и варианты закрытия |
| `business-rule-analysis` | нормативные правила, условия и исключения |
| `use-case-modeling` | actors, flows и границы use case |
| `functional-requirements` | проверяемое функциональное поведение |
| `nonfunctional-requirements` | измеримые NFR и quality attributes |
| `data-analysis` | данные, сущности, связи и ограничения |
| `integration-analysis` | системы, потоки и integration boundaries |
| `api-contract-analysis` | API schemas, errors, auth и compatibility |
| `traceability` | полнота графа sources -> requirements -> verification |
| `change-impact-analysis` | влияние изменения по связанным слоям |
| `acceptance-criteria` | детерминированные критерии приемки |
| `specification-authoring` | создание SRS, ТЗ и feature specifications |
| `specification-review` | независимая проверка спецификации |
| `requirements-validation` | validation полноты, согласованности и testability |

`status` принимает только `active | deprecated | superseded`.

## Инварианты

- `method_id` уникален без учета регистра.
- `owner_scope` равен только `project`.
- `applies_to` непустой и содержит только IDs из закрытого списка.
- `source_refs` непустой; каждый ref безопасен, существует или является разрешенным HTTPS/logical source.
- `verified_at` является валидной датой и не находится в будущем.
- `review_due >= verified_at`.
- `supersedes` направлен от более нового метода к заменяемому: он равен null или существующему `method_id`, не ссылается на себя и не образует цикл.
- Метод со `status: superseded` обязан иметь хотя бы одну входящую ссылку `supersedes` от другого метода. Его собственный `supersedes` может оставаться null для первой версии или указывать на еще более старый метод в цепочке.
- Любой метод, на который указывает `supersedes`, имеет `status: superseded`; replacement может оставаться `active` до следующей замены.
- Файл зарегистрирован обычной Markdown-ссылкой в таблице ниже.
- Незарегистрированный файл, duplicate ID, missing metadata, broken ref и invalid graph блокируются.
- Local mastery проходит тот же data-safety scanner, что RAW, candidates и research artifacts.

Overdue extension появляется в report, но не удаляется. Overdue, deprecated и superseded extension не выбирается автоматически.

## Обучаемость без самоизменения

Система предлагает новый метод как обычный knowledge candidate с `type: method`, `domain: mastery`, `claim_key: method.<id>` и точным `target_ref: mastery/local/INDEX.md#зарегистрированные-расширения`.

Candidate допустим только при `confidence: medium | high`, непустом `review_due` и одном из оснований:

1. Два независимых завершенных task/run source.
2. Явная коррекция оператора с `capture_basis: explicit-user-capture`, `user-request:...` authority и хотя бы одним project source.

Автоматического promotion нет. После прямого одобрения оператора Lead:

1. Создает один файл метода из [`TEMPLATE.md`](TEMPLATE.md).
2. Добавляет строку в реестр ниже и backlink на applied candidate.
3. Ставит `review_due` через 180 дней, если оператор не задал другую дату.
4. Запускает strict verification и обновляет [производный граф знаний](../../knowledge/graph/INDEX.md).

История candidate сохраняется. Просроченный метод не выбирается автоматически и не удаляется.

## Retrieval route

`$startup-researcher` или `$it-analysis` выполняет маршрут в своей baseline-зоне:

1. Прочитать `mastery/INDEX.md`.
2. Выбрать один основной baseline profile из `mastery/researcher` или `mastery/analyst` согласно workflow.
3. При необходимости выбрать максимум один дополняющий baseline profile.
4. Прочитать этот registry.
5. Открыть максимум одно active, непросроченное и релевантное local extension.
6. Записать точные baseline refs, local `method_id` и local file ref в research brief и decision.

Verifier проверяет существование, регистрацию, status, dates и method refs. Он не утверждает, что понимает смысловую релевантность extension.

## Зарегистрированные расширения

| Method ID | Расширение | Applies to | Проверено | Review due | Статус |
|---|---|---|---|---|---|
| Пока нет | - | - | - | - | - |

## Маршруты

- [Project Mastery](../INDEX.md) - границы project-local mastery.
- [Researcher Mastery](../researcher/INDEX.md) - неизменяемый baseline исследовательских методов.
- [Analyst Mastery](../analyst/INDEX.md) - неизменяемый baseline бизнес- и системного анализа.
- [Knowledge](../../knowledge/INDEX.md) - candidate и promotion для устойчивого project-local метода.
