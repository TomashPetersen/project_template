# Knowledge closeout и Local Mastery

Используй после изменения репозитория или для проверки повторяемого project-local метода.

## Готовый prompt

```text
Используй $knowledge-curator. Сопоставь текущий Git state с pre-task snapshot,
включая staged, unstaged, untracked, deleted и renamed paths. Проверь repository
mode, owner, authority, существующий канон и candidates. Выполни durable-delta
gate и верни один outcome: none, existing, ready:<ID>, applied:<ID> или blocked.

Не создавай candidate из очевидного содержимого diff, временного состояния,
секретов или PII. Повторяемый Local Mastery method предлагай только при достаточном
learning evidence или прямой коррекции владельца. Не применяй candidate и не
меняй mastery/local без отдельного одобрения. Запусти требуемые graph, knowledge
и structure gates. Не выполняй commit или push.
```

## Готово, когда

Knowledge outcome объясним, проверяем и не создает скрытого канона или автоматического promotion.
