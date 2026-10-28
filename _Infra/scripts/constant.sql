-- Создание таблицы констант
do $$
begin
	-- Удаление таблицы и счётчика
	drop table if exists constants cascade;
	drop sequence if exists seq_constants cascade;

	-- Создание таблицы констант
	create table constants(
		id_constant int not null,
		name varchar(50) not null,
		value numeric(8,2) not null,
		description varchar(255)
	);
	
	-- Создание счётчика, привязка его и уникальных ключей
	create sequence seq_constants;
	alter table constants alter column id_constant set default nextval('seq_constants');
	alter table constants add primary key (id_constant);
	alter table constants add constraint unique_constant_name unique (name);

	-- Комментарии к таблице
	comment on table constants is 'Таблица для хранения констант системы';
	comment on column constants.id_constant is 'Уникальный счётчик констант';
	comment on column constants.name is 'Имя константы (уникальное)';
	comment on column constants.value is 'Значение константы';
	comment on column constants.description is 'Описание константы';

	-- Вставка данных констант
	insert into constants(name, value, description) values
		('BASE_PRESSURE', 750.00, 'Табличное значение наземного давления (мм рт. ст.)'),
		('BASE_TEMP', 15.90, 'Табличное значение приземной виртуальной температуры (°С)');
end $$;

-- Функция для получения значения константы по имени
create or replace function get_constant(p_name varchar) 
returns numeric 
language plpgsql 
as $$
declare
    v_value numeric;
begin
    select value into v_value from constants where name = p_name;
    return coalesce(v_value, 0);
end;
$$;