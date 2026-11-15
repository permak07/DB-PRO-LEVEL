-- Анализ продажи товара, шаг "месяц".
-- Кассовый журнал journal хранит каждую позицию чека.
-- Операции типа 101 (PLU Sales) = продажа товара.
-- Группируем по году и месяцу колонки dater.
SELECT
    YEAR(j.dater)                                                  AS Год,
    MONTH(j.dater)                                                 AS Месяц,
    COUNT(*)                                                       AS Продаж,
    SUM(j.amount)                                                  AS Сумма
FROM dbo.journal j
WHERE j.transtype = 101
GROUP BY YEAR(j.dater), MONTH(j.dater)
ORDER BY Год, Месяц;
