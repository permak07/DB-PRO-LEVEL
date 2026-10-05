-- dml-скрипт напи
insert into packs (id_packs, name, id_users, id_equipment, measurement_date) values
    (4, 'Пачка ДМК №4', 1, 1, '2026-09-22 08:00:00'),
    (5, 'Пачка ВР №5', 1, 2, '2026-09-22 11:30:00'),
    (6, 'Пачка ДМК №6', 1, 1, '2026-09-22 14:00:00'),
    (7, 'Пачка ВР №7', 1, 2, '2026-09-22 16:45:00'),
    (8, 'Пачка ДМК №8', 1, 1, '2026-09-23 09:15:00'),
    (9, 'Пачка ВР №9', 1, 2, '2026-09-23 10:30:00'),
    (10, 'Пачка ДМК №10', 2, 1, '2026-09-23 13:00:00'),
    (11, 'Пачка ВР №11', 2, 2, '2026-09-23 15:20:00'),
    (12, 'Пачка ДМК №12', 3, 1, '2026-09-24 08:45:00'),
    (13, 'Пачка ВР №13', 3, 2, '2026-09-24 12:10:00'),
    (14, 'Пачка ДМК №14', 3, 1, '2026-09-24 15:30:00'),
    (15, 'Пачка ВР №15', 3, 2, '2026-09-25 09:00:00');

insert into parameters (id_parameters, id_parameter_type, value, id_packs) values
    -- пачка 4 (ДМК, полная)
    (16, 1, 100.00, 4),
    (17, 2, 20.00, 4),
    (18, 3, 750.00, 4),
    (19, 4, 15.00, 4),
    (20, 5, 5.00, 4),
    -- пачка 5 (ВР, полная)
    (21, 1, 120.00, 5),
    (22, 2, 10.50, 5),
    (23, 3, 780.00, 5),
    (24, 4, 25.00, 5),
    (25, 6, 30.00, 5),
    -- пачка 6 (ДМК, полная)
    (26, 1, 150.00, 6),
    (27, 2, -70.00, 6),
    (28, 3, 400.00, 6),
    (29, 4, 30.00, 6),
    (30, 5, 8.00, 6),
    -- пачка 7 (ВР, полная)
    (31, 1, 200.00, 7),
    (32, 2, 25.00, 7),
    (33, 3, 760.00, 7),
    (34, 4, 75.00, 7),
    (35, 6, 50.00, 7),
    -- пачка 9 (ВР, неполная (2 из 5))
    (36, 1, 0.00, 9),
    (37, 2, 5.00, 9),
    -- пачка 10 (ДМК, полная)
    (38, 1, 90.00, 10),
    (39, 2, 18.30, 10),
    (40, 3, 500.00, 10),
    (41, 4, 0.00, 10),
    (42, 5, 0.00, 10),
    -- пачка 12 (ДМК, неполная (3 из 5))
    (43, 1, 110.00, 12),
    (44, 2, 22.00, 12),
    (45, 3, 730.00, 12),
    -- пачка 13 (ВР, полная)
    (46, 1, 130.00, 13),
    (47, 2, 28.00, 13),
    (48, 3, 950.00, 13),
    (49, 4, 40.00, 13),
    (50, 6, 150.00, 13),
    -- пачка 14 (ДМК, полная)
    (51, 1, -50.00, 14),
    (52, 2, 65.00, 14),
    (53, 3, 770.00, 14),
    (54, 4, 59.00, 14),
    (55, 5, 20.00, 14),
    -- пачка 15 (ВР, неполная (3 из 5))
    (56, 1, 140.00, 15),
    (57, 2, 8.00, 15),
    (58, 3, 800.00, 15);

-- 1 запрос
-- Каждый пользователь имеет одинаковое количество измерений?
select 
    users.full_name as "Пользователь", 
    count(parameters.id_parameters) as "Количество измерений"
from users
left join packs 
    on users.id_users = packs.id_users
left join parameters
    on packs.id_packs = parameters.id_packs
group by users.full_name;

-- 2 запрос
-- У нас нет пустых пачек измерения?
select 
    packs.id_packs as "Номер пачки", 
    coalesce(count(parameters.id_parameters), 0) as "Кол-во параметров"
from packs
left join parameters 
    on packs.id_packs = parameters.id_packs
group by packs.id_packs
having coalesce(count(parameters.id_parameters), 0) = 0;

-- 3 запрос
-- Каждая пачка измерений содержит полное количество параметров (5 шт)?
select 
    packs.id_packs as "Номер пачки", 
    count(parameters.id_parameters) as "Кол-во параметров",
    case 
        when count(parameters.id_parameters) = 5 then 'Да' 
        else 'Нет' 
    end as "Полная (5 шт)?"
from packs
left join parameters 
    on packs.id_packs = parameters.id_packs
group by packs.id_packs;

-- 4 запрос
-- Все значения корректны и в рамках нужного нам диапазонов?
select 
    p.id_parameters as "ID",
    pt.name as "Параметр", 
    p.value as "Значение",
    case
        when pt.id_parameter_type = 2 and p.value not between -58 and 58 then 'Вне диапазона [-58; 58]'
        when pt.id_parameter_type = 3 and p.value not between 500 and 900 then 'Вне диапазона [500; 900]'
        when pt.id_parameter_type = 4 and p.value not between 0 and 59 then 'Вне диапазона [0; 59]'
        when pt.id_parameter_type = 5 and p.value not between 0 and 15 then 'Вне диапазона [0; 15]'
        when pt.id_parameter_type = 6 and p.value not between 0 and 150 then 'Вне диапазона [0; 150]'
        else 'ОК'
    end as "Статус"
from parameters p
inner join parameter_types pt 
    on p.id_parameter_type = pt.id_parameter_type
order by p.id_parameters;

-- 5 запрос
-- Все единицы измерения верны и корректны по отношению к указанным параметрам?
select 
    parameter_types.name as "Параметр", 
    measurement_units.name as "Ошибочная ед. изм."
from parameter_types
inner join measurement_units 
    on parameter_types.id_unit = measurement_units.id_unit
where not (
       (parameter_types.id_parameter_type = 1 and measurement_units.id_unit = 1)
    or (parameter_types.id_parameter_type = 2 and measurement_units.id_unit = 2)
    or (parameter_types.id_parameter_type = 3 and measurement_units.id_unit = 3)
    or (parameter_types.id_parameter_type = 4 and measurement_units.id_unit = 4)
    or (parameter_types.id_parameter_type = 5 and measurement_units.id_unit = 5)
    or (parameter_types.id_parameter_type = 6 and measurement_units.id_unit = 1)
);