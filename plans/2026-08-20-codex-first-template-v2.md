---
artifact_kind: plan
plan_contract_version: 2
plan_id: PLAN-20260820-codex-first-template-v2
task_key: codex-first-template-v2
prompt_ref: null
status: complete
current_phase: null
updated_at: 2026-08-20T10:04:38Z
completed_at: 2026-08-20T10:04:38Z
closeout_status: complete
knowledge_outcome: none
candidate_ids: []
result_refs:
  - README.md
  - CODEX-INSTALL-PROMPT.md
  - .template-manifest.json
  - .github/workflows/template-integrity.yml
  - docs/decisions/2026-08-20-codex-first-template-v2.md
  - scripts/lib/ModelProject.Platform.psm1
  - scripts/lib/ModelProject.Plan.psm1
  - scripts/new-mastery.ps1
  - retrospectives/2026-08-20_14-01_codex-first-template-v2.md
affected_canon:
  - README.md
  - CODEX-INSTALL-PROMPT.md
  - .template-manifest.json
  - AGENTS.md
  - INDEX.md
  - TEMPLATE.md
  - docs/decisions/2026-08-20-codex-first-template-v2.md
  - knowledge/INDEX.md
  - mastery/INTENTS.json
blocked_reason: null
---

# План: Codex-first шаблон проекта v2.0.0

## Проблема и цель

Текущий consumer надежно распространяется и защищает knowledge lifecycle, но перегружен formal business/system analysis, не имеет предметных зон product, architecture и codebase, не обеспечивает repository-level возобновление планирующих prompts и поддерживает только Windows.

Цель - выпустить локально проверенный breaking-шаблон v2.0.0 для работы с Codex, сохранив manifest allowlist, безопасную инициализацию, provenance, privacy, candidates, graph, Researcher Mastery, ADR и ручной promotion.

## Границы

Входит:

- Plan v2, prompt contract, deterministic plan index и project-delivery skill;
- product, business, architecture и codebase canon;
- plan closeout и knowledge graph;
- Local Mastery v2, intent catalog и безопасный generator/promotion;
- удаление formal analysis из v2 после переноса универсальных защит;
- Windows/macOS PowerShell 7 и source-only CI;
- README, prompts, manifest, ADR, changelog и retrospective.

Не входит:

- миграция существующих generated projects;
- создание stack-native каталогов;
- MCP, plugins, credentials, deploy, commit, tag или push;
- изменение пользовательских `.agents/skills/bulletproof/**`, `.agents/skills/frontend-design/**` и `.codex/**`.

## Критерии приемки

- [x] AC-01 Каждый planning prompt имеет machine-readable policy и до предметной записи создает или продолжает ровно один plan.
- [x] AC-02 Plan сохраняет current phase, checks, working paths, next action и восстанавливается через `AGENTS.md` и `plans/INDEX.md`.
- [x] AC-03 Consumer содержит новые предметные домены и не содержит formal-analysis paths.
- [x] AC-04 Graph индексирует только разрешенный активный canon, Local Mastery и candidates и остается детерминированным.
- [x] AC-05 Local Mastery создается из подтвержденного method candidate через preview и отдельное authority.
- [x] AC-06 Bootstrap, verifiers и generators работают в PowerShell 7 на Windows и macOS semantics.
- [x] AC-07 Fresh local copy, DistributionTemplate и GitHub Template initialization проходят с точным allowlist.
- [x] AC-08 Privacy, provenance, traversal, link, case, symlink/reparse, lock и prompt negative fixtures проходят.
- [x] AC-09 README начинает с Codex installation prompt, затем дает ручной запуск и рабочие маршруты.
- [x] AC-10 `v1.6.2` остается неизменным, stage/commit/tag/push не выполняются.

## Решения и отклоненные варианты

- План является tracked Markdown source of truth, а не памятью чата или скрытым state.
- Machine statuses остаются `planned | in-progress | complete | blocked`; русский интерфейс строится производным индексом.
- Prompt policy имеет только `none | required | existing`; неоднозначный `conditional` не используется.
- Mastery остается knowledge artifact, Skill - исполняемым workflow; автоматического Mastery-to-Skill нет.
- Complete plan терминален; follow-up получает новый plan ID.
- Formal analysis не становится optional pack v2: точная реализация остается в immutable tag `v1.6.2` и Git history.

## Риски, безопасность и откат

- Массовое изменение verifier может дать false-green. Каждый новый контракт получает positive и negative fixtures до удаления старого слоя.
- Cross-platform refactor может ослабить path trust. Общие helpers вводятся с parity fixtures и fail-closed поведением.
- Изменения выполняются пофазно; откат - поименный возврат файлов этой задачи. Исторический tag не изменяется.
- Generated projects не мигрируются и не очищаются автоматически.

## Фаза P1 - [x] Plan и prompt control plane

Цель: сделать plan обязательным и возобновляемым артефактом для planning prompts.

Deliverable: Plan v2 schema, prompt policy, new/set/update scripts, deterministic index, verifier fixtures и project-delivery skill.

Сделано, когда: AC-01 и AC-02 проходят focused tests.

- [x] Обновить `plans/TEMPLATE.md` и `plans/README.md`.
- [x] Реализовать `new-plan.ps1`, `set-plan-status.ps1` и `update-plan-index.ps1`.
- [x] Добавить prompt frontmatter и planning entrypoints.
- [x] Добавить Plan v2 gates и fixtures.
- [x] Добавить `project-delivery` и root routing.

## Фаза P2 - [x] Предметный canon и graph

Цель: добавить product, business, architecture и codebase без дублирования владельцев знаний.

Deliverable: новые canonical templates, indexes, graph routes и обновленный root navigation.

Сделано, когда: AC-03 и AC-04 проходят focused tests.

- [x] Создать новые домены и canon frontmatter.
- [x] Свести RAW к `inbox/raw/`.
- [x] Обновить candidate domains и knowledge graph.
- [x] Перенести универсальные analysis protections и удалить formal analysis.

## Фаза P3 - [x] Mastery v2

Цель: дать быстрый, проверяемый и расширяемый путь создания Local Mastery.

Deliverable: intent catalog, новый method contract, derived index, preview/promotion generator и fixtures.

Сделано, когда: AC-05 проходит focused и negative tests.

- [x] Добавить `mastery/INTENTS.json` и общий template.
- [x] Обновить method candidate schema и evidence rules.
- [x] Реализовать `update-mastery-index.ps1` и `new-mastery.ps1`.
- [x] Обновить retrieval route и prompt интервью.

## Фаза P4 - [x] Cross-platform distribution

Цель: сохранить trust boundary на Windows и macOS.

Deliverable: portable process/path/lock helpers, platform fixtures и source-only CI matrix.

Сделано, когда: AC-06, AC-07 и AC-08 проходят доступные локальные gates, а macOS workflow готов к source push.

- [x] Устранить `NUL`, `Local\\`, Windows-only executable leaves и path separators.
- [x] Добавить input control-character и length gates.
- [x] Прогнать local/bootstrap/distribution fixtures.
- [x] Добавить `.github/workflows/template-integrity.yml` только в source.

## Фаза P5 - [x] Документация и release closeout

Цель: передать пользователю понятный consumer template и доказанный pre-push state.

Deliverable: README, prompts, AGENTS, manifest 2.0.0, ADR, changelog, retrospective и gate report.

Сделано, когда: AC-09 и AC-10 выполнены, все доступные gates зеленые.

- [x] Переписать README и installation prompt.
- [x] Обновить manifest/version/baseline hashes и source-only paths.
- [x] Выполнить AST, diff, structure, knowledge, privacy, distribution и fresh-copy gates.
- [x] Провести соло correctness/security review и knowledge closeout.

## Проверки

- Pre-task HEAD: `96f6c11d0b3b2e00147889619ba689c10042e287`.
- Pre-task branch: `source`, worktree и index чистые, untracked files отсутствуют.
- Baseline: `pwsh -NoProfile -File ./scripts/verify-structure.ps1 -Mode TemplateSource` - PASS до начала задачи.
- Plan v2 focused fixtures: `pwsh -NoProfile -File ./scripts/test-plan-lifecycle.ps1` - PASS.
- P2 canon contract: `pwsh -NoProfile -File ./scripts/verify-canon.ps1 -Report` - PASS, 12 base canon files.
- P2 canon/graph fixtures: `pwsh -NoProfile -File ./scripts/test-canon-graph.ps1` - PASS.
- P2 consumer boundary: `pwsh -NoProfile -File ./scripts/test-v2-consumer-boundary.ps1` - PASS, 112 portable files, formal-analysis absent, DistributionTemplate green.
- P2 knowledge safety: `pwsh -NoProfile -File ./scripts/verify-knowledge.ps1 -SelfTest` - PASS.
- P2 integration: `pwsh -NoProfile -File ./scripts/verify-structure.ps1 -Mode TemplateSource` - PASS after formal-analysis removal.
- P3 focused lifecycle: `pwsh -NoProfile -File ./scripts/test-mastery-v2.ps1` - PASS, preview/no-mutation, authority, apply, data-driven intents, stale index and SHA-exact rollback.
- P3 semantic regression: `pwsh -NoProfile -File ./scripts/verify-knowledge.ps1 -SelfTest` - PASS.
- P3 extended Mastery regression: `pwsh -NoProfile -File ./scripts/test-knowledge-mastery.ps1` - PASS, 24/24 cases.
- P3 source integration: `pwsh -NoProfile -File ./scripts/verify-structure.ps1 -Mode TemplateSource` - PASS, 113 canonical Markdown files.
- P3 consumer boundary: `pwsh -NoProfile -File ./scripts/test-v2-consumer-boundary.ps1` - PASS, 116 portable files and formal-analysis absent.
- P4 platform primitives: `pwsh -NoProfile -File ./scripts/test-platform.ps1` - PASS, filesystem case semantics, symlink/reparse, null device, `pwsh`/`git`, ArgumentList, Git environment, input controls and lock contention.
- P4 semantic regression: `pwsh -NoProfile -File ./scripts/verify-knowledge.ps1 -SelfTest` - PASS after candidate and verifier process/path refactor.
- P4 bootstrap integration: `pwsh -NoProfile -File ./scripts/test-cross-platform-bootstrap.ps1` - PASS, local copy, GitHub Template initialization, default role owner and invalid-input no-mutation.
- P4 privacy regression: `pwsh -NoProfile -File ./scripts/test-knowledge-privacy.ps1` - PASS, 37 bounded public-CLI checks.
- P4 focused regression: `test-plan-lifecycle`, `test-canon-graph`, `test-mastery-v2`, `test-v2-consumer-boundary` - PASS; portable files: 117.
- P4 source CI: `.github/workflows/template-integrity.yml` содержит `windows-latest` и `macos-latest`; macOS runner локально не исполнялся.
- P5 documentation: README начинается с Codex install prompt, содержит ручной Windows/macOS setup, заполнение owners, plans, codebase, Mastery, skills и opt-in MCP/plugins.
- P5 source release: superseding ADR, changelog 2.0.0, source-only retrospective и local pre-push report созданы; `v1.6.2` разрешается в `c8639f22f0517ca7b6dbba5d96b1ff3ef5c8e326`.
- P5 distribution: `test-github-template-distribution.ps1` - PASS, 14/14; real tagged build, commit/clone и GitHub-style initialization.
- P5 extended regressions: control-plane A01-A23, research A43-A54, artifacts 15/15, Mastery 24/24 и privacy 37/37 - PASS по полным и focused прогонам.
- P5 final gates: PowerShell AST PASS; `git diff --check` PASS; knowledge report 0 candidates/conflicts/drift; canon 12/12; TemplateSource PASS, 115 canonical Markdown files.

## Связанные решения

- [Codex-first template v2](../docs/decisions/2026-08-20-codex-first-template-v2.md).
- [Knowledge control plane](../docs/decisions/2026-07-29-knowledge-control-plane.md).
- [Generated payload boundary](../docs/decisions/2026-08-01-generated-payload-boundary.md).
- [GitHub Template distribution](../docs/decisions/2026-08-17-github-template-distribution.md).

## Resume checkpoint

- Текущая фаза: нет - план завершен
- Уже выполнено: P1-P5 deliverables завершены: v2 consumer, Plan, canon, Mastery, cross-platform distribution, README, ADR, changelog, retrospective и closeout.
- Последние успешные проверки: AST and diff-check PASS; TemplateSource PASS 115; canon 12/12; consumer 117; privacy 37/37; distribution 14/14; knowledge SelfTest PASS; control-plane A01-A23; research A43-A54; Mastery v2 and 24/24 PASS.
- Точные рабочие paths: README.md; CODEX-INSTALL-PROMPT.md; TEMPLATE.md; TEMPLATE-CHANGELOG.md; .template-manifest.json; .github/workflows/template-integrity.yml; docs/decisions/2026-08-20-codex-first-template-v2.md; retrospectives/2026-08-20_14-01_codex-first-template-v2.md; scripts/; mastery/; plans/.
- Git checkpoint: v1:cdddf52583ade27ef3bf0432376699a4b16b98d528190e587b840a77636fb07d
- Следующее действие: нет - plan terminal; follow-up требует новый plan_id
- Блокеры: нет
- Обновлено: 2026-08-20T10:04:38Z

## Итог

- Реализовано целиком: да, фазы P1-P5 завершены.
- Consumer v2 содержит 117 portable-файлов и не содержит formal-analysis payload.
- Local pre-push state: Windows gates зеленые; macOS workflow подготовлен, но удаленный runner еще не запускался.
- Knowledge closeout: `none` - durable delta уже выражена в ADR, contracts, scripts и tests, а template mode запрещает candidate creation.
- Коммиты: не создавались.
- Tag и push: не выполнялись.
