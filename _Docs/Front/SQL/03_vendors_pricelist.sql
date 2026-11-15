-- Анализ взаимоотношений с поставщиками: прайс-лист поставщика.
-- pricelist.vendorid -> vendors.id, productid -> product.id,
-- groupid -> pricegroup.pricegroupid (группа цен).
SELECT TOP 10
    v.clientid                                                     AS Поставщик,
    p.description                                                  AS Товар,
    pg.description                                                 AS ГруппаЦен,
    pl.basecost                                                    AS ЗакупочнаяЦена
FROM dbo.pricelist pl
LEFT JOIN dbo.vendors    v  ON v.id        = pl.vendorid
JOIN     dbo.product    p  ON p.id        = pl.productid
LEFT JOIN dbo.pricegroup pg ON pg.pricegroupid = pl.groupid
ORDER BY pl.id;
