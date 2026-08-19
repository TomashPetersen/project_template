# Скрипты шаблона

- `initialize-project.ps1` - создает `generated-project + initialized + report-only`, UUID и `TEMPLATE-ORIGIN.md`; `-InitializeGit` создает независимый Git для локальной копии, `-FromGitHubTemplate` сохраняет существующий Git и remote. Оба пути имеют rollback и не выполняют stage, commit или push.
- [`lib/ModelProject.Knowledge.psm1`](lib/ModelProject.Knowledge.psm1) - portable модуль чистых parser/safety primitives и общего эвристического privacy scanner; entrypoints загружают его только по фиксированному пути относительно доверенного `$PSScriptRoot`, никогда из проверяемого `-Root`, а уникальные business rules остаются в scripts.
- `new-knowledge-candidate.ps1` - после полной валидации атомарно создает один `ready` candidate только в `active + safe-local`.
- `new-analysis-run.ps1` - в initialized/active generated project атомарно создает exact eight-file analysis run из trusted assets.
- `verify-analysis.ps1` - проверяет working runs, canonical analytical artifacts, authority, provenance, refs и traceability; поддерживает `-Report` и `-SelfTest`.
- `verify-knowledge.ps1` - проверяет project modes, candidates, RAW, evidence, mastery и root reachability; поддерживает `-Report` и `-SelfTest`.
- `update-knowledge-graph.ps1` - детерминированно строит или проверяет tracked `knowledge/graph/INDEX.md`; поддерживает `-Mode Check | Write | Report | SelfTest`.
- `verify-structure.ps1` - проверяет manifest, reserved roots, Markdown-ссылки, anchors, регистр и пути, затем вызывает trusted knowledge-graph, analysis и knowledge gates.

Source-only `build-github-template.ps1` строит consumer payload из exact clean source tag/commit, сверяет declared repository с GitHub identity `origin`, требует обычный tracked index state всех manifest-файлов, заполняет `TEMPLATE-DISTRIBUTION.json` и проверяет `DistributionTemplate`. Source-only `test-github-template-distribution.ps1` воспроизводит happy path и negative trust fixtures во временных Git repositories. Оба скрипта не входят в generated project.

## Portable manifest

`.template-manifest.json` является единственным источником:

- переносимых файлов и пустых каталогов;
- Git-tracked `.gitkeep` markers для пустых корней `analysis/runs` и `research/runs`, чтобы они сохранялись после настоящего clone;
- source-only истории шаблона;
- запрещенных generated paths;
- extension zones контролируемых деревьев;
- версии и SHA-256 Researcher Mastery baseline.

До и после копирования проверяются exact inventory, traversal, case и reparse points. UNC, device и сетевые destinations запрещены. При ошибке final destination не появляется, а удаляется только проверенный GUID-staging без перехода по reparse points. `.git` source, `.codex`, owner overlays, source-maintenance artifacts, заполненные runs и candidates не копируются. В generated project выбранный стек может создавать `src/`, `tests/`, `package.json` и другие пути вне template-controlled roots.

## Режимы проверки

```powershell
.\scripts\verify-structure.ps1 -Mode TemplateSource
.\scripts\verify-structure.ps1 -Mode DistributionTemplate
.\scripts\verify-structure.ps1 -Mode GeneratedProject
.\scripts\verify-structure.ps1 -Mode Auto
```

- `TemplateSource` требует placeholders и статус `template`, проверяет portable Markdown-граф от `INDEX.md`, статический source-maintenance граф от `TEMPLATE.md`, пустой `research/runs/` и точные project-local mastery/skill. Historical plans и retrospectives не требуют root reachability. Посторонний незатреканный overlay `.agents` и `.codex` владельца не анализируется, но Git не должен отслеживать запрещенные overlay-пути.
- `DistributionTemplate` требует производный `distribution-template + template + disabled`, exact descriptor и pre-init payload hashes. Semantic project gates выполняются после инициализации, когда repository становится generated.
- `GeneratedProject` принимает `initialized`, `active` или `archived` только с согласованным capture mode, запрещает `.codex`, все source-only пути и защищает contract roots.
- `Auto` выбирает режим по `repository_kind`.

Параметр `-Root` всегда считается данными. Structural verifier вызывает semantic verifier только рядом с собственным доверенным `$PSScriptRoot` и не запускает Git внутри произвольного внешнего root. Внешние `git` и PowerShell host разрешаются как точные application-файлы вне контролируемого root и без reparse chain. Git subprocess не наследует управляющие `GIT_*`, не читает system/global config, ограничивает вывод, а linked worktree принимается только с обратной ссылкой административного `gitdir` на текущий `.git` marker. Markdown URI, frontmatter и evidence проверяются до использования; опасные схемы, credential-bearing URLs, reparse points и превышение файловых лимитов блокируются.

Bootstrap и structural child processes запускаются через отдельный `ProcessStartInfo`: `GIT_*` очищаются только в окружении ребенка, exit code берется из process object, а PowerShell output декодируется как UTF-8. Bounded `git ls-files` читает stdout построчно и останавливается при лимите tracked paths.

Semantic commands:

```powershell
.\scripts\verify-knowledge.ps1
.\scripts\verify-knowledge.ps1 -Report
.\scripts\verify-knowledge.ps1 -SelfTest
.\scripts\verify-analysis.ps1
.\scripts\verify-analysis.ps1 -Report
.\scripts\verify-analysis.ps1 -SelfTest
.\scripts\update-knowledge-graph.ps1 -Mode Check
.\scripts\update-knowledge-graph.ps1 -Mode Write
.\scripts\update-knowledge-graph.ps1 -Mode Report
.\scripts\update-knowledge-graph.ps1 -Mode SelfTest
```

Чистота `research/runs/`, `analysis/runs/` и `knowledge/candidates/` обязательна непосредственно после `new-project.ps1`. Позднее generated project допускает валидные динамические записи, которые не требуют ручного реестра.

Скрипты не используют сеть и не читают `.env`.
