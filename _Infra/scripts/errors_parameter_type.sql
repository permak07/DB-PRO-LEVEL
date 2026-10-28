--Создание таблицы ошибок
do $$
begin
	--Удаление таблицы и счётчика
	drop table if exists parameter_errors cascade;
	drop sequence if exists seq_parameter_errors cascade;

	-- Создание таблицы ошибок
	create table parameter_errors(
		id_error int not null,
		id_parameter_type int not null,
		min_value numeric(8,2),
		max_value numeric(8,2),
		error_message varchar(255) not null
	);
	
	--Создание счётчика, привязка его, и уникального ключа, и связи
	create sequence seq_parameter_errors;
	alter table parameter_errors alter column id_error set default nextval('seq_parameter_errors');
	alter table parameter_errors add primary key (id_error);
	alter table parameter_errors add foreign key (id_parameter_type) references parameter_types(id_parameter_type);

	-- Комментарии к таблице
	comment on table parameter_errors is 'Таблица правил валидации и описаний ошибок';
	comment on column parameter_errors.id_error is 'Уникальный счётчик ошибок';
	comment on column parameter_errors.id_parameter_type is 'Ссылка на тип параметра';
	comment on column parameter_errors.min_value is 'Минимально допустипое значение (вкл)';
	comment on column parameter_errors.max_value is 'Максимально допустимое значение (вкл)';
	comment on column parameter_errors.error_message is 'Текст ошибки';

	--Вставка данных об ощибках
	insert into parameter_errors(id_parameter_type,min_value,max_value,error_message) values
		(1,null,null,'Некорректное значение высоты'),
		(2, -58, 58, 'Температура вне диапазона [-58; 58]'),
        (3, 500, 900, 'Давление вне диапазона [500; 900]'),
        (4, 0, 59, 'Направление ветра вне диапазона [0; 59]'),
        (5, 0, 15, 'Скорость ветра вне диапазона [0; 15]'),
        (6, 0, 150, 'Дальность сноса пуль вне диапазона [0; 150]');
end $$;

-- Создание типа
do $$
begin
	if not exists(select 1 from pg_type where typname='parameter_type') then
		create type parameter_type as (
			id_equipment_type int,
			height numeric(8,2),
			temperature numeric(8,2),
			pressure numeric(8,2),
			wind_direction numeric(8,2),
			wind_speed numeric(8,2),
			drift_range numeric(8,2)
		);
	end if;
end $$;

--Создание функции для нахождения ошибки
create or replace function validate_parameter_type(params parameter_type)
returns varchar
language plpgsql
as $$
declare
	v_errors text;
begin
	with param_value(id_type,value) as (
		values
			(1,params.height),
			(2,params.temperature),
			(3,params.pressure),
			(4,params.wind_direction),
			(case when params.id_equipment_type=1 then 5 else null end,params.wind_speed),
			(case when params.id_equipment_type=2 then 6 else null end,params.drift_range)
	)
	select string_agg(pe.error_message,'. ')
	into v_errors
	from param_value pv
	join parameter_errors pe on pe.id_parameter_type=pv.id_type
	where pv.value is not null
		and(
			(pv.id_type=1 and pv.value!=trunc(pv.value))
			or
			(pv.id_type!=1 and(pv.value<pe.min_value or pv.value>pe.max_value))
		);
	return coalesce(v_errors,'');
end;
$$;

-- Добавление тестовых данных с ошибками
do $$
begin
    insert into packs (id_packs, name, id_users, id_equipment) values
        (4, 'Пачка ДМК (с ошибками)', 1, 1),
        (5, 'Пачка ВР (с ошибками)', 2, 2),
        (6, 'Пачка ДМК (с ошибками)', 3, 1);

    insert into parameters (id_parameters, id_packs, id_parameter_type, value) values
        (16, 4, 1, 100.50),
        (17, 4, 2, -70.00),
        (18, 4, 3, 750.00),
        (19, 4, 4, 30.00),
        (20, 4, 5, 25.00),
        (21, 5, 1, 120.00),
        (22, 5, 2, 15.00),
        (23, 5, 3, 950.00),
        (24, 5, 4, 65.00),
        (25, 5, 6, 200.00),
        (26, 6, 1, 150.00),
        (27, 6, 2, 60.00),
        (28, 6, 3, 400.00),
        (29, 6, 4, 10.00),
        (30, 6, 5, 5.00);
end $$;

-- Запрос "Список параметров с ошибками"
with main_data as (
	select
		p.id_packs,
		p.id_equipment,
		eq.name as equipment_type,
		max(case when param.id_parameter_type=1 then param.value end) as height,
		max(case when param.id_parameter_type=2 then param.value end) as temperature,
		max(case when param.id_parameter_type=3 then param.value end) as pressure,
		max(case when param.id_parameter_type=4 then param.value end) as wind_direction,
		max(case when param.id_parameter_type=5 then param.value end) as wind_speed,
		max(case when param.id_parameter_type=6 then param.value end) as drift_range
	from packs p
	join equipment eq on p.id_equipment=eq.id_equipment
	left join parameters param on p.id_packs=param.id_packs
	group by p.id_packs,p.id_equipment,eq.name
),

validation_data as (
	select
		*,
		validate_parameter_type((
			id_equipment,
			height,
			temperature,
			pressure,
			wind_direction,
			wind_speed,
			drift_range
		)::parameter_type) as errors
	from main_data
)
select
	id_packs as "#",
	equipment_type as "Тип оборудования",
	height as "Высота метеопоста",
	temperature as "Температура",
	pressure as "Давление",
	wind_direction as "Направление ветра",
	wind_speed as "Скорость ветра ",
	drift_range as "Дальность сноса пуль",
	case when errors is not null and errors <> '' then 'Да' else 'Нет' end as "Флаг: Есть ошибка",
	coalesce(errors,'') as "Описание ошибки"
from validation_data
order by id_packs

-- Запрос "Лучший стрелок"
with pack_errors as (
    select 
        id_packs,
        err
    from (
        select 
            id_packs, id_equipment,
            max(value) filter (where id_parameter_type = 1) as h,
            max(value) filter (where id_parameter_type = 2) as t,
            max(value) filter (where id_parameter_type = 3) as pr,
            max(value) filter (where id_parameter_type = 4) as wd,
            max(value) filter (where id_parameter_type = 5) as ws,
            max(value) filter (where id_parameter_type = 6) as dr
        from packs
        left join parameters using(id_packs)
        group by 1, 2
    ) p,
    lateral validate_parameter_type((id_equipment, h, t, pr, wd, ws, dr)::parameter_type) as err
),
user_stats as (
    select 
        u.full_name as "Пользователь",
        sum(case when pe.err <> '' then 1 else 0 end) as error_count
    from users u
    left join packs pk using(id_users)
    left join pack_errors pe using(id_packs)
    group by u.full_name
)
select 
    "Пользователь",
    error_count as "Количество пачек с ошибками",
    rank() over (order by error_count asc) as "Место"
from user_stats;