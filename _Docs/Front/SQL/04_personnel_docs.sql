-- Анализ работы персонала: проверка связи "документ -> сотрудник".
-- bm_JournalBarnetDocs.PersonID = personnel.personid (кто оформил документ),
-- JournalID -> bm_JournalType (журнал документа).
SELECT TOP 10
    p.personid                                                     AS ТабНомер,
    p.lastname + ' ' + p.firstname                                 AS Сотрудник,
    d.ID                                                           AS Документ,
    jt.JournalName                                                 AS Журнал,
    CONVERT(varchar(19), d.Period, 120)                            AS Период,
    d.Amount                                                       AS Сумма
FROM dbo.bm_JournalBarnetDocs d
JOIN dbo.personnel       p  ON p.personid = d.PersonID
LEFT JOIN dbo.bm_JournalType jt ON jt.ID   = d.JournalID
ORDER BY d.ID DESC;
