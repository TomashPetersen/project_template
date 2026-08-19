---
artifact_kind: retrospective
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

# Ретроспектива: hardening knowledge control plane 1.2.1

## Задача и связи

Локально завершить [план hardening](../plans/2026-07-31-knowledge-control-plane-hardening.md), не меняя [принятое архитектурное решение](../docs/decisions/2026-07-29-knowledge-control-plane.md), product data или внешнюю общую базу.

## Что сделано

- Ужесточены repository modes, activation, Git baseline, authority, candidate, RAW, research, cross-artifact и mastery contracts.
- Generator получил cooperative mutex, повторную exact deduplication и fail-closed preflight без partial artifacts.
- Git subprocess изолирован от управляющих `GIT_*`, system/global config и неподтвержденного linked worktree; HEAD blob и tree читаются с лимитами.
- Initializer и new-project получили trusted host resolution, rollback и безопасные публичные failure codes.
- Local mastery включен в retrieval route, а replacement graph проверяется как newer-to-older.
- Public verifier и structural chain используют единый UTF-8 output contract.

## Что проверено и какими командами

| Gate | Итог |
|---|---|
| A74 direct и nested UTF-8 fixtures | PASS, оба blocking diagnostics читаемы, exit 1 |
| AST всех `scripts/**/*.ps1` и `scripts/**/*.psm1` | PASS, 12 файлов |
| `scripts/verify-knowledge.ps1` и `-Report` | PASS, exit 0, report counters 0 |
| `scripts/verify-structure.ps1 -Mode TemplateSource` и `Auto` | PASS, 68 Markdown |
| Fresh copy через `scripts/new-project.ps1` | PASS |
| Fresh `GeneratedProject` и `Auto` | PASS, 64 Markdown |
| Manifest, empty zones, mastery hashes, Git | PASS, 77 файлов, 0 commits, 0 staged |
| Repeat initializer | PASS, exit 1, `initialization-rejected`, post-state unchanged |
| `git diff --check` | PASS |
| Privacy/RAW matrix | REUSED PASS, 37 bounded checks |
| A21, A23 и A53 | REUSED PASS |

## Что не получилось или осталось

По прямой команде ускорить release полные semantics A19-A30 и artifacts A55-A64 не повторялись на финальном snapshot. Это осознанный остаточный test-coverage risk. Текущая интеграция доказана source strict gates и одной fresh copy, но финал не выдает пропущенные матрицы за запущенные.

Остаточные semantic limitations сохраняются: scanner является denylist, `authority_ref` не доказывает consent, verifier не определяет semantic owner или semantic duplicate, а cooperative mutex не защищает от hostile same-user writer.

## Как было и как стало

До hardening отдельные contracts могли давать false-green на activation, lifecycle, privacy, linked Git state и concurrent candidate creation. Теперь известные детерминированные нарушения блокируются публичными entrypoints, failed write не оставляет partial artifacts, а generated copy проверяется до публикации.

## Что выучено

- Проверка Git history безопасна только при явной привязке к доверенному git-dir/worktree, очищенном environment и bounded output.
- Output encoding является частью публичного CLI contract, если tests проверяют точную локализованную диагностику.
- Текущий capture mode регулирует новую запись, но не переписывает provenance исторического artifact.
- Supersession graph должен иметь одно направление: replacement ссылается на заменяемый метод, а заменяемый имеет `superseded`.

## Security review

- Персональные данные: synthetic privacy fixtures блокируются; реальные персональные данные не сохранялись.
- Контент третьих лиц: внешние документы и RAW не копировались.
- Внешние отправки: отсутствовали; общая база использовалась только read-only.
- Секреты: реальные secrets не читались и не выводились; diagnostics редактируют проверяемые пути и значения.
- Destructive operations: разрешена только проверяемая очистка точных временных fixture roots после release gate.

## Independent review

Security review выявил и закрыл inherited Git environment, forged worktree marker, unbounded HEAD reads, weak host resolution и partial initializer state. Fixture-oracle review усилил exact diagnostics и post-state checks. Последний UTF-8 transport finding закрыт отдельными direct и nested A74 fixtures.

## Knowledge closeout

Итог `existing`: устойчивые решения уже зафиксированы в accepted ADR, knowledge policy, local mastery contract и scripts documentation. Новый central candidate не создавался, потому что он дублировал бы канон, а template находится в `disabled`.

## Финальная стабилизация 2026-08-09

Ускоренный release profile заменен полным прогоном текущего snapshot. Semantics A19-A30, artifacts A55-A64, privacy/RAW A31-A42, research A43-A54, mastery A65-A78 и control-plane A01-A23 прошли полностью. Control-plane включал два восьмипроцессных race-повтора.

Disposable generated project прошел GeneratedProject и Auto, exact inventory из 69 файлов, отсутствие `.codex` и owner overlays, чистые candidates/runs/local mastery, ветку `main`, 0 commits и 0 staged. Повторная инициализация вернула `initialization-rejected` и не изменила SHA tree; затем exact temp-root был проверенно удален.

Полный gate обнаружил и закрыл четыре остаточных finding:

- semantics harness декодировал UTF-8 output как OEM в Windows PowerShell;
- research A51 создавал пустой HEAD без обязательного `PROJECT.md` blob;
- control-plane A09 ожидал устаревший diagnostic вместо `blocked: repository-preflight`;
- bootstrap helpers временно изменяли process-wide `GIT_*` и могли потерять exit code вложенного процесса; теперь child environment изолируется через `ProcessStartInfo`, а bounded `git ls-files` имеет явный exit code и streaming limit.

После каждого исправления выполнены focused reproducer и полный затронутый harness. Остаточного test-coverage долга ускоренного профиля больше нет. Семантические ограничения control plane остаются прежними и явно документированы.
