-- Анализ продажи товара: проверка связи "чек -> товары -> категории".
-- Таблица bm_Journal_Details хранит состав заказа:
--   SourceID  -> journal.transnumber (операция чека),
--   ProductID -> product.id (товар),
--   RangeID   -> size.ID (фасовка).
-- product.CategoryID -> category.id (категория товара).
SELECT TOP 10
    j.transnumber                                                  AS Операция,
    j.receiptn                                                     AS Чек,
    p.description                                                  AS Товар,
    c.description                                                  AS Категория,
    sz.description                                                 AS Фасовка
FROM dbo.bm_Journal_Details d
JOIN dbo.journal  j  ON j.transnumber = d.SourceID
JOIN dbo.product  p  ON p.id          = d.ProductID
LEFT JOIN dbo.category c  ON c.id     = p.CategoryID
LEFT JOIN dbo.size     sz ON sz.ID    = d.RangeID
ORDER BY j.transnumber DESC;
