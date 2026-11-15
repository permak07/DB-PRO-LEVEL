-- Анализ продажи товара: проверка связей "чек -> кассир -> тип операции".
-- journal.loginid содержит код кассира и должен совпадать с personnel.personid,
-- journal.transtype ссылается на справочник transtype.
-- Если строки вернулись - связи подтверждены.
SELECT TOP 10
    j.transnumber                                                  AS Операция,
    j.receiptn                                                     AS Чек,
    tt.description                                                 AS ТипОперации,
    p.lastname + ' ' + p.firstname                                 AS Кассир,
    j.quantity                                                     AS Количество,
    j.amount                                                       AS Сумма,
    CONVERT(varchar(19), j.dater, 120)                             AS Дата
FROM dbo.journal j
JOIN dbo.transtype tt ON tt.transtypeid = j.transtype
JOIN dbo.personnel p  ON p.personid    = CAST(j.loginid AS int)
WHERE j.transtype = 101
ORDER BY j.transnumber DESC;
