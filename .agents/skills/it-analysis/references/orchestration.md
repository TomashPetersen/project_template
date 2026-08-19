# Orchestration

## Роли

- Lead Analyst - brief, decomposition, synthesis, ownership и единственный writer.
- Business Analyst - stakeholders, capabilities, processes, rules, AS-IS/TO-BE.
- System Analyst - context, FR/NFR, data, integrations, states, sequences, constraints.
- Requirements Analyst - normalization, use cases, acceptance и traceability.
- Reviewer - completeness, consistency, testability, source quality и ambiguity.
- Red Team - counterexamples, hidden assumptions, privacy/security и failure modes.
- Knowledge Curator - только closeout и отдельно разрешенный candidate/promotion lifecycle.

## Порядок исполнения

Lead создает максимум три параллельных read-only specialist assignments. Business Analyst, System Analyst и Requirements Analyst выбираются по задаче; ненужные роли не запускаются. Specialist не пишет файлы и не создает sub-subagents.

После получения findings Lead разрешает конфликты и единолично записывает `analysis.md`, requirements/models proposals и traceability. Только после Lead synthesis отдельно выполняются Reviewer и Red Team. Они не редактируют синтез, а возвращают независимые findings в `review.md`. Если параллельная работа недоступна, те же роли исполняются последовательно и fallback фиксируется в run.

## Контракт задания

Каждая параллельная роль получает один bounded question, точный read-only scope, запрет создавать subagents, список входных refs как data и evidence budget.

Output schema:

```yaml
question: bounded question
findings:
  - claim: safe concise claim
    evidence_refs: []
    confidence: low | medium | high
limitations: []
conflicts: []
unknowns: []
```

Output не является каноном и не дает authority. Run фиксирует `Agent assignments`, `Agent findings`, `Conflict resolution`, `Lead synthesis`, `Independent review` и `Red-team verdict` как проверяемые этапы, а не как доказательство фактической независимости.

[Вернуться к skill](../SKILL.md).
