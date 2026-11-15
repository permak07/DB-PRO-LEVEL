-- Анализ закупки продукции, шаг "месяц".
-- Проверяем, что колонка Period таблицы bm_StorageOperations хранит месяц
-- в формате YYYYMM и по ней можно строить помесячный разрез закупок.
-- Учитываем только операции типа "Поступление" (OperationID = 1).
SELECT
    so.Period                                                      AS Месяц,
    COUNT(*)                                                       AS Операций,
    SUM(so.Amount)                                                 AS Сумма
FROM dbo.bm_StorageOperations so
WHERE so.OperationID = 1
GROUP BY so.Period
ORDER BY so.Period;
