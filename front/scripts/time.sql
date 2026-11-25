-- Ресурс (метрика) "Время": структура и наполнение
do $$
declare
	v_date date := date '2012-01-01';
	v_months text[] := array[
		'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
		'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
	];
	v_quarters text[] := array['1 квартал', '2 квартал', '3 квартал', '4 квартал'];
	v_quarter int;
begin
	-- Удаление старой таблицы и счётчика
	drop table if exists dim_time cascade;
	drop sequence if exists seq_dim_time cascade;

	-- Создание таблицы временных метрик
	create table dim_time(
		id bigint not null,
		time_id bigint not null,
		date_start date not null,
		date_end date not null,
		month_name text not null,
		year int not null,
		quarter_num int not null,
		quarter_name text not null,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_time;
	alter table dim_time alter column id set default nextval('seq_dim_time');
	alter table dim_time add primary key (id);
	alter table dim_time add constraint unique_dim_time_id unique (time_id);
	comment on table dim_time is 'Метрика времени: код YYYYMM, границы месяца, квартал';
	comment on column dim_time.id is 'Внутренний код записи';
	comment on column dim_time.time_id is 'Код месяца в формате YYYYMM';
	comment on column dim_time.date_start is 'Дата начала месяца';
	comment on column dim_time.date_end is 'Дата окончания месяца';
	comment on column dim_time.month_name is 'Название месяца';
	comment on column dim_time.year is 'Год';
	comment on column dim_time.quarter_num is 'Номер квартала';
	comment on column dim_time.quarter_name is 'Название квартала';
	comment on column dim_time.date_add is 'Дата добавления записи';

	-- Наполнение календарём на 2012-2026 гг. (180 месяцев)
	while v_date <= date '2026-12-01' loop
		v_quarter := (extract(month from v_date)::int - 1) / 3 + 1;

		insert into dim_time(
			time_id,
			date_start,
			date_end,
			month_name,
			year,
			quarter_num,
			quarter_name
		) values (
			extract(year from v_date)::int * 100 + extract(month from v_date)::int,
			v_date,
			(v_date + interval '1 month - 1 day')::date,
			v_months[extract(month from v_date)::int],
			extract(year from v_date)::int,
			v_quarter,
			v_quarters[v_quarter] || ' ' || extract(year from v_date)::int
		);

		v_date := (v_date + interval '1 month')::date;
	end loop;
end $$;

-- Проверка
select * from dim_time order by time_id;
