drop table if exists parameters;
drop table if exists packs;
drop table if exists users;
drop table if exists equipment;
drop table if exists post;

create table post (
    id_post int primary key,
    name varchar(100)
);
comment on table post is 'Таблица должностей';
comment on column post.name is 'Название должности';

create table users(
	id_users int primary key,
    full_name varchar(100) ,
    id_post int references post(id_post)
);
comment on table users is 'Таблица пользователей';
comment on column users.full_name is 'Полное имя пользователя';
comment on column users.id_post is 'Код должности пользователя';

create table equipment (
    id_equipment int primary key,
    name varchar(50)
);
comment on table equipment is 'Таблица типов оборудования';
comment on column equipment.name is 'Название типа оборудования (ДМК, ВР)';

create table packs (
    id_packs int primary key,
    name varchar(100),
    id_users int references users(id_users),
    id_equipment int references equipment(id_equipment),
    measurement_date timestamp default current_timestamp
);
comment on table packs is 'Таблица пачек';
comment on column packs.name is 'Название пачки';
comment on column packs.id_users is 'Код пользователя, создавшего пачку';
comment on column packs.id_equipment is 'Код оборудования';
comment on column packs.measurement_date is 'Дата и время измерения';

create table parameters (
    id_parameters int primary key,
    name varchar(100),
    value varchar(50),
    id_packs int references packs(id_packs)
);
comment on table parameters is 'Таблица параметров измерений';
comment on column parameters.name is 'Название параметра (высота, температура и т.д.)';
comment on column parameters.value is 'Значение параметра';
comment on column parameters.id_packs is 'Код пачки, к которой относится параметр';

-- Тестовые данные
insert into post(id_post,name) values
	(1,'Младший Лейтенант'),
	(2,'Лейтенант'),
	(3,'Старший Лейтенант');
	
insert into users(id_users, full_name, id_post) values
	(1,'Иван Иванов',2),
	(2,'Петр Петров',1),
	(3,'Николай Николаевич',3);

insert into equipment(id_equipment, name) values
	(1, 'ДМК'),
	(2, 'ВР');

insert into packs(id_packs, name, id_users, id_equipment, measurement_date) values
	(1, 'Пачка ДМК', 1, 1, '2026-09-20 10:30:00'),
    (2, 'Пачка ДМК', 3, 1, '2026-09-20 14:15:00'),
    (3, 'Пачка ВР',  2, 2, '2026-09-21 09:00:00');

insert into parameters(id_parameters, name, value, id_packs) values
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
    post.name           as post,
    users.full_name     as user_name,
    equipment.name      as equipment,
    packs.name          as pack,
    packs.measurement_date as measurement_date,
    parameters.name     as parameter,
    parameters.value    as value
from packs
join users      on packs.id_users      = users.id_users
join post       on users.id_post       = post.id_post
join equipment  on packs.id_equipment  = equipment.id_equipment
join parameters on packs.id_packs      = parameters.id_packs
order by packs.id_packs, parameters.id_parameters;