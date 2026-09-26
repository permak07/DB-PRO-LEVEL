-- Создание новых таблиц
create table base_measurement_units(
	id_base_unit int primary key,
	name varchar(100)
);
comment on table base_measurement_units is 'Таблица базовых единиц';
comment on column base_measurement_units.name is 'Название базовой единицы';

create table measurement_units(
	id_unit int primary key,
	name varchar(50),
	id_base_unit int references base_measurement_units(id_base_unit)
);
comment on table measurement_units is 'Таблица единиц измерения';
comment on column measurement_units.name is 'Название единицы (м/с, с и т.д.)';
comment on column measurement_units.id_base_unit is 'Код базовой единицы';

create table parameter_types(
	id_parameter_type int primary key,
	name varchar(100),
	id_unit int references measurement_units(id_unit)
);
comment on table parameter_types is 'Справочник типов параметров';
comment on column parameter_types.name is 'Название параметра';
comment on column parameter_types.id_unit is 'Код единицы измерения';

-- Изменение старых таблиц
alter table equipment add column description varchar(255);
comment on column equipment.description is 'Расширенное описание оборудования';

delete from parameters;

alter table parameters drop column name;
alter table parameters drop column value;
alter table parameters add column id_parameter_type int references parameter_types(id_parameter_type);
alter table parameters add column value decimal(10, 2);

comment on column parameters.id_parameter_type is 'Код типа параметра';
comment on column parameters.value is 'Значение параметра';

update equipment set description = 'Десантный метео комплекс' where name = 'ДМК';
update equipment set description = 'Ветровое ружье' where name = 'ВР';

-- Тестовые данные
insert into base_measurement_units(id_base_unit,name) values
	(1,'длина'),
	(2,'температура'),
	(3,'давление'),
	(4,'угол'),
	(5,'скорость');

insert into measurement_units(id_unit,name,id_base_unit) values
	(1,'м',1),
	(2,'C',2),
	(3,'мм рт.ст.',3),
	(4,'дел. угл.',4),
	(5,'м/с',5);

insert into parameter_types(id_parameter_type, name, id_unit) values
	(1, 'высота дмк', 1),
    (2, 'температура', 2),
    (3, 'давление', 3),
    (4, 'направление ветра', 4),
    (5, 'скорость ветра', 5),
    (6, 'дальность сноса пуль', 1);

insert into parameters(id_parameters, id_packs, id_parameter_type, value) values
	(1,1,1,100),
	(2,1,2,20),
	(3,1,3,700),
	(4,1,4,0),
	(5,1,5,0),
	(6,2,1,110),
	(7,2,2,15),
	(8,2,3,750),
	(9,2,4,10),
	(10,2,5,5),
	(11,3,1,120),
	(12,3,2,10),
	(13,3,3,780),
	(14,3,4,20),
	(15,3,6,3);

select
	packs.measurement_date as "Дата измерения",
	packs.id_packs as "Номер пачки",
	users.full_name as "Фио сотрудника",
	parameter_types.name || ' (' || measurement_units.name || ')' as "Наименование параметра и ед. измерения",
	parameters.value as "Значение"
from packs
inner join users
	on packs.id_users=users.id_users
inner join parameters
	on packs.id_packs=parameters.id_packs
inner join parameter_types
	on parameters.id_parameter_type=parameter_types.id_parameter_type
inner join measurement_units
	on parameter_types.id_unit=measurement_units.id_unit
order by packs.id_packs,parameters.id_parameters;	