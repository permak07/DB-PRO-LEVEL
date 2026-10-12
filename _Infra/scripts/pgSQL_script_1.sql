do $$
begin

	-- Удаление старых таблиц и счётчиков
	drop table if exists parameters cascade;
    drop table if exists parameter_types cascade;
    drop table if exists measurement_units cascade;
    drop table if exists base_measurement_units cascade;
    drop table if exists packs cascade;
    drop table if exists users cascade;
    drop table if exists equipment cascade;
    drop table if exists post cascade;
    drop table if exists temperature cascade;

    drop sequence if exists seq_post cascade;
    drop sequence if exists seq_equipment cascade;
    drop sequence if exists seq_users cascade;
    drop sequence if exists seq_packs cascade;
    drop sequence if exists seq_base_measurement_units cascade;
    drop sequence if exists seq_measurement_units cascade;
    drop sequence if exists seq_parameter_types cascade;
    drop sequence if exists seq_parameters cascade;
    drop sequence if exists seq_temperature cascade;
	
    -- транзакция 1: структура таблиц и счетчики
    create table post(
        id_post integer not null,
        name varchar(100) not null
    );
    
    create table equipment(
        id_equipment integer not null,
        name varchar(50) not null,
        description varchar(255)
    );
    
    create table users(
        id_users integer not null,
        full_name varchar(100) not null,
        id_post integer not null
    );
    
    create table packs(
        id_packs integer not null,
        name varchar(100),
        id_users integer not null,
        id_equipment integer not null,
        measurement_date timestamp not null default current_timestamp
    );
    
    create table base_measurement_units(
        id_base_unit integer not null,
        name varchar(100) not null
    );
    
    create table measurement_units(
        id_unit integer not null,
        name varchar(50) not null,
        id_base_unit integer not null
    );
    
    create table parameter_types(
        id_parameter_type integer not null,
        name varchar(100) not null,
        id_unit integer not null
    );
    
    create table parameters(
        id_parameters integer not null,
        value decimal(10,2) not null,
        id_packs integer not null,
        id_parameter_type integer not null
    );
    
    -- Таблица Расчёта температур
    create table temperature(
        id_temp integer not null,
        temp_range varchar(50) not null,
        value decimal(5,1) not null
    );

    -- привязываем счетчики
    create sequence seq_post;
    alter table post alter column id_post set default nextval('seq_post');
    
    create sequence seq_equipment;
    alter table equipment alter column id_equipment set default nextval('seq_equipment');
    
    create sequence seq_users;
    alter table users alter column id_users set default nextval('seq_users');
    
    create sequence seq_packs;
    alter table packs alter column id_packs set default nextval('seq_packs');
    
    create sequence seq_base_measurement_units;
    alter table base_measurement_units alter column id_base_unit set default nextval('seq_base_measurement_units');
    
    create sequence seq_measurement_units;
    alter table measurement_units alter column id_unit set default nextval('seq_measurement_units');
    
    create sequence seq_parameter_types;
    alter table parameter_types alter column id_parameter_type set default nextval('seq_parameter_types');
    
    create sequence seq_parameters;
    alter table parameters alter column id_parameters set default nextval('seq_parameters');
    
    create sequence seq_temperature;
    alter table temperature alter column id_temp set default nextval('seq_temperature');
    
    commit;

	begin
	    -- транзакция 2: Наполнение тестовыми данными
	    insert into post(name) values
	        ('Младший лейтенант'), ('Лейтенант'), ('Старший лейтенант');
	
	    insert into equipment(name, description) values
	        ('ДМК', 'Десантный метео комплекс'), ('ВР', 'Ветровое ружье');
	
	    insert into users(full_name, id_post) values
	        ('Иван Иванов', 2), ('Петр Петров', 1), ('Николай Николаевич', 3);
	
	    insert into packs(name, id_users, id_equipment) values
	        ('Пачка ДМК', 1, 1), ('Пачка ДМК', 3, 1), ('Пачка ВР',  2, 2);
	
	    insert into base_measurement_units(name) values
	        ('Длина'), ('Температура'), ('Давление'), ('Угол'), ('Скорость');
	
	    insert into measurement_units(name, id_base_unit) values
	        ('м', 1), ('С', 2), ('мм рт.ст.', 3), ('дел. угл.', 4), ('м/с', 5);
	
	    insert into parameter_types(name, id_unit) values
	        ('Высота ДМК', 1), ('Температура', 2), ('Давление', 3), 
	        ('Направление ветра', 4), ('Скорость ветра', 5), ('Дальность сноса пуль', 1);
	
	    insert into parameters(value, id_packs, id_parameter_type) values
	        (100, 1, 1), (20, 1, 2), (700, 1, 3), (0, 1, 4), (0, 1, 5),
	        (110, 2, 1), (15, 2, 2), (750, 2, 3), (10, 2, 4), (5, 2, 5),
	        (120, 3, 1), (10, 3, 2), (780, 3, 3), (20, 3, 4), (3, 3, 6);
	
	    insert into temperature (temp_range, value) values
	        ('Ниже 0', 0.0), ('0 - 5', 0.5), ('10 - 15', 1.0),
	        ('20', 1.5), ('25', 2.0), ('30', 3.5), ('40', 4.5);
	
	    commit;
	end;

	begin
	    -- транзакция 3: связи и ограничения
	    -- первичные ключи
	    alter table post add primary key (id_post);
	    alter table equipment add primary key (id_equipment);
	    alter table users add primary key (id_users);
	    alter table packs add primary key (id_packs);
	    alter table base_measurement_units add primary key (id_base_unit);
	    alter table measurement_units add primary key (id_unit);
	    alter table parameter_types add primary key (id_parameter_type);
	    alter table parameters add primary key (id_parameters);
	    alter table temperature add primary key (id_temp);
	
	    -- связи
	    alter table users add foreign key (id_post) references post(id_post);
	    
	    alter table packs add foreign key (id_users) references users(id_users);
	    alter table packs add foreign key (id_equipment) references equipment(id_equipment);
	    
	    alter table measurement_units add foreign key (id_base_unit) references base_measurement_units(id_base_unit);
	    alter table parameter_types add foreign key (id_unit) references measurement_units(id_unit);
	    
	    alter table parameters add foreign key (id_packs) references packs(id_packs);
	    alter table parameters add foreign key (id_parameter_type) references parameter_types(id_parameter_type);
	
	    -- ограничения
	    alter table temperature add constraint chk_correction check (value >= 0);
	
	    commit;
	end;
end $$;