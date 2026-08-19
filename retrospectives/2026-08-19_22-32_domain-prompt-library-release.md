---
artifact_kind: retrospective
knowledge_outcome: none
candidate_ids: []
affected_canon:
  - .gitattributes
  - .template-manifest.json
  - INDEX.md
  - LICENSE
  - PROJECT.md
  - README.md
  - scripts/test-github-template-distribution.ps1
  - scripts/verify-analysis.ps1
  - scripts/verify-structure.ps1
  - TEMPLATE-DISTRIBUTION.json
  - TEMPLATE-CHANGELOG.md
  - TEMPLATE.md
  - prompts/README.md
blocked_reason: null
---

# Ретроспектива: доменная библиотека промтов

## Задача и связи

Владелец попросил дополнить onboarding короткими интервью и prompts для заполнения значимых папок, затем выпустить шаблон в GitHub.

- [План](../plans/2026-08-19-domain-prompt-library-release.md)
- [Контракт GitHub distribution](../docs/decisions/2026-08-17-github-template-distribution.md)

## Что сделано

- Добавлен переносимый индекс и восемь доменных prompts для AI Clone, паспорта, идеи, business, research, analysis, delivery и knowledge/mastery.
- README связывает быстрый маршрут с отдельными файлами, не копируя внутрь весь доменный contract.
- AI Clone и business используют короткое поэтапное интервью с подтверждением резюме.
- Manifest, descriptor placeholder, template contract и changelog обновлены до `1.6.2`.

## Что проверено и какими командами

- `verify-knowledge.ps1` - semantic gate прошел.
- `verify-structure.ps1 -Mode TemplateSource` - 146 канонических Markdown-файлов.
- `test-github-template-distribution.ps1` - `14/14`, включая настоящий commit/clone.
- `verify-analysis.ps1 -SelfTest` - `54/54` после разрешения `.gitkeep` marker.
- Focused privacy review - 9 файлов, 226 строк, PII/secret/path findings `0`.
- Manifest review - все 9 prompt-файлов входят в portable allowlist.
- `git diff --check` - замечаний нет.
- `git push --dry-run origin source` - GitHub authentication и target подтверждены без изменения remote.
- Actual `v1.6.2` consumer - 141 файл, 140 descriptor hashes, 9 prompt-файлов, mismatches `0`.
- Fresh clone - `DistributionTemplate` PASS, markers сохранены, clean worktree и единственный нейтральный author.
- Atomic push - опубликованы только `main`, `source`, `v1.6.2`; remote `HEAD` указывает на `main`.

## Что не получилось или осталось

Pre-release review обнаружил, что Git не переносит объявленные пустые run-каталоги, а `eol=crlf` меняет SHA-256 семи portable `.ps1` после checkout. Дополнительный full-tree privacy review нашел личное имя в `LICENSE` и персональные author metadata в локальной Git-истории. Проблемы исправлены в `v1.6.2`: run roots получили markers, text payload переведен на LF, лицензия обезличена, а public refs собраны из чистой истории. Локальные tags `v1.6.0` и `v1.6.1` не опубликованы.

## Как было и как стало

Раньше README содержал несколько общих примеров, но для заполнения разных зон требовалось самостоятельно формулировать границы задачи. Теперь README ведет к короткому доменному prompt с вопросами, target paths, stop conditions и критерием готовности.

## Что выучено

Prompt library полезнее как portable navigation layer, а не как второй policy: правила остаются в `AGENTS.md`, domain indexes и skills, а prompts только запускают правильный маршрут.

Локальная directory-copy проверка не доказывает GitHub delivery для пустых каталогов. Release harness обязан включать настоящий commit/clone roundtrip.

## Security review

- Персональные данные: prompts не содержат данных владельца и запрещают лишний сбор PII; личное имя удалено из `LICENSE`, локальная персонализированная Git-история исключена из public refs.
- Контент третьих лиц: новый сторонний контент не добавлен.
- Внешние отправки: выполнен разрешенный atomic push только refs `main`, `source`, `v1.6.2` в явно указанный repository; remote refs и default branch проверены после публикации.
- Секреты: credentials не читались и не сохранялись; Git authentication делегирована настроенному credential helper.

## Итог публикации

- Public source/tag commit: `c8639f22f0517ca7b6dbba5d96b1ff3ef5c8e326`.
- Public consumer `main` commit: `31927e05f5f94442c3ddf3eeeda26f4642a411fa`.
- Knowledge closeout: `none` - durable changes уже выражены в source contract, prompts, tests и changelog; template mode запрещает automatic candidate.
