-- Таблицы для расчёта корректировок по высотам
do $$
begin

	-- Удаление старых таблиц и счётчиков
	begin
		drop table if exists calc_correction cascade;
		drop table if exists calc_correction_types cascade;
		drop table if exists calc_correction_heights cascade;
		drop table if exists calc_correction_headers cascade;
		drop sequence if exists calc_correction_seq cascade;
		drop sequence if exists calc_correction_types_seq cascade;
		drop sequence if exists calc_correction_height_seq cascade;
		drop sequence if exists calc_correction_headers_seq cascade;
	end;

	-- Таблица стандартных высот
	begin
		create sequence calc_correction_height_seq;
		create table calc_correction_heights
		(
			id integer primary key not null default nextval('public.calc_correction_height_seq'),
			height integer not null
		);

		insert into calc_correction_heights(height)
		values(200),(400),(800),(1200),(1600),(2000),(2400),(3000),(4000);

		comment on table calc_correction_heights is 'Таблица стандартных высот';
		comment on column calc_correction_heights.id is 'Уникальный код';
		comment on column calc_correction_heights.height is 'Высота';
	end;

	-- Справочник типов таблиц корректировок
	begin
		create sequence calc_correction_types_seq;
		create table calc_correction_types
		(
			id integer not null primary key default nextval('public.calc_correction_types_seq'),
			parent_id integer,
			measurment_equipment_id integer,
			description text not null,
			header_values integer[]
		);

		comment on table calc_correction_types is 'Справочник типов таблиц с собственными заголовками';
		comment on column calc_correction_types.id is 'Уникальный код';
		comment on column calc_correction_types.parent_id is 'Уникальный код владельца - тип таблицы';
		comment on column calc_correction_types.measurment_equipment_id is 'Тип оборудования';
		comment on column calc_correction_types.description is 'Описание к таблице';
		comment on column calc_correction_types.header_values is 'Значения в заголовке таблицы';
	end;

	-- Универсальная таблица корректировок
	begin
		create sequence calc_correction_seq;
		create table calc_correction
		(
			id integer not null primary key default nextval('public.calc_correction_seq'),
			height_id integer not null,
			type_id integer not null,
			row_values integer[]
		);

		comment on table calc_correction is 'Универсальная таблица корректировок';
		comment on column calc_correction.id is 'Уникальный код';
		comment on column calc_correction.height_id is 'Код высоты';
		comment on column calc_correction.type_id is 'Код типа таблиц';
		comment on column calc_correction.row_values is 'Значения с корректировками';
	end;

	-- Справочник заголовков таблиц корректировок
	begin
		create sequence calc_correction_headers_seq;
		create table calc_correction_headers
		(
			id integer not null primary key default nextval('public.calc_correction_headers_seq'),
			description varchar(255) not null,
			header_values integer[] not null
		);

		comment on table calc_correction_headers is 'Справочник заголовков таблиц корректировок';
		comment on column calc_correction_headers.id is 'Уникальный код';
		comment on column calc_correction_headers.description is 'Описание заголовка';
		comment on column calc_correction_headers.header_values is 'Значения заголовка (входы в таблицу)';
	end;

end $$;
