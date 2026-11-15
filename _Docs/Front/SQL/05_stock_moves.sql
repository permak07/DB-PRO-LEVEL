-- Анализ остатков, шаг "одна неделя": движения товаров за неделю.
-- Проверяем связи: операция -> товар (product) -> склад (storages) ->
-- тип операции (bm_StorageOperationsType).
-- Количество операции - колонка Count (поступления с плюсом, списания с минусом).
-- Фильтр по неделе 27.11.2023 - 03.12.2023 (колонка DateAdd).
SELECT TOP 15
    CONVERT(varchar(19), so.DateAdd, 120)                          AS Дата,
    t.Description                                                  AS Операция,
    p.description                                                  AS Товар,
    s.description                                                  AS Склад,
    so.Count                                                       AS Количество,
    so.Amount                                                      AS Сумма
FROM dbo.bm_StorageOperations so
JOIN dbo.bm_StorageOperationsType t ON t.ID = so.OperationID
JOIN dbo.product  p ON p.id  = so.ProductID
JOIN dbo.storages s ON s.id  = so.StorageID
WHERE so.DateAdd BETWEEN '2023-11-27' AND '2023-12-04'
ORDER BY so.DateAdd;
