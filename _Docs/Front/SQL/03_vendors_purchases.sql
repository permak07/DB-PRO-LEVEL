-- Анализ взаимоотношений с поставщиками: объёмы закупок по месяцам.
-- История закупок у поставщика хранится в bm_StorageOperations.VendorID
-- (ссылка на vendors.id), шаг анализа - месяц (колонка Period).
SELECT TOP 20
    so.Period                                                      AS Месяц,
    v.clientid                                                     AS Поставщик,
    COUNT(*)                                                       AS Поставок,
    SUM(so.Amount)                                                 AS Сумма
FROM dbo.bm_StorageOperations so
JOIN dbo.vendors v ON v.id = so.VendorID
WHERE so.OperationID = 1
GROUP BY so.Period, v.clientid
ORDER BY so.Period DESC, Сумма DESC;
