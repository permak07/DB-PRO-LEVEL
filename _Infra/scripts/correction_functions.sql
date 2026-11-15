-- Тип для входящих параметров
do $$
begin
	if not exists (select 1 from pg_type where typname = 'input_params_type') then
		create type input_params_type as
		(
			height numeric(8,2),
			temperature numeric(8,2),
			pressure numeric(8,2),
			wind_direction numeric(8,2),
			wind_speed numeric(8,2),
			bullet_demolition_range numeric(8,2)
		);
	end if;
end $$;

comment on type input_params_type is 'Тип для входящих параметров расчёта метеосреднего';

-- Функция форматирования высоты (H)
create or replace function fn_format_h(p_height integer)
returns varchar
language plpgsql
as $$
begin
	return lpad((p_height / 100)::varchar, 2, '0');
end;
$$;

comment on function fn_format_h(integer) is 'Формат высоты в бюллетене (сотни метров)';

-- Функция форматирования отклонения температуры (TT)
create or replace function fn_format_tt(p_deviation integer)
returns varchar
language plpgsql
as $$
begin
	if p_deviation < 0 then
		return lpad((abs(p_deviation) + get_constant('NEGATIVE_TEMP_SHIFT')::int)::varchar, 2, '0');
	end if;
	return lpad(p_deviation::varchar, 2, '0');
end;
$$;

comment on function fn_format_tt(integer) is 'Формат отклонения температуры в бюллетене';

-- Функция форматирования направления ветра (HH)
create or replace function fn_format_hh(p_direction integer)
returns varchar
language plpgsql
as $$
begin
	return lpad((p_direction % get_constant('WIND_DIRECTION_MODULE')::int)::varchar, 2, '0');
end;
$$;

comment on function fn_format_hh(integer) is 'Формат направления ветра в бюллетене';

-- Функция форматирования скорости ветра (CC)
create or replace function fn_format_cc(p_speed integer)
returns varchar
language plpgsql
as $$
begin
	return lpad(p_speed::varchar, 2, '0');
end;
$$;

comment on function fn_format_cc(integer) is 'Формат скорости ветра в бюллетене';

-- Процедура расчёта метеосреднего по стандартным высотам
-- На вход: тип входящих параметров и тип оборудования (1 - ДМК, 2 - ВР)
create or replace function fn_calc_meteo_average(
	p_params input_params_type,
	p_equipment_type integer
)
returns table (
	height integer,
	temp_deviation integer,
	wind_direction integer,
	wind_speed integer
)
language plpgsql
as $$
declare
	v_errors text;

	-- отклонение приземной виртуальной температуры
	v_delta_t integer;
	-- тип таблицы 2 (8 - положительные, 9 - отрицательные)
	v_temp_type_id integer;
	-- десятки и единицы отклонения и их позиции в заголовке
	v_tens integer;
	v_units integer;
	v_tens_idx integer;
	v_units_idx integer;
	-- заголовок и строка таблицы 2
	v_temp_header integer[];
	v_temp_row integer[];

	-- ключ поиска по таблице 3 (скорость ветра ДМК или дальность сноса ВР)
	v_wind_key integer;
	-- типы таблицы 3 для скорости и направления
	v_speed_type_id integer;
	v_dir_type_id integer;
	-- заголовок, строка и позиция в таблице 3
	v_speed_header integer[];
	v_speed_row integer[];
	v_speed_idx integer;
	-- приращение направления среднего ветра
	v_delta_alpha integer;

	v_h record;
begin
	-- проверка типа оборудования
	if p_equipment_type not in (1, 2) then
		raise exception 'Некорректный тип оборудования: %. Допустимы 1 (ДМК) и 2 (ВР)', p_equipment_type;
	end if;

	-- проверка входных параметров
	v_errors := validate_parameter_type((
		p_equipment_type,
		p_params.height,
		p_params.temperature,
		p_params.pressure,
		p_params.wind_direction,
		p_params.wind_speed,
		p_params.bullet_demolition_range
	)::parameter_type);
	if coalesce(v_errors, '') <> '' then
		raise exception 'Ошибки входных параметров: %', v_errors;
	end if;

	-- отклонение приземной виртуальной температуры: ΔT0мп = T0 - 15.9, T0 = t0 + ΔTv
	v_delta_t := round(
		p_params.temperature
		+ calculate_interpolation(p_params.temperature, get_interpolation_type_temperature_correction(p_params.temperature))
		- get_constant('BASE_TEMP')
	)::int;

	-- тип таблицы 2 по знаку отклонения
	if v_delta_t < 0 then
		v_temp_type_id := 9;
	elsif v_delta_t > 0 then
		v_temp_type_id := 8;
	end if;

	-- раскладываем отклонение на десятки и единицы
	if v_temp_type_id is not null then
		v_tens := (abs(v_delta_t) / 10) * 10;
		v_units := abs(v_delta_t) - v_tens;

		select h.header_values
		into v_temp_header
		from calc_correction_types t
		join calc_correction_headers h on h.id = t.header_id
		where t.id = v_temp_type_id;

		v_tens_idx := array_position(v_temp_header, v_tens);
		v_units_idx := array_position(v_temp_header, v_units);
	end if;

	-- типы таблицы 3 и ключ поиска
	if p_equipment_type = 1 then
		-- ДМК: ключ - скорость приземного ветра
		if p_params.wind_speed < get_constant('MIN_WIND_SPEED_DMK') then
			v_speed_type_id := null;
		else
			v_speed_type_id := 6;
			v_dir_type_id := 7;
			v_wind_key := p_params.wind_speed::int;
		end if;
	else
		-- ВР: ключ - дальность сноса пуль, округлённая до десятков метров
		if p_params.bullet_demolition_range < get_constant('MIN_BULLET_DRIFT_VR') then
			v_speed_type_id := null;
		else
			v_speed_type_id := 4;
			v_dir_type_id := 5;
			v_wind_key := (round(p_params.bullet_demolition_range / 10) * 10)::int;
		end if;
	end if;

	-- позиция ключа в заголовке таблицы 3
	if v_speed_type_id is not null then
		select h.header_values
		into v_speed_header
		from calc_correction_types t
		join calc_correction_headers h on h.id = t.header_id
		where t.id = v_speed_type_id;

		v_speed_idx := array_position(v_speed_header, v_wind_key);
	end if;

	-- расчёт по каждой стандартной высоте
	for v_h in
		select ch.id, ch.height from calc_correction_heights ch order by ch.height
	loop
		height := v_h.height;

		-- среднее отклонение температуры (десятки + единицы)
		if v_temp_type_id is null then
			temp_deviation := 0;
		else
			select c.row_values
			into v_temp_row
			from calc_correction c
			where c.height_id = v_h.id
			  and c.type_id = v_temp_type_id;

			temp_deviation := coalesce(v_temp_row[v_tens_idx], 0)
			                + coalesce(v_temp_row[v_units_idx], 0);
		end if;

		-- направление и скорость среднего ветра
		if v_speed_type_id is null then
			-- слабый ветер: заполняем нулями
			wind_direction := 0;
			wind_speed := 0;
		else
			select c.row_values
			into v_speed_row
			from calc_correction c
			where c.height_id = v_h.id
			  and c.type_id = v_speed_type_id;

			wind_speed := coalesce(v_speed_row[v_speed_idx], 0);

			select c.row_values[1]
			into v_delta_alpha
			from calc_correction c
			where c.height_id = v_h.id
			  and c.type_id = v_dir_type_id;

			wind_direction := (p_params.wind_direction::int + coalesce(v_delta_alpha, 0))
			                % get_constant('WIND_DIRECTION_MODULE')::int;
		end if;

		return next;
	end loop;
end;
$$;

comment on function fn_calc_meteo_average(input_params_type, integer)
is 'Расчёт метеосреднего по стандартным высотам (200-4000 м)';
