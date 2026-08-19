# История шаблона

## 1.6.2 - 2026-08-19

- Удалено личное имя правообладателя из переносимого `LICENSE`; используется нейтральная атрибуция `Model Project contributors`.
- Публичная Git-история выпускается отдельными чистыми commits с нейтральной служебной подписью, поэтому локальные author name и e-mail не попадут в GitHub.
- Версии 1.6.0 и 1.6.1 остались только локальными pre-release tags и не публикуются.

## 1.6.1 - 2026-08-19

- Исправлен Git roundtrip consumer payload: `analysis/runs` и `research/runs` теперь сохраняются через переносимые `.gitkeep` markers.
- `.gitattributes` фиксирует LF для текстового payload, чтобы Git checkout не менял байты `.ps1` и SHA-256 descriptor.
- Analysis verifier игнорирует только точный root marker, но продолжает блокировать остальные non-directory run entries.
- Distribution harness выполняет настоящий local commit/clone и проверяет `DistributionTemplate` уже после потери нетрекнутых каталогов.
- Версия 1.6.1 исправила локальный pre-release 1.6.0, но также не публикуется после privacy review перед первым GitHub release.

## 1.6.0 - 2026-08-19

- Добавлена переносимая библиотека `prompts/` с коротким индексом и отдельными copy-paste prompts для AI Clone, паспорта, идеи, business, research, analysis, delivery и knowledge/mastery.
- AI Clone и business prompts используют пошаговый интервью-формат, ограничивают сбор персональных данных и требуют подтверждать резюме перед записью.
- README, PROJECT и корневой INDEX ведут к доменным prompts, не дублируя канонические contracts.
- Каждый prompt явно отделяет подготовку от authority на commit, push, promotion, external write и canonical handoff.
- Версия 1.6.0 входит только в новые fresh copies. Существующие generated projects автоматически не мигрируются.

## 1.5.0 - 2026-08-17

- Добавлен GitHub Template distribution pipeline с канонической `source` и производной default-веткой `main`.
- Source-only builder требует exact clean release tag/commit, создает consumer payload через staging и фиксирует SHA-256 в `TEMPLATE-DISTRIBUTION.json`.
- Builder сверяет declared repository с GitHub identity source `origin` и отклоняет manifest-файлы, отсутствующие в tagged commit или скрытые index flags.
- `initialize-project.ps1 -FromGitHubTemplate` сохраняет существующий Git repository, блокирует canonical remote, source refs, dirty state и повторную инициализацию.
- Корневой README и отдельный Codex install prompt описывают onboarding, `ai-clone`, business, Local Mastery, skills, MCP и базовые рабочие prompts.
- В portable payload добавлен пустой project-local `ai-clone`; данные владельца source template не переносятся.
- MIT license шаблона после setup становится `TEMPLATE-LICENSE.md`, notices сохраняются отдельно, а лицензия продукта остается невыбранной.
- `safe-local` требует HEAD с тем же generated project ID и тем же origin, поэтому pre-init GitHub Template commit не является baseline.
- Версия 1.5.0 входит только в новые fresh copies. Существующие generated projects автоматически не мигрируются.

## 1.4.0 - 2026-08-16

- Knowledge closeout стал обязательным после каждой write-задачи: fresh initialized project остается report-only, а automatic ready candidate разрешен только в `active + safe-local` с Git `HEAD`.
- Добавлен tracked deterministic `knowledge/graph/INDEX.md` с обычными ссылками, root-relative Wikilinks, outgoing links, backlinks, orphans, conflicts и evidence refs.
- Новый trusted `update-knowledge-graph.ps1` поддерживает `Check`, `Write`, `Report` и `SelfTest`; structure gate блокирует stale, вручную измененный или небезопасный граф до analysis и knowledge gates.
- Минимальная обучаемость использует существующий `type: method` candidate lifecycle: независимые task/run sources либо явная коррекция оператора, direct authority, review due, local template и отсутствие automatic promotion.
- `$it-analysis` ограничивает parallel fan-out тремя read-only специалистами, оставляет Lead единственным writer и запускает независимые Reviewer и Red Team только после Lead synthesis.
- Exact eight-file analysis run фиксирует assignments, findings, conflict resolution, Lead synthesis, independent review и red-team verdict; semantic verifier отклоняет пропущенные этапы.
- Версия 1.4.0 входит только в новые fresh copies. Существующие generated projects автоматически не мигрируются.

## 1.3.0 - 2026-08-15

- Добавлен portable control plane бизнес- и системного анализа: working runs отделены от canonical requirements, models, specifications, change requests и review decisions.
- Введены закрытые namespace, lifecycle, authority, provenance и traceability contracts без автоматического approval или promotion.
- Добавлены immutable Analyst Mastery, project-local `$it-analysis`, exact eight-file run assets и атомарный `new-analysis-run.ps1`.
- `verify-analysis.ps1` проверяет schemas, refs, anchors, IDs, run completion, canonical relations, safety и resource budgets; `verify-structure.ps1` запускает его из trusted scripts перед knowledge gate.
- Shared module получил reusable path, reparse, exact-case, bounded UTF-8 и anchor primitives; machine refs и file-relative Markdown links используют разные bases.
- Existing generated projects автоматически не мигрируются. Новая структура появляется только в fresh copy версии 1.3.0 либо через отдельную осознанную миграцию.
- Release verification включает analysis/knowledge self-tests, TemplateSource gate и disposable fresh-copy smoke; итоговое evidence фиксируется в плане и retrospective этой версии.

## 1.2.1 - 2026-08-01

- Финальная стабилизация 2026-08-09 заменила ускоренное evidence полным regression gate текущего snapshot: semantics, artifacts, privacy, research, mastery, control plane и disposable fresh copy прошли.
- Bootstrap subprocess isolation переведен на per-child environment без временного изменения process-wide `GIT_*`; exit code и UTF-8 output теперь захватываются явно.
- Bounded `git ls-files` использует отдельный sanitized process с лимитом строк; исправлены stale fixture oracles для UTF-8, A09 и реалистичного A51 Git baseline.
- Manifest стал единственным источником версии; legacy-зеркало `.template-version` удалено вместе с синхронизацией и отдельной проверкой.
- Source maintenance отделен от generated payload: `TEMPLATE.md`, changelog, owner ADR, release history, regression harnesses и `new-project.ps1` остаются в исходном шаблоне, а fresh copy получает только portable workflow и `TEMPLATE-ORIGIN.md`.
- `INDEX.md` проекта и `TEMPLATE.md` владельца проверяются как независимые navigation roots, поэтому maintenance-ссылки не могут маскировать orphan в generated project.
- GeneratedProject gate отклоняет повторное появление любого exact source-only пути, а staging cleanup повторно проверяет reparse chain перед рекурсивным удалением.
- Удалены пустые legacy archive-заглушки и незаполненный brand guide; повторяющиеся RAW, plan, retrospective, research и decision правила сведены к каноническим contracts.
- Закрыты false-green режимы activation, Git baseline, authority, candidate lifecycle, RAW, research, plans, retrospectives и Researcher Mastery.
- Candidate generator получил cooperative mutex, повторную exact deduplication и fail-closed preflight без partial artifacts.
- Git subprocess изолирован от управляющих `GIT_*`, system/global config и forged linked worktree; HEAD blob и tree читаются с жесткими лимитами.
- Local Mastery получил проверяемый replacement graph и реальный retrieval route в `$startup-researcher`.
- Инициализация и fresh-copy pipeline получили trusted host resolution, rollback, controlled failure codes и проверку нулевого Git baseline.
- Public verifier и structural chain используют единый UTF-8 output contract для точных локализованных diagnostics.
- Security и independent reviews закрыли доказанные findings; остаточный coverage-риск ускоренного release-профиля зафиксирован в retrospective.

## 1.2.0 - 2026-07-31

- Добавлен agent-driven knowledge closeout с единым `knowledge/INDEX.md`, central candidates и `$knowledge-curator`.
- Добавлены атомарный generator и semantic verifier для candidate states, provenance, RAW safety, evidence IDs, root reachability и reports.
- Усилен trust boundary: проверяемый root остается данными, чтение ограничено лимитами, unsafe URI/reparse блокируются, а fresh copy публикуется только после проверки staging.
- `$startup-researcher` переведен с run-local promotion proposal на central candidate IDs без скрытого изменения `idea/`.
- RAW требует прямой capture-команды, provenance, rights и retention; новые записи больше не перемещаются физически в archive.
- `.template-manifest.json` стал единым portable contract для copy и structural verification.
- Researcher Mastery зафиксирован baseline-хэшами, а project-local расширения разрешены только через зарегистрированный `mastery/local/`.
- Новая копия создается как `initialized + report-only` с уникальным project ID; переход в `active` выполняется отдельно.
- Старые проекты не мигрируются автоматически.

## 1.1.0 - 2026-07-21

- Добавлена project-local `mastery/researcher/` с пятью проверенными авторскими профилями.
- Добавлен project-local skill `.agents/skills/startup-researcher/` для шести типов доказательного исследования.
- Добавлен чистый `research/` с отдельными runs и безопасным предложением продвижения в `idea/`.
- `new-project.ps1` переведен на явный allowlist для скрытых и mastery-зон.
- `verify-structure.ps1` разделяет исходный шаблон и созданный проект режимами `TemplateSource`, `GeneratedProject` и `Auto`.
- Существующие проекты не мигрируются автоматически.

## 1.0.0 - 2026-07-20

- Отделен единый AI-клон и общая база знаний.
- Добавлены паспорт, корневой индекс и контракт шаблона.
- Добавлены гибридный RAW-процесс, decisions и link-check.
- Глобальные skills и Context7 вынесены из шаблона.
- Зафиксировано, что старые проекты не мигрируются автоматически.
