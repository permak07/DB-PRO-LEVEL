do $$
begin
	-- Проверка нахождения точек интерполяции внутри 1 интервала
	assert get_interpolation_type_temperature_correction(21.0)=get_interpolation_type_temperature_correction(24.0),
	'ошибка: параметры 21.0 и 24.0 должны возвращать одни и те же параметры';

	-- Попадание в табличное значение 10.0 -> 1.0
	assert calculate_interpolation(10.0, get_interpolation_type_temperature_correction(10.0)) = 1.00,
	'ошибка: для узлового значения 10.0 ожидалась поправка 1.00';

	-- Середина отрезка 20-25: при 22.5 ожидается поправка 1.50
	assert calculate_interpolation(22.5, get_interpolation_type_temperature_correction(22.5)) = 1.50,
	'ошибка: для 22.5 ожидалась поправка 1.50';

	-- В интервале 10-15 (13 -> поправка 1.0)
	assert calculate_interpolation(13.0, get_interpolation_type_temperature_correction(13.0)) = 1.00,
	'ошибка: в интервале 10-15 (13)';

	-- В интервале 25-30 (27.5 -> поправка 2.75)
	assert calculate_interpolation(27.5, get_interpolation_type_temperature_correction(27.5)) = 2.75,
	'ошибка: в интервале 25-30 (27.5)';

	-- Выход за верхнюю границу (50.0 -> поправка 4.5)
	assert calculate_interpolation(50.0, get_interpolation_type_temperature_correction(50.0)) = 4.50,
	'ошибка: выход за верхнюю границу в 50';

	-- Проверка совпадения поправок при выходе из диапозона
	assert calculate_interpolation(44.0, get_interpolation_type_temperature_correction(44.0)) = 
	       calculate_interpolation(50.0, get_interpolation_type_temperature_correction(50.0)),
	'ошибка: параметры 50.0 и 44.0 должны возвращать одинаковую поправку';

	-- выход за нижнюю границу (-10.0 -> 0.0)
	assert calculate_interpolation(-10.0, get_interpolation_type_temperature_correction(-10.0)) = 0.0,
	'ошибка: выход за нижнюю границу в -10';

	raise notice 'Все проверки успешно пройдены';
end $$;