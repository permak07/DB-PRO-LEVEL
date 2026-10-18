do $$
-- Создание типа, если он ещё не создан
begin
	if not exists (select 1 from pg_type where typname='interpolation_type') then
		create type interpolation_type as (
			x0 numeric(8,2),
            y0 numeric(8,2),
            x1 numeric(8,2),
            y1 numeric(8,2)
		);
	end if;
end $$;

-- Удаление старых функций
drop function if exists get_interpolation_type_temperature_correction(numeric) cascade;
drop function if exists calculate_interpolation(numeric, interpolation_type) cascade;

-- Функция поиска точек интерполяции
create or replace function get_interpolation_type_temperature_correction(
	p_temp numeric
	)
returns interpolation_type
language plpgsql
as $$
declare
	points interpolation_type;
begin
	-- Если температура меньше 0, то поправка 0.0
	if p_temp < 0 then
		points.x0 := p_temp;
		points.y0 := 0.00;
		points.x1 := 0.00;
		points.y1 := 0.00;
		return points;
	end if;
	
	-- Находим нижнюю точку (x0,y0)
	select
		coalesce(
			(select temperature from temperature_correction where temperature <=p_temp order by temperature desc limit 1),
			p_temp
		),
		coalesce(
			(select correction from temperature_correction where temperature <=p_temp order by temperature desc limit 1),
			(select correction from temperature_correction order by temperature asc limit 1)
		)
	into points.x0, points.y0;

	-- Находим верхнюю точку (x1,y1)
	select
	coalesce(
		(select temperature from temperature_correction where temperature>=p_temp order by temperature asc limit 1),
		p_temp
	),
	coalesce(
		(select correction from temperature_correction where temperature >= p_temp order by temperature asc limit 1),
		(select correction from temperature_correction order by temperature desc limit 1)
	)
	into points.x1,points.y1;

	return points;
end;
$$;

-- Функция расчета линейной интерполяции
create or replace function calculate_interpolation(
	x_point numeric,
	points interpolation_type
)
returns numeric
language plpgsql
as $$
begin
	if points.x0=points.x1 then
	return points.y0;
	end if;

	return round(points.y0 + ((x_point - points.x0) * (points.y1 - points.y0) / (points.x1 - points.x0)),2);
end;
$$;