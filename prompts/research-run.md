# Доказательный Research run

Используй для нового evidence, которое нельзя надежно получить из текущего канона.

## Готовый prompt

```text
Используй $startup-researcher. Прочитай AGENTS.md, PROJECT.md, research/INDEX.md,
idea/INDEX.md и релевантный предметный канон. Создай bounded research run по
вопросу <ВОПРОС>. До поиска зафиксируй критерии решения, scope, временной срез,
baseline methods и стоп-условия. Собирай независимые первичные источники,
отделяй evidence от inference и выполни red-team.

Сохрани полный обязательный набор run-файлов и итоговое decision. Не меняй idea/
или business/ автоматически. Если есть durable delta, предложи central candidate
по knowledge contract, но не выполняй promotion. Не выполняй commit или push.
```

## Готово, когда

Decision отвечает на исходный вопрос, содержит ограничения evidence и дает следующий проверяемый шаг.
