-- Миграционный скрипт
-- 2026-09-23
drop table if exists military_ranks;
drop table if exists employees;
drop table if exists measurment_types;
drop table if exists measurment_input_params;
drop table if exists measurment_baths;

-- 1. Справочник должностей
create table military_ranks
(
	id integer,
	description character varying(255)
);

comment on table military_ranks is 'Справочник должностей';
comment on column military_ranks.id is 'Уникальный код';
comment on column military_ranks.description is 'Описание';

-- Заполняем данные
insert into military_ranks(id, description)
values(1,'Рядовой'),(2,'Лейтенант');

-- 2. Пользователя
create table employees
(
    id integer,
	name text,
	birthday timestamp ,
	military_rank_id integer
);

comment on table employees is 'Пользователи';
comment on column employees.id is 'Уникальный код';
comment on column employees.name is 'Наименование';
comment on column employees.birthday is 'Дата рождения';
comment on column employees.military_rank_id is 'Уникальный код должности';

-- Заполняем данные
insert into employees(id, name, birthday,military_rank_id )  
values(1, 'Воловиков Александр Сергеевич','1978-06-24', 2);

-- 3. Устройства для измерения
create table measurment_types
(
   id integer,
   short_name  character varying(50),
   description text 
);

comment on table measurment_types is 'Измерительное оборудование';
comment on column measurment_types.id is 'Уникальный код';
comment on column measurment_types.short_name is 'Краткое наименование';
comment on column measurment_types.description is 'Описание';

-- Заполняем данные
insert into measurment_types(id, short_name, description)
values(1, 'ДМК', 'Десантный метео комплекс'),
(2,'ВР','Ветровое ружье');


-- 3. Таблица с параметрами
create table measurment_input_params
(
    id integer primary key,
	measurment_batch_id integer,
	parameters_types_id integer,
	value decimal
);

comment on table measurment_input_params is 'Таблица с параметрами';
comment on column measurment_input_params.id is 'Уникальный код';
comment on column measurment_input_params.measurment_batch_id is 'Уникальный код пачки';
comment on column measurment_input_params.parameters_types_id is 'Уникальный код типы праметра';
comment on column measurment_input_params.value is 'Значение';

-- Заполняем данные
insert into measurment_input_params(id, measurment_batch_id, parameters_types_id,vvalue )values
	(1, 1, 1, 5),
	(1, 2, 2, 19);

-- 4. Таблица типов параметров
create table parameters_types(
	id integer primary key,
	name text,
	measuarment_unit_id integer references measurement_unit(id)
);

insert into parametere_types(id,name,measurement_unit_id) values
	(1,'Скорость ветра',1),
	(2,'Температура',2);
	
-- 5. Таблица единицы измерения
create table measurement_unit(
	id integer primary key,
	name text
);
insert into measurement_unit(id,name) values
	(1,'м/с'),
	(2,'C');

	
-- 6. Таблица с историей (пачки)
create table measurment_batchs
(
	id integer,
	emploee_id integer,
	measurment_type_id integer,
	started timestamp default now()
);

comment on table measurment_batchs is 'Пачки';
comment on column measurment_batchs.emploee_id is 'Уникальный код пользователя';
comment on column measurment_batchs.measurment_type_id is 'Уникальный код оборудования';
comment on column measurment_batchs.started is 'Дата измерения';

-- Заполняем данные
insert into measurment_batchs(id, emploee_id, measurment_type_id, started)
values(1, 1, 1, '2026-09-01'),(2,1,2, '2026-09-02');

---------------------------------------------------
-- Итоговый запрос
---------------------------------------------------

select *
from measurment_batchs, measurment_input_params, measurment_types, employees, military_ranks
where
        -- Связь пачка - пользователи
	    employees.id = measurment_batchs.emploee_id
		-- Связь должность - пользователь
	and employees.military_rank_id = military_ranks.id
	   -- Связь пачка - тип оборудования
	and measurment_types.id = measurment_batchs.measurment_type_id
	   -- Связь пачка - параетры
	and measurment_input_params.measurment_batch_id = measurment_batchs.id;
	








