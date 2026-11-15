-- Анализ остатков: остаток товара на конец недели 27.11.2023 - 03.12.2023.
-- В таблице bm_StorageOperations количество хранится в колонке Count:
-- поступления - с плюсом, списания - с минусом.
-- Остаток на дату = сумма Count по всем операциям товара до конца недели
-- (ProductID -> product.id).
SELECT TOP 15
    p.description                                                  AS Товар,
    SUM(so.Count)                                                  AS Остаток
FROM dbo.bm_StorageOperations so
JOIN dbo.product p ON p.id = so.ProductID
WHERE so.DateAdd <= '2023-12-03'
GROUP BY p.description
ORDER BY Остаток DESC;
