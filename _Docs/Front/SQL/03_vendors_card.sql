-- Анализ взаимоотношений с поставщиками: карточка поставщика.
-- vendors.clientgroup -> vendorgroup, cityid -> city, countryid -> country,
-- bankid -> banks. Проверяем, что у поставщиков заполняются реквизиты.
SELECT
    v.id                                                           AS Код,
    v.clientid                                                     AS Поставщик,
    vg.description                                                 AS Группа,
    ct.name                                                        AS Город,
    cn.name                                                        AS Страна,
    b.description                                                  AS Банк,
    v.INN                                                          AS ИНН
FROM dbo.vendors v
LEFT JOIN dbo.vendorgroup vg ON vg.vendorgroupid = v.clientgroup
LEFT JOIN dbo.city        ct ON ct.cityid       = v.cityid
LEFT JOIN dbo.country     cn ON cn.id           = v.countryid
LEFT JOIN dbo.banks       b  ON b.id            = v.bankid
ORDER BY v.id;
