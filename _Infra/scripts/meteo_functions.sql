-- Создание Функции расчета ДДЧЧМ
create or replace function get_ddchchm(p_date timestamp) 
returns varchar 
language plpgsql 
as $$
begin
    return to_char(p_date, 'DDHH24') || floor(extract(minute from p_date) / 10)::varchar;
end;
$$;

-- Создание Функции расчета ВВВВ 
create or replace function get_vvvv(p_height numeric) 
returns varchar 
language plpgsql 
as $$
begin
    return lpad(abs(trunc(p_height))::varchar, 4, '0');
end;
$$;

-- Создание Функции расчета БББТТ
create or replace function get_bbbtt(p_pressure numeric, p_temperature numeric) 
returns varchar 
language plpgsql 
as $$
declare
    v_base_pressure numeric;
    v_base_temp numeric;
    
    v_delta_p int;
    v_bbb varchar(3);
    
    v_delta_tv numeric;
    v_t0 numeric;
    v_delta_t int;
    v_tt varchar(2);
begin
    -- Получаем константы
    v_base_pressure := get_constant('BASE_PRESSURE');
    v_base_temp := get_constant('BASE_TEMP');
    
    --Расчёт БББ
    v_delta_p := round(p_pressure - v_base_pressure);
    if v_delta_p >= 0 then
        v_bbb := lpad(v_delta_p::varchar, 3, '0');
    else
        v_bbb := (500 + abs(v_delta_p))::varchar;
    end if;
    
    --Расчёт ТТ
    v_delta_tv := calculate_interpolation(p_temperature, get_interpolation_type_temperature_correction(p_temperature));
    
    -- T0 = t0 + ∆Tv
    v_t0 := p_temperature + v_delta_tv;
    
    -- Отклонение от табличного значения
    v_delta_t := round(v_t0 - v_base_temp);
    
    if v_delta_t < 0 then
        v_tt := lpad((abs(v_delta_t) + 50)::varchar, 2, '0');
    else
        v_tt := lpad(v_delta_t::varchar, 2, '0');
    end if;
    
    return v_bbb || v_tt;
end;
$$;