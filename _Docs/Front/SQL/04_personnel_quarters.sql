-- Анализ работы персонала, шаг "квартал".
-- Активность кассиров: journal.loginid = personnel.personid.
-- Считаем операции продаж (transtype = 101) по сотрудникам и кварталам.
SELECT TOP 20
    p.personid                                                     AS ТабНомер,
    p.lastname + ' ' + p.firstname                                 AS Сотрудник,
    YEAR(j.dater)                                                  AS Год,
    DATEPART(quarter, j.dater)                                     AS Квартал,
    COUNT(*)                                                       AS Операций,
    SUM(j.amount)                                                  AS Сумма
FROM dbo.journal j
JOIN dbo.personnel p ON p.personid = CAST(j.loginid AS int)
WHERE j.transtype = 101
GROUP BY p.personid, p.lastname, p.firstname, YEAR(j.dater), DATEPART(quarter, j.dater)
ORDER BY Год DESC, Квартал DESC, Операций DESC;
