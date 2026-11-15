-- Анализ закупки продукции: проверка цепочки связей.
-- Документ закупки (bm_JournalBarnetDocs) -> складская операция
-- (bm_StorageOperations) -> товар (product) -> поставщик (vendors) -> склад (storages).
-- Если запрос возвращает строки, значит связи между таблицами корректны.
SELECT TOP 10
    d.ID                                                           AS Документ,
    t.Description                                                  AS ТипОперации,
    p.description                                                  AS Товар,
    v.clientid                                                     AS Поставщик,
    s.description                                                  AS Склад,
    so.Count                                                       AS Количество,
    so.Amount                                                      AS Сумма,
    so.Period                                                      AS Месяц
FROM dbo.bm_StorageOperations so
JOIN dbo.bm_JournalBarnetDocs   d  ON d.ID    = so.DocumentID
JOIN dbo.bm_StorageOperationsType t ON t.ID   = so.OperationID
JOIN dbo.product                p  ON p.id    = so.ProductID
JOIN dbo.vendors                v  ON v.id    = so.VendorID
JOIN dbo.storages               s  ON s.id    = so.StorageID
WHERE so.OperationID = 1
ORDER BY so.ID DESC;
