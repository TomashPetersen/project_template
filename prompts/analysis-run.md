# Business или System analysis run

Используй для требований, процессов, моделей, интеграций, API-контрактов, NFR и change impact.

## Готовый prompt

```text
Используй $it-analysis. Прочитай AGENTS.md, PROJECT.md, analysis/INDEX.md,
analysis/CONTRACT.md и нужный предметный канон. Создай bounded analysis run для
<ЗАДАЧА_ИЛИ_ФУНКЦИЯ>. Зафиксируй scope, stakeholders, assumptions, source refs и
acceptance criteria. Подготовь необходимые процессы, требования, модели, NFR и
traceability, затем выполни независимый review и red-team по контракту skill.

Рабочие выводы оставь в analysis/runs/. Не выдавай их за принятое решение и не
обновляй business/analysis или docs/analysis без моего отдельного разрешения на
canonical handoff. Не выполняй commit или push.
```

## Готово, когда

Каждое значимое требование связано с источником, моделью или критерием приемки, а нерешенные конфликты видимы.
