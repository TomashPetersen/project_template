---
artifact_kind: decision
status: accepted
knowledge_outcome: existing
candidate_ids: []
affected_canon:
  - .template-manifest.json
  - AGENTS.md
  - TEMPLATE.md
  - knowledge/INDEX.md
supersedes: []
blocked_reason: null
---

# Решение: граница generated payload

## Контекст и владелец

Исходный шаблон одновременно содержит рабочие контракты будущего проекта и материалы, необходимые только владельцу для развития, проверки и выпуска самого шаблона. Если переносить оба слоя без различия, generated project получает историю и маршруты, которыми не может пользоваться. Если удалить рабочие контракты вместе с maintenance-слоем, копия перестает быть самодостаточной.

Владелец этого решения - template source. Решение определяет состав fresh generated project и не мигрирует существующие проекты.

## Решение

Generated payload содержит только три вида материалов:

1. runtime - скрипты и проверки, которые исполняются в жизненном цикле конкретного проекта;
2. workflow - инструкции, templates и project-local skills, по которым ведется работа;
3. canon - паспорт, предметные зоны, project-local решения и знания этого проекта.

Research, mastery и knowledge control plane остаются portable. Они обеспечивают доказательный research, knowledge closeout и проверяемую маршрутизацию внутри каждого проекта.

Source maintenance остается source-only. К нему относятся `TEMPLATE.md`, `TEMPLATE-CHANGELOG.md`, решения об устройстве template source, release plans, release retrospectives, regression harnesses и bootstrap entrypoint, который создает новую копию. Конкретный allowlist portable и source-only путей определяет `.template-manifest.json`.

Fresh generated project получает пустые project-owned зоны и `TEMPLATE-ORIGIN.md` с версией происхождения. Он не получает template-owner ADR или maintenance history. Навигация generated project не должна ссылаться на source-only материалы.

Единственный источник версии шаблона - поле `template_version` в `.template-manifest.json`. Дополнительные файлы-зеркала версии не используются.

## Рассмотренные альтернативы

1. Копировать весь source tree - отклонено: в проект попадают Git и maintenance-контекст другого владельца, а навигация смешивает два жизненных цикла.
2. Удалить research, mastery или knowledge из стандартной копии - отклонено: это рабочие возможности generated project, а не служебная история шаблона.
3. Поддерживать отдельный файл-зеркало версии - отклонено: второй источник требует синхронного обновления и допускает дрейф без дополнительной ценности.

## Последствия и риски

- Изменение границы требует согласованного обновления manifest, навигации и verifier expectations.
- Source-only документы остаются доступны владельцу шаблона, но не должны быть целями ссылок из portable Markdown.
- Старые generated projects не перестраиваются и не очищаются автоматически.
- Ошибка allowlist может удалить нужный runtime или вернуть maintenance-файл в копию, поэтому fresh inventory проверяется относительно manifest.

## Проверка

- `verify-structure.ps1` в режиме TemplateSource проверяет manifest, запрет ссылок portable -> source-only и два корня достижимости: `INDEX.md` для portable canon и `TEMPLATE.md` для статического source maintenance.
- Публичный `new-project.ps1` создает fresh copy, после чего GeneratedProject и Auto должны пройти.
- Fresh inventory точно совпадает с portable allowlist и generated artifacts.
- В fresh copy отсутствуют source maintenance, owner overlays, заполненные dynamic zones и Git commits.

## Откат или замена

Откат выполняется поименным возвратом путей в portable allowlist и восстановлением их переносимой навигации. Автоматическая миграция уже созданных проектов не выполняется.

## Связи

- Контракт исходного шаблона: [`../../TEMPLATE.md`](../../TEMPLATE.md)
- Knowledge control plane: [`2026-07-29-knowledge-control-plane.md`](2026-07-29-knowledge-control-plane.md)
- Knowledge policy: [`../../knowledge/INDEX.md`](../../knowledge/INDEX.md)
