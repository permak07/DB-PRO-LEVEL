-- Создание структуры OLAP-базы: измерения
do $$
begin
	-- Удаление таблиц и счётчиков
	drop table if exists dim_base_units cascade;
	drop table if exists dim_categories cascade;
	drop table if exists dim_vendors cascade;
	drop table if exists dim_products cascade;
	drop table if exists dim_personnel cascade;
	drop table if exists dim_storages cascade;
	drop table if exists dim_operations cascade;
	drop table if exists dim_securityaccess cascade;

	drop sequence if exists seq_dim_base_units cascade;
	drop sequence if exists seq_dim_categories cascade;
	drop sequence if exists seq_dim_vendors cascade;
	drop sequence if exists seq_dim_products cascade;
	drop sequence if exists seq_dim_personnel cascade;
	drop sequence if exists seq_dim_storages cascade;
	drop sequence if exists seq_dim_operations cascade;
	drop sequence if exists seq_dim_securityaccess cascade;

	-- Измерение "Базовые единицы измерения"
	create table dim_base_units(
		id bigint not null,
		external_id bigint,
		group_id bigint,
		short_name text,
		name text,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_base_units;
	alter table dim_base_units alter column id set default nextval('seq_dim_base_units');
	alter table dim_base_units add primary key (id);
	comment on table dim_base_units is 'Справочник базовых единиц измерения';
	comment on column dim_base_units.id is 'Внутренний код записи';
	comment on column dim_base_units.external_id is 'Код единицы измерения в базе Front';
	comment on column dim_base_units.group_id is 'Код группы единиц измерения';
	comment on column dim_base_units.short_name is 'Краткое обозначение единицы измерения';
	comment on column dim_base_units.name is 'Полное наименование единицы измерения';
	comment on column dim_base_units.date_add is 'Дата добавления записи';

	-- Измерение "Категории"
	create table dim_categories(
		id bigint not null,
		external_id bigint,
		name text,
		parent_id bigint,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_categories;
	alter table dim_categories alter column id set default nextval('seq_dim_categories');
	alter table dim_categories add primary key (id);
	comment on table dim_categories is 'Справочник категорий продукции';
	comment on column dim_categories.id is 'Внутренний код записи';
	comment on column dim_categories.external_id is 'Код категории в базе Front';
	comment on column dim_categories.name is 'Наименование категории';
	comment on column dim_categories.parent_id is 'Код родительской категории';
	comment on column dim_categories.date_add is 'Дата добавления записи';

	-- Измерение "Поставщики"
	create table dim_vendors(
		id bigint not null,
		external_id bigint,
		name text,
		parent_id bigint,
		parent_name text,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_vendors;
	alter table dim_vendors alter column id set default nextval('seq_dim_vendors');
	alter table dim_vendors add primary key (id);
	comment on table dim_vendors is 'Справочник поставщиков';
	comment on column dim_vendors.id is 'Внутренний код записи';
	comment on column dim_vendors.external_id is 'Код поставщика в базе Front';
	comment on column dim_vendors.name is 'Наименование поставщика';
	comment on column dim_vendors.parent_id is 'Код группы поставщиков';
	comment on column dim_vendors.parent_name is 'Наименование группы поставщиков';
	comment on column dim_vendors.date_add is 'Дата добавления записи';

	-- Измерение "Товары"
	create table dim_products(
		id bigint not null,
		external_id bigint,
		name text,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_products;
	alter table dim_products alter column id set default nextval('seq_dim_products');
	alter table dim_products add primary key (id);
	comment on table dim_products is 'Справочник товаров (номенклатура)';
	comment on column dim_products.id is 'Внутренний код записи';
	comment on column dim_products.external_id is 'Код товара в базе Front';
	comment on column dim_products.name is 'Наименование товара';
	comment on column dim_products.date_add is 'Дата добавления записи';

	-- Измерение "Сотрудники"
	create table dim_personnel(
		id bigint not null,
		external_id bigint,
		lastname text,
		firstname text,
		securityaccess integer,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_personnel;
	alter table dim_personnel alter column id set default nextval('seq_dim_personnel');
	alter table dim_personnel add primary key (id);
	comment on table dim_personnel is 'Справочник сотрудников';
	comment on column dim_personnel.id is 'Внутренний код записи';
	comment on column dim_personnel.external_id is 'Табельный номер сотрудника в базе Front';
	comment on column dim_personnel.lastname is 'Фамилия сотрудника';
	comment on column dim_personnel.firstname is 'Имя сотрудника';
	comment on column dim_personnel.securityaccess is 'Код уровня доступа сотрудника';
	comment on column dim_personnel.date_add is 'Дата добавления записи';

	-- Измерение "Склады"
	create table dim_storages(
		id bigint not null,
		external_id bigint,
		name text,
		address text,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_storages;
	alter table dim_storages alter column id set default nextval('seq_dim_storages');
	alter table dim_storages add primary key (id);
	comment on table dim_storages is 'Справочник складов';
	comment on column dim_storages.id is 'Внутренний код записи';
	comment on column dim_storages.external_id is 'Код склада в базе Front';
	comment on column dim_storages.name is 'Наименование склада';
	comment on column dim_storages.address is 'Адрес склада';
	comment on column dim_storages.date_add is 'Дата добавления записи';

	-- Измерение "Операции"
	create table dim_operations(
		id bigint not null,
		external_id bigint,
		name text,
		factor integer,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_operations;
	alter table dim_operations alter column id set default nextval('seq_dim_operations');
	alter table dim_operations add primary key (id);
	comment on table dim_operations is 'Справочник видов складских операций';
	comment on column dim_operations.id is 'Внутренний код записи';
	comment on column dim_operations.external_id is 'Код операции в базе Front';
	comment on column dim_operations.name is 'Наименование операции';
	comment on column dim_operations.factor is 'Знак операции: 1 — приход, -1 — расход';
	comment on column dim_operations.date_add is 'Дата добавления записи';

	-- Измерение "Уровни доступа"
	create table dim_securityaccess(
		id bigint not null,
		external_id bigint,
		name text,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_securityaccess;
	alter table dim_securityaccess alter column id set default nextval('seq_dim_securityaccess');
	alter table dim_securityaccess add primary key (id);
	comment on table dim_securityaccess is 'Справочник уровней доступа сотрудников';
	comment on column dim_securityaccess.id is 'Внутренний код записи';
	comment on column dim_securityaccess.external_id is 'Код уровня доступа в базе Front';
	comment on column dim_securityaccess.name is 'Наименование уровня доступа';
	comment on column dim_securityaccess.date_add is 'Дата добавления записи';
end $$;
