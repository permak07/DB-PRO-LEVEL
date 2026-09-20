drop table if exists parameters;
drop table if exists packs;
drop table if exists users;
drop table if exists equipment;
drop table if exists post;

create table post(
	id_post INT PRIMARY KEY,
	name TEXT
);

create table users(
	id_users INT PRIMARY KEY,
	name TEXT,
	id_post INT
);

create table equipment(
	id_equipment INT PRIMARY KEY,
	name TEXT
);

create table packs(
	id_packs INT PRIMARY KEY,
	name TEXT,
	id_users INT,
	id_equipment INT
);

create table parameters(
	id_parameters INT PRIMARY KEY,
	name TEXT,
	value TEXT,
	id_packs INT
);

insert into post(id_post,name) 
values
	(1,'Младший Лейтенант'),
	(2,'Лейтенант'),
	(3,'Старший Лейтенант');
	
insert into users(id_users, name, id_post) 
values
	(1,'Ивван Иванов',2),
	(2,'Петр Петров',1),
	(3,'Николай Николаевич',3);

insert into equipment(id_equipment, name)
values
	(1, 'ДМК'),
	(2, 'ВР');

insert into packs(id_packs, name, id_users, id_equipment)
values
	(1, 'Пачка ДМК', 1, 1),
	(2, 'Пачка ДМК', 3, 1),
	(3, 'Пачка ВР', 2, 2);

insert into parameters(id_parameters, name, value, id_packs)
values
	(1, 'Высота ДМК', '100', 1),
	(2, 'Температура', '20', 1),
	(3, 'Давление', '700', 1),
	(4, 'Направление ветра', '00', 1),
	(5, 'Скорость ветра', '0', 1),
	(6, 'Высота ДМК', '110', 2),
	(7, 'Температура', '15', 2),
	(8, 'Давление', '750', 2),
	(9, 'Направление ветра', '10', 2),
	(10, 'Скорость ветра', '5', 2),
	(11, 'Высота ДМК', '120', 3),
	(12, 'Температура', '10', 3),
	(13, 'Давление', '780', 3),
	(14, 'Направление ветра', '20', 3),
	(15, 'Дальность сноса пуль', '3', 3);

select
	post.name as post,
	users.name as user_name,
	equipment.name as equipment,
	packs.name as pack,
	parameters.name as parameter,
	parameters.value as value
from packs
join users on packs.id_users = users.id_users
join post on users.id_post = post.id_post
join equipment on packs.id_equipment = equipment.id_equipment
join parameters on packs.id_packs = parameters.id_packs;