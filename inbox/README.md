# Inbox проекта

Временная приемная для RAW, когда пользователь еще не указал домен или материал пересекает несколько зон.

- [`raw/README.md`](raw/README.md) - прием и активные записи.
- [`raw/TEMPLATE.md`](raw/TEMPLATE.md) - формат RAW.

Если материал явно относится к бизнесу этого проекта, сразу используй [`../business/raw/README.md`](../business/raw/README.md). Не хранить одну запись в двух приемных.

## Поток

`прямая просьба сохранить -> RAW -> классификация и provenance -> candidate.source_refs -> разрешенное продвижение -> canonical target + backlink`.

Inbox не является источником подтвержденных фактов.

Новый RAW физически не перемещается после обработки. Его payload после capture неизменяем; менять разрешено только lifecycle frontmatter. Candidate state, target и knowledge outcome в RAW не дублируются.
