-- Анализ работы персонала: проверка связи "бонус -> сотрудник -> клиент".
-- bm_BonusHistory.PersonID = personnel.personid (кто начислил),
-- bm_BonusHistory.ClientID = clients.id (кому начислили).
SELECT TOP 10
    p.personid                                                     AS ТабНомер,
    p.lastname + ' ' + p.firstname                                 AS Сотрудник,
    COUNT(*)                                                       AS Операций,
    SUM(b.BonusValue)                                              AS Бонусов
FROM dbo.bm_BonusHistory b
JOIN dbo.personnel p ON p.personid = b.PersonID
GROUP BY p.personid, p.lastname, p.firstname
ORDER BY Бонусов DESC;
