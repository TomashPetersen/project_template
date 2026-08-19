---
artifact_kind: plan
status: complete
knowledge_outcome: existing
candidate_ids: []
affected_canon:
  - .template-manifest.json
  - AGENTS.md
  - INDEX.md
  - PROJECT.md
  - TEMPLATE.md
  - docs/decisions/2026-08-01-generated-payload-boundary.md
  - knowledge/INDEX.md
blocked_reason: null
---

# План: консистентность и эффективность модельного шаблона

## Цель

Сделать fresh generated project внутренне согласованным: переносить только полезные ему runtime, workflow и canonical artifacts, иметь один источник версии и не показывать мертвые маршруты сопровождения исходного шаблона. Полноценные research, mastery, knowledge и regression-test контракты сохранить.

## Границы

Входит:

- разделение template-source, bootstrap и generated responsibilities без нового универсального профиля;
- удаление только доказанно мертвых fresh-project маршрутов и пустых legacy-заглушек;
- устранение зеркала версии и дрейфующих повторов нормативных правил;
- обновление manifest, навигации, verifier expectations и release-документов;
- fresh-copy проверка публичного `new-project.ps1`.

Не входит:

- удаление или optionalization research, mastery, knowledge control plane;
- объединение предметных `idea/` и `business/` файлов ради размера;
- удаление независимых source-only harnesses;
- выделение встроенного `verify-knowledge -SelfTest` в отдельный runner;
- stage, commit, push, deploy или изменение owner overlays.

## Критерии приемки

1. `.template-manifest.json` остается единственным источником template version; `.template-version` отсутствует и не имеет внутренних потребителей.
2. Fresh generated project не содержит `scripts/new-project.ps1`, `TEMPLATE.md`, `TEMPLATE-CHANGELOG.md` и template-owner ADR, но содержит `TEMPLATE-ORIGIN.md` с версией происхождения.
3. Fresh project не содержит пустые legacy archive-каталоги и пустой brand-guide; backward-compatible verifier по-прежнему безопасно обрабатывает старые archive paths.
4. Project navigation использует переносимые Markdown-ссылки без локально дублирующих Wikilink-блоков.
5. Artifact и workflow README ссылаются на один canonical contract вместо копирования machine-схем и lifecycle-правил.
6. Research, mastery, knowledge generator/verifier, skills и шесть независимых source-only harnesses остаются функционально доступны в прежнем объеме.
7. TemplateSource, Auto, knowledge strict/report, PowerShell AST, `git diff --check` и fresh-copy GeneratedProject/Auto проходят.
8. Fresh copy имеет exact manifest inventory, пустые dynamic zones, ноль commits, не содержит owner overlays и безопасно отвергает повторную инициализацию.
9. Pre-existing dirty state остается unstaged; stage, commit, push и deploy не выполняются.

## Исследование и выбранный подход

Текущий portable payload функционально полный, но смешивает три владельца lifecycle: сопровождение template source, одноразовый bootstrap и работу generated project. Оптимизация по размеру привела бы к ошибочным удалениям полезных research и knowledge слоев. Выбран узкий ownership-подход:

- оставить функциональные слои и granular canonical files;
- source-maintenance artifacts объявить source-only;
- одноразовый `new-project.ps1` не переносить в созданный проект;
- manifest оставить runtime allowlist и единственным источником версии;
- повторяющийся текст заменить ссылками на canonical policy и templates;
- не выносить self-tests и не централизовать security-sensitive helpers без отдельного доказанного performance или maintenance запроса.

Отклонено:

1. Сокращать проект по числу файлов или байтам - ухудшает selective loading и полноту workflow.
2. Делать research или knowledge optional - противоречит текущему research-first и knowledge-closeout контракту.
3. Переписать bootstrap lifecycle и self-test loader в этой задаче - расширяет риск без доказанного пользовательского выигрыша.

## Риски, безопасность и откат

- Изменение portable/source-only inventory может сломать fresh copy. Проверяется public initializer и exact manifest inventory.
- Удаление version mirror может оставить скрытого потребителя. До изменения проверяются все repository refs; после изменения выполняются AST и source/fresh gates.
- Сокращение документации может удалить обязательную инструкцию. Canonical owner каждого правила фиксируется до редактирования, а независимый review проверяет reachable workflows.
- Откат выполняется поименно возвратом manifest entries, удаленных файлов и ссылок. Старые проекты не мигрируются.

## Фаза 1 - [x] Ownership и single-source contract

Цель: отделить source maintenance от generated payload и убрать зеркала.

Deliverable: согласованные manifest, version, navigation и source-only decisions.

Сделано, когда: критерии 1-4 выполняются на source tree.

Задачи:

- [x] Добавить accepted source-only ADR о generated payload boundary.
- [x] Удалить `.template-version` и внутренних потребителей.
- [x] Перевести source-maintenance documents и `new-project.ps1` в source-only.
- [x] Удалить legacy archive-заглушки, blank brand-guide и dead function.
- [x] Обновить навигацию и manifest.

## Фаза 2 - [x] Canonical documentation

Цель: уменьшить риск дрейфа повторяющихся контрактов.

Deliverable: короткие route/readme документы, ссылающиеся на canonical templates и `knowledge/INDEX.md`.

Сделано, когда: критерии 5-6 выполнены без потери обязательных workflows.

Задачи:

- [x] Сократить повтор strict frontmatter в plan, retrospective и decision README.
- [x] Сократить дубли RAW, research и curator правил только там, где canonical owner однозначен.
- [x] Сохранить уникальные safety, evidence и operational instructions.

## Фаза 3 - [x] Интеграция и проверка

Цель: доказать source и generated contracts.

Deliverable: зеленые focused, source и fresh-copy gates.

Сделано, когда: критерии 7-9 подтверждены командами и независимым review.

Задачи:

- [x] Запустить AST и focused verifier checks.
- [x] Запустить knowledge strict/report, TemplateSource и Auto.
- [x] Создать fresh copy и проверить GeneratedProject, Auto, inventory, empty zones, overlays, commits и repeated init refusal.
- [x] Выполнить independent и security review, исправить только доказанные дефекты.
- [x] Создать retrospective и выполнить knowledge closeout.

## Проверки

- PowerShell AST всех измененных `.ps1` и `.psm1`.
- `scripts/verify-knowledge.ps1` и `-Report`.
- `scripts/verify-structure.ps1 -Mode TemplateSource` и `-Mode Auto`.
- Public fresh copy через `scripts/new-project.ps1`, затем GeneratedProject и Auto.
- Exact inventory по manifest, dynamic-zone, overlay, Git и repeated-initialization oracles.
- `git diff --check`.

## Связанные решения

- Решения: [`docs/decisions/2026-07-29-knowledge-control-plane.md`](../docs/decisions/2026-07-29-knowledge-control-plane.md); [`docs/decisions/2026-08-01-generated-payload-boundary.md`](../docs/decisions/2026-08-01-generated-payload-boundary.md).

## Итог

- Реализовано целиком: да, включая findings независимого consistency и security review.
- Что осталось: автоматическая миграция старых generated projects не выполняется; полное устранение concurrent path-swap TOCTOU требует handle-based filesystem API и остается явно ограниченным residual risk.
- Коммиты: не создаются этой задачей.
