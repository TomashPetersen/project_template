---
artifact_kind: decision
status: accepted
knowledge_outcome: existing
candidate_ids: []
affected_canon:
  - .gitignore
  - .template-manifest.json
  - AGENTS.md
  - PROJECT.md
  - README.md
  - TEMPLATE.md
  - scripts/initialize-project.ps1
  - scripts/verify-knowledge.ps1
  - scripts/verify-structure.ps1
supersedes: []
blocked_reason: null
---

# Решение: распространение через GitHub Template

## Контекст и владелец

Владелец шаблона хочет разворачивать его в новых проектах и передавать знакомым. Локальный source template уже имеет безопасный allowlist copy, но не дает удобного GitHub onboarding и не отделяет release-maintenance history от default consumer branch.

## Решение

- Каноническая ветка называется `source`; default-ветка `main` содержит только производный consumer payload.
- Consumer payload строится source-only скриптом из exact SemVer tag и соответствующего commit, а не редактируется вручную.
- GitHub Template UI используется только для создания нового независимого репозитория. `Include all branches` запрещен.
- Новый репозиторий клонируется, затем один раз инициализируется через `initialize-project.ps1 -FromGitHubTemplate`.
- Pre-init consumer имеет режим `distribution-template + template + disabled`; после setup он становится `generated-project + initialized + report-only`.
- `TEMPLATE-DISTRIBUTION.json` фиксирует source tag, commit, template repository, build timestamp и SHA-256 pre-init payload. Он сохраняется после setup.
- `TEMPLATE-ORIGIN.md` связывает descriptor digest и уникальный project ID.
- GitHub Template commit не является knowledge baseline. Для `safe-local` HEAD должен уже содержать тот же generated project ID и тот же origin.
- Generic `ai-clone` включается как пустой project-local scaffold. Персональные данные владельца исходного шаблона не включаются.
- Три project-local skills включаются в payload. MCP, plugins, hooks, automations, `.codex` и global skills не встраиваются.
- MIT лицензирует template materials. После setup она сохраняется как `TEMPLATE-LICENSE.md`; лицензия продукта выбирается отдельно.

## Рассмотренные альтернативы

- Один branch с source history отклонен, потому что default GitHub Template payload будет содержать release plans, retrospectives и source-only bootstrap.
- GitHub release archive как основной onboarding отклонен из-за более сложного UX и отсутствия независимого repository creation flow.
- Copier/Cookiecutter отклонены на первом этапе из-за дополнительной runtime-зависимости и второго template language.
- Прямой clone канонического репозитория отклонен из-за риска сохранить неправильный remote и отправить изменения в template source.
- Автоматическая установка MCP/plugins отклонена, потому что это меняет внешнее окружение и permissions получателя.

## Последствия и риски

- Source tag и consumer branch должны выпускаться как один release operation.
- `main` является derived artifact и не принимает ручные fixes. Исправление всегда начинается в `source`.
- Private GitHub Template в личном аккаунте нужно проверить внешним collaborator. Если GitHub не разрешит ожидаемый flow, rollout блокируется до отдельного решения, а не ослабляет локальные gates.
- Cross-platform, network drives и автоматическая миграция старых projects пока не поддерживаются.

## Проверка

Builder обязан блокировать dirty или tag-mismatched source, валидировать source и distribution payload и оставлять destination только после зеленого gate. Initializer обязан негативно проверить source refs, canonical remote, dirty repository, повторный setup и descriptor drift. Fresh local и GitHub-style copies должны пройти `GeneratedProject` gate.

## Откат или замена

Удалить consumer builder и distribution mode, вернуть единственный локальный `new-project.ps1`, не меняя generated projects. Уже созданные repositories остаются самостоятельными и не откатываются автоматически.

## Связи

- План: [распространение через GitHub Template](../../plans/2026-08-17-github-template-distribution.md).
- Предметный документ: [контракт шаблона](../../TEMPLATE.md).
- Обратные ссылки на примененные candidates: нет, решение принято прямой командой пользователя и зафиксировано этим ADR.
