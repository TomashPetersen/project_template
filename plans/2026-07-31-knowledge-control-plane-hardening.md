---
artifact_kind: plan
status: complete
knowledge_outcome: existing
candidate_ids: []
affected_canon:
  - AGENTS.md
  - docs/decisions/2026-07-29-knowledge-control-plane.md
  - knowledge/INDEX.md
  - scripts/README.md
  - TEMPLATE-CHANGELOG.md
blocked_reason: null
---

# План: hardening knowledge control plane 1.2.1

## Паспорт работы

- Дата начала: 2026-08-01
- Целевая версия шаблона: `1.2.1`
- Режим bulletproof: `L`
- Обязательные skills: `$bulletproof`, `$skill-creator`, `$knowledge-curator`
- Предыдущий исторический план: [маршрутизация и автонакопление знаний 1.2.0](2026-07-29-knowledge-lifecycle-routing.md)
- Архитектурное решение: [минимальный knowledge control plane](../docs/decisions/2026-07-29-knowledge-control-plane.md)

Старый план и его retrospective остаются историческими артефактами. Этот файл фиксирует отдельный follow-up после аудита и не переписывает прошлые утверждения задним числом.

## Проблема и evidence

Версия 1.2.0 ввела единый Markdown/Git knowledge control plane, но последующий аудит доказал false-green в исполняемой цепочке. Текущие проверки проходят, хотя остаются незакрытыми режимы activation, Git baseline, повторное использование `mastery/local`, generator concurrency, privacy, lifecycle, authority, полный research scaffold, cross-artifact references и проверяемый mastery version bump.

Pre-task snapshot зафиксирован до изменений:

```text
git status --porcelain=v1 -z
git diff HEAD
git diff --cached
git ls-files --others --exclude-standard
```

- Исходный worktree уже содержал незакоммиченный слой версии 1.2.0.
- Staged paths отсутствовали.
- Внешний read-only snapshot: `temporary-snapshot:ModelProjectHardening-PreTask-20260801-019fbbe2`; физический путь в репозитории не хранится.
- Snapshot содержит 87 файлов, 837471 байт и исключает `.git`.
- Owner overlays `.agents/skills/bulletproof/**`, `.agents/skills/frontend-design/**` и `.codex/**` принадлежат исходному состоянию и не меняются.

Исходный зеленый baseline не является release evidence:

| Команда | Exit code | Длительность |
|---|---:|---:|
| `scripts/verify-knowledge.ps1` | 0 | 4.816 с |
| `scripts/verify-knowledge.ps1 -Report` | 0 | 4.810 с |
| `scripts/verify-knowledge.ps1 -SelfTest` | 0 | 50.763 с |
| `scripts/verify-structure.ps1 -Mode TemplateSource` | 0 | 22.128 с |
| `scripts/verify-structure.ps1 -Mode Auto` | 0 | 22.035 с |

## Цель

Локально выпустить шаблон `1.2.1`, в котором все детерминированные нарушения из threat model блокируются через public entrypoints, каждый исходный finding имеет regression fixture, fresh generated copy совпадает с manifest, а ограничения семантических гарантий названы честно.

## Scope

Входит:

- hardening существующих пяти PowerShell entrypoints;
- один общий portable module только при доказанном сокращении дублирования;
- executable mode, activation, Git baseline, authority и lifecycle contracts;
- fail-closed RAW, research, candidate, ADR, plan, retrospective и mastery validation;
- mutex и повторная deduplication generator;
- retrieval route `mastery/local` в `$startup-researcher`;
- обновление двух project-local skills через `$skill-creator` и их official validation;
- regression matrix, fresh copy, security review, independent review;
- прозрачное дополнение существующего ADR;
- retrospective, manifest, changelog и version bump после зеленого gate.

Не входит:

- данные конкретного продукта;
- миграция старых проектов, migration script или migration guide;
- database, vector store, daemon, watcher, hooks, event ledger, вторая очередь или второй router;
- отдельный promotion pipeline или run-local promotion proposal;
- автоматическое удаление;
- копирование внешней Copywriting Mastery;
- запись во внешний `Модельный портфель`;
- внешние зависимости;
- push, merge или deploy; stage и локальный commit разрешены только отдельной финальной задачей 2026-08-09;
- изменение owner overlays.

## Модель угроз и граница гарантий

Verifier и generator должны fail-closed обрабатывать ошибочного агента, параллельные generator processes, malformed repository data, traversal, reparse points, неправильный регистр, опасные URI, известные synthetic PII/secret classes и противоречивые lifecycle artifacts.

Они не доказывают смысловую истинность claim, реальный consent, отсутствие любой обфусцированной PII, семантического дубля или shared owner, а также безопасность против same-user writer с полным доступом. Эти свойства остаются agent-enforced.

## Сохраняемая архитектура

```text
активные инструкции
-> обязательный SKILL.md
-> PROJECT.md
-> INDEX.md
-> knowledge/INDEX.md
-> тематический INDEX или README
-> точный источник, рабочий артефакт или канон
-> knowledge-curator
-> verify-knowledge.ps1
```

Алгоритм маршрутизации остается:

```text
intent -> repository mode -> owner -> artifact kind -> domain -> authority -> target
```

## Research и выбор подхода

### Существующие project patterns

- `.template-manifest.json` является единственным portable allowlist.
- Markdown остается каноном, Git остается историей состояний.
- `verify-structure.ps1` вызывает trusted `verify-knowledge.ps1` рядом с собственным `$PSScriptRoot`.
- Generated copy строится в случайном sibling staging и публикуется rename.
- Candidate публикуется одним `CreateNew`, но exact claim dedup пока не защищен межпроцессным mutex.
- Self-tests уже используют временный generated-like root и public generator, поэтому матрицу следует расширять в существующем `-SelfTest`, а не создавать второй test runner.

### Альтернативы

| Подход | Польза | Стоимость и риск | Решение |
|---|---|---|---|
| Только обновить Markdown | Малый diff | Не закрывает false-green и гонку | Отклонен |
| Переписать control plane или добавить отдельную инфраструктуру | Можно унифицировать все сразу | Высокий regression risk, второй источник истины, выход за scope | Отклонен |
| Точечно усилить текущие entrypoints, затем вынести доказанно общие pure helpers в один module | Сохраняет public CLI и архитектуру, дает проверяемые gates | Требует фазового refactor и parity fixtures | Выбран |

### Рекомендация

Сначала добавить failing fixtures через public entrypoints, затем закрывать behavior по доменам. После зеленых behavior gates вынести только совпадающие parser/path/safety/date/SHA helpers в `scripts/lib/ModelProject.Knowledge.psm1`, сохранив unique business rules в entrypoints.

## Acceptance criteria

- [x] AC-01 Исполняемая цепочка исправлена, а не только документация.
- [x] AC-02 Каждый исходный finding имеет regression fixture с exit code и post-state oracle.
- [x] AC-03 Blocking violation возвращает ненулевой exit code public entrypoint.
- [x] AC-04 Failed write не оставляет final, draft, temp, lock или частично обновленный target.
- [x] AC-05 Каждое machine field проверяется и имеет consumer либо удалено.
- [x] AC-06 Каждый сохраняемый knowledge type имеет retrieval route.
- [x] AC-07 `$startup-researcher` реально выбирает допустимое `mastery/local` extension.
- [x] AC-08 Race fixture стабильно создает ровно один candidate.
- [x] AC-09 Privacy fixtures не дают false PASS, diagnostics не раскрывают sentinel.
- [x] AC-10 `active + safe-local` невозможно без заполненного паспорта и Git HEAD.
- [x] AC-11 Explicit promotion в `report-only` работает только с authority.
- [x] AC-12 Automatic promotion отсутствует.
- [x] AC-13 RAW, ADR, plan, retrospective и research lifecycle refs проверяемы.
- [x] AC-14 Template source и fresh copy проходят полный release gate.
- [x] AC-15 Version и changelog меняются последними.
- [x] AC-16 Plan и retrospective содержат фактическое evidence.
- [x] AC-17 Ни один исходный defect не оставлен как TODO, warning или manual follow-up.
- [x] AC-18 Остаточные semantic limitations названы честно.

## Матрица finding -> regression fixture

| ID | Исходный finding | Positive fixture | Negative fixture | Enforcement layer |
|---|---|---|---|---|
| F-01 | `mastery/local` не извлекается | активный зарегистрированный релевантный method ref | unknown, unregistered, duplicate, overdue, deprecated, superseded и cycle | startup skill + knowledge verifier |
| F-02 | generator race | разные claim keys создаются без потерь | 8 процессов с одним normalized claim key через barrier, несколько повторов | generator mutex + CreateNew |
| F-03 | PII, secrets и credentials пропускаются | обезличенный summary и безопасные URLs | email, phone, ФИО, адрес, дата рождения, keys, bearer, cookie, signed URL, transcript | общий data-safety scanner |
| F-04 | RAW template утверждает consent | template с `storage_basis: null`, `authority_ref: null` | реальный RAW без basis или authority | RAW schema verifier |
| F-05 | RAW lifecycle раздвоен | captured/reviewed/rejected/retention-due | старые promotion fields и status | closed RAW schema |
| F-06 | research partial scaffold проходит | exact six-file run | только pair, отсутствие каждого файла, extra proposal, bad run name | research run inventory gate |
| F-07 | `authority_ref` неисполняем | policy, user-request или accepted ADR по контексту | arbitrary authority, unsafe ref, missing authority | authority grammar + generator intent |
| F-08 | report-only запрещает explicit promotion | active report-only + direct authority | automatic capture в report-only, template/archived promotion | mode + write intent preflight |
| F-09 | Git/diff baseline ненадежен | tracked, staged, untracked, deleted, renamed snapshot | missing pre-task snapshot и safe-local без HEAD | curator + project gate |
| F-10 | blank active/safe-local проходит | заполненный active report-only и safe-local с HEAD | placeholders и пустые passport sections | activation verifier |
| F-11 | applied допускает conflicts | ready с conflicts попадает в report | applied с conflicts | candidate lifecycle verifier |
| F-12 | state dates и supersedes нестроги | valid terminal states и acyclic graph | self, 2/3-cycle, missing ID, future dates, applied before created | lifecycle graph/date gate |
| F-13 | mastery version bump не доказан | coordinated fingerprint + SemVer bump | drift without bump и fake bump | trusted Git change-aware structural gate |
| F-14 | Copywriting logical route расходится | `logical:shared-mastery/copywriting` как source | identifier как target и unknown shared logical ID | shared logical grammar |
| F-15 | archived restore/delete противоречивы | explicit restore -> initialized/report-only | ordinary archived write и promotion | mode contract + docs |
| F-16 | parser/path/safety code дублируется | parity всех public entrypoints | mutation одного общего check снова красит fixture | optional shared module |
| F-17 | заявляется межфайловая атомарность | итоговый consistent worktree + strict gate | failed write без partial artifacts | docs + write-path tests |

Обязательные acceptance cases A-01..A-87 из задачи являются частью AC-02 и release gate. Их реализация ведется в существующем `scripts/verify-knowledge.ps1 -SelfTest` и в fresh-copy harness. Для каждого critical class нужен хотя бы один независимый filesystem, JSON или text oracle, а не только production parser.

## Фаза 1 - Контракт и failing fixtures [x]

- Цель: воспроизвести каждый исходный defect до production fix.
- Deliverable: этот plan, обновляемая matrix, failing fixtures A-01..A-87.
- Сделано, когда: каждый F-01..F-17 имеет red reproducer через public entrypoint.
- Зависимости: pre-task snapshot и исходный baseline.
- Риски: не допустить ослабления старых fixtures ради нового контракта.
- Задачи:
  - [x] Прочитать инструкции, canon, предыдущий plan/retrospective, skills, templates и entrypoints.
  - [x] Зафиксировать Git baseline и внешний snapshot.
  - [x] Замерить текущие verifier-ы.
  - [x] Добавить fixture helpers и negative matrix без production fixes.
  - [x] Зафиксировать ожидаемый red evidence по каждому class.
- Gates:
  - `scripts/verify-knowledge.ps1 -SelfTest` - ненулевой exit до production fixes.
  - focused fixture command - ненулевой exit и отсутствие partial artifacts.
- Evidence: baseline table выше; red evidence добавляется после fixtures.

## Фаза 2 - Security и concurrency [x]

- Цель: единый fail-closed safety behavior и deterministic generator serialization.
- Deliverable: safety scanner, RAW schema, research-wide scan, mutex и second-check dedup.
- Сделано, когда: privacy fixtures блокируются без disclosure, race создает один candidate.
- Задачи:
  - [x] Реализовать общий safety behavior и безопасные diagnostics.
  - [x] Закрыть RAW schema и sensitive/verbatim rules.
  - [x] Сканировать все research files и local mastery.
  - [x] Добавить SHA-256 scoped mutex, timeout, abandoned recovery и retry.
- Gates: F-02, F-03, F-04, F-05; race минимум 8 процессов и несколько повторов.

## Фаза 3 - Authority, promotion и lifecycle [x]

- Цель: сделать explicit promotion исполняемым и terminal states согласованными.
- Deliverable: closed authority grammar, write intent, conflicts, dates, dismissal и supersedes graph.
- Сделано, когда: invalid transitions блокируются, explicit report-only promotion проходит с authority.
- Задачи:
  - [x] Добавить `-WriteIntent automatic-capture | explicit-promotion`.
  - [x] Проверить authority по intent и provenance.
  - [x] Запретить applied conflicts, self/cycles и invalid date/state combinations.
  - [x] Проверить historical outcomes без переписывания истории.
- Gates: F-07, F-08, F-11, F-12, F-17.

## Фаза 4 - Retrieval и research [x]

- Цель: замкнуть local method retrieval и exact six-file run.
- Deliverable: local schema/registry/selection, method refs в brief/decision, full run inventory, canonical Copywriting ID.
- Сделано, когда: valid local method достижим, partial run и invalid method ref блокируются.
- Задачи:
  - [x] Обновить `$startup-researcher` и assets через `$skill-creator`.
  - [x] Реализовать local method IDs, status, applies_to, dates и graph.
  - [x] Проверять exact run directory и assets-derived six-file set.
  - [x] Унифицировать `logical:shared-mastery/copywriting`.
- Gates: F-01, F-06, F-14.

## Фаза 5 - Cross-artifact validation [x]

- Цель: убрать декоративные machine fields и проверять lifecycle refs.
- Deliverable: strict frontmatter ADR, plan и retrospective contracts.
- Сделано, когда: broken candidate, affected canon, supersedes или outcome не дает PASS.
- Задачи:
  - [x] Перевести templates на frontmatter без изменения исторического смысла source-only artifacts.
  - [x] Проверить candidate IDs, affected canon и supersedes graphs.
  - [x] Проверить complete/blocked plan и retrospective historical outcomes.
- Gates: F-05, F-11, F-12 и acceptance A-55..A-64.

## Фаза 6 - Repository modes и mastery baseline [x]

- Цель: доказуемые activation, Git baseline, restore и bundle bump.
- Deliverable: passport readiness, HEAD requirement, trusted Git comparison, archived routes, baseline metadata.
- Сделано, когда: blank active и safe-local без HEAD блокируются, coordinated bump проходит.
- Задачи:
  - [x] Реализовать deterministic passport placeholder/section gate.
  - [x] Запретить safe-local без trusted HEAD, не требовать HEAD для active/report-only.
  - [x] Сравнивать trusted TemplateSource manifest с HEAD без Git внутри arbitrary root.
  - [x] Добавить `verified_at` и `review_due`, report overdue.
  - [x] Зафиксировать restore/delete правила.
- Gates: F-09, F-10, F-13, F-15.

## Фаза 7 - Consolidation [x]

- Цель: сократить доказанное дублирование после исправления behavior.
- Deliverable: максимум один `scripts/lib/ModelProject.Knowledge.psm1`, обновленные docs и public CLI parity.
- Сделано, когда: module загружается только относительно trusted `$PSScriptRoot`, entrypoint parity зелен.
- Задачи:
  - [x] Сравнить совпадающие helper implementations после fixes.
  - [x] Вынести только общие parser/path/reference/HTTPS/safety/date/SHA helpers, если diff реально уменьшается.
  - [x] Не переносить unique business rules и CommonMark graph без доказанной пользы.
  - [x] Обновить manifest и scripts README.
- Gates: F-16, AST, focused parity, `git diff --check`.

## Фаза 8 - [x] Fresh copy и release

- Цель: доказать целостность source template и будущего generated project без повторного многочасового прогона уже доказанных матриц.
- Deliverable: одна fresh copy, объединенный source gate, retrospective, manifest/changelog/version `1.2.1`.
- Основание сокращения: прямая команда пользователя применить ускоренный release-профиль и переиспользовать зеленое evidence этой задачи.

## Ускоренный release gate 1.2.1

| Проверка | Результат | Evidence |
|---|---|---|
| A74 direct и nested UTF-8 diagnostics | PASS | Оба нарушения дали exit 1 и точные русские diagnostics без replacement characters |
| PowerShell AST | PASS | 12 файлов, 647 мс |
| `verify-knowledge.ps1` | PASS | exit 0, 14896 мс |
| `verify-knowledge.ps1 -Report` | PASS | exit 0, 15710 мс; все счетчики 0 |
| `verify-structure.ps1 -Mode TemplateSource` | PASS | exit 0, 44061 мс; 68 Markdown |
| `verify-structure.ps1 -Mode Auto` | PASS | exit 0, 43985 мс; TemplateSource |
| `git diff --check` | PASS | exit 0, 293 мс |
| Fresh copy через `new-project.ps1` | PASS | exit 0, 92347 мс |
| Fresh GeneratedProject и Auto | PASS | exit 0, 31466 и 31603 мс; 64 Markdown |
| Fresh inventory и Git | PASS | 77 ожидаемых файлов, пустые candidates/runs/local mastery, 0 commits, 0 staged |
| Повторная инициализация | PASS | exit 1, `initialization-rejected`, filesystem unchanged |
| Privacy/RAW matrix | REUSED PASS | 37 bounded checks, exit 0, 523429 мс |
| Bounded Git tree A23 | REUSED PASS | exit 0, 226922 мс |
| Initializer rollback A21 | REUSED PASS | rollback и retry, exit 0, 63931 мс |
| Local mastery research A53 | REUSED PASS | exit 0, 85263 мс |
| Security и independent reviews | COMPLETE | Доказанные findings исправлены и затронутые gates повторены |

Полные semantics A19-A30 и artifacts A55-A64 не повторялись после прямого сокращения scope. Это остаточный test-coverage risk ускоренного release-профиля, а не утверждение об их новом полном прогоне. Integration покрыт текущими strict source gates и fresh-copy gate.

## Риски, безопасность, rollback и deploy gate

- Privacy scanner остается документированным denylist, а не абсолютной гарантией.
- Named mutex защищает cooperative generator processes, но не hostile same-user writer.
- Change-aware Git checks выполняются только для trusted source root и не исполняются внутри arbitrary `-Root`.
- Межфайловая promotion не называется atomic. До зеленого strict gate change set считается незавершенным, а Git обеспечивает восстановимую историю.
- Rollback выполняется только поименно по фактическому task diff относительно pre-task snapshot. `reset`, `checkout` и массовый откат запрещены.
- Deploy, merge, commit, push и stage не входят в эту задачу.

## Challenge log

1. Coverage: F-01..F-17 сопоставлены с AC-01..AC-18; повтор всех A-01..A-87 заменен прямой командой на ускоренный gate выше.
2. Alternatives: выбран точечный hardening текущей архитектуры; docs-only и полный rewrite отклонены.
3. Scope discipline: не добавляются новые storage/router/lifecycle systems, migration и automatic delete.

## Финальный статус

- Статус: complete по ускоренному release-профилю 1.2.1.
- Исполняемая цепочка, trust boundaries, lifecycle, RAW/research/mastery и fresh-copy contracts реализованы.
- Security review закрыл Git environment isolation, linked-worktree backlink, bounded Git output, trusted hosts и initializer rollback.
- Independent fixture review усилил A21/A22, lifecycle diagnostics и post-state oracles; отдельный UTF-8 transport defect закрыт direct и nested A74 checks.
- `$knowledge-curator`: `existing`. Устойчивые выводы уже находятся в accepted ADR, `knowledge/INDEX.md`, `mastery/local/INDEX.md` и `scripts/README.md`; новый candidate был бы дублем.
- Версия, manifest version и changelog являются последними repository file edits. После них выполняются только read-only source verifier и exact fixture cleanup.

## Фаза 9 - [x] Финальная стабилизация release baseline

- Цель: закрыть остаточный test-coverage risk ускоренного профиля и зафиксировать воспроизводимый локальный baseline `1.2.1`.
- Deliverable: полный regression gate, disposable fresh copy, согласованный plan/retrospective и локальный focused commit без push.
- Сделано, когда: все source и generated gates проходят на одном snapshot, временная копия удалена, owner overlays не затронуты, а релизный diff зафиксирован в Git.
- Задачи:
  - [x] Запустить `verify-knowledge.ps1 -SelfTest` и все шесть `test-knowledge-*.ps1` harnesses.
  - [x] Создать disposable fresh copy и проверить GeneratedProject, Auto, inventory, empty zones, Git baseline и repeat-init refusal.
  - [x] Согласовать acceptance checklist и фазовые статусы с фактическим evidence.
  - [x] Повторить AST, strict/report, TemplateSource/Auto и `git diff --check`.
  - [x] Выполнить security/review closeout и `$knowledge-curator`.
  - [x] Создать локальный focused commit `1.2.1`; push и deploy не выполнять.

### Финальный release gate 2026-08-09

| Проверка | Результат |
|---|---|
| `verify-knowledge.ps1 -SelfTest` | PASS, все встроенные fixtures |
| Semantics A19-A30 | PASS, полный текущий прогон |
| Artifacts A55-A64 | PASS, 13 проверок |
| Privacy/RAW A31-A42 | PASS, 37 bounded checks |
| Research A43-A54 | PASS, 12 cases |
| Mastery A65-A78 | PASS, 20 проверок |
| Control plane A01-A23 | PASS, включая два race-повтора |
| Disposable fresh copy | PASS, 69 файлов, GeneratedProject/Auto, `main`, 0 commits, 0 staged |
| Repeat initializer | PASS, exit 1, `initialization-rejected`, SHA tree unchanged |
| Cleanup | PASS, exact verified disposable root удален |

Во время полного прогона исправлены четыре доказанных finding: UTF-8 capture semantics harness, пустой A51 Git baseline fixture, устаревший A09 safe diagnostic oracle и production isolation дочерних процессов при inherited `GIT_*`. Все затронутые focused cases и полные harnesses повторены.
